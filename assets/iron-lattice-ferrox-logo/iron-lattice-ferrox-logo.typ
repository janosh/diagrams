#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, line, on-layer

// === Configuration ===
#let show-grid = true // false = render single logo, true = render all in grid
#let selected = 0 // gradient index for single mode (0–5)

#let cell-size = 1.0
#let node-radius = 0.1

// === Gradient Definitions ===
// Each: (name, ((r-base, r-scale), (g-base, g-scale), (b-base, b-scale)))
#let gradients = (
  ("Brown → Orange", ((80, 160), (15, 120), (0, 15))),
  ("Blue → Magenta", ((20, 220), (80, -50), (220, 35))),
  ("Red → Gold", ((180, 75), (15, 195), (0, 10))),
  ("Emerald → Teal", ((0, 30), (80, 175), (50, 155))),
  ("Purple → Pink", ((60, 195), (10, 50), (120, 100))),
  ("Indigo → Cyan", ((25, 5), (20, 210), (100, 155))),
)

// F letter cell positions (col, row), from the top bar down to the baseline
#let f-cells = (
  range(4).map(col => (col, 5)) // top bar
    + ((0, 4),) // stem
    + range(3).map(col => (col, 3)) // middle bar
    + range(3).rev().map(row => (0, row)) // stem down to the baseline
)

// x letter diamond offsets from center — inner (full) and outer tips (truncated)
#let x-inner = ((0, 0), (1, 1), (2, 2), (-1, 1), (-2, 2), (1, -1), (2, -2), (-1, -1), (-2, -2))
#let x-tips = ((3, 3), (-3, 3), (3, -3), (-3, -3))

// === Render one Fx logo with a given gradient ===
#let render-fx(grad, scale: 1cm) = {
  let ratio = scale / 1cm
  let (red, green, blue) = grad

  let color-at(x, y) = {
    let fraction = calc.clamp((x + 0.4 * y) / 11, 0, 1)
    let channel(base, slope) = calc.clamp(calc.floor(base + fraction * slope), 0, 255)
    rgb(channel(..red), channel(..green), channel(..blue))
  }

  // Edges go on a lower layer so every node is drawn on top of them.
  let lattice-edges(..pairs) = on-layer(-1, for (from, to) in pairs.pos() {
    let mid = ((from.at(0) + to.at(0)) / 2, (from.at(1) + to.at(1)) / 2)
    line(from, to, stroke: (paint: color-at(..mid), thickness: 1.5pt * ratio))
  })
  let lattice-nodes(..positions) = for pos in positions.pos() {
    circle(pos, radius: node-radius, fill: white, stroke: (
      paint: color-at(..pos),
      thickness: 3pt * ratio,
    ))
  }

  // Four corners in order around the cell plus a center node, joined by sides and both diagonals.
  let cell((c0, c1, c2, c3), center) = {
    lattice-edges((c0, c1), (c1, c2), (c2, c3), (c3, c0), (c0, c2), (c1, c3))
    lattice-nodes(c0, c1, c2, c3, center)
  }

  canvas(length: scale, {
    let x-cx = 6.8 * cell-size
    let x-cy = 2.25 * cell-size // 3*d so flat bottom aligns with F baseline
    let d = 0.75 * cell-size

    for (col, row) in f-cells {
      let (x0, y0) = (col * cell-size, row * cell-size)
      let (x1, y1) = (x0 + cell-size, y0 + cell-size)
      cell(((x0, y0), (x1, y0), (x1, y1), (x0, y1)), (x0 + cell-size / 2, y0 + cell-size / 2))
    }
    for (ox, oy) in x-inner {
      let (cx, cy) = (x-cx + ox * d, x-cy + oy * d)
      cell(((cx, cy + d), (cx + d, cy), (cx, cy - d), (cx - d, cy)), (cx, cy))
    }
    // Truncated tip diamonds: remove outward vertex (top for upper, bottom for lower)
    for (ox, oy) in x-tips {
      let (cx, cy) = (x-cx + ox * d, x-cy + oy * d)
      let kept = (cx, cy - if oy > 0 { d } else { -d })
      let (right, left) = ((cx + d, cy), (cx - d, cy))
      lattice-edges((right, kept), (kept, left), (left, right), ((cx, cy), kept))
      lattice-nodes(right, left, (cx, cy), kept)
    }
  })
}

// === Output ===
#set page(width: auto, height: auto, margin: if show-grid { 12pt } else { 8pt }, fill: none)
#set text(size: 12pt)

#if show-grid {
  grid(
    columns: 3,
    column-gutter: 20pt,
    row-gutter: 12pt,
    ..gradients.map(((name, grad)) => stack(
      dir: ttb,
      spacing: 6pt,
      render-fx(grad, scale: 0.5cm),
      align(center, text(weight: "bold", name)),
    ))
  )
} else {
  render-fx(gradients.at(selected).at(1))
}
