#import "@preview/cetz:0.3.4": canvas, draw
#import draw: line, content, circle, rect, hobby

#set page(width: auto, height: auto, margin: 3pt)

#canvas({
  let rx = 5
  let ry = 3
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
  content((rx - 0.6, 0.2), text(fill: blue)[$P$])

  let rect-scale = calc.sqrt(2) / 2 // scale rectangle so corners touch ellipse
  rect(
    (-rx * rect-scale, -ry * rect-scale),
    (rx * rect-scale, ry * rect-scale),
    stroke: rgb("#ffa500"),
    fill: rgb(100%, 65%, 0%, 10%),
    name: "rect",
  )
  content((-rx / 4, ry / 2), text(fill: rgb("#ffa500"))[$R$ for $omega in.not QQ$])

  // Trajectory
  hobby(
    (-rx * rect-scale, ry * rect-scale),
    (-1.1, -ry * rect-scale + 0.4),
    (-.5, -ry * rect-scale + 0.1),
    (.1, -ry * rect-scale + 0.4),
    (rx * rect-scale, ry * rect-scale),
    omega: 0,
    stroke: red,
  )
  hobby(
    (-rx * rect-scale, ry * rect-scale),
    (-.1, -ry * rect-scale + 0.4),
    (.5, -ry * rect-scale + 0.1),
    (1.1, -ry * rect-scale + 0.45),
    (rx * rect-scale, ry * rect-scale),
    omega: 0,
    stroke: red,
  )
  content(
    (2.5, -1.3),
    align(
      center,
      text(fill: red)[$R$ for\ $omega = 2 in QQ$],
    ),
  )
})
