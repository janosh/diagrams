// Fractal drawer for janosh/diagrams — page setup belongs in <slug>.typ.
// Style aligned with https://github.com/janosh/diagrams (CeTZ, auto page, 10pt text).

#import "@preview/cetz:0.5.2": canvas, draw
#import draw: line, rect, circle

// --- palette (shared across all contribution diagrams) ---
#let _stroke = rgb("#1f3a5f") + 0.7pt
#let _carpet-fill = rgb("#2d3436")
#let _cantor-fill = rgb("#4a6fa5")
#let _point-fill = rgb("#3d7ea6").lighten(18%)
#let _title-size = 12pt
#let _label-size = 9pt
#let _panel-size-default = 4.2cm
#let _gutter-default = 10pt

// --- L-system engine ---
#let _expand(axiom, rules, order) = {
  let match-str = regex(rules.keys().join("|"))
  let s = axiom
  for _ in range(order) {
    s = s.replace(match-str, key => rules.at(key.text))
  }
  s
}

#let _rect-step(dir) = {
  if dir == 0 { (1.0, 0.0) }
  else if dir == 1 { (0.0, 1.0) }
  else if dir == 2 { (-1.0, 0.0) }
  else { (0.0, -1.0) }
}

#let _hex-step(dir) = {
  let s3 = calc.sqrt(3.0)
  if dir == 0 { (1.0, 0.0) }
  else if dir == 1 { (0.5, s3 / 2.0) }
  else if dir == 2 { (-0.5, s3 / 2.0) }
  else if dir == 3 { (-1.0, 0.0) }
  else if dir == 4 { (-0.5, -s3 / 2.0) }
  else { (0.5, -s3 / 2.0) }
}

#let _turtle(path, draw-symbols, turtle: "rect", scale: 1) = {
  let step-fn = if turtle == "rect" { _rect-step } else { _hex-step }
  let n-dir = if turtle == "rect" { 4 } else { 6 }
  let x = 0.0
  let y = 0.0
  let dir = 0
  let segments = ()
  for ch in path {
    if ch in draw-symbols {
      for _ in range(scale) {
        let (dx, dy) = step-fn(dir)
        let x1 = x + dx
        let y1 = y + dy
        segments.push((x, y, x1, y1))
        x = x1
        y = y1
      }
    } else if ch == "+" {
      dir = calc.rem(dir - 1 + n-dir, n-dir)
    } else if ch == "-" {
      dir = calc.rem(dir + 1, n-dir)
    }
  }
  (segments: segments)
}

// --- Eisenstein fractal (ports generateEisensteinFractal.m) ---
#let _c-add(a, b) = (a.at(0) + b.at(0), a.at(1) + b.at(1))
#let _c-mul(a, b) = (
  a.at(0) * b.at(0) - a.at(1) * b.at(1),
  a.at(0) * b.at(1) + a.at(1) * b.at(0),
)
#let _c-scale(s, a) = (s * a.at(0), s * a.at(1))
#let _c-neg(a) = (-a.at(0), -a.at(1))
#let _c-from-angle(theta) = (calc.cos(theta), calc.sin(theta))

#let _omega = _c-from-angle(2.0 * calc.pi / 3.0)
#let _omega2 = _c-mul(_omega, _omega)
#let _eisenstein-vertices = ((0.0, 0.0), (1.0, 0.0), _omega, _omega2)

#let _eisenstein-positions(stage, center: (0.0, 0.0)) = {
  if stage <= 1 {
    return _eisenstein-vertices.map(p => _c-add(p, center))
  }
  let positions = _eisenstein-vertices
  let r-last = _c-from-angle(0.0)
  for p in range(2, stage + 1) {
    let delta = calc.pow(2, p - 1)
    let r = _c-from-angle((p - 1) * calc.pi / 3.0)
    r-last = r
    let new-pos = ()
    for v in _eisenstein-vertices {
      let shift = _c-scale(delta, _c-mul(r, v))
      for pos in positions {
        new-pos.push(_c-add(pos, shift))
      }
    }
    positions = new-pos
  }
  let neg-r = _c-neg(r-last)
  positions.map(pt => _c-add(_c-mul(neg-r, pt), center))
}

// --- bounds helpers ---
#let _bounds-segments(segments) = {
  let (x-min, x-max, y-min, y-max) = (0.0, 0.0, 0.0, 0.0)
  for seg in segments {
    let (x0, y0, x1, y1) = seg
    x-min = calc.min(x-min, x0, x1)
    x-max = calc.max(x-max, x0, x1)
    y-min = calc.min(y-min, y0, y1)
    y-max = calc.max(y-max, y0, y1)
  }
  (x-min: x-min, x-max: x-max, y-min: y-min, y-max: y-max)
}

