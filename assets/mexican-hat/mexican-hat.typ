#import "@preview/cetz:0.4.2": canvas, draw, matrix
#import draw: circle, content, line, on-layer, rotate, scale, set-style, set-transform, translate

#set page(width: auto, height: auto, margin: 12pt, fill: none)
#set text(size: 15pt, fill: black)

#let radius_domain = (0.0, 1.25)
#let angle_steps = 84
#let radius_steps = 24
#let x_limits = (-1.6, 1.6)
#let y_limits = (-1.6, 1.6)
#let z_limits = (0.0, 1.3)

#let mexican_hat_height(radius_val) = {
  calc.pow(radius_val * radius_val - 1.0, 2)
}

#let surface_point(radius_val, theta_deg) = {
  let theta = theta_deg * 1deg
  (
    calc.sin(theta) * radius_val,
    calc.cos(theta) * radius_val,
    mexican_hat_height(radius_val),
  )
}

#let draw_downhill_arrow(arrow_steps, arrow_radius_start, arrow_radius_stop, downhill_point, theta_deg) = {
  line(
    ..(
      for step_idx in range(arrow_steps + 1) {
        let t = step_idx / arrow_steps
        let radius_val = arrow_radius_start + t * (arrow_radius_stop - arrow_radius_start)
        (downhill_point(radius_val, theta_deg),)
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
  let (radius_min, radius_max) = radius_domain
  let radius_step = (radius_max - radius_min) / radius_steps
  let angle_step = 360.0 / angle_steps
  set-style(stroke: rgb("#1a1a1a") + 0.22pt, fill: white)
  for radius_rev_idx in range(radius_steps) {
    let radius_idx = radius_steps - 1 - radius_rev_idx
    let radius_inner = radius_min + radius_idx * radius_step
    let radius_outer = radius_inner + radius_step
    for angle_idx in range(angle_steps) {
      let theta_left = angle_idx * angle_step
      let theta_right = theta_left + angle_step

      line(
        surface_point(radius_inner, theta_left),
        surface_point(radius_inner, theta_right),
        surface_point(radius_outer, theta_right),
        surface_point(radius_outer, theta_left),
        close: true,
      )
    }
  }
  let apex_point = surface_point(0.0, 0.0)
  let first_ring_radius = radius_step
  for angle_idx in range(angle_steps) {
    let theta_left = angle_idx * angle_step
    let theta_right = theta_left + angle_step
    line(
      apex_point,
      surface_point(first_ring_radius, theta_left),
      surface_point(first_ring_radius, theta_right),
      close: true,
    )
  }
  // Axis lines centered at the origin.
  let (x_min, x_max) = x_limits
  let (y_min, y_max) = y_limits
  let (z_min, z_max) = z_limits
  on-layer(-2, {
    set-style(stroke: rgb("#1f1f1f") + 0.22pt, mark: (
      fill: rgb("#1f1f1f"),
      stroke: rgb("#1f1f1f"),
      scale: 0.52,
      end: "stealth",
    ))
    line((x_min, 0, 0), (x_max, 0, 0))
    line((0, y_min, 0), (0, y_max, 0))
    line((0, 0, z_min), (0, 0, z_max))
  })

  on-layer(8, {
    set-style(fill: black)
    content((1.42, 0.6, 0.02), [$phi_1$], anchor: "west")
    content((-0.7, -0.95, -0.02), [$phi_2$], anchor: "north")
    content((0.02, 0.02, 1.47), [$U_k(rho)$], anchor: "south")
  })

  // Highlighted states.
  let center_point = surface_point(0.0, 0.0)
  let minimum_point = surface_point(1.0, 30.0)
  circle(center_point, radius: 0.09, fill: rgb("#00008b"), stroke: none)
  circle(minimum_point, radius: 0.09, fill: rgb("#8b0000"), stroke: none)

  // Double downhill arrow that follows the surface profile.
  let arrow_color = rgb("#c4c4c4")
  let arrow_steps = 40
  let arrow_radius_start = 0.03
  let arrow_radius_stop = 1.02
  let arrow_clearance = 0.05
  let downhill_point(radius_val, theta_deg) = {
    let theta = theta_deg * 1deg
    (
      calc.sin(theta) * radius_val,
      calc.cos(theta) * radius_val,
      mexican_hat_height(radius_val) + arrow_clearance,
    )
  }
  on-layer(9, {
    set-style(
      stroke: (paint: arrow_color, thickness: 1.1pt),
      fill: none,
      mark: (fill: arrow_color, stroke: arrow_color, scale: 0.56, end: "stealth"),
    )
    draw_downhill_arrow(arrow_steps, arrow_radius_start, arrow_radius_stop, downhill_point, 28.8)
    draw_downhill_arrow(arrow_steps, arrow_radius_start, arrow_radius_stop, downhill_point, 32.8)
    // Dark inner stroke for crisp arrow edges.
    set-style(
      stroke: (paint: rgb("#575757"), thickness: 0.42pt),
      fill: none,
      mark: (fill: rgb("#575757"), stroke: rgb("#575757"), scale: 0.44, end: "stealth"),
    )
    draw_downhill_arrow(arrow_steps, arrow_radius_start, arrow_radius_stop, downhill_point, 28.8)
    draw_downhill_arrow(arrow_steps, arrow_radius_start, arrow_radius_stop, downhill_point, 32.8)
  })
})
