#import "@preview/cetz:0.5.2": canvas, draw
#import "../_shared/layout.typ": card-grid, label-size, paragraph-size, takeaway

#set page(width: 780pt, height: auto, margin: 22pt, fill: none)
#set text(font: "Avenir Next", size: paragraph-size, fill: rgb("#19324f"))
#set par(leading: 0.55em)

// Unit steps for the square and hexagonal lattice headings.
#let square-steps = ((1.0, 0.0), (0.0, 1.0), (-1.0, 0.0), (0.0, -1.0))
#let hexagonal-steps = (
  (1.0, 0.0),
  (0.5, calc.sqrt(3.0) / 2.0),
  (-0.5, calc.sqrt(3.0) / 2.0),
  (-1.0, 0.0),
  (-0.5, -calc.sqrt(3.0) / 2.0),
  (0.5, -calc.sqrt(3.0) / 2.0),
)
// Equal-width panels retain their natural aspect ratios.
#let stage-panels(panel-size, stages, draw-stage) = grid(
  columns: stages.len(),
  column-gutter: 14pt,
  row-gutter: 6pt,
  ..stages.map(order => box(width: panel-size, align(center + horizon, draw-stage(order)))),
  ..stages.map(order => align(center, text(size: label-size)[$n = #order$])),
)
#let curve-stages(panel-size, stages, steps, rules, axiom, drawing-symbols) = {
  let draw-stage(order) = {
    // Repeatedly replace symbols to build the curve path.
    let pattern = regex(rules.keys().join("|"))
    let path = axiom
    for _ in range(order) { path = path.replace(pattern, matched => rules.at(matched.text)) }

    // Follow the path: drawing symbols advance one unit; + and - turn one heading.
    let (x-pos, y-pos, direction) = (0.0, 0.0, 0)
    let points = ((x-pos, y-pos),)
    for symbol in path {
      if symbol in drawing-symbols {
        let (delta-x, delta-y) = steps.at(direction)
        x-pos += delta-x
        y-pos += delta-y
        points.push((x-pos, y-pos))
      } else if symbol == "+" {
        direction = calc.rem(direction + 1, steps.len())
      } else if symbol == "-" {
        direction = calc.rem(direction - 1 + steps.len(), steps.len())
      }
    }

    // Fit the path's bounds to the panel while preserving its aspect ratio.
    let (xs, ys) = (points.map(point => point.at(0)), points.map(point => point.at(1)))
    let (x-min, y-min) = (calc.min(..xs), calc.min(..ys))
    let span = calc.max(calc.max(..xs) - x-min, calc.max(..ys) - y-min, 1.0)
    let shift(point) = (point.at(0) - x-min, point.at(1) - y-min)
    // Early stages read thicker; dense stages stay fine.
    let thickness = calc.max(0.45pt, calc.min(0.75pt, 3.2pt / calc.sqrt(points.len() - 1)))
    canvas(length: panel-size / span, {
      for (start, end) in points.zip(points.slice(1)) {
        draw.line(shift(start), shift(end), stroke: (
          paint: black,
          thickness: thickness,
          join: "round",
          cap: "round",
        ))
      }
    })
  }

  stage-panels(panel-size, stages, draw-stage)
}

// === Dragon Curve ===
#let figure-0 = curve-stages(
  2cm,
  (5, 9, 13),
  square-steps,
  ("X": "X+YF+", "Y": "-FX-Y"),
  "FX",
  "F",
)

// === Koch Curve ===
#let figure-1 = curve-stages(
  7.9cm,
  (2, 3, 4),
  hexagonal-steps,
  ("F": "F+F--F+F"),
  "F",
  "F",
)

// === 3  Gosper Curve ===
#let figure-2 = curve-stages(
  2cm,
  (1, 2, 3),
  hexagonal-steps,
  ("A": "A-B--B+A++AA+B-", "B": "+A-BB--B-A++A+B"),
  "A",
  "AB",
)

// === 4  Sierpinski Curve ===
// Even orders keep the same triangle orientation.
#let figure-3 = curve-stages(
  2.35cm,
  (2, 4, 6),
  hexagonal-steps,
  ("A": "B-A-B", "B": "A+B+A"),
  "A",
  "AB",
)

// === 5  Sierpinski Carpet ===
#let figure-4 = [
  #let panel-size = 3.5cm
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

  #stage-panels(panel-size, stages, draw-stage)
]

// === 6  Eisenstein ===
#let figure-5 = [
  #let panel-size = 3.5cm
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


  #let stages = (2, 3, 4)

  #stage-panels(panel-size, stages, draw-stage)
]

Simple repeated rules create intricate shapes. Within each row the iteration increases from left to right; each panel is resized to make its structure visible.
#v(14pt)
// The shallow Koch sequence gets its own strip; similarly shaped curves share a row.
#card-grid(
  columns: 1,
  (
    [1  Koch Curve],
    figure-1,
    [Replace each segment with four segments at one-third scale. The added triangular bump repeats at every level; turn angles are 60 degrees.],
  ),
)
#v(12pt)
#card-grid(
  columns: 3,
  (
    [2  Dragon Curve],
    figure-0,
    [A folding construction becomes repeated right-angle turns. The numbered panels show increasingly detailed iterations, each fitted to its own frame.],
  ),
  (
    [3  Gosper Curve],
    figure-2,
    [A seven-part replacement on a hexagonal grid builds a denser curve. The two drawing symbols have different replacement rules.],
  ),
  (
    [4  Sierpinski Curve],
    figure-3,
    [A recursive triangular path grows on a hexagonal grid. Keep this curve distinct from the filled Sierpiński triangle and the square carpet.],
  ),
)
#v(12pt)
#card-grid(
  (
    [5  Sierpinski Carpet],
    figure-4,
    [Split a square into nine equal cells; remove the middle cell and repeat on the eight survivors. Black marks what remains.],
  ),
  (
    [6  Eisenstein],
    figure-5,
    [Copy the seed on a triangular lattice, rotate, and expand the arrangement. Here the marks are points rather than a continuous turtle path.],
  ),
)
#v(12pt)
#takeaway[*Same rule, finer detail.* $n$ is the iteration index, with the seed convention shown by each construction. Panel resizing hides changes in absolute size; compare structure rather than printed length.]