#let _bounds-rects(rects) = {
  let (x-min, x-max, y-min, y-max) = (0.0, 0.0, 0.0, 0.0)
  for r in rects {
    let (x0, y0, x1, y1) = r
    x-min = calc.min(x-min, x0, x1)
    x-max = calc.max(x-max, x0, x1)
    y-min = calc.min(y-min, y0, y1)
    y-max = calc.max(y-max, y0, y1)
  }
  (x-min: x-min, x-max: x-max, y-min: y-min, y-max: y-max)
}

#let _bounds-points(points) = {
  let (x-min, x-max, y-min, y-max) = (0.0, 0.0, 0.0, 0.0)
  for p in points {
    let (x, y) = p
    x-min = calc.min(x-min, x)
    x-max = calc.max(x-max, x)
    y-min = calc.min(y-min, y)
    y-max = calc.max(y-max, y)
  }
  (x-min: x-min, x-max: x-max, y-min: y-min, y-max: y-max)
}

// --- recursive carpet / cantor ---
#let _carpet-rects(len, ox, oy, rects) = {
  if len <= 1 { return rects }
  let third = calc.floor(len / 3)
  for i in range(3) {
    for j in range(3) {
      if i == 1 and j == 1 { continue }
      let bx = ox + i * third
      let by = oy + j * third
      if third <= 1 {
        rects.push((bx, by, bx + 1.0, by + 1.0))
      } else {
        rects = _carpet-rects(third, bx, by, rects)
      }
    }
  }
  rects
}

#let _cantor-rects(len, ox, oy, rects) = {
  if len <= 1 { return rects }
  let third = calc.floor(len / 3)
  for i in range(3) {
    for j in range(3) {
      if i == 1 or j == 1 { continue }
      let bx = ox + i * third
      let by = oy + j * third
      if third <= 1 {
        rects.push((bx, by, bx + 1.0, by + 1.0))
      } else {
        rects = _cantor-rects(third, bx, by, rects)
      }
    }
  }
  rects
}

#let _recursive-rects(kind, order) = {
  let size = calc.pow(3, order)
  if kind == "carpet" {
    _carpet-rects(size, 0.0, 0.0, ())
  } else {
    _cantor-rects(size, 0.0, 0.0, ())
  }
}

// --- CeTZ drawers ---
#let _draw-segments-canvas(segments, stroke: _stroke, padding: 0.5, max-size: _panel-size-default) = {
  let b = _bounds-segments(segments)
  let w = b.x-max - b.x-min + 2 * padding
  let h = b.y-max - b.y-min + 2 * padding
  let unit = max-size / calc.max(w, h, 1.0)
  canvas(length: unit, {
    for seg in segments {
      let (x0, y0, x1, y1) = seg
      line(
        (x0 - b.x-min + padding, y0 - b.y-min + padding),
        (x1 - b.x-min + padding, y1 - b.y-min + padding),
        stroke: stroke,
      )
    }
  })
}

#let _draw-rects-canvas(rects, fill, stroke: _stroke, padding: 0.5, max-size: _panel-size-default) = {
  let b = _bounds-rects(rects)
  let w = b.x-max - b.x-min + 2 * padding
  let h = b.y-max - b.y-min + 2 * padding
  let unit = max-size / calc.max(w, h, 1.0)
  canvas(length: unit, {
    for r in rects {
      let (x0, y0, x1, y1) = r
      rect(
        (x0 - b.x-min + padding, y0 - b.y-min + padding),
        (x1 - b.x-min + padding, y1 - b.y-min + padding),
        stroke: stroke,
        fill: fill,
      )
    }
  })
}

#let _draw-points-canvas(points, fill: _point-fill, padding: 0.5, max-size: _panel-size-default) = {
  let b = _bounds-points(points)
  let w = b.x-max - b.x-min + 2 * padding
  let h = b.y-max - b.y-min + 2 * padding
  let unit = max-size / calc.max(w, h, 1.0)
  let n = calc.max(points.len(), 1)
  let radius = calc.max(0.022, 0.11 / calc.sqrt(n))
  canvas(length: unit, {
    for p in points {
      let (x, y) = p
      circle(
        (x - b.x-min + padding, y - b.y-min + padding),
        radius: radius,
        fill: fill,
        stroke: none,
      )
    }
  })
}

// --- layout ---
#let _plot-slot(body, panel-size) = {
  box(
    width: panel-size,
    height: panel-size,
    align(center + horizon, body),
  )
}

#let _order-label(order) = {
  align(center)[
    #text(size: _label-size, fill: luma(100))[order #order]
  ]
}

