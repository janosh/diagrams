#import "@preview/cetz:0.5.2": canvas, draw

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#let panel-size = 4.5cm
#let stages = (2, 3, 4)

// Subdivide a square into 3×3 cells, drop the center, and recurse until unit cells.
#let carpet(size, origin-x: 0.0, origin-y: 0.0) = {
  if size == 1 {
    // Stroking with the fill color closes antialiasing seams between adjacent cells.
    draw.rect(
      (origin-x, origin-y),
      (origin-x + 1.0, origin-y + 1.0),
      stroke: black + 0.3pt,
      fill: black,
    )
  } else {
    let third = calc.floor(size / 3)
    for column in range(3) {
      for row in range(3) {
        if column != 1 or row != 1 {
          carpet(third, origin-x: origin-x + column * third, origin-y: origin-y + row * third)
        }
      }
    }
  }
}

#let draw-stage(order) = {
  let size = calc.pow(3, order)
  canvas(length: panel-size / size, carpet(size))
}

// Equal-width panels retain their natural aspect ratios.
#grid(
  columns: stages.len(),
  column-gutter: 14pt,
  row-gutter: 6pt,
  ..stages.map(order => box(width: panel-size, align(center + horizon, draw-stage(order)))),
  ..stages.map(order => align(center, text(size: 10pt)[$n = #order$])),
)
