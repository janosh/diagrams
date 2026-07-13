// Fractal drawer for janosh/diagrams — page setup belongs in <slug>.typ.
// Style matches typical CeTZ assets: transparent page, black strokes, math labels.

#import "@preview/cetz:0.5.2": canvas, draw
#import draw: line, rect, circle

// --- palette (shared across all contribution diagrams) ---
// Prefer black geometry like Feynman / contour diagrams; colored fills like ball-tree.
#let _stroke-paint = black
#let _stroke-thin = 0.45pt
#let _stroke-thick = 0.75pt
#let _carpet-fill = black
#let _cantor-fill = blue.lighten(25%)
#let _point-fill = blue.darken(5%)
#let _label-size = 10pt
#let _panel-size-default = 4.5cm
#let _gutter-default = 14pt

// --- L-system engine ---
#let _expand(axiom, rules, order) = {
  let rule-pattern = regex(rules.keys().join("|"))
  let path = axiom
  for _ in range(order) {
    path = path.replace(rule-pattern, matched => rules.at(matched.text))
  }
  path
}

// Unit step per heading: 4 headings on the square grid, 6 on the hexagonal grid.
#let _turtle-steps = (
  rect: ((1.0, 0.0), (0.0, 1.0), (-1.0, 0.0), (0.0, -1.0)),
  hex: (
    (1.0, 0.0),
    (0.5, calc.sqrt(3.0) / 2.0),
    (-0.5, calc.sqrt(3.0) / 2.0),
    (-1.0, 0.0),
    (-0.5, -calc.sqrt(3.0) / 2.0),
    (0.5, -calc.sqrt(3.0) / 2.0),
  ),
)

#let _turtle(path, draw-symbols, turtle: "rect") = {
  let steps = _turtle-steps.at(turtle)
  let (x-pos, y-pos, direction) = (0.0, 0.0, 0)
  let segments = ()
  for symbol in path {
    if symbol in draw-symbols {
      let (delta-x, delta-y) = steps.at(direction)
      segments.push((x-pos, y-pos, x-pos + delta-x, y-pos + delta-y))
      x-pos += delta-x
      y-pos += delta-y
    } else if symbol == "+" {
      direction = calc.rem(direction + 1, steps.len())
    } else if symbol == "-" {
      direction = calc.rem(direction - 1 + steps.len(), steps.len())
    }
  }
  segments
}

// Density-aware stroke: early L-system stages read thicker; dense stages stay fine.
#let _curve-stroke(segment-count) = {
  let thickness = calc.max(
    _stroke-thin,
    calc.min(_stroke-thick, 3.2pt / calc.sqrt(calc.max(segment-count, 1))),
  )
  (paint: _stroke-paint, thickness: thickness, join: "round", cap: "round")
}

// --- Eisenstein fractal (ports generateEisensteinFractal.m) ---
#let _complex-add(left, right) = (left.at(0) + right.at(0), left.at(1) + right.at(1))
#let _complex-multiply(left, right) = (
  left.at(0) * right.at(0) - left.at(1) * right.at(1),
  left.at(0) * right.at(1) + left.at(1) * right.at(0),
)
#let _complex-scale(factor, value) = (factor * value.at(0), factor * value.at(1))
#let _complex-from-angle(angle) = (calc.cos(angle), calc.sin(angle))

#let _omega = _complex-from-angle(2.0 * calc.pi / 3.0)
#let _eisenstein-vertices = (
  (0.0, 0.0),
  (1.0, 0.0),
  _omega,
  _complex-multiply(_omega, _omega),
)

#let _eisenstein-positions(stage) = {
  // Stage 1 is the seed vertices (paper §2.1). The final -r_p display rotation
  // only applies after iterative growth (stage >= 2).
  if stage <= 1 {
    return _eisenstein-vertices
  }
  let positions = _eisenstein-vertices
  let last-rotation = _complex-from-angle(0.0)
  for generation in range(2, stage + 1) {
    let spacing = calc.pow(2, generation - 1)
    let rotation = _complex-from-angle((generation - 1) * calc.pi / 3.0)
    last-rotation = rotation
    let next-positions = ()
    for vertex in _eisenstein-vertices {
      let shift = _complex-scale(spacing, _complex-multiply(rotation, vertex))
      for position in positions {
        next-positions.push(_complex-add(position, shift))
      }
    }
    positions = next-positions
  }
  let negative-rotation = _complex-scale(-1.0, last-rotation)
  positions.map(point => _complex-multiply(negative-rotation, point))
}

// --- recursive carpet / cantor ---
// Subdivide a square into 3×3 cells, drop cells failing `keep`, recurse until unit cells.
#let _grid-rectangles(size, origin-x, origin-y, rectangles, keep) = {
  if size <= 1 { return rectangles }
  let third = calc.floor(size / 3)
  for column in range(3) {
    for row in range(3) {
      if not keep(column, row) { continue }
      let block-x = origin-x + column * third
      let block-y = origin-y + row * third
      if third <= 1 {
        rectangles.push((block-x, block-y, block-x + 1.0, block-y + 1.0))
      } else {
        rectangles = _grid-rectangles(third, block-x, block-y, rectangles, keep)
      }
    }
  }
  rectangles
}

// --- CeTZ drawers ---
// Bounding box over items holding one or more (x, y) pairs:
// points (x, y) or segments/rects (x0, y0, x1, y1).
#let _bounds(items) = {
  let (x0, y0) = (items.at(0).at(0), items.at(0).at(1))
  let (x-min, x-max, y-min, y-max) = (x0, x0, y0, y0)
  for item in items {
    for idx in range(0, item.len(), step: 2) {
      x-min = calc.min(x-min, item.at(idx))
      x-max = calc.max(x-max, item.at(idx))
      y-min = calc.min(y-min, item.at(idx + 1))
      y-max = calc.max(y-max, item.at(idx + 1))
    }
  }
  (x-min: x-min, x-max: x-max, y-min: y-min, y-max: y-max)
}