#let standalone-stages(
  title: "Fractal",
  stages: (1, 2, 3),
  draw-stage: order => none,
  panel-size: _panel-size-default,
  gutter: _gutter-default,
  label-gap: 5pt,
) = {
  let n = stages.len()
  let plot-cells = stages.map(order => _plot-slot(draw-stage(order), panel-size))
  let label-cells = stages.map(order => _order-label(order))

  box(width: n * panel-size + calc.max(0, n - 1) * gutter)[
    #align(center)[#text(size: _title-size, weight: "bold")[#title]]
    #v(8pt)
    #grid(
      columns: n,
      column-gutter: gutter,
      row-gutter: label-gap,
      ..plot-cells,
      ..label-cells,
    )
  ]
}

#let standalone-lsystem-stages(
  title: "Fractal",
  axiom: "F",
  rules: ("F": "F"),
  draw-symbols: "F",
  turtle: "rect",
  stages: (1, 2, 3),
  stroke: _stroke,
  panel-size: _panel-size-default,
) = {
  standalone-stages(
    title: title,
    stages: stages,
    panel-size: panel-size,
    draw-stage: order => {
      let path = _expand(axiom, rules, order)
      let geom = _turtle(path, draw-symbols, turtle: turtle)
      _draw-segments-canvas(geom.segments, stroke: stroke, max-size: panel-size)
    },
  )
}

#let standalone-recursive-stages(
  title: "Fractal",
  kind: "carpet",
  stages: (2, 3, 4),
  fill: _carpet-fill,
  stroke: _stroke,
  panel-size: _panel-size-default,
) = {
  standalone-stages(
    title: title,
    stages: stages,
    panel-size: panel-size,
    draw-stage: order => {
      let rects = _recursive-rects(kind, order)
      _draw-rects-canvas(rects, fill, stroke: stroke, max-size: panel-size)
    },
  )
}

#let standalone-eisenstein-stages(
  title: "Eisenstein Fractal",
  stages: (2, 3, 4),
  panel-size: _panel-size-default,
  fill: _point-fill,
) = {
  standalone-stages(
    title: title,
    stages: stages,
    panel-size: panel-size,
    draw-stage: stage => {
      let points = _eisenstein-positions(stage)
      _draw-points-canvas(points, fill: fill, max-size: panel-size)
    },
  )
}

#let presets = (
  dragon: (
    title: "Dragon Curve",
    kind: "lsystem",
    axiom: "FX",
    rules: ("X": "X+YF+", "Y": "-FX-Y"),
    draw-symbols: "F",
    turtle: "rect",
    stages: (4, 8, 12),
  ),
  koch: (
    title: "Koch Curve",
    kind: "lsystem",
    axiom: "F",
    rules: ("F": "-F++F-F"),
    draw-symbols: "F",
    turtle: "hex",
    stages: (2, 3, 4),
  ),
  sierpinski-curve: (
    title: "Sierpiński Curve",
    kind: "lsystem",
    axiom: "A",
    rules: ("A": "B-A-B", "B": "A+B+A"),
    draw-symbols: "AB",
    turtle: "hex",
    stages: (3, 5, 6),
  ),
  gosper: (
    title: "Gosper Curve",
    kind: "lsystem",
    axiom: "A",
    rules: ("A": "A-B--B+A++AA+B-", "B": "+A-BB--B-A++A+B"),
    draw-symbols: "AB",
    turtle: "hex",
    stages: (1, 2, 3),
  ),
  carpet: (
    title: "Sierpiński Carpet",
    kind: "carpet",
    stages: (2, 3, 4),
  ),
  cantor: (
    title: "Cantor Dust",
    kind: "cantor",
    stages: (2, 3, 4),
  ),
  eisenstein: (
    title: "Eisenstein Fractal",
    kind: "eisenstein",
    stages: (2, 3, 4),
  ),
)

#let standalone-preset-stages(name, ..style) = {
  let p = presets.at(name)
  if p.kind == "lsystem" {
    standalone-lsystem-stages(
      title: p.title,
      axiom: p.axiom,
      rules: p.rules,
      draw-symbols: p.draw-symbols,
      turtle: p.turtle,
      stages: p.stages,
      ..style,
    )
  } else if p.kind == "eisenstein" {
    standalone-eisenstein-stages(
      title: p.title,
      stages: p.stages,
      ..style,
    )
  } else {
    standalone-recursive-stages(
      title: p.title,
      kind: p.kind,
      stages: p.stages,
      fill: if p.kind == "carpet" { _carpet-fill } else { _cantor-fill },
      ..style,
    )
  }
}
