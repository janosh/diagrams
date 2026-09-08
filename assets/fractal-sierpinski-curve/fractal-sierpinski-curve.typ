#import "@preview/cetz:0.5.2": canvas, draw

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#let panel-size = 4.5cm
// Even orders keep the same triangle orientation.
#let stages = (2, 4, 6)

// Unit step for each heading on the hexagonal grid.
#let steps = (
  (1.0, 0.0),
  (0.5, calc.sqrt(3.0) / 2.0),
  (-0.5, calc.sqrt(3.0) / 2.0),
  (-1.0, 0.0),
  (-0.5, -calc.sqrt(3.0) / 2.0),
  (0.5, -calc.sqrt(3.0) / 2.0),
)

#let draw-stage(order) = {
  // Repeatedly replace symbols to build the curve path.
  let rules = ("A": "B-A-B", "B": "A+B+A")
  let pattern = regex(rules.keys().join("|"))
  let path = "A"
  for _ in range(order) { path = path.replace(pattern, matched => rules.at(matched.text)) }

  // Follow the path: drawing symbols advance one unit; + and - turn one heading.
  let (x-pos, y-pos, direction) = (0.0, 0.0, 0)
  let points = ((x-pos, y-pos),)
  for symbol in path {
    if symbol in "AB" {
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

// Equal-width panels retain their natural aspect ratios.
#grid(
  columns: stages.len(),
  column-gutter: 14pt,
  row-gutter: 6pt,
  ..stages.map(order => box(width: panel-size, align(center + horizon, draw-stage(order)))),
  ..stages.map(order => align(center, text(size: 10pt)[$n = #order$])),
)
