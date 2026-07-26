// Constant-energy shell of a 1D harmonic oscillator in (q_1, q_2) phase space,
// shared by the momentum-shell and ergodic diagrams.

#import "@preview/cetz:0.5.2": draw
#import draw: circle, content, line
#import "theme.typ": leader

// Arrowed q_1/q_2 axes plus the energy ellipse, its semi-axes named by leader lines.
#let energy-shell(rx, ry) = {
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
}
