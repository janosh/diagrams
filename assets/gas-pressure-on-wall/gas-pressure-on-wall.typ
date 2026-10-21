#import "@preview/cetz:0.5.3": canvas, draw
#import draw: content, on-layer

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 12pt)

#let hatched = tiling(size: (.2cm, .2cm))[
  #place(rect(width: 100%, height: 100%, fill: rgb("#cdd3da"), stroke: none))
  #place(line(start: (0%, 100%), end: (100%, 0%), stroke: 0.4pt))
]

// Morse-type wall potential: long-range attraction, short-range repulsion.
#let wall-potential(x, A, B, alpha) = -A * calc.exp(-alpha * x) + B * calc.exp(-2 * alpha * x)

#canvas({
  let arrow-style = (mark: (end: ">", fill: black, scale: 0.7))
  let wall-width = 0.5
  draw.line((-0.1, 0), (6.2, 0), ..arrow-style, name: "x-axis")
  draw.line((0, -0.7), (0, 4), ..arrow-style, name: "y-axis")
  content((rel: (-0.2, 0.3), to: "x-axis.end"), $x$)
  content((rel: (0.5, 0), to: "y-axis.end"), $U(x)$)

  // Draw the wall above the potential curves.
  on-layer(1, draw.rect((0, 0), (wall-width, 3.6), fill: hatched, stroke: 0.75pt))

  let dx = (6 - wall-width) / 100
  for (A, B, alpha, color, label, label-dy) in (
    (10, 25, 1, blue.darken(10%), $1 \/ alpha approx ell$, -.45),
    (15, 120, 3, orange.darken(35%), $1 \/ alpha << ell$, .4),
  ) {
    let potential(x) = wall-potential(x, A, B, alpha)
    draw.line(
      ..range(100).map(idx => wall-width + idx * dx).map(x => (x, potential(x))),
      stroke: color,
    )
    let label-x = wall-width + 67.5 * dx
    content((label-x, potential(label-x) + label-dy), text(fill: color, label))
  }
})
