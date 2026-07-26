#import "@preview/cetz:0.5.2": canvas, draw, matrix
#import draw: circle, content, line, on-layer, rotate, scale, set-style, set-transform, translate

#set page(width: auto, height: auto, margin: 12pt, fill: none)
#set text(size: 15pt, fill: black)

#let radius-domain = (0.0, 1.25)
#let angle-steps = 84
#let radius-steps = 24
#let x-limits = (-1.6, 1.6)
#let y-limits = (-1.6, 1.6)
#let z-limits = (0.0, 1.3)

#let mexican-hat-height(radius-val) = {
  calc.pow(radius-val * radius-val - 1.0, 2)
}

#let surface-point(radius-val, theta-deg) = {
  let theta = theta-deg * 1deg
  (
    calc.sin(theta) * radius-val,
    calc.cos(theta) * radius-val,
    mexican-hat-height(radius-val),
  )
}

// @typstyle off
#let draw-downhill-arrow(arrow-steps, arrow-radius-start, arrow-radius-stop, downhill-point, theta-deg) = {
  line(
    ..(
      for step-idx in range(arrow-steps + 1) {
        let t = step-idx / arrow-steps
        let radius-val = (
          arrow-radius-start + t * (arrow-radius-stop - arrow-radius-start)
        )
        (downhill-point(radius-val, theta-deg),)
      }
    ),
  )
}

#canvas({
  set-transform(matrix.transform-rotate-dir((2.5, 0.6, -2), (0, 1, 0.3)))
  scale(x: 3, y: 3, z: -2.5)
  rotate(z: -5deg)
  translate((0, -0.02, 0))

  // Surface mesh, drawn first.
  let (radius-min, radius-max) = radius-domain
  let radius-step = (radius-max - radius-min) / radius-steps
  let angle-step = 360.0 / angle-steps
  set-style(stroke: rgb("#1a1a1a") + 0.22pt, fill: white)
  for radius-rev-idx in range(radius-steps) {
    let radius-idx = radius-steps - 1 - radius-rev-idx
    let radius-inner = radius-min + radius-idx * radius-step
    let radius-outer = radius-inner + radius-step
    for angle-idx in range(angle-steps) {
      let theta-left = angle-idx * angle-step
      let theta-right = theta-left + angle-step

      line(
        surface-point(radius-inner, theta-left),
        surface-point(radius-inner, theta-right),
        surface-point(radius-outer, theta-right),
        surface-point(radius-outer, theta-left),
        close: true,
      )
    }
  }
  let apex-point = surface-point(0.0, 0.0)
  let first-ring-radius = radius-step
  for angle-idx in range(angle-steps) {
    let theta-left = angle-idx * angle-step
    let theta-right = theta-left + angle-step
    line(
      apex-point,
      surface-point(first-ring-radius, theta-left),
      surface-point(first-ring-radius, theta-right),
      close: true,
    )
  }
  // Axis lines centered at the origin.
  let (x-min, x-max) = x-limits
  let (y-min, y-max) = y-limits
  let (z-min, z-max) = z-limits
  on-layer(-2, {
    set-style(stroke: rgb("#1f1f1f") + 0.22pt, mark: (
      fill: rgb("#1f1f1f"),
      stroke: rgb("#1f1f1f"),
      scale: 0.52,
      end: "stealth",
    ))
    line((x-min, 0, 0), (x-max, 0, 0))
    line((0, y-min, 0), (0, y-max, 0))
    line((0, 0, z-min), (0, 0, z-max))
  })

  on-layer(8, {
    set-style(fill: black)
    content((1.42, 0.6, 0.02), [$phi_1$], anchor: "west")
    content((-0.7, -0.95, -0.02), [$phi_2$], anchor: "north")
    content((0.02, 0.02, 1.47), [$U_k(rho)$], anchor: "south")
  })

  // Highlighted states.
  let center-point = surface-point(0.0, 0.0)
  let minimum-point = surface-point(1.0, 30.0)
  circle(center-point, radius: 0.09, fill: rgb("#00008b"), stroke: none)
  circle(minimum-point, radius: 0.09, fill: rgb("#8b0000"), stroke: none)

  // Double downhill arrow that follows the surface profile.
  let arrow-color = rgb("#c4c4c4")
  let arrow-steps = 40
  let arrow-radius-start = 0.03
  let arrow-radius-stop = 1.02
  let arrow-clearance = 0.05
  let downhill-point(radius-val, theta-deg) = {
    let theta = theta-deg * 1deg
    (
      calc.sin(theta) * radius-val,
      calc.cos(theta) * radius-val,
      mexican-hat-height(radius-val) + arrow-clearance,
    )
  }
  on-layer(9, {
    set-style(
      stroke: (paint: arrow-color, thickness: 1.1pt),
      fill: none,
      mark: (
        fill: arrow-color,
        stroke: arrow-color,
        scale: 0.56,
        end: "stealth",
      ),
    )
    draw-downhill-arrow(
      arrow-steps,
      arrow-radius-start,
      arrow-radius-stop,
      downhill-point,
      28.8,
    )
    draw-downhill-arrow(
      arrow-steps,
      arrow-radius-start,
      arrow-radius-stop,
      downhill-point,
      32.8,
    )
    // Dark inner stroke for crisp arrow edges.
    set-style(
      stroke: (paint: rgb("#575757"), thickness: 0.42pt),
      fill: none,
      mark: (
        fill: rgb("#575757"),
        stroke: rgb("#575757"),
        scale: 0.44,
        end: "stealth",
      ),
    )
    draw-downhill-arrow(
      arrow-steps,
      arrow-radius-start,
      arrow-radius-stop,
      downhill-point,
      28.8,
    )
    draw-downhill-arrow(
      arrow-steps,
      arrow-radius-start,
      arrow-radius-stop,
      downhill-point,
      32.8,
    )
  })
})
