#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, line

// Hairline tying a label to whatever it names: pole callouts, semi-axis leaders,
// off-diagram vertex captions.
#let leader = (paint: rgb("#78828C"), thickness: 0.5pt)

#set page(width: auto, height: auto, margin: 3pt, fill: none)

#canvas({
  let (rx, ry) = (4, 2.2)
  // Arrowed axes and energy ellipse; hairlines identify the semi-axes.
  let arrow-style = (mark: (end: "stealth", fill: black), stroke: 1pt)
  line((-rx - 0.5, 0), (rx + 0.5, 0), ..arrow-style)
  content((rx + 0.5, 0), $q_1$, anchor: "west", padding: 2pt)
  line((0, -ry - 0.5), (0, ry + 0.5), ..arrow-style)
  content((0, ry + 0.5), $q_2$, anchor: "south", padding: 2pt)

  circle(
    (0, 0),
    radius: (rx, ry),
    stroke: blue,
    fill: rgb(0%, 0%, 100%, 5%),
    name: "ellipse",
  )

  content((rx + .2, 1), $sqrt(2E \/ m)$, anchor: "south-west", padding: 1pt, name: "r1")
  line((rx, 0), "r1.south", stroke: leader)
  content((0.5, ry + .5), $sqrt(2E \/ k)$, anchor: "south-west", padding: 1pt, name: "r2")
  line((0, ry), "r2.south-west", stroke: leader)
  content((3, 1), text(fill: blue)[$P$])
})
