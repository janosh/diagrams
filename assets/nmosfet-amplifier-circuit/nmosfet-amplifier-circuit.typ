#import "@preview/cetz:0.5.2"
#set page(width: auto, height: auto, margin: 8pt, fill: none)

#let connect-orthogonal(start_anchor, end_anchor, style: "hv", ..styling) = {
  assert(style in ("hv", "vh"), message: "Style must be 'hv' or 'vh'.")
  let corner = if style == "hv" { (start_anchor, "|-", end_anchor) } else { (start_anchor, "-|", end_anchor) }
  cetz.draw.line(start_anchor, corner, end_anchor, ..styling)
}

#let _draw_label(label, label_pos, label_offset, label_anchor, label_size, text_fill: black) = {
  if label != none {
    cetz.draw.content(
      (rel: label_offset, to: label_pos),
      text(size: label_size, fill: text_fill, label),
      anchor: label_anchor,
    )
  }
}

#let _define_anchors(anchors) = {
  for (name, pos) in anchors { cetz.draw.anchor(name, pos) }
}

/// Shared L/R two-terminal compass anchors used by resistor and capacitor.
#let _lr_anchors(lead_start_x, lead_end_x, hh) = (
  ("L", (lead_start_x, 0)),
  ("R", (lead_end_x, 0)),
  ("center", (0, 0)),
  ("north", (0, hh)),
  ("south", (0, -hh)),
  ("east", (lead_end_x, 0)),
  ("west", (lead_start_x, 0)),
  ("T", (0, hh)),
  ("B", (0, -hh)),
  ("default", (lead_start_x, 0)),
)

#let _base_component(
  position,
  name,
  scale: 1.0,
  rotate: 0deg,
  draw_content_func,
  anchor_definitions,
  label: none,
  label_pos: "center",
  label_anchor: "center",
  label_offset: (0, 0),
  label_size: 8pt,
  text_fill: black,
  ..styling,
) = {
  cetz.draw.group(name: name, ..styling, {
    cetz.draw.set-origin(position)
    cetz.draw.scale(scale)
    cetz.draw.rotate(rotate)
    draw_content_func(..styling)
    _define_anchors(anchor_definitions)
    _draw_label(label, label_pos, label_offset, label_anchor, label_size, text_fill: text_fill)
  })
}

