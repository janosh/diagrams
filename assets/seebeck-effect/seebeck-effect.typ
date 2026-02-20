#import "@preview/cetz:0.4.2": canvas, decorations, draw
#import draw: circle, content, line, on-layer, rect

#set page(width: 12cm, height: 9cm, margin: 4pt, fill: none)

#let dx = 0.45
#let dy = 0.45
#let sink_dx = 0.84
#let sink_dy = 0.58
#let bar_dx = 0.66
#let pillar_dx = 0.66
#let edge_stroke = (paint: black, thickness: 0.6pt)
#let circuit_stroke = (paint: black, thickness: 1.1pt)
#let circuit_mark = (symbol: "stealth", fill: black, scale: 0.5, shorten-to: none)
#let field_color = black.transparentize(10%)
#let field_stroke = (paint: field_color, thickness: 1.0pt)
#let field_mark = (end: "stealth", fill: field_color, scale: 0.55)

#let sink_blue = rgb("#0b0bff")
#let sink_side_blue = rgb("#0606cf")
#let pillar_grad = gradient.linear(
  rgb("#d20a17"),
  rgb("#5660d4"),
  angle: 90deg,
)
#let bar_red = rgb("#ef1313")
#let bar_side_red = rgb("#de1313")
#let bar_top_red = rgb("#ff2222")
#let n_color = rgb("#11b7ef")
#let p_color = rgb("#ffa300")
#let bar_x0 = 1.0
#let bar_y0 = 7.0
#let bar_w = 9.95
#let bar_h = 0.9

#let draw_prism(x0, y0, w, h, depth_x, front_fill, right_fill, top_fill, stroke, depth_y: dy) = {
  rect((x0, y0), (x0 + w, y0 + h), fill: front_fill, stroke: stroke)
  line(
    (x0 + w, y0),
    (x0 + w + depth_x, y0 + depth_y),
    (x0 + w + depth_x, y0 + h + depth_y),
    (x0 + w, y0 + h),
    close: true,
    fill: right_fill,
    stroke: stroke,
  )
  line(
    (x0, y0 + h),
    (x0 + w, y0 + h),
    (x0 + w + depth_x, y0 + h + depth_y),
    (x0 + depth_x, y0 + h + depth_y),
    close: true,
    fill: top_fill,
    stroke: stroke,
  )
}

#let charge_marker(x, y, sign: $+$, fill: p_color) = {
  circle((x, y), radius: 0.2, fill: fill, stroke: none)
  content((x, y + 0.03), text(size: 12pt, weight: "light", fill: black)[#sign], anchor: "center")
  line(
    (x, y - 0.22),
    (x, y - 0.72),
    stroke: (paint: black, thickness: 1.3pt),
    mark: (end: "stealth", fill: black, scale: 0.7),
  )
}

#let sink_block(x0, y0, w: 2.9, h: 0.85) = {
  draw_prism(
    x0,
    y0,
    w,
    h,
    sink_dx,
    sink_blue,
    sink_side_blue,
    sink_side_blue.lighten(20%),
    edge_stroke,
    depth_y: sink_dy,
  )
  content((x0 + w / 2, y0 + h / 2), text(size: 14pt, fill: white)[heat sink], anchor: "center")
}

#let pillar_w = 2.45
#let pillar_h = 5.35

