import logging
import threading
import json
import time
import os
import pathlib
import tempfile
import sys
from collections import deque
from flask import Flask, render_template, jsonify, request, Response

# Add current dir to path to import tr2 modules
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from tr2d_daemon import TR2DaemonManager, TR2Client
from tr2d_structs import TR2Config, RingConfig, CouplingConfig, PortState
import ssc  # To interact with the global link registry

app = Flask(__name__)
mgr = TR2DaemonManager()

# Global state
class LogBuffer:
    def __init__(self, limit=200):
        self.logs = deque(maxlen=limit)
        self.lock = threading.Lock()
        self.total_count = 0

    def add(self, msg):
        with self.lock:
            self.logs.append(msg)
            self.total_count += 1

    def get_new_since(self, last_idx):
        with self.lock:
            # How many new messages since last_idx?
            new_msgs_count = self.total_count - last_idx
            if new_msgs_count <= 0:
                return [], self.total_count

            # If the client is very far behind, just give them whatever is in the buffer
            if new_msgs_count > len(self.logs):
                return list(self.logs), self.total_count

            # Otherwise, give them the exact slice of new messages
            # e.g. if we have 5 items and 2 are new, we want the last 2
            return list(self.logs)[-new_msgs_count:], self.total_count

log_buffer = LogBuffer()

class BufferLogHandler(logging.Handler):
    def emit(self, record):
        msg = self.format(record)
        log_buffer.add(msg)

# Setup logging
log_handler = BufferLogHandler()
log_handler.setFormatter(logging.Formatter("[%(levelname)s] %(message)s"))
logging.getLogger().addHandler(log_handler)
logging.getLogger().setLevel(logging.INFO)

# A simple link registry: (node_id_A, port_A) <-> (node_id_B, port_B)
# In ssc.py, we will check this registry to forward packets.
links = []  # List of dicts: {"n1": id1, "p1": p1, "n2": id2, "p2": p2, "active": True}

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/state", methods=["GET"])
def get_state():
    status = mgr.status()
    return jsonify({
        "nodes": status,
        "links": links
    })

@app.route("/spawn", methods=["POST"])
def spawn_node():
    idx = len(mgr._daemons)
    sock_path = str(pathlib.Path(tempfile.gettempdir()) / f"tr2_sim_gui_{idx}.sock")
    d = mgr.add(debug_level=5, socket_path=sock_path, instance_id=idx)

    # Store the instance ID on the backend so ssc.py knows who it is
    d.ssc.sw.instance_id = idx

    time.sleep(0.5)
    cli = TR2Client(sock_path)
    # Default config: Ring 1 enabled, ports 1 and 2
    cfg = TR2Config(1, [RingConfig(1, 0, 1, 2), RingConfig(0, 0xFF, 3, 4)], CouplingConfig(0))
    try:
        cli.activate(cfg)
        logging.info(f"Spawned and activated Node {idx}")
    except Exception as e:
        logging.error(f"Failed to activate Node {idx}: {e}")

    return jsonify({"status": "ok", "id": idx})

@app.route("/kill", methods=["POST"])
def kill_node():
    data = request.json
    idx = data.get("id")
    if idx is not None and 0 <= idx < len(mgr._daemons):
        mgr._daemons[idx].stop()
        logging.info(f"Killed Node {idx}")
        return jsonify({"status": "ok"})
    return jsonify({"error": "Invalid node ID"}), 400

@app.route("/kill_all", methods=["POST"])
def kill_all():
    mgr.stop_all()
    mgr._daemons.clear()
    mgr._threads.clear()
    links.clear()
    logging.info("Killed all nodes and cleared links")
    return jsonify({"status": "ok"})

@app.route("/link", methods=["POST"])
def modify_link():
    data = request.json
    action = data.get("action")
    n1, p1 = data.get("n1"), data.get("p1")
    n2, p2 = data.get("n2"), data.get("p2")

    if action == "add":
        links.append({"n1": n1, "p1": p1, "n2": n2, "p2": p2, "active": True})

        # Link up events
        d1 = mgr._daemons[n1]
        d2 = mgr._daemons[n2]
        d1.ssc.sw.set_port_enable(p1, True)
        d2.ssc.sw.set_port_enable(p2, True)
        logging.info(f"Link added: Node {n1} (Port {p1}) <-> Node {n2} (Port {p2})")

    elif action == "remove":
        for l in links:
            if l["n1"] == n1 and l["p1"] == p1 and l["n2"] == n2 and l["p2"] == p2:
                links.remove(l)
                d1 = mgr._daemons[n1]
                d2 = mgr._daemons[n2]
                d1.ssc.sw.set_port_enable(p1, False)
                d2.ssc.sw.set_port_enable(p2, False)
                logging.info(f"Link removed: Node {n1} (Port {p1}) <-> Node {n2} (Port {p2})")
                break

    elif action == "toggle":
        for l in links:
            if l["n1"] == n1 and l["p1"] == p1 and l["n2"] == n2 and l["p2"] == p2:
                l["active"] = not l["active"]
                d1 = mgr._daemons[n1]
                d2 = mgr._daemons[n2]

                # Update link states
                d1.ssc.sw.set_port_enable(p1, l["active"])
                d2.ssc.sw.set_port_enable(p2, l["active"])

                state_str = "up" if l["active"] else "down"
                logging.info(f"Link toggled {state_str}: Node {n1} (Port {p1}) <-> Node {n2} (Port {p2})")
                break

    # Re-apply config to force topology check or let the polling handle it.
    return jsonify({"status": "ok"})

@app.route("/logs_sse")
def logs_sse():
    def generate():
        last_idx = 0
        while True:
            new_logs, current_idx = log_buffer.get_new_since(last_idx)
            if new_logs:
                for msg in new_logs:
                    yield f"data: {json.dumps({'msg': msg})}\n\n"
                last_idx = current_idx
            time.sleep(0.5)
    return Response(generate(), mimetype="text/event-stream")

# Inject global registry into ssc
ssc.GLOBAL_LINKS = links
ssc.GLOBAL_DAEMONS = mgr._daemons

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