#let nmos_transistor(
  position,
  name,
  label: none,
  label_pos: "D",
  label_anchor: "north-west",
  label_offset: (0.05, 0.05),
  label_size: 8pt,
  show_pin_labels: false,
  pin_label_size: 7pt,
  scale: 1.0,
  rotate: 0deg,
  width: 0.9,
  height: 1.2,
  gate_lead_factor: 0.3,
  bulk_lead_factor: 0.3,
  gate_pos_factor: 0.3,
  channel_pos_factor: 0.4,
  gate_v_extent_factor: 0.35,
  channel_v_extent_factor: 0.35,
  thick_factor: 2.0,
  arrow_scale: 0.8,
  arrow_fill: black,
  ..styling,
) = {
  cetz.draw.group(name: name, ..styling, {
    cetz.draw.set-origin(position)
    cetz.draw.scale(scale)
    cetz.draw.rotate(rotate)

    let center_y = height / 2
    let gate_line_x = gate_pos_factor * width
    let channel_line_x = channel_pos_factor * width
    let gate_v_extent = height * gate_v_extent_factor
    let channel_v_extent = height * channel_v_extent_factor
    let drain_term_rel = (width, height)
    let source_term_rel = (width, 0)
    let gate_term_rel = (-gate_lead_factor * width, center_y)
    let bulk_term_rel = (width + bulk_lead_factor * width, center_y)
    let gate_line_top = (gate_line_x, center_y + gate_v_extent)
    let gate_line_bottom = (gate_line_x, center_y - gate_v_extent)
    let gate_conn_pt = (gate_line_x, center_y)
    let channel_top = (channel_line_x, center_y + channel_v_extent)
    let channel_bottom = (channel_line_x, center_y - channel_v_extent)
    let bulk_conn_pt = (channel_line_x, center_y)
    let horiz_top = (width, center_y + channel_v_extent)
    let horiz_bottom = (width, center_y - channel_v_extent)
    let line_thickness = 0.6pt * thick_factor

    _define_anchors((
      ("G", gate_term_rel),
      ("D", drain_term_rel),
      ("S", source_term_rel),
      ("B", bulk_term_rel),
      ("center", (width / 2, height / 2)),
      ("bulk_conn", bulk_conn_pt),
      ("gate_conn", gate_conn_pt),
      ("north", (width / 2, height)),
      ("south", (width / 2, 0)),
      ("east", (width, height / 2)),
      ("west", (0, height / 2)),
      ("north-east", (width, height)),
      ("south-west", (0, 0)),
      ("south-east", (width, 0)),
      ("default", gate_term_rel),
    ))

    cetz.draw.line(channel_bottom, channel_top, ..styling, thickness: line_thickness)
    cetz.draw.line(gate_line_bottom, gate_line_top, ..styling, thickness: line_thickness)
    cetz.draw.line(gate_term_rel, gate_conn_pt, ..styling)
    cetz.draw.line(bulk_conn_pt, bulk_term_rel, ..styling)

    cetz.draw.line(drain_term_rel, horiz_top, ..styling)
    cetz.draw.line(horiz_top, channel_top, ..styling)
    cetz.draw.line(horiz_bottom, source_term_rel, ..styling)
    cetz.draw.line(channel_bottom, horiz_bottom, ..styling, mark: (end: "stealth", fill: arrow_fill, scale: arrow_scale))

    if show_pin_labels {
      cetz.draw.content((rel: (-0.05, 0), to: "G"), text(size: pin_label_size, $G$), anchor: "east")
      cetz.draw.content((rel: (0.05, 0), to: "S"), text(size: pin_label_size, $S$), anchor: "south")
      cetz.draw.content((rel: (0.05, 0), to: "D"), text(size: pin_label_size, $D$), anchor: "north")
      cetz.draw.content((rel: (0.05, 0), to: "B"), text(size: pin_label_size, $B$), anchor: "west")
    }
    _draw_label(label, label_pos, label_offset, label_anchor, label_size)
  })
}

#let gnd_symbol(
  position,
  name,
  label: none,
  label_pos: "north",
  label_anchor: "south",
  label_offset: (0, 0.1),
  label_size: 8pt,
  scale: 1.0,
  rotate: 0deg,
  lead_length: 0.3,
  bar_width: 0.5,
  bar_spacing: 0.05,
  bar_width_factors: (1.0, 0.7, 0.4),
  ..styling,
) = {
  assert(bar_width_factors.len() == 3, message: "bar_width_factors must have 3 elements.")
  let draw_func(..styling) = {
    let y_coords = (-lead_length, -lead_length - bar_spacing, -lead_length - 2 * bar_spacing)
    cetz.draw.line((0, 0), (0, -lead_length), ..styling)
    for (idx, y) in y_coords.enumerate() {
      let half_w = bar_width * bar_width_factors.at(idx) / 2
      cetz.draw.line((-half_w, y), (half_w, y), ..styling)
    }
  }
  let south_y = -lead_length - 2 * bar_spacing
  let anchors = (
    ("T", (0, 0)),
    ("north", (0, 0)),
    ("south", (0, south_y)),
    ("west", (-bar_width * bar_width_factors.at(0) / 2, -lead_length)),
    ("east", (bar_width * bar_width_factors.at(0) / 2, -lead_length)),
    ("center", (0, (-lead_length + south_y) / 2)),
    ("default", (0, 0)),
  )
  _base_component(
    position,
    name,
    scale: scale,
    rotate: rotate,
    draw_func,
    anchors,
    label: label,
    label_pos: label_pos,
    label_anchor: label_anchor,
    label_offset: label_offset,
    label_size: label_size,
    ..styling,
  )
}