#let pillar_block(x0, y0, w: pillar_w, h: pillar_h, label: [N]) = {
  rect((x0, y0), (x0 + w, y0 + h), fill: pillar_grad, stroke: none)
  line(
    (x0 + w, y0),
    (x0 + w + pillar_dx, y0 + dy),
    (x0 + w + pillar_dx, y0 + h + dy),
    (x0 + w, y0 + h),
    close: true,
    fill: pillar_grad,
    stroke: none,
  )
  circle((x0 + w / 2, y0 + h * 0.58), radius: 0.38, stroke: (paint: white.transparentize(25%), thickness: 0.7pt))
  content((x0 + w / 2, y0 + h * 0.58), text(size: 16pt, fill: white.transparentize(25%))[#label], anchor: "center")
}

#let field_arrow_with_polarity(x, y_start, y_end, top_label, bottom_label, label_side) = {
  line((x, y_start), (x, y_end), stroke: field_stroke, mark: field_mark)
  let x_offset = if label_side == "west" { 0.18 } else { -0.18 }
  content((x + x_offset, y_start), text(size: 11pt, fill: field_color)[#top_label], anchor: label_side)
  content((x + x_offset, y_end), text(size: 11pt, fill: field_color)[#bottom_label], anchor: label_side)
}

#let draw_circuit_leg(..pts) = {
  line(
    ..pts,
    stroke: circuit_stroke,
  )
}

#canvas({
  let left_sink_x = 1.05
  let right_sink_x = 7.9
  let sink_y = 0.8
  let pillar_y = sink_y + 0.95
  let left_pillar_x = left_sink_x + 0.35
  let right_pillar_x = right_sink_x + 0.35

  // Left (N) pillar and sink
  sink_block(left_sink_x, sink_y)
  pillar_block(left_pillar_x, pillar_y, label: [N])
  let left_field_x = left_pillar_x + pillar_w + pillar_dx + 0.25
  field_arrow_with_polarity(left_field_x, pillar_y + pillar_h - 0.6, pillar_y + 0.6, [+], [-], "west")
  for (dx_offset, dy_offset) in ((1.05, 5.2), (2.25, 5.2), (1.05, 2.3), (2.35, 2.45)) {
    charge_marker(left_sink_x + dx_offset, sink_y + dy_offset, sign: [−], fill: n_color)
  }

  // Right (P) pillar and sink
  sink_block(right_sink_x, sink_y)
  pillar_block(right_pillar_x, pillar_y, label: [P])
  let right_field_x = right_pillar_x - 0.25
  field_arrow_with_polarity(right_field_x, pillar_y + 0.55, pillar_y + pillar_h - 0.55, [-], [+], "east")
  content(
    ((left_field_x + right_field_x) / 2, pillar_y + pillar_h * 0.55),
    text(size: 15pt, fill: field_color)[electric field],
    anchor: "center",
  )
  for (dx_offset, dy_offset) in ((1.02, 5.2), (2.2, 5.2), (1.02, 2.3), (2.32, 2.45)) {
    charge_marker(right_sink_x + dx_offset, sink_y + dy_offset, sign: [+], fill: p_color)
  }

  // Top heat source bar (foreground so it occludes pillars/charges)
  on-layer(20, {
    draw_prism(bar_x0, bar_y0, bar_w, bar_h, bar_dx, bar_red, bar_side_red, bar_top_red, edge_stroke)
    content((6.05, 8.16), text(size: 15pt, fill: white)[heat source], anchor: "center")
    content((5.68, 7.4), text(size: 20pt, fill: white)[$J arrow.r$], anchor: "center")
  })

  // Bottom wire closing the electric circuit with central resistor zig-zag.
  let wire_y = 0.12
  let left_wire_x = left_sink_x + 0.2
  let right_wire_x = right_sink_x + 2.55
  let zig_right_x = 5.85
  let zig_left_x = 4.65

  // Right-angle segments.
  draw_circuit_leg((right_wire_x, sink_y), (right_wire_x, wire_y), (zig_right_x, wire_y))
  draw_circuit_leg((zig_left_x, wire_y), (left_wire_x, wire_y), (left_wire_x, sink_y))
  // Center resistor as a decorated zigzag, with multiple arrow tips on the same path.
  decorations.zigzag(
    line(
      (zig_right_x, wire_y),
      (zig_left_x, wire_y),
      stroke: circuit_stroke,
      mark: (
        end: (
          (pos: 20%, ..circuit_mark),
          (pos: 50%, ..circuit_mark),
          (pos: 80%, ..circuit_mark),
        ),
      ),
    ),
    amplitude: 0.12,
    segment-length: 0.2,
  )
})
