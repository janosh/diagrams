#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, hobby, line, rect

// Hairline tying a label to whatever it names: pole callouts, semi-axis leaders,
// off-diagram vertex captions.
#let leader = (paint: rgb("#78828C"), thickness: 0.5pt)

#set page(width: auto, height: auto, margin: 3pt, fill: none)

#canvas({
  let (rx, ry) = (5, 3)
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
  content((rx - 0.6, 0.2), text(fill: blue)[$P$])

  // rectangle scaled so its corners sit on the ellipse
  let rect-scale = calc.sqrt(2) / 2
  let (half-w, half-h) = (rx * rect-scale, ry * rect-scale)
  rect(
    (-half-w, -half-h),
    (half-w, half-h),
    stroke: rgb("#ffa500"),
    fill: rgb(100%, 65%, 0%, 10%),
    name: "rect",
  )
  content((-rx / 4, ry / 2), text(fill: rgb("#ffa500"))[$R$ for $omega in.not QQ$])

  // a rational frequency ratio closes the trajectory after two passes; each pass dips
  // to the given (x, height above the rectangle's bottom edge) control points
  for dips in (
    ((-1.1, .4), (-.5, .1), (.1, .4)),
    ((-.1, .4), (.5, .1), (1.1, .45)),
  ) {
    hobby(
      (-half-w, half-h),
      ..dips.map(((x, dy)) => (x, -half-h + dy)),
      (half-w, half-h),
      omega: 0,
      stroke: red,
    )
  }
  content((2.5, -1.3), align(center, text(fill: red)[$R$ for\ $omega = 2 in QQ$]))
})