#let resistor(
  position,
  name,
  label: none,
  label_pos: "south",
  label_anchor: "north",
  label_offset: (0, -0.1),
  label_size: 8pt,
  scale: 1.0,
  rotate: 0deg,
  width: 0.8,
  height: 0.3,
  zigs: 3,
  lead_extension: 0.3,
  ..styling,
) = {
  let hw = width / 2
  let hh = height / 2
  let lead_start_x = -hw - lead_extension
  let lead_end_x = hw + lead_extension
  let zig_start_x = -hw
  let num_segments = zigs * 2
  let seg_h = width / num_segments
  let draw_func(..styling) = {
    let sgn = 1
    cetz.draw.line(
      (lead_start_x, 0),
      (zig_start_x, 0),
      (rel: (seg_h / 2, hh * sgn)),
      ..for _ in range(num_segments - 1) {
        sgn *= -1
        ((rel: (seg_h, hh * 2 * sgn)),)
      },
      (rel: (seg_h / 2, hh)),
      (lead_end_x, 0),
      ..styling,
    )
  }
  _base_component(
    position,
    name,
    scale: scale,
    rotate: rotate,
    draw_func,
    _lr_anchors(lead_start_x, lead_end_x, hh),
    label: label,
    label_pos: label_pos,
    label_anchor: label_anchor,
    label_offset: label_offset,
    label_size: label_size,
    ..styling,
  )
}

#let capacitor(
  position,
  name,
  label: none,
  label_pos: "south",
  label_anchor: "north",
  label_offset: (0, -0.1),
  label_size: 8pt,
  scale: 1.0,
  rotate: 0deg,
  plate_height: 0.6,
  plate_gap: 0.2,
  lead_extension: 0.5,
  ..styling,
) = {
  let hg = plate_gap / 2
  let hh = plate_height / 2
  let lead_start_x = -hg - lead_extension
  let lead_end_x = hg + lead_extension
  let plate_left_x = -hg
  let plate_right_x = hg
  let draw_func(..styling) = {
    cetz.draw.line((lead_start_x, 0), (plate_left_x, 0), ..styling)
    cetz.draw.line((plate_left_x, -hh), (plate_left_x, hh), ..styling)
    cetz.draw.line((plate_right_x, hh), (plate_right_x, -hh), ..styling)
    cetz.draw.line((plate_right_x, 0), (lead_end_x, 0), ..styling)
  }
  _base_component(
    position,
    name,
    scale: scale,
    rotate: rotate,
    draw_func,
    _lr_anchors(lead_start_x, lead_end_x, hh),
    label: label,
    label_pos: label_pos,
    label_anchor: label_anchor,
    label_offset: label_offset,
    label_size: label_size,
    ..styling,
  )
}

