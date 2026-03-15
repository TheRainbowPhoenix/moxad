import os
import sys
import time
import json
import socket
import logging
import threading
import tempfile
from flask import Flask, render_template, request
from flask_socketio import SocketIO, emit, join_room, leave_room

import compat
import ssc
import tr2d_structs
import tr2d_core
import tr2d_daemon

DEBUG_LEVEL=5

# Enforce custom template folder as requested
WEB_DIR = os.path.join(os.path.dirname(__file__), 'template')
app = Flask(__name__, template_folder=WEB_DIR, static_folder=WEB_DIR)

# Configure SocketIO for fast, asynchronous WebSocket streaming
socketio = SocketIO(app, async_mode='threading', cors_allowed_origins="*")

# Global mapping to track which thread belongs to which Node ID for logging
thread_to_node = {}


# --- CORE FIX: Eliminate the 2-second IPC blocking timeout ---
def fast_client_send(self, cmd, subtype=0, payload=b""):
    sock = compat.ipc_connect(self.path)
    sock.sendall(tr2d_structs.build_msg(cmd, subtype, payload))
    try:
        sock.shutdown(socket.SHUT_WR)  
    except OSError:
        pass
    reply = b""
    sock.settimeout(2.0)
    try:
        while True:
            chunk = sock.recv(tr2d_structs.READ_BUF)
            if not chunk:
                break
            reply += chunk
    except socket.timeout:
        pass
    sock.close()
    return reply

tr2d_daemon.TR2Client._send = fast_client_send


# --- Custom Log Handler for Raw log_printf ---
class SocketIOLogHandler(logging.Handler):
    def emit(self, record):
        try:
            # Map the current executing thread to its Daemon Node ID
            tid = threading.current_thread().ident
            if tid not in thread_to_node:
                thread_to_node[tid] = max(thread_to_node.values()) + 1
            nid = thread_to_node.get(tid, None)
            msg = self.format(record)
            socketio.emit('raw_log', {'ts': time.time(), 'msg': f"[Node {nid}] {msg}"}, to='logs')
        except Exception:
            pass

log_handler = SocketIOLogHandler()
log_handler.setFormatter(logging.Formatter('%(message)s'))
tr2d_logger = logging.getLogger("tr2d")
tr2d_logger.setLevel(logging.DEBUG)
tr2d_logger.addHandler(log_handler)


# --- Simulator Backends & Overrides ---

class NetworkedSimSwitchBackend(ssc.SimSwitchBackend):
    def __init__(self, node_id, router_cb, port_count=12):
        super().__init__(port_count)
        self.node_id = node_id
        self.router_cb = router_cb

    def send_frame(self, tx_fd=None, raw_fd=None, port=0, frame=b"", vid=0):
        super().send_frame(tx_fd, raw_fd, port, frame, vid)
        if hasattr(self, 'router_cb') and self.router_cb:
            self.router_cb(self.node_id, port, frame)
        return len(frame)

