#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, line
#import "../_shared/feynman.typ" as fey

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#canvas({
  line((-2.25, 0), (2.25, 0), stroke: 1pt, name: "a-to-b")
  content("a-to-b.start", $phi_a$, anchor: "east", padding: 3pt)
  content("a-to-b.end", $phi_b$, anchor: "west", padding: 3pt)

  for (idx, x-start) in ((1, -2), (2, 1)) {
    line((x-start, 0.15), (x-start + 1, 0.15), ..fey.momentum-arrow, name: "p")
    content((rel: (0, 0.3), to: "p.mid"), $p_#idx$)
  }

  circle((0, 0), radius: 0.25, fill: fey.hatched, name: "vertex")
  content((rel: (0, 0.5), to: "vertex"), $G_(k,a b)(p_1,p_2)$)
})
