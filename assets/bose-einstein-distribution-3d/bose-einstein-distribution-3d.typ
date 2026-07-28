#import "@preview/cetz:0.5.2": canvas, draw, matrix
#import draw: content, grid, line, set-style, set-transform

#set page(width: auto, height: auto, margin: 18pt, fill: none)
#set text(fill: black)

#let x-domain = (-10.0, 10.0)
#let y-domain = (-10.0, 10.0)
#let z-domain = (0.0, 3.0)
#let surface-subdivisions = 96
#let axis-tick-values = (-10, -5, 0, 5, 10)
#let z-tick-values = (1, 2, 3) // omit 0: it coincides with the Im=10 tick at the shared corner
#let tick-font-size = 26pt
#let axis-label-font-size = 36pt

#let n-b-surface(x-val, y-val) = {
  let denominator = (
    calc.exp(2 * x-val) - 2 * calc.exp(x-val) * calc.cos(y-val * 1rad) + 1
  )
  if denominator <= 0.001 { return 2.0 }

  let z-val = calc.pow(denominator, -0.5)
  if x-val >= -2 and x-val <= 1 and z-val > 2.0 { return 2.0 }
  calc.max(0.0, z-val)
}

#let surface-color(z-val) = {
  let (min-z, max-z) = (0.0, 2.0)
  let z-ratio = calc.max(0.0, calc.min(1.0, (z-val - min-z) / (max-z - min-z)))
  let low-color = rgb("#3b4cc0")
  let mid-color = rgb("#f9d057")
  let high-color = rgb("#b40426")
  if z-ratio < 0.5 {
    color.mix((low-color, 1.0 - z-ratio * 2), (mid-color, z-ratio * 2))
  } else {
    color.mix(
      (mid-color, 1.0 - (z-ratio - 0.5) * 2),
      (high-color, (z-ratio - 0.5) * 2),
    )
  }
}

#canvas({
  let view-transform = matrix.transform-rotate-dir((2.25, 1.75, -4), (0, 1, 0))
  let base-transform = matrix.mul-mat(view-transform, matrix.transform-scale((
    0.95,
    0.95,
    6.0,
  )))

  let (x-min, x-max) = x-domain
  let (y-min, y-max) = y-domain
  let (z-min, z-max) = z-domain

  let axis-stroke = black + 0.4pt
  let grid-stroke = rgb("#9a9a9a").transparentize(35%) + 0.08pt

  // Builtin CeTZ grid on three planes of the axis-aligned box.
  set-style(stroke: grid-stroke)
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

      let z-lb = n-b-surface(x-left, y-bottom)
      let z-lt = n-b-surface(x-left, y-top)
      let z-rt = n-b-surface(x-right, y-top)
      let z-rb = n-b-surface(x-right, y-bottom)
      let z-avg = (z-lb + z-lt + z-rt + z-rb) / 4

      let depth = (
        depth-x * (x-left + x-right) / 2 + depth-y * (y-bottom + y-top) / 2 + depth-z * z-avg
      )
      quads.push((
        depth,
        (
          (x-left, y-bottom, z-lb),
          (x-left, y-top, z-lt),
          (x-right, y-top, z-rt),
          (x-right, y-bottom, z-rb),
        ),
        surface-color(z-avg),
      ))
    }
  }
  for (_, corners, fill) in quads.sorted(key: quad => quad.first()) {
    line(..corners, fill: fill, stroke: fill + 0.02pt)
  }

  // Box axes and front edges.
  set-style(stroke: axis-stroke)
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
  let tick-length = 0.35
  for tick-x in axis-tick-values {
    line((tick-x, y-max, z-min), (tick-x, y-max + tick-length, z-min))
    content(
      (tick-x, y-max + 2.5, z-min),
      text(size: tick-font-size)[#tick-x],
      anchor: "south",
    )
  }
  for tick-y in axis-tick-values {
    line((x-max, tick-y, z-min), (x-max + tick-length, tick-y, z-min))
    content(
      (x-max + 1.2, tick-y, z-min),
      text(size: tick-font-size)[#tick-y],
      anchor: "west",
    )
  }
  for tick-z in z-tick-values {
    line((x-max, y-max, tick-z), (x-max + tick-length, y-max, tick-z))
    content(
      (x-max + 1.2, y-max, tick-z),
      text(size: tick-font-size)[#tick-z],
      anchor: "west",
    )
  }

  content(
    (2.0, y-max + 6.8, z-min),
    text(size: axis-label-font-size)[$"Re"(p_0)$],
    anchor: "south",
  )
  content(
    (x-max + 3, (y-min + y-max) / 2 + 2.4, z-min),
    text(size: axis-label-font-size)[$"Im"(p_0)$],
    anchor: "west",
  )
  content(
    (x-max + 2.6, y-max, (z-min + z-max) / 2),
    text(size: axis-label-font-size)[$n_(upright(B))(p_0)$],
    anchor: "west",
  )
})