class WebTR2Daemon(tr2d_daemon.TR2Daemon):
    def __init__(self, node_id, router_cb, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.node_id = node_id
        self.router_cb = router_cb
        self.backend = NetworkedSimSwitchBackend(node_id, router_cb, port_count=12)
        self.ssc.sw = self.backend
        
    def start(self):
        r, w = compat.make_wakeup_pair()
        self.raw_fd = r
        self.tx_fd = w
        
        # Populate the thread_to_node mapping for accurate logging
        thread_to_node[threading.current_thread().ident] = self.node_id
        for t in self._ring_mains: 
            thread_to_node[t._thread.ident] = self.node_id
        for t in self._ring_auxes: 
            thread_to_node[t._thread.ident] = self.node_id
        if self._lhc_thread and self._lhc_thread._thread: 
            thread_to_node[self._lhc_thread._thread.ident] = self.node_id
        if self._msg_thread: 
            thread_to_node[self._msg_thread.ident] = self.node_id
        
        super().start()

# --- Main Simulator Engine ---

class Simulator:
    def __init__(self):
        self.nodes = {}
        self.links = {}
        self.ring_order = []
        self.next_node_id = 0
        self.log_counter = 0
        self.shared_mac = bytes([0x00, 0x11, 0x22, 0x33, 0x44, 0x55])
        
        # Start state broadcaster
        threading.Thread(target=self.state_broadcaster, daemon=True).start()

    def router_cb(self, src_node, src_port, frame):
        target = None
        for link in self.links.values():
            if (link['n1'] == src_node and link['p1'] == src_port) or \
               (link['n2'] == src_node and link['p2'] == src_port):
                target = link
                break

        if len(frame) > 27:
            pkt_type = frame[27]
            type_str = {2: 'POLLING', 3: 'BPDU', 4: 'PORT_DOWN', 5: 'COUPLER_NEGO', 
                        6: 'COUPLER_TC', 7: 'FWD_REQ', 8: 'LHC'}.get(pkt_type, str(pkt_type))
        else:
            type_str = 'UNKNOWN'

        is_drop = target is None or target['broken']
        dst_node = target['n2'] if target and target['n1'] == src_node else (target['n1'] if target else None)
        dst_port = target['p2'] if target and target['n1'] == src_node else (target['p1'] if target else None)

        # Broadcast packet log specifically to clients subscribed to the 'logs' room
        log_entry = {
            "id": self.log_counter,
            "ts": time.time(),
            "src": src_node, "sport": src_port,
            "dst": dst_node, "dport": dst_port,
            "type": type_str,
            "len": len(frame),
            "drop": is_drop
        }
        self.log_counter += 1
        socketio.emit('log_entry', log_entry, to='logs')

        # Inject hardware frame
        if not is_drop and dst_node is not None and dst_node in self.nodes:
            dst_daemon = self.nodes[dst_node]['daemon']
            dsa = tr2d_structs.dsa_build(dst_port)
            new_frame = frame[:12] + dsa + frame[16:]
            try:
                dst_daemon.tx_fd.sendall(new_frame)
                for ring in dst_daemon.rings:
                    tr2d_core.MgmtTR2Wakeup(ring)
            except Exception:
                pass

    def stop_all(self):
        for n in self.nodes.values():
            n['daemon'].stop()
            compat.ipc_cleanup(n['socket'])
        self.nodes = {}
        self.links = {}
        self.ring_order = []

    def init_ring(self, num_nodes):
        self.stop_all()
        if num_nodes == 0: return
        
        self.next_node_id = num_nodes
        self.ring_order = list(range(num_nodes))

        for i in self.ring_order:
            self._spawn_daemon(i)

        self.rebuild_links()
        self.push_configs()

    def add_node(self, after_id):
        new_id = self.next_node_id
        self.next_node_id += 1
        
        try:
            idx = self.ring_order.index(after_id)
        except ValueError:
            idx = len(self.ring_order) - 1
            
        self.ring_order.insert(idx + 1, new_id)
        self._spawn_daemon(new_id)
        
        self.rebuild_links()
        self.push_configs()

    def remove_node(self, node_id):
        if node_id not in self.ring_order: return
        self.ring_order.remove(node_id)
        
        if node_id in self.nodes:
            self.nodes[node_id]['daemon'].stop()
            compat.ipc_cleanup(self.nodes[node_id]['socket'])
            del self.nodes[node_id]
            
        self.rebuild_links()
        self.push_configs()

    def _spawn_daemon(self, node_id):
        sock_path = os.path.join(tempfile.gettempdir(), f"tr2sim_{node_id}.sock")
        compat.ipc_cleanup(sock_path)
        d = WebTR2Daemon(node_id, self.router_cb, debug_level=5, socket_path=sock_path, use_sim=True)
        t = threading.Thread(target=d.run, daemon=True)
        t.start()
        d.mac = self.shared_mac
        d.ssc.mac = self.shared_mac
        self.nodes[node_id] = {"daemon": d, "socket": sock_path}

    def rebuild_links(self):
        self.links = {}
        n_len = len(self.ring_order)
        if n_len < 2: return
        
        for i in range(n_len):
            n1 = self.ring_order[i]
            n2 = self.ring_order[(i + 1) % n_len]
            lid = f"l_{n1}_{n2}"
            self.links[lid] = {
                "id": lid,
                "n1": n1, "p1": 2, # Respecting custom config: Ring0 ports 1 & 2
                "n2": n2, "p2": 1,
                "broken": False
            }

    def push_configs(self):
        def _push():
            time.sleep(0.5) 
            for i, nid in enumerate(self.ring_order):
                if nid not in self.nodes: continue
                try:
                    c = tr2d_daemon.TR2Client(self.nodes[nid]['socket'])
                    cfg = tr2d_structs.TR2Config(
                        enabled=1,
                        # Aligning to the user-requested format Ring0 = X X 1 2
                        rings=[tr2d_structs.RingConfig(enabled=1, priority=0 if i==0 else 0xFF, port0=1, port1=2), tr2d_structs.RingConfig()],
                        coupling=tr2d_structs.CouplingConfig(0)
                    )
                    c.activate(cfg)
                except Exception as e:
                    tr2d_logger.error(f"Failed to push config to node {nid}: {e}")
        threading.Thread(target=_push, daemon=True).start()

    def toggle_link(self, link_id):
        if link_id in self.links:
            l = self.links[link_id]
            l['broken'] = not l['broken']
            is_up = not l['broken']
            self.nodes[l['n1']]['daemon'].backend._port_link[l['p1']] = is_up
            self.nodes[l['n2']]['daemon'].backend._port_link[l['p2']] = is_up

    def get_state(self):
        state_nodes = []
        for nid in self.ring_order:
            node = self.nodes.get(nid)
            if not node: continue
            
            try:
                client = tr2d_daemon.TR2Client(node['socket'])
                rings = client.get_rings()
                rinfo = rings[0].to_dict() if rings else {}
                
                # Intercept logic to ensure physical Down state propagates to the UI
                if rinfo and 'ports' in rinfo:
                    for p in rinfo['ports']:
                        is_up = node['daemon'].backend._port_link[p['id']]
                        p['is_down'] = not is_up
                        
                    # If completely isolated from the ring, mark as Isolated.
                    if len(rinfo['ports']) > 0 and all(p.get('is_down', False) for p in rinfo['ports']):
                        rinfo['status'] = 'Isolated'

            except Exception:
                rinfo = {}
            state_nodes.append({"id": nid, "ring": rinfo})
            
        return {"nodes": state_nodes, "links": list(self.links.values())}

    def state_broadcaster(self):
        """Continuously checks topology state and streams to clients on change."""
        last_state_str = ""
        while True:
            time.sleep(0.2)
            try:
                state = self.get_state()
                state_str = json.dumps(state)
                if state_str != last_state_str:
                    socketio.emit('topology_update', state)
                    last_state_str = state_str
            except Exception:
                pass


sim = Simulator()

# --- Flask & Socket.IO Routes ---

@app.route('/')
def index():
    return render_template("index.html")

@socketio.on('connect')
def handle_connect():
    emit('topology_update', sim.get_state())

@socketio.on('init_ring')
def ws_init_ring(data):
    sim.init_ring(data['nodes'])
    emit('topology_update', sim.get_state(), broadcast=True)

@socketio.on('add_node')
def ws_add_node(data):
    sim.add_node(data['after_id'])
    emit('topology_update', sim.get_state(), broadcast=True)

@socketio.on('remove_node')
def ws_remove_node(data):
    sim.remove_node(data['id'])
    emit('topology_update', sim.get_state(), broadcast=True)

@socketio.on('toggle_link')
def ws_toggle_link(data):
    sim.toggle_link(data['id'])
    emit('topology_update', sim.get_state(), broadcast=True)

@socketio.on('subscribe_logs')
def ws_subscribe_logs():
    join_room('logs')

@socketio.on('unsubscribe_logs')
def ws_unsubscribe_logs():
    leave_room('logs')


if __name__ == '__main__':
    print("Starting TurboRing Simulator. Navigate to http://127.0.0.1:5000")
    socketio.run(app, port=5000, debug=False)