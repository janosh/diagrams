#import "@preview/cetz:0.5.2": canvas, draw, matrix
#import draw: content, grid, line, set-style, set-transform

#set page(width: auto, height: auto, margin: 18pt, fill: none)
#set text(size: 12pt, fill: black)

#let surface-subdivisions = 96
#let axis-tick-values = (-10, -5, 0, 5, 10)
#let z-tick-values = (1, 2, 3) // omit 0: it coincides with the Im=10 tick at the shared corner
#let tick-font-size = 26pt
#let axis-label-font-size = 36pt

// |n_B(p_0)| = |1 / (e^(p_0) - 1)| at T = 1 for p_0 = x + i y
#let n-b-surface(x-val, y-val) = {
  let denominator = calc.exp(2 * x-val) - 2 * calc.exp(x-val) * calc.cos(y-val * 1rad) + 1
  // Clip the divergent peak at height 2 before taking the inverse square root.
  calc.pow(calc.max(denominator, 0.25), -0.5)
}

// Diverging colormap over heights 0 to 2
#let surface-color(z-val) = {
  let z-ratio = calc.max(0.0, calc.min(1.0, z-val / 2.0))
  let (low-color, mid-color, high-color) = (rgb("#3b4cc0"), rgb("#f9d057"), rgb("#b40426"))
  if z-ratio < 0.5 {
    color.mix((low-color, 1.0 - z-ratio * 2), (mid-color, z-ratio * 2))
  } else {
    color.mix((mid-color, 1.0 - (z-ratio - 0.5) * 2), (high-color, (z-ratio - 0.5) * 2))
  }
}

#canvas({
  let view-transform = matrix.transform-rotate-dir((2.25, 1.75, -4), (0, 1, 0))
  let base-transform = matrix.mul-mat(view-transform, matrix.transform-scale((0.95, 0.95, 6.0)))

  let (x-min, x-max) = (-10.0, 10.0)
  let (y-min, y-max) = (-10.0, 10.0)
  let (z-min, z-max) = (0.0, 3.0)

  // Builtin CeTZ grid on the floor of the axis-aligned box.
  set-style(stroke: rgb("#9a9a9a").transparentize(35%) + 0.08pt)
  set-transform(base-transform)
  grid(
    (x-min, y-min, z-min),
    (x-max, y-max, z-min),
    step: (1, 1),
  )

  // CeTZ has no depth buffer, so the quads have to be painted back to front by hand.
  // Under an orthographic projection the view depth of a point is the third row of the
  // transform dotted with it, so sorting quad centers on that gives the right order.
  let x-step = (x-max - x-min) / surface-subdivisions
  let y-step = (y-max - y-min) / surface-subdivisions
  let (depth-x, depth-y, depth-z, ..) = base-transform.at(2)
  let quads = ()
  for y-idx in range(surface-subdivisions) {
    let y-bottom = y-min + y-idx * y-step
    let y-top = y-bottom + y-step
    for x-idx in range(surface-subdivisions) {
      let x-left = x-min + x-idx * x-step
      let x-right = x-left + x-step
      let corners = (
        (x-left, y-bottom, n-b-surface(x-left, y-bottom)),
        (x-left, y-top, n-b-surface(x-left, y-top)),
        (x-right, y-top, n-b-surface(x-right, y-top)),
        (x-right, y-bottom, n-b-surface(x-right, y-bottom)),
      )
      let z-avg = corners.map(corner => corner.at(2)).sum() / 4
      let depth = (
        depth-x * (x-left + x-right) / 2 + depth-y * (y-bottom + y-top) / 2 + depth-z * z-avg
      )
      quads.push((depth, corners, surface-color(z-avg)))
    }
  }
  for (_, corners, fill) in quads.sorted(key: quad => quad.first()) {
    line(..corners, fill: fill, stroke: fill + 0.02pt)
  }

  // Box edges.
  set-style(stroke: black + 0.4pt)
  line((x-min, y-min, z-min), (x-max, y-min, z-min))
  line((x-min, y-max, z-min), (x-max, y-max, z-min))
  line((x-min, y-min, z-min), (x-min, y-max, z-min))
  line((x-max, y-min, z-min), (x-max, y-max, z-min))
  line((x-min, y-min, z-min), (x-min, y-min, z-max))
  line((x-max, y-max, z-min), (x-max, y-max, z-max))
  line((x-min, y-max, z-min), (x-min, y-max, z-max))
  line((x-max, y-min, z-min), (x-max, y-min, z-max))
  line((x-min, y-min, z-max), (x-min, y-max, z-max))
  line((x-min, y-min, z-max), (x-max, y-min, z-max))
  line((x-max, y-min, z-max), (x-max, y-max, z-max))
  line((x-min, y-max, z-max), (x-max, y-max, z-max))

  // Ticks and labels.
  let (tick-length, tick-label-gap) = (0.35, 1.2)
  let tick-label(pos, value, anchor) = content(
    pos,
    text(size: tick-font-size)[#value],
    anchor: anchor,
  )
  // Re ticks sit on the front edge so they don't line up with the poles behind them.
  for tick-x in axis-tick-values {
    line((tick-x, y-min, z-min), (tick-x, y-min - tick-length, z-min))
    tick-label((tick-x, y-min - tick-label-gap, z-min), tick-x, "north")
  }
  for tick-y in axis-tick-values {
    line((x-max, tick-y, z-min), (x-max + tick-length, tick-y, z-min))
    tick-label((x-max + tick-label-gap, tick-y, z-min), tick-y, "west")
  }
  for tick-z in z-tick-values {
    line((x-max, y-max, tick-z), (x-max + tick-length, y-max, tick-z))
    tick-label((x-max + tick-label-gap, y-max, tick-z), tick-z, "west")
  }

  for (pos, label, anchor) in (
    ((0, y-min - 5, z-min), $"Re"(p_0)$, "north"),
    ((x-max + 4, 2.5, z-min), $"Im"(p_0)$, "west"),
    ((x-max + 2.6, y-max, (z-min + z-max) / 2), $abs(n_(upright(B))(p_0))$, "west"),
  ) {
    content(pos, text(size: axis-label-font-size, label), anchor: anchor)
  }
})
