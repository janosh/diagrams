#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, line

#set page(width: auto, height: auto, margin: 3pt, fill: none)
#set text(size: 12pt)

#canvas({
  let (rx, ry) = (4, 2.2)
  // Arrowed axes and energy ellipse; hairlines tie the semi-axis labels to their intercepts.
  for (tip, label, anchor) in (((rx + 0.5, 0), $q_1$, "west"), ((0, ry + 0.5), $q_2$, "south")) {
    line(tip.map(coord => -coord), tip, mark: (end: "stealth", fill: black), stroke: 1pt)
    content(tip, label, anchor: anchor, padding: 2pt)
  }
  circle((0, 0), radius: (rx, ry), stroke: blue, fill: rgb(0%, 0%, 100%, 5%))
  for (intercept, pos, label, anchor) in (
    ((rx, 0), (rx + .2, 1), $sqrt(2E \/ m)$, "south"),
    ((0, ry), (0.5, ry + .5), $sqrt(2E \/ k)$, "south-west"),
  ) {
    content(pos, label, anchor: "south-west", padding: 1pt, name: "label")
    line(intercept, "label." + anchor, stroke: (paint: rgb("#78828C"), thickness: 0.5pt))
  }
  content((3, 1), text(fill: blue)[$P$])
})
