#import "@preview/fractusist:0.3.0": lsystem, lsystem-use

#set page(width: auto, height: auto, margin: 0pt, fill: none)
#set text(fill: white, size: 12pt)

// Sierpiński triangle of Fe/C₃PC molecules (yellow) bordered by BPyB (orange) on Au(100)
#let (substrate-color, fill-color, border-color) = (
  rgb(200, 50, 50),
  rgb(255, 230, 100),
  rgb(200, 140, 0),
)
#let (triangle-size, margin) = (128pt, 20pt)
#let canvas-width = triangle-size + 2 * margin
#let canvas-height = triangle-size * calc.pow(3, 0.5) / 2 + 2 * margin + 50pt

#rect(width: canvas-width, height: canvas-height, fill: rgb(50, 50, 50), {
  // Substrate atoms in a hexagonal arrangement, overscanned past the canvas edges.
  let (horizontal-spacing, vertical-spacing) = (2.5pt, 2.2pt)
  for y in range(-3, int(canvas-height / vertical-spacing) + 3) {
    let offset = if calc.odd(y) { horizontal-spacing / 2 } else { 0pt }
    for x in range(-3, int(canvas-width / horizontal-spacing) + 3) {
      place(
        dx: x * horizontal-spacing + offset,
        dy: y * vertical-spacing,
        circle(radius: 1pt, fill: substrate-color, stroke: none),
      )
    }
  }

  place(dx: margin / 2, dy: margin / 2 + 50pt, lsystem(
    ..lsystem-use("Sierpinski Triangle"),
    order: 5,
    step-size: 4,
    start-angle: 1,
    fill: fill-color,
    stroke: 0.5pt + border-color,
  ))

  place(block(inset: (x: 3pt, y: 2pt), radius: 2pt, fill: rgb(30, 30, 30), grid(
    columns: (8pt, auto),
    column-gutter: 2.5pt,
    row-gutter: 3pt,
    ..(
      (substrate-color, [Au(100)]),
      (fill-color, [Fe/C#sub[3]PC]),
      (border-color, [BPyB]),
    )
      .map(((fill, label)) => (rect(width: 8pt, height: 8pt, fill: fill, radius: 1pt), label))
      .flatten(),
  )))
})