// Scale a drawing so its padded bounds fit max-size, and hand `render` a closure
// shifting (x, y) coordinates into the padded canvas.
#let _fit-canvas(items, padding, max-size, render) = {
  let bounds = _bounds(items)
  let width = bounds.x-max - bounds.x-min + 2 * padding
  let height = bounds.y-max - bounds.y-min + 2 * padding
  let unit-length = max-size / calc.max(width, height, 1.0)
  let shift = point => (
    point.at(0) - bounds.x-min + padding,
    point.at(1) - bounds.y-min + padding,
  )
  canvas(length: unit-length, render(shift))
}

#let _draw-segments-canvas(segments, max-size: _panel-size-default) = {
  let stroke = _curve-stroke(segments.len())
  _fit-canvas(segments, 0, max-size, shift => {
    for (x0, y0, x1, y1) in segments {
      line(shift((x0, y0)), shift((x1, y1)), stroke: stroke)
    }
  })
}

#let _draw-rectangles-canvas(rectangles, fill, stroke: auto, max-size: _panel-size-default) = {
  // Stroking with the fill color closes antialiasing seams between adjacent unit cells.
  let stroke = if stroke == auto { fill + 0.3pt } else { stroke }
  _fit-canvas(rectangles, 0, max-size, shift => {
    for (x0, y0, x1, y1) in rectangles {
      rect(shift((x0, y0)), shift((x1, y1)), stroke: stroke, fill: fill)
    }
  })
}

#let _draw-points-canvas(points, fill: _point-fill, max-size: _panel-size-default) = {
  let bounds = _bounds(points)
  let span = calc.max(bounds.x-max - bounds.x-min, bounds.y-max - bounds.y-min, 1.0)
  // Taper dots as stages get denser, but never below ~1pt wide on the page
  // (0.055 canvas units shrink to a fraction of a pixel at dense stages).
  let radius = calc.max(
    0.32 / calc.sqrt(calc.max(points.len(), 1)),
    0.5pt / (max-size / span),
  )
  _fit-canvas(points, radius, max-size, shift => {
    for point in points {
      circle(shift(point), radius: radius, fill: fill, stroke: none)
    }
  })
}

// --- layout ---
#let standalone-stages(
  stages: (1, 2, 3),
  draw-stage: order => none,
  panel-size: _panel-size-default,
  gutter: _gutter-default,
  label-gap: 6pt,
) = {
  // Fixed width, natural height: wide curves (Koch) and near-square sets (carpet)
  // both fill the panel without forced letterboxing.
  grid(
    columns: stages.len(),
    column-gutter: gutter,
    row-gutter: label-gap,
    ..stages.map(order => box(
      width: panel-size,
      align(center + horizon, draw-stage(order)),
    )),
    ..stages.map(order => align(center, text(size: _label-size)[$n = #order$])),
  )
}

// Titles live in each diagram's YAML file; presets only carry geometry.
#let presets = (
  dragon: (
    kind: "lsystem",
    axiom: "FX",
    rules: ("X": "X+YF+", "Y": "-FX-Y"),
    draw-symbols: "F",
    turtle: "rect",
    stages: (5, 9, 13),
  ),
  koch: (
    kind: "lsystem",
    axiom: "F",
    rules: ("F": "F+F--F+F"),
    draw-symbols: "F",
    turtle: "hex",
    stages: (2, 3, 4),
  ),
  sierpinski-curve: (
    kind: "lsystem",
    axiom: "A",
    rules: ("A": "B-A-B", "B": "A+B+A"),
    draw-symbols: "AB",
    turtle: "hex",
    // Even orders share orientation; odd orders flip the triangle.
    stages: (2, 4, 6),
  ),
  gosper: (
    kind: "lsystem",
    axiom: "A",
    rules: ("A": "A-B--B+A++AA+B-", "B": "+A-BB--B-A++A+B"),
    draw-symbols: "AB",
    turtle: "hex",
    stages: (1, 2, 3),
  ),
  carpet: (
    kind: "grid",
    keep: (column, row) => not (column == 1 and row == 1), // punch out center cell
    fill: _carpet-fill,
    stages: (2, 3, 4),
  ),
  cantor: (
    kind: "grid",
    keep: (column, row) => column != 1 and row != 1, // keep only corner cells
    fill: _cantor-fill,
    stages: (2, 3, 4),
  ),
  eisenstein: (kind: "eisenstein", stages: (2, 3, 4)),
)

#let standalone-preset-stages(preset-name, panel-size: _panel-size-default, ..style) = {
  let preset = presets.at(preset-name)
  let draw-stage = if preset.kind == "lsystem" {
    order => {
      let path = _expand(preset.axiom, preset.rules, order)
      let segments = _turtle(path, preset.draw-symbols, turtle: preset.turtle)
      _draw-segments-canvas(segments, max-size: panel-size)
    }
  } else if preset.kind == "grid" {
    order => {
      let rectangles = _grid-rectangles(calc.pow(3, order), 0.0, 0.0, (), preset.keep)
      _draw-rectangles-canvas(rectangles, preset.fill, max-size: panel-size)
    }
  } else {
    stage => _draw-points-canvas(_eisenstein-positions(stage), max-size: panel-size)
  }
  standalone-stages(
    stages: preset.stages,
    draw-stage: draw-stage,
    panel-size: panel-size,
    ..style,
  )
}