#let voltage_source(
  position,
  name,
  label: none,
  annotation_label_pos: "left",
  annotation_label_anchor: auto,
  annotation_label_offset: auto,
  annotation_label_size: 8pt,
  show_voltage_annotation: true,
  voltage_arrow_pos: "left",
  voltage_arrow_dir: "down",
  voltage_arrow_length_factor: 2,
  voltage_arrow_offset_factor: 0.7,
  arrow_scale: 1.0,
  arrow_fill: black,
  stroke_thickness: 0.6pt,
  scale: 1.0,
  rotate: 0deg,
  radius: 0.3,
  lead_length: 0.3,
  ..styling,
) = {
  let draw_func(..styling) = {
    let top_y = radius
    let bottom_y = -radius
    let top_lead_y = top_y + lead_length
    let bottom_lead_y = bottom_y - lead_length
    cetz.draw.circle((0, 0), radius: radius, ..styling)
    cetz.draw.line((0, top_y), (0, top_lead_y), ..styling)
    cetz.draw.line((0, bottom_y), (0, bottom_lead_y), ..styling)
    if show_voltage_annotation {
      let arrow_x = if voltage_arrow_pos == "left" { -radius * (1 + voltage_arrow_offset_factor) } else {
        radius * (1 + voltage_arrow_offset_factor)
      }
      let arrow_len = radius * voltage_arrow_length_factor
      let arrow_half_len = arrow_len / 2
      let (arrow_start_y, arrow_end_y) = if voltage_arrow_dir == "down" { (arrow_half_len, -arrow_half_len) } else {
        (-arrow_half_len, arrow_half_len)
      }
      cetz.draw.line((arrow_x, arrow_start_y), (arrow_x, arrow_end_y), ..styling, mark: (
        end: "stealth",
        scale: arrow_scale * 0.4,
        fill: arrow_fill,
        stroke: (paint: black, thickness: stroke_thickness),
      ))
      if label != none {
        let (default_anchor, default_offset) = if annotation_label_pos == "left" { ("east", (-0.05, 0)) } else {
          ("west", (0.05, 0))
        }
        let final_anchor = if annotation_label_anchor == auto { default_anchor } else { annotation_label_anchor }
        let final_offset = if annotation_label_offset == auto { default_offset } else { annotation_label_offset }
        cetz.draw.content(
          (rel: (0.1 * scale * arrow_x / calc.abs(arrow_x), 0), to: (arrow_x, 0)),
          text(size: annotation_label_size, fill: arrow_fill, label),
          anchor: final_anchor,
          offset: final_offset,
        )
      }
    }
  }
  let top_lead_y = radius + lead_length
  let bottom_lead_y = -radius - lead_length
  let anchors = (
    ("T", (0, top_lead_y)),
    ("B", (0, bottom_lead_y)),
    ("center", (0, 0)),
    ("north", (0, top_lead_y)),
    ("south", (0, bottom_lead_y)),
    ("east", (radius, 0)),
    ("west", (-radius, 0)),
    ("default", (0, top_lead_y)),
  )
  _base_component(
    position,
    name,
    scale: scale,
    rotate: rotate,
    draw_func,
    anchors,
    label: none,
    ..styling,
  )
}

#let node(
  position,
  name,
  label: none,
  radius: 0.05,
  label_size: 8pt,
  label_offset: (0, 0),
  label_anchor: "center",
  fill: white,
  text_fill: black,
  scale: 1.0,
  rotate: 0deg,
  ..styling,
) = {
  let draw_func(..styling) = {
    cetz.draw.circle((0, 0), radius: radius, ..styling, fill: fill)
  }
  let diag_offset = radius * calc.cos(45deg)
  let anchors = (
    ("center", (0, 0)),
    ("default", (0, 0)),
    ("north", (0, radius)),
    ("south", (0, -radius)),
    ("east", (radius, 0)),
    ("west", (-radius, 0)),
    ("north-east", (diag_offset, diag_offset)),
    ("north-west", (-diag_offset, diag_offset)),
    ("south-east", (diag_offset, -diag_offset)),
    ("south-west", (-diag_offset, -diag_offset)),
  )
  _base_component(
    position,
    name,
    scale: scale,
    rotate: rotate,
    draw_func,
    anchors,
    label: label,
    label_pos: "center",
    label_anchor: label_anchor,
    label_offset: label_offset,
    label_size: label_size,
    text_fill: text_fill,
    ..styling,
  )
}

