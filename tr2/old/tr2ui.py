import os
import sys
import time
import json
import queue
import threading
import tempfile
from collections import deque
from flask import Flask, request, jsonify, Response, render_template

# Local module imports from your provided tr2d codebase
import compat
import ssc
import tr2d_structs
import tr2d_core
import tr2d_daemon

WEB_DIR = os.path.join(os.path.dirname(__file__), 'template')
app = Flask(__name__, template_folder=WEB_DIR, static_folder=WEB_DIR)

# --- Simulator Backends & Overrides ---

class NetworkedSimSwitchBackend(ssc.SimSwitchBackend):
    """
    Subclasses the pure python SimSwitchBackend to intercept physical
    frames destined for the network and pass them to our central router.
    """
    def __init__(self, node_id, router_cb, port_count=12):
        super().__init__(port_count)
        self.node_id = node_id
        self.router_cb = router_cb

    def send_frame(self, tx_fd=None, raw_fd=None, port=0, frame=b"", vid=0):
        # Allow parent to process it for logs
        super().send_frame(tx_fd, raw_fd, port, frame, vid)
        # Intercept and route the raw ethernet frame
        if hasattr(self, 'router_cb') and self.router_cb:
            self.router_cb(self.node_id, port, frame)
        return len(frame)

class WebTR2Daemon(tr2d_daemon.TR2Daemon):
    """
    Overrides the Daemon startup to bind genuine loopback sockets for packet
    injection (circumventing the disconnected raw sockets of the default sim).
    """
    def __init__(self, node_id, router_cb, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.node_id = node_id
        self.router_cb = router_cb
        
        # Override backend to intercept outgoing sends
        self.backend = NetworkedSimSwitchBackend(node_id, router_cb, port_count=12)
        self.ssc.sw = self.backend
        
    def start(self):
        # Create a real loopback TCP/UNIX pair for packet injection
        # This gives `MgmtRecvTR2Packet` genuine socket descriptors to select() on
        r, w = compat.make_wakeup_pair()
        self.raw_fd = r
        self.tx_fd = w
        super().start()


# --- Main Simulator Engine ---

class Simulator:
    def __init__(self):
        self.nodes = {}
        self.links = {}
        self.log_history = deque(maxlen=200)
        self.log_listeners = []
        # We enforce a shared MAC across all nodes so `MgmtRecvTR2Packet` 
        # doesn't reject frames from peer nodes thinking they are rogue.
        self.shared_mac = bytes([0x00, 0x11, 0x22, 0x33, 0x44, 0x55])

    def router_cb(self, src_node, src_port, frame):
        """Intercepts outgoing frames from any node, resolves links, and injects."""
        target = None
        for link in self.links.values():
            if link['n1'] == src_node and link['p1'] == src_port:
                target = link
                break
            if link['n2'] == src_node and link['p2'] == src_port:
                target = link
                break

        # Decode packet type for logging
        if len(frame) > 27:
            pkt_type = frame[27]
            type_str = {2: 'POLLING', 3: 'BPDU', 4: 'PORT_DOWN', 5: 'COUPLER_NEGO', 
                        6: 'COUPLER_TC', 7: 'FWD_REQ', 8: 'LHC'}.get(pkt_type, str(pkt_type))
        else:
            type_str = 'UNKNOWN'

        is_drop = target is None or target['broken']
        dst_node = target['n2'] if target and target['n1'] == src_node else (target['n1'] if target else None)
        dst_port = target['p2'] if target and target['n1'] == src_node else (target['p1'] if target else None)

        # Broadcast telemetry locally
        log_entry = {
            "ts": time.time(),
            "src": src_node, "sport": src_port,
            "dst": dst_node, "dport": dst_port,
            "type": type_str,
            "len": len(frame),
            "drop": is_drop
        }
        self.add_log(log_entry)

        # Hardware injection
        if not is_drop:
            dst_daemon = self.nodes[dst_node]['daemon']
            # Reconstruct frame applying the new DSA switch-port tag indicating arrival port
            dsa = tr2d_structs.dsa_build(dst_port)
            new_frame = frame[:12] + dsa + frame[16:]
            try:
                # Push frame into Daemon's virtual Raw descriptor
                dst_daemon.tx_fd.sendall(new_frame)
                # Fire the Daemon's UNIX IRQ equivalent to awake it from polling block
                for ring in dst_daemon.rings:
                    tr2d_core.MgmtTR2Wakeup(ring)
            except Exception as e:
                print(f"Hardware injection error: {e}")

    def add_log(self, msg):
        self.log_history.append(msg)
        dead_qs = []
        for q in self.log_listeners:
            try:
                q.put_nowait(msg)
            except queue.Full:
                dead_qs.append(q)
        for q in dead_qs:
            self.log_listeners.remove(q)

    def stop_all(self):
        for n in self.nodes.values():
            n['daemon'].stop()
            compat.ipc_cleanup(n['socket'])
        self.nodes = {}
        self.links = {}
        self.log_history.clear()

    def init_ring(self, num_nodes):
        self.stop_all()
        if num_nodes == 0: return

        # 1. Spawn Daemons
        for i in range(num_nodes):
            sock_path = os.path.join(tempfile.gettempdir(), f"tr2sim_{i}.sock")
            compat.ipc_cleanup(sock_path)
            
            # Use debug level 2 (WARN) to keep terminal logs clean for Python
            d = WebTR2Daemon(i, self.router_cb, debug_level=2, socket_path=sock_path, use_sim=True)
            t = threading.Thread(target=d.run, daemon=True)
            t.start()
            
            # Force shared MAC pool
            d.mac = self.shared_mac
            d.ssc.mac = self.shared_mac
            
            self.nodes[i] = {"daemon": d, "socket": sock_path}

        # 2. Virtual Wiring 
        # Node i:10 -> Node i+1:9
        for i in range(num_nodes):
            next_node = (i + 1) % num_nodes
            lid = f"l_{i}_{next_node}"
            self.links[lid] = {
                "id": lid,
                "n1": i, "p1": 10,
                "n2": next_node, "p2": 9,
                "broken": False
            }

        time.sleep(1.0) # Wait for daemons to spin up loopbacks

        # 3. Provision configurations via Client IPC
        for i in range(num_nodes):
            c = tr2d_daemon.TR2Client(self.nodes[i]['socket'])
            cfg = tr2d_structs.TR2Config(
                enabled=1,
                # Force node 0 to be Ring Master (Priority=0)
                rings=[tr2d_structs.RingConfig(enabled=1, priority=0 if i==0 else 0xFF, port0=9, port1=10), tr2d_structs.RingConfig()],
                coupling=tr2d_structs.CouplingConfig(0)
            )
            c.activate(cfg)

    def get_state(self):
        """Polls daemons via IPC to get genuine real-time protocol status."""
        state_nodes = []
        for nid, node in self.nodes.items():
            client = tr2d_daemon.TR2Client(node['socket'])
            try:
                rings = client.get_rings()
                rinfo = rings[0].to_dict() if rings else {}
            except Exception:
                rinfo = {}
            state_nodes.append({"id": nid, "ring": rinfo})
            
        return {
            "nodes": state_nodes,
            "links": list(self.links.values())
        }

    def toggle_link(self, link_id):
        """Severes the link and enforces link-down states on the backend."""
        if link_id in self.links:
            l = self.links[link_id]
            l['broken'] = not l['broken']
            is_up = not l['broken']
            
            # Pull down the link state internally for fast switch polling
            self.nodes[l['n1']]['daemon'].backend._port_link[l['p1']] = is_up
            self.nodes[l['n2']]['daemon'].backend._port_link[l['p2']] = is_up

sim = Simulator()

# --- Flask Routes ---

@app.route('/')
def index():
    return render_template("index.html")

@app.route('/api/init', methods=['POST'])
def api_init():
    num_nodes = int(request.json.get('nodes', 3))
    sim.init_ring(num_nodes)
    return jsonify({"status": "ok"})

@app.route('/api/state')
def api_state():
    return jsonify(sim.get_state())

@app.route('/api/link/toggle', methods=['POST'])
def api_link_toggle():
    sim.toggle_link(request.json['id'])
    return jsonify({"status": "ok"})

@app.route('/api/logs')
def sse_logs():
    """Event stream containing telemetry frames intercepted by router_cb."""
    def stream():
        q = queue.Queue(maxsize=200)
        sim.log_listeners.append(q)
        
        # Flush history immediately on connect
        for msg in list(sim.log_history):
            yield f"data: {json.dumps(msg)}\n\n"
            
        try:
            while True:
                msg = q.get()
                yield f"data: {json.dumps(msg)}\n\n"
        except GeneratorExit:
            if q in sim.log_listeners:
                sim.log_listeners.remove(q)
                
    return Response(stream(), mimetype="text/event-stream")

if __name__ == '__main__':
    print("Starting TurboRing Simulator. Navigate to http://127.0.0.1:5000")
    # Using threaded mode to avoid blocking background threads
    app.run(port=5000, threaded=True, debug=False)