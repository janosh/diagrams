#import "@preview/cetz:0.5.2": canvas, draw

// Complex arithmetic for the Eisenstein lattice construction.
#let complex-multiply(left, right) = (
  left.at(0) * right.at(0) - left.at(1) * right.at(1),
  left.at(0) * right.at(1) + left.at(1) * right.at(0),
)

#let complex-from-angle(angle) = (calc.cos(angle), calc.sin(angle))

#let omega = complex-from-angle(2.0 * calc.pi / 3.0)

#let eisenstein-vertices = (
  (0.0, 0.0),
  (1.0, 0.0),
  omega,
  complex-multiply(omega, omega),
)

#let eisenstein-positions(stage) = {
  // Stage 1 is the seed vertices (paper §2.1). The final -r_p display rotation
  // only applies after iterative growth (stage >= 2).
  if stage <= 1 {
    return eisenstein-vertices
  }
  let positions = eisenstein-vertices
  let last-rotation = complex-from-angle(0.0)
  for generation in range(2, stage + 1) {
    let spacing = calc.pow(2, generation - 1)
    let rotation = complex-from-angle((generation - 1) * calc.pi / 3.0)
    last-rotation = rotation
    let next-positions = ()
    for vertex in eisenstein-vertices {
      let shift = complex-multiply(rotation, vertex).map(value => spacing * value)
      for position in positions {
        next-positions.push(position.zip(shift).map(((pos, delta)) => pos + delta))
      }
    }
    positions = next-positions
  }
  let negative-rotation = last-rotation.map(value => -1.0 * value)
  positions.map(point => complex-multiply(negative-rotation, point))
}

#let panel-size = 4.5cm

#let draw-stage(stage) = {
  let points = eisenstein-positions(stage)
  let (xs, ys) = (points.map(point => point.at(0)), points.map(point => point.at(1)))
  let (x-min, y-min) = (calc.min(..xs), calc.min(..ys))
  let (width, height) = (calc.max(..xs) - x-min, calc.max(..ys) - y-min)
  let span = calc.max(width, height, 1.0)
  // Taper dots as stages get denser, but never below ~1pt wide on the page.
  let radius = calc.max(0.32 / calc.sqrt(points.len()), 0.5pt / (panel-size / span))
  // Include the dot radius in the fitted bounds so the outermost dots remain visible.
  canvas(length: panel-size / calc.max(width + 2 * radius, height + 2 * radius, 1.0), {
    for (x-pos, y-pos) in points {
      draw.circle(
        (x-pos - x-min + radius, y-pos - y-min + radius),
        radius: radius,
        fill: blue.darken(5%),
        stroke: none,
      )
    }
  })
}

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#let stages = (2, 3, 4)

// Equal-width panels retain their natural aspect ratios.
#grid(
  columns: stages.len(),
  column-gutter: 14pt,
  row-gutter: 6pt,
  ..stages.map(order => box(
    width: panel-size,
    align(center + horizon, draw-stage(order)),
  )),
  ..stages.map(order => align(center, text(size: 10pt)[$n = #order$])),
)