#let vdd_symbol(
  position,
  name,
  label: none,
  label_pos: "north",
  label_anchor: "south",
  label_offset: (0, 0.1),
  label_size: 8pt,
  scale: 1.0,
  rotate: 0deg,
  stem_length: 0.3,
  bar_width: 0.5,
  text_fill: black,
  ..styling,
) = {
  let draw_func(..styling) = {
    let stem_top_y = stem_length
    let bar_half_width = bar_width / 2
    cetz.draw.line((0, 0), (0, stem_top_y), ..styling)
    cetz.draw.line((-bar_half_width, stem_top_y), (bar_half_width, stem_top_y), ..styling)
  }
  let stem_top_y = stem_length
  let bar_half_width = bar_width / 2
  let anchors = (
    ("B", (0, 0)),
    ("south", (0, 0)),
    ("default", (0, 0)),
    ("T", (0, stem_top_y)),
    ("north", (0, stem_top_y)),
    ("TL", (-bar_half_width, stem_top_y)),
    ("TR", (bar_half_width, stem_top_y)),
    ("west", (-bar_half_width, stem_top_y)),
    ("east", (bar_half_width, stem_top_y)),
    ("center", (0, stem_top_y / 2)),
  )
  _base_component(
    position,
    name,
    scale: scale,
    rotate: rotate,
    draw_func,
    anchors,
    label: label,
    label_pos: label_pos,
    label_anchor: label_anchor,
    label_offset: label_offset,
    label_size: label_size,
    text_fill: text_fill,
    ..styling,
  )
}

#cetz.canvas({
  let default_stroke = (stroke: (thickness: .6pt))
  // Coordinates
  let x_vin = 0
  let x_r1 = 1.0
  let x_m1 = 1.9
  let x_out = x_m1 + 0.9
  let x_cl = x_out + 2.0
  let x_vout = x_cl + 1.0
  let y_gate = 1.6
  let y_m1_base = 1.0
  let y_m1_s = y_m1_base
  let y_m1_d = y_m1_base + 1.2
  let y_m1_b = y_m1_base + 0.6
  let y_vdd = y_m1_d + 1.5
  let y_gnd = -1.0
  let y_cl_center = y_m1_s - 0.95

  // Components
  voltage_source((x_vin, y_gate - 1), "Vin", label: $V_"in"$, radius: 0.4, lead_length: 0.2, ..default_stroke)
  resistor((x_r1, y_gate), "R1", label: $R_1$, label_pos: "north", label_offset: (0, 0.4), width: 1.0, ..default_stroke)
  nmos_transistor(
    (x_m1, y_m1_base),
    "M1",
    label: $M_1$,
    label_pos: "east",
    label_anchor: "west",
    label_offset: (0.3, 0.3),
    ..default_stroke,
  )
  vdd_symbol((x_out, y_vdd), "Vdd", label: $V_"DD"$, ..default_stroke)
  resistor(
    (x_out, y_m1_s - 1),
    "R2",
    rotate: 90deg,
    label: $R_2$,
    label_pos: "west",
    label_offset: (0.5, 0.5),
    ..default_stroke,
  )
  capacitor(
    (x_cl, y_cl_center),
    "CL",
    rotate: 90deg,
    label: $C_L$,
    label_pos: "east",
    label_offset: (-0.2, -0.5),
    ..default_stroke,
  )
  node((x_vout, y_m1_b), "VoutNode", label: $V_"out"$, label_offset: (0.15, 0), label_anchor: "west", ..default_stroke)

  // Ground connections
  for (name, pos) in (
    ("GND_Vin", (x_vin, y_gnd)),
    ("GND_M1B", (x_m1 + 1.27, y_m1_b)),
    ("GND_R2", (x_out, y_gnd)),
    ("GND_CL", (x_cl, y_gnd)),
  ) {
    gnd_symbol(pos, name, ..default_stroke)
  }

  // Connections
  for (start, end) in (
    ("Vin.T", "R1.L"),
    ("Vin.B", "GND_Vin.T"),
    ("R1.R", "M1.G"),
    ("M1.D", "Vdd.B"),
    ("M1.B", "GND_M1B.T"),
    ("M1.S", "R2.R"),
    ("GND_R2.T", "R2.L"),
    ("GND_CL.T", "CL.L"),
    ("CL.R", "M1.S"),
    ("VoutNode", "M1.S"),
  ) {
    connect-orthogonal(start, end, style: "hv", ..default_stroke)
  }
})
