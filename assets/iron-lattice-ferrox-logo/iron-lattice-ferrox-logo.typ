#import "@preview/cetz:0.4.2": canvas, draw
#import draw: circle, line, on-layer

// === Configuration ===
#let show-grid = true // false = render single logo, true = render all in grid
#let selected = 0 // gradient index for single mode (0–5)

#let s = 1.0
#let nr = 0.1

// === Gradient Definitions ===
// Each: (name, ((r_base, r_scale), (g_base, g_scale), (b_base, b_scale)))
#let gradients = (
  ("Brown → Orange", ((80, 160), (15, 120), (0, 15))),
  ("Blue → Magenta", ((20, 220), (80, -50), (220, 35))),
  ("Red → Gold", ((180, 75), (15, 195), (0, 10))),
  ("Emerald → Teal", ((0, 30), (80, 175), (50, 155))),
  ("Purple → Pink", ((60, 195), (10, 50), (120, 100))),
  ("Indigo → Cyan", ((25, 5), (20, 210), (100, 155))),
)

// F letter cell positions (col, row)
#let f-cells = (
  (0, 5),
  (1, 5),
  (2, 5),
  (3, 5), // top bar
  (0, 4), // vertical stroke
  (0, 3),
  (1, 3),
  (2, 3), // middle bar
  (0, 2),
  (0, 1),
  (0, 0), // vertical stroke + bottom
)

// x letter diamond offsets from center — inner (full) and outer tips (truncated)
#let x-inner = (
  (0, 0),
  (1, 1),
  (2, 2),
  (-1, 1),
  (-2, 2),
  (1, -1),
  (2, -2),
  (-1, -1),
  (-2, -2),
)
#let x-tips = ((3, 3), (-3, 3), (3, -3), (-3, -3))

// === Render one Fx logo with a given gradient ===
#let render-fx(grad, scale: 1cm) = {
  let ratio = scale / 1cm
  let sw = 1.5pt * ratio
  let nw = 3pt * ratio
  let (rc, gc, bc) = grad

  let color-at(x, y) = {
    let t = calc.clamp((x + 0.4 * y) / 11, 0, 1)
    let ch(base, sc) = calc.clamp(calc.floor(base + t * sc), 0, 255)
    rgb(ch(..rc), ch(..gc), ch(..bc))
  }

  let lattice-edge(from, to) = {
    let mx = (from.at(0) + to.at(0)) / 2
    let my = (from.at(1) + to.at(1)) / 2
    line(from, to, stroke: (paint: color-at(mx, my), thickness: sw))
  }

  let lattice-node(pos) = {
    circle(pos, radius: nr, fill: white, stroke: (paint: color-at(..pos), thickness: nw))
  }

  let square-cell-edges(col, row) = {
    let (x0, y0) = (col * s, row * s)
    let (x1, y1) = (x0 + s, y0 + s)
    lattice-edge((x0, y0), (x1, y0))
    lattice-edge((x1, y0), (x1, y1))
    lattice-edge((x1, y1), (x0, y1))
    lattice-edge((x0, y1), (x0, y0))
    lattice-edge((x0, y0), (x1, y1))
    lattice-edge((x1, y0), (x0, y1))
  }

  let square-cell-nodes(col, row) = {
    let (x0, y0) = (col * s, row * s)
    lattice-node((x0, y0))
    lattice-node((x0 + s, y0))
    lattice-node((x0 + s, y0 + s))
    lattice-node((x0, y0 + s))
    lattice-node((x0 + s / 2, y0 + s / 2))
  }

  let diamond-cell-edges(cx, cy, d) = {
    let top = (cx, cy + d)
    let right = (cx + d, cy)
    let bottom = (cx, cy - d)
    let left = (cx - d, cy)
    lattice-edge(top, right)
    lattice-edge(right, bottom)
    lattice-edge(bottom, left)
    lattice-edge(left, top)
    lattice-edge(top, bottom)
    lattice-edge(left, right)
  }

  let diamond-cell-nodes(cx, cy, d) = {
    for v in ((cx, cy + d), (cx + d, cy), (cx, cy - d), (cx - d, cy), (cx, cy)) {
      lattice-node(v)
    }
  }

  canvas(length: scale, {
    let x-cx = 6.8 * s
    let x-cy = 2.25 * s // 3*d so flat bottom aligns with F baseline
    let d = 0.75 * s

    on-layer(-1, {
      for (col, row) in f-cells { square-cell-edges(col, row) }
      for (ox, oy) in x-inner { diamond-cell-edges(x-cx + ox * d, x-cy + oy * d, d) }
      // Truncated tip diamonds: remove outward vertex (top for upper, bottom for lower)
      for (ox, oy) in x-tips {
        let cx = x-cx + ox * d
        let cy = x-cy + oy * d
        let sy = if oy > 0 { 1 } else { -1 }
        let kept = (cx, cy - sy * d)
        let right = (cx + d, cy)
        let left = (cx - d, cy)
        lattice-edge(right, kept)
        lattice-edge(kept, left)
        lattice-edge(left, right)
        lattice-edge((cx, cy), kept)
      }
    })

    for (col, row) in f-cells { square-cell-nodes(col, row) }
    for (ox, oy) in x-inner { diamond-cell-nodes(x-cx + ox * d, x-cy + oy * d, d) }
    for (ox, oy) in x-tips {
      let cx = x-cx + ox * d
      let cy = x-cy + oy * d
      let sy = if oy > 0 { 1 } else { -1 }
      for v in ((cx + d, cy), (cx - d, cy), (cx, cy), (cx, cy - sy * d)) {
        lattice-node(v)
      }
    }
  })
}

// === Output ===
#set page(width: auto, height: auto, margin: if show-grid { 12pt } else { 8pt })

#if show-grid {
  grid(
    columns: 3,
    column-gutter: 20pt,
    row-gutter: 12pt,
    ..gradients.map(((name, grad)) => stack(
      dir: ttb,
      spacing: 6pt,
      render-fx(grad, scale: 0.5cm),
      align(center, text(size: 8pt, weight: "bold", name)),
    ))
  )
} else {
  render-fx(gradients.at(selected).at(1))
}
