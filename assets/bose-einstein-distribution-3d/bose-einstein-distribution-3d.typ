#import "@preview/cetz:0.4.2": canvas, draw, matrix

#set page(width: auto, height: auto, margin: 18pt, fill: none)
#set text(fill: black)

#let x_domain = (-10.0, 10.0)
#let y_domain = (-10.0, 10.0)
#let z_domain = (0.0, 3.0)
#let surface_subdivisions = 96
#let axis_tick_values = (-10, -5, 0, 5, 10)
#let z_tick_values = (0, 1, 2, 3)
#let tick_font_size = 26pt
#let axis_label_font_size = 36pt
#let peak_overlay_threshold = 1.6

#let n_b_surface(x_val, y_val) = {
  let denominator = calc.exp(2 * x_val) - 2 * calc.exp(x_val) * calc.cos(y_val * 1rad) + 1
  if denominator <= 0.001 { return 2.0 }

  let z_val = calc.pow(denominator, -0.5)
  if x_val >= -2 and x_val <= 1 and z_val > 2.0 { return 2.0 }
  calc.max(0.0, z_val)
}

#let surface_color(z_val) = {
  let (min_z, max_z) = (0.0, 2.0)
  let z_ratio = calc.max(0.0, calc.min(1.0, (z_val - min_z) / (max_z - min_z)))
  let low_color = rgb("#3b4cc0")
  let mid_color = rgb("#f9d057")
  let high_color = rgb("#b40426")
  if z_val >= 1.6 {
    high_color
  } else if z_ratio < 0.5 {
    color.mix((low_color, 1.0 - z_ratio * 2), (mid_color, z_ratio * 2))
  } else {
    color.mix((mid_color, 1.0 - (z_ratio - 0.5) * 2), (high_color, (z_ratio - 0.5) * 2))
  }
}

#canvas({
  import draw: content, grid, line, set-style, set-transform

  let view_transform = matrix.transform-rotate-dir((-2.25, 1.75, 4), (0, -1, 0))
  let base_transform = matrix.mul-mat(view_transform, matrix.transform-scale((0.95, 0.95, 6.0)))

  let (x_min, x_max) = x_domain
  let (y_min, y_max) = y_domain
  let (z_min, z_max) = z_domain

  let axis_stroke = black + 0.4pt
  let grid_stroke = rgb("#9a9a9a").transparentize(35%) + 0.08pt

  // Builtin CeTZ grid on three planes of the axis-aligned box.
  set-style(stroke: grid_stroke)
  set-transform(base_transform)
  grid(
    (x_min, y_min, z_min),
    (x_max, y_max, z_min),
    step: (1, 1),
  )

  // Surface quads in two passes so peaks render above the base sheet.
  let x_step = (x_max - x_min) / surface_subdivisions
  let y_step = (y_max - y_min) / surface_subdivisions
  let draw_surface_pass(draw_peak_overlay) = {
    for y_idx in range(surface_subdivisions) {
      let y_bottom = y_min + y_idx * y_step
      let y_top = y_bottom + y_step
      for x_idx in range(surface_subdivisions) {
        let x_left = x_min + x_idx * x_step
        let x_right = x_left + x_step

        let z_lb = n_b_surface(x_left, y_bottom)
        let z_lt = n_b_surface(x_left, y_top)
        let z_rt = n_b_surface(x_right, y_top)
        let z_rb = n_b_surface(x_right, y_bottom)
        let z_avg = (z_lb + z_lt + z_rt + z_rb) / 4

        let should_draw_quad = if draw_peak_overlay {
          z_avg >= peak_overlay_threshold
        } else { z_avg < peak_overlay_threshold }
        if should_draw_quad {
          line(
            (x_left, y_bottom, z_lb),
            (x_left, y_top, z_lt),
            (x_right, y_top, z_rt),
            (x_right, y_bottom, z_rb),
            fill: surface_color(z_avg),
          )
        }
      }
    }
  }
  set-style(stroke: none)
  draw_surface_pass(false)
  draw_surface_pass(true)

  // Box axes and front edges.
  set-style(stroke: axis_stroke)
  line((x_min, y_min, z_min), (x_max, y_min, z_min))
  line((x_min, y_max, z_min), (x_max, y_max, z_min))
  line((x_min, y_min, z_min), (x_min, y_max, z_min))
  line((x_max, y_min, z_min), (x_max, y_max, z_min))
  line((x_min, y_min, z_min), (x_min, y_min, z_max))
  line((x_max, y_max, z_min), (x_max, y_max, z_max))
  line((x_min, y_max, z_min), (x_min, y_max, z_max))
  line((x_max, y_min, z_min), (x_max, y_min, z_max))
  line((x_min, y_min, z_max), (x_min, y_max, z_max))
  line((x_min, y_min, z_max), (x_max, y_min, z_max))
  line((x_max, y_min, z_max), (x_max, y_max, z_max))
  line((x_min, y_max, z_max), (x_max, y_max, z_max))

  // Ticks and labels.
  let tick_length = 0.35
  for tick_x in axis_tick_values {
    line((tick_x, y_max, z_min), (tick_x, y_max + tick_length, z_min))
    content((tick_x, y_max + 2.5, z_min), text(size: tick_font_size)[#tick_x], anchor: "south")
  }
  for tick_y in axis_tick_values {
    line((x_max, tick_y, z_min), (x_max + tick_length, tick_y, z_min))
    content((x_max + 1.2, tick_y, z_min), text(size: tick_font_size)[#tick_y], anchor: "west")
  }
  for tick_z in z_tick_values {
    line((x_max, y_max, tick_z), (x_max + tick_length, y_max, tick_z))
    content((x_max + 1.2, y_max, tick_z), text(size: tick_font_size)[#tick_z], anchor: "west")
  }

  content((2.0, y_max + 6.8, z_min), text(size: axis_label_font_size)[$"Re"(p_0)$], anchor: "south")
  content(
    (x_max + 3, (y_min + y_max) / 2 + 2.4, z_min),
    text(size: axis_label_font_size)[$"Im"(p_0)$],
    anchor: "west",
  )
  content((x_max + 2.6, y_max, (z_min + z_max) / 2), text(size: axis_label_font_size)[$n_B(p_0)$], anchor: "west")
})
