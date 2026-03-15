# TurboRing 2 
```
tr2> status              # coloured table: ★MASTER, ─/✗ links, ↑/↓ ports
tr2> ring                # ASCII ring diagram
tr2> ping 0 5 5          # tracert 5 frames N0→N5, show each hop CW+CCW
tr2> pathping 0 5 20     # per-hop loss bar chart over 20 probes
tr2> break 3 4           # sever the 3↔4 link
tr2> heal 3 4            # restore it
tr2> isolate 0           # hard-crash node 0
tr2> elect 1             # promote node 1 to master
tr2> restore 0           # bring node 0 back
tr2> watch               # live auto-refresh every 0.5 s
tr2> reset               # rebuild ring from scratch
```