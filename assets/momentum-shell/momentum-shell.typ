#import "@preview/cetz:0.3.4": canvas, draw
#import draw: line, content, circle

#set page(width: auto, height: auto, margin: 3pt)

#canvas({
  let (rx, ry) = (4, 2.2)
  let arrow-style = (mark: (end: "stealth", fill: black), stroke: 1pt)

  // Axes
  line((-rx - 0.5, 0), (rx + 0.5, 0), ..arrow-style)
  content((rx + 0.5, 0), $q_1$, anchor: "west", padding: 2pt)

  line((0, -ry - 0.5), (0, ry + 0.5), ..arrow-style)
  content((0, ry + 0.5), $q_2$, anchor: "south", padding: 2pt)

  // Ellipse
  circle(
    (0, 0),
    radius: (rx, ry),
    stroke: blue,
    fill: rgb(0%, 0%, 100%, 5%),
    name: "ellipse",
  )

  // Labels for radii
  content((rx + .2, 1), $sqrt(2E \/ m)$, anchor: "south-west", padding: 1pt, name: "r1")
  line((rx, 0), "r1.south", stroke: 0.2pt)
  content((0.5, ry + .5), $sqrt(2E \/ k)$, anchor: "south-west", padding: 1pt, name: "r2")
  line((0, ry), "r2.south-west", stroke: 0.2pt)

  // Label P
  content((3, 1), text(fill: blue)[$P$])
})
