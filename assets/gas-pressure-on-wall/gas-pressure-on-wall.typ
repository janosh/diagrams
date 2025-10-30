#import "@preview/cetz:0.4.2": canvas, draw
#import draw: content, on-layer

#set page(width: auto, height: auto, margin: 8pt)

#let hatched = tiling(size: (.2cm, .2cm))[
  #place(rect(width: 100%, height: 100%, fill: white, stroke: none))
  #place(line(start: (0%, 100%), end: (100%, 0%), stroke: 0.4pt))
]

#let lennard-jones(x, A, B, alpha) = {
  -A * calc.exp(-alpha * x) + B * calc.exp(-2 * alpha * x)
}

#canvas({
  let arrow-style = (mark: (end: ">", fill: black, scale: 0.7))
  let wall-width = 0.5

  // Draw axes
  draw.line((-0.1, 0), (6.2, 0), ..arrow-style, name: "x-axis")
  draw.line((0, -0.7), (0, 4), ..arrow-style, name: "y-axis")

  // Add axis labels
  content((rel: (-0.2, 0.3), to: "x-axis.end"), $x$, name: "x-label")
  content((rel: (0.5, 0), to: "y-axis.end"), $U(x)$, name: "y-label")

  // Draw wall with hatching
  on-layer(
    1, // draw wall above pressure lines
    draw.rect(
      (0, 0),
      (wall-width, 3.6),
      fill: hatched,
      pattern: "north-east-lines",
      stroke: 0.75pt,
    ),
  )

  // Draw potential curves
  let samples = 100
  let dx = (6 - wall-width) / samples

  // First curve (blue)
  let (A1, B1, alpha1) = (10, 25, 1)

  for ii in range(samples - 1) {
    let x1 = wall-width + ii * dx
    let x2 = x1 + dx
    let y1 = lennard-jones(x1, A1, B1, alpha1)
    let y2 = lennard-jones(x2, A1, B1, alpha1)
    draw.line(
      (x1, y1),
      (x2, y2),
      stroke: blue,
    )
  }
  content((4.2, -0.6), text(fill: blue)[$1 / alpha << ell$], name: "alpha-label")

  // Second curve (orange)
  let (A2, B2, alpha2) = (15, 120, 3)

  for ii in range(samples - 1) {
    let x1 = wall-width + ii * dx
    let x2 = x1 + dx
    let y1 = lennard-jones(x1, A2, B2, alpha2)
    let y2 = lennard-jones(x2, A2, B2, alpha2)
    draw.line(
      (x1, y1),
      (x2, y2),
      stroke: orange,
      name: "orange-line-" + str(ii),
    )
  }
  content((4.2, 0.4), text(fill: orange)[$1 / alpha << ell$], name: "alpha-label")
})
