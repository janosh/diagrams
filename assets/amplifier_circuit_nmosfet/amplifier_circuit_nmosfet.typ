#import "@preview/cetz:0.3.4" as cetz
#set page(width: auto, height: auto, margin: 8pt)
#let connect-orthogonal(
  start_anchor,
  end_anchor,
  style: "hv",
  ..styling
) = {
  assert(style in ("hv", "vh"), message: "Orthogonal connection style must be 'hv' or 'vh'.")

  let corner = if style == "hv" {
    (start_anchor, "|-", end_anchor)
  } else {
    (start_anchor, "-|", end_anchor)
  }

  cetz.draw.line(start_anchor, corner, end_anchor, ..styling)
}

#let nmos_transistor(
  position, name,
  label: none, label_pos: "D", label_anchor: "north-west",
  label_offset: (0.05, 0.05),
  label_size: 8pt,
  show_pin_labels: false, pin_label_size: 7pt,
  scale: 1.0, rotate: 0deg, width: 0.9, height: 1.2,
  gate_lead_factor: 0.3, bulk_lead_factor: 0.3, gate_pos_factor: 0.3,
  channel_pos_factor: 0.4, gate_v_extent_factor: 0.35, channel_v_extent_factor: 0.35,
  thick_factor: 2.0, arrow_scale: 0.8, arrow_fill: black,
  ..styling
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
    let drain_horiz = (width, center_y + channel_v_extent)
    let source_horiz = (width, center_y - channel_v_extent)

    cetz.draw.anchor("G", gate_term_rel)
    cetz.draw.anchor("D", drain_term_rel)
    cetz.draw.anchor("S", source_term_rel)
    cetz.draw.anchor("B", bulk_term_rel)
    cetz.draw.anchor("center", (width/2, height/2))
    cetz.draw.anchor("bulk_conn", bulk_conn_pt)
    cetz.draw.anchor("gate_conn", gate_conn_pt)
    cetz.draw.anchor("north", (width/2, height))
    cetz.draw.anchor("south", (width/2, 0))
    cetz.draw.anchor("east", (width, height/2))
    cetz.draw.anchor("west", (0, height/2))
    cetz.draw.anchor("north-east", (width, height))
    cetz.draw.anchor("south-west", (0, 0))
    cetz.draw.anchor("default", gate_term_rel)

    cetz.draw.line(channel_bottom, channel_top, ..styling, thickness: 0.6pt * thick_factor)
    cetz.draw.line(gate_line_bottom, gate_line_top, ..styling, thickness: 0.6pt * thick_factor)
    cetz.draw.line(gate_term_rel, gate_conn_pt, ..styling)
    cetz.draw.line(drain_term_rel, drain_horiz, ..styling)
    cetz.draw.line(drain_horiz, channel_top, ..styling)
    cetz.draw.line(source_horiz, source_term_rel, ..styling)
    cetz.draw.line(
      channel_bottom, source_horiz, ..styling,
      mark: (end: "stealth", fill: arrow_fill, scale: arrow_scale)
    )
    cetz.draw.line(bulk_conn_pt, bulk_term_rel, ..styling)

    if show_pin_labels {

      cetz.draw.content((rel: (-0.05, 0), to: "G"), text(size: pin_label_size, $G$), anchor: "east")
      cetz.draw.content((rel: (0, -0.05), to: "D"), text(size: pin_label_size, $D$), anchor: "north")
      cetz.draw.content((rel: (0, 0.05), to: "S"), text(size: pin_label_size, $S$), anchor: "south")
      cetz.draw.content((rel: (0.05, 0), to: "B"), text(size: pin_label_size, $B$), anchor: "west")
    }
    if label != none {
       cetz.draw.content(

         (rel: label_offset, to: label_pos),

         text(size: label_size, label),

         anchor: label_anchor
       )
    }
  })
}

#let pmos_transistor(
  position, name,
  label: none, label_pos: "S", label_anchor: "south-west",
  label_offset: (0.05, 0.05),
  label_size: 8pt,
  show_pin_labels: false, pin_label_size: 7pt,
  show_gate_bubble: true, bubble_radius_factor: 0.08,
  scale: 1.0, rotate: 0deg, width: 0.9, height: 1.2,
  gate_lead_factor: 0.3, bulk_lead_factor: 0.3, gate_pos_factor: 0.3,
  channel_pos_factor: 0.4, gate_v_extent_factor: 0.35, channel_v_extent_factor: 0.35,
  thick_factor: 2.0, arrow_scale: 0.8, arrow_fill: black,
  ..styling
) = {
  cetz.draw.group(name: name, {
    cetz.draw.set-origin(position)
    cetz.draw.scale(scale)
    cetz.draw.rotate(rotate)
    let center_y = height / 2
    let gate_line_x = gate_pos_factor * width
    let channel_line_x = channel_pos_factor * width
    let gate_v_extent = height * gate_v_extent_factor
    let channel_v_extent = height * channel_v_extent_factor
    let source_term_rel = (width, height)
    let drain_term_rel = (width, 0)
    let gate_term_rel = (-gate_lead_factor * width, center_y)
    let bulk_term_rel = (width + bulk_lead_factor * width, center_y)
    let gate_line_top = (gate_line_x, center_y + gate_v_extent)
    let gate_line_bottom = (gate_line_x, center_y - gate_v_extent)
    let gate_conn_pt = (gate_line_x, center_y)
    let channel_top = (channel_line_x, center_y + channel_v_extent)
    let channel_bottom = (channel_line_x, center_y - channel_v_extent)
    let bulk_conn_pt = (channel_line_x, center_y)
    let source_horiz = (width, center_y + channel_v_extent)
    let drain_horiz = (width, center_y - channel_v_extent)
    let bubble_radius = height * bubble_radius_factor

    cetz.draw.anchor("G", gate_term_rel)
    cetz.draw.anchor("S", source_term_rel)
    cetz.draw.anchor("D", drain_term_rel)
    cetz.draw.anchor("B", bulk_term_rel)
    cetz.draw.anchor("center", (width/2, height/2))
    cetz.draw.anchor("bulk_conn", bulk_conn_pt)
    cetz.draw.anchor("gate_conn", gate_conn_pt)
    cetz.draw.anchor("north", (width/2, height))
    cetz.draw.anchor("south", (width/2, 0))
    cetz.draw.anchor("east", (width, height/2))
    cetz.draw.anchor("west", (0, height/2))
    cetz.draw.anchor("north-east", (width, height))
    cetz.draw.anchor("south-east", (width, 0))
    cetz.draw.anchor("south-west", (0, 0))
    cetz.draw.anchor("default", gate_term_rel)

    cetz.draw.line(channel_bottom, channel_top, ..styling, thickness: 0.6pt * thick_factor)
    cetz.draw.line(gate_line_bottom, gate_line_top, ..styling, thickness: 0.6pt * thick_factor)
    cetz.draw.line(gate_term_rel, gate_conn_pt, ..styling)
    cetz.draw.line(drain_term_rel, drain_horiz, ..styling)
    cetz.draw.line(drain_horiz, channel_bottom, ..styling)
    cetz.draw.line(source_term_rel, source_horiz, ..styling)
    cetz.draw.line(
        source_horiz, channel_top, ..styling,
        mark: (end: "stealth", fill: arrow_fill, scale: arrow_scale)
    )
    cetz.draw.line(bulk_conn_pt, bulk_term_rel, ..styling)

    if show_gate_bubble {

        let bubble_center = (rel: (-bubble_radius, 0), to: gate_conn_pt)
        cetz.draw.circle(bubble_center, radius: bubble_radius, ..styling, fill: white)
    }

    if show_pin_labels {

      cetz.draw.content((rel: (-0.05, 0), to: "G"), text(size: pin_label_size, $G$), anchor: "east")
      cetz.draw.content((rel: (0.05, 0), to: "S"), text(size: pin_label_size, $S$), anchor: "west")
      cetz.draw.content((rel: (0.05, 0), to: "D"), text(size: pin_label_size, $D$), anchor: "west")
      cetz.draw.content((rel: (0.05, 0), to: "B"), text(size: pin_label_size, $B$), anchor: "west")
    }
    if label != none {
       cetz.draw.content(

         (rel: label_offset, to: label_pos),

         text(size: label_size, label),

         anchor: label_anchor
       )
    }
  })
}

#let gnd_symbol(
  position, name,
  label: none, label_pos: "north", label_anchor: "south",
  label_offset: (0, 0.1),
  label_size: 8pt,
  scale: 1.0, rotate: 0deg, lead_length: 0.3, bar_width: 0.5,
  bar_spacing: 0.05, bar_width_factors: (1.0, 0.7, 0.4),
  ..styling
) = {
  cetz.draw.group(name: name, {
    cetz.draw.set-origin(position)
    cetz.draw.scale(scale)
    cetz.draw.rotate(rotate)
    let lead_end_y = -lead_length
    let bar1_y = lead_end_y
    let bar2_y = lead_end_y - bar_spacing
    let bar3_y = lead_end_y - 2 * bar_spacing
    assert(bar_width_factors.len() == 3, message: "bar_width_factors must have 3 elements.")
    let bar1_half_w = bar_width * bar_width_factors.at(0) / 2
    let bar2_half_w = bar_width * bar_width_factors.at(1) / 2
    let bar3_half_w = bar_width * bar_width_factors.at(2) / 2
    let south_y = bar3_y

    cetz.draw.anchor("T", (0, 0))
    cetz.draw.anchor("north", (0, 0))
    cetz.draw.anchor("south", (0, south_y))
    cetz.draw.anchor("west", (-bar1_half_w, bar1_y))
    cetz.draw.anchor("east", (bar1_half_w, bar1_y))
    cetz.draw.anchor("center", (0, (bar1_y + bar3_y) / 2))
    cetz.draw.anchor("default", (0, 0))

    cetz.draw.line((0, 0), (0, lead_end_y), ..styling)
    cetz.draw.line((-bar1_half_w, bar1_y), (bar1_half_w, bar1_y), ..styling)
    cetz.draw.line((-bar2_half_w, bar2_y), (bar2_half_w, bar2_y), ..styling)
    cetz.draw.line((-bar3_half_w, bar3_y), (bar3_half_w, bar3_y), ..styling)

    if label != none {
      cetz.draw.content(

        (rel: label_offset, to: label_pos),

        text(size: label_size, label),

        anchor: label_anchor
      )
    }
  })
}

#let resistor(
  position, name,
  label: none, label_pos: "south", label_anchor: "north",
  label_offset: (0, -0.1),
  label_size: 8pt,
  scale: 1.0, rotate: 0deg,
  width: 0.8,
  height: 0.3,
  zigs: 3,
  lead_extension: 0.3,
  ..styling
) = {
  cetz.draw.group(name: name, {
    cetz.draw.set-origin(position)
    cetz.draw.scale(scale)
    cetz.draw.rotate(rotate)

    let half_width = width / 2
    let half_height = height / 2
    let lead_start_x = -half_width - lead_extension
    let lead_end_x = half_width + lead_extension
    let zig_start_x = -half_width
    let zig_end_x = half_width

    let num_segments = zigs * 2

    let segment_h_dist = width / num_segments

    let sgn = 1

    cetz.draw.line(
      (lead_start_x, 0),
      (zig_start_x, 0),

      (rel: (segment_h_dist / 2, half_height * sgn)),

      ..for _ in range(num_segments - 1) {
        sgn *= -1

        ((rel: (segment_h_dist, half_height * 2 * sgn)),)
      },

      (rel: (segment_h_dist / 2, half_height)),

      (lead_end_x, 0),
      ..styling
    )

    cetz.draw.anchor("L", (lead_start_x, 0))
    cetz.draw.anchor("R", (lead_end_x, 0))
    cetz.draw.anchor("center", (0, 0))
    cetz.draw.anchor("north", (0, half_height))
    cetz.draw.anchor("south", (0, -half_height))
    cetz.draw.anchor("east", (lead_end_x, 0))
    cetz.draw.anchor("west", (lead_start_x, 0))

    cetz.draw.anchor("T", (0, half_height))
    cetz.draw.anchor("B", (0, -half_height))
    cetz.draw.anchor("default", (lead_start_x, 0))

    if label != none {
      cetz.draw.content(

        (rel: label_offset, to: label_pos),

        text(size: label_size, label),

        anchor: label_anchor

      )
    }
  })
}

#let capacitor(
  position, name,
  label: none, label_pos: "south", label_anchor: "north",
  label_offset: (0, -0.1),
  label_size: 8pt,
  scale: 1.0, rotate: 0deg,
  plate_height: 0.6,
  plate_gap: 0.2,
  lead_extension: 0.5,
  ..styling
) = {
  cetz.draw.group(name: name, {
    cetz.draw.set-origin(position)
    cetz.draw.scale(scale)
    cetz.draw.rotate(rotate)

    let half_gap = plate_gap / 2
    let half_height = plate_height / 2
    let lead_start_x = -half_gap - lead_extension
    let lead_end_x = half_gap + lead_extension
    let plate_left_x = -half_gap
    let plate_right_x = half_gap

    cetz.draw.line( (lead_start_x, 0), (plate_left_x, 0), ..styling )
    cetz.draw.line( (plate_left_x, -half_height), (plate_left_x, half_height), ..styling )

    cetz.draw.line( (plate_right_x, half_height), (plate_right_x, -half_height), ..styling )
    cetz.draw.line( (plate_right_x, 0), (lead_end_x, 0), ..styling )

    cetz.draw.anchor("L", (lead_start_x, 0))
    cetz.draw.anchor("R", (lead_end_x, 0))
    cetz.draw.anchor("center", (0, 0))
    cetz.draw.anchor("north", (0, half_height))
    cetz.draw.anchor("south", (0, -half_height))
    cetz.draw.anchor("east", (lead_end_x, 0))
    cetz.draw.anchor("west", (lead_start_x, 0))

    cetz.draw.anchor("T", (0, half_height))
    cetz.draw.anchor("B", (0, -half_height))
    cetz.draw.anchor("default", (lead_start_x, 0))

    if label != none {
      cetz.draw.content(

        (rel: label_offset, to: label_pos),

        text(size: label_size, label),

        anchor: label_anchor

      )
    }
  })
}
#let voltage_source(
  position, name,

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

  scale: 1.0, rotate: 0deg,
  radius: 0.3,
  lead_length: 0.3,
  ..styling
) = {
  cetz.draw.group(name: name, {
    cetz.draw.set-origin(position)
    cetz.draw.scale(scale)
    cetz.draw.rotate(rotate)

    let circle_top_y = radius
    let circle_bottom_y = -radius
    let top_lead_end_y = circle_top_y + lead_length
    let bottom_lead_end_y = circle_bottom_y - lead_length

    cetz.draw.circle((0, 0), radius: radius, ..styling)

    cetz.draw.line((0, circle_top_y), (0, top_lead_end_y), ..styling)

    cetz.draw.line((0, circle_bottom_y), (0, bottom_lead_end_y), ..styling)

    if show_voltage_annotation {

      let arrow_x = if voltage_arrow_pos == "left" {
         -radius * (1 + voltage_arrow_offset_factor)
      } else {
         radius * (1 + voltage_arrow_offset_factor)
      }
      let arrow_len = radius * voltage_arrow_length_factor
      let arrow_half_len = arrow_len / 2

      let (arrow_start_y, arrow_end_y) = if voltage_arrow_dir == "down" {
        (arrow_half_len, -arrow_half_len)
      } else {
        (-arrow_half_len, arrow_half_len)
      }
      let arrow_start = (arrow_x, arrow_start_y)
      let arrow_end = (arrow_x, arrow_end_y)
      let arrow_mid_pt = (arrow_x, 0)

      cetz.draw.line(
        arrow_start, arrow_end,
        ..styling,
        mark: (
          end: "stealth",
          scale: arrow_scale * 0.4,
          fill: arrow_fill,
          stroke: (paint: black, thickness: stroke_thickness)
        )
      )

      if label != none {

        let (default_anchor, default_offset) = if annotation_label_pos == "left" {
           ("east", (-0.05, 0))
        } else {
           ("west", (0.05, 0))
        }

        let final_anchor = if annotation_label_anchor == auto { default_anchor } else { annotation_label_anchor }
        let final_offset = if annotation_label_offset == auto { default_offset } else { annotation_label_offset }

        cetz.draw.content(
          (rel:(0.1*scale*arrow_x/calc.abs(arrow_x),0),to:arrow_mid_pt),
          text(size: annotation_label_size, fill: arrow_fill, label),
          anchor: final_anchor,
          offset: final_offset
        )
      }
    }

    cetz.draw.anchor("T", (0, top_lead_end_y))
    cetz.draw.anchor("B", (0, bottom_lead_end_y))
    cetz.draw.anchor("center", (0, 0))
    cetz.draw.anchor("north", (0, top_lead_end_y))
    cetz.draw.anchor("south", (0, bottom_lead_end_y))
    cetz.draw.anchor("east", (radius, 0))
    cetz.draw.anchor("west", (-radius, 0))
  })
}

#let node(
  position,
  name,
  label:none,

  radius: 0.05,
  label_size: 8pt,

  label_offset: (0, 0),
  label_anchor: "center",
  fill: white,
  text_fill: black,
  scale: 1.0,
  rotate: 0deg,
  ..styling
) = {
  cetz.draw.group(name: name, ..styling, {

    cetz.draw.set-origin(position)
    cetz.draw.scale(scale)
    cetz.draw.rotate(rotate)

    cetz.draw.circle((0, 0), radius: radius, ..styling, fill: fill)

    if label != none {
        cetz.draw.content(
          (rel: label_offset, to: (0, 0)),
          text(size: label_size, fill: text_fill, label),
          anchor: label_anchor
        )
      }

    cetz.draw.anchor("center", (0, 0))
    cetz.draw.anchor("default", (0, 0))
    cetz.draw.anchor("north", (0, radius))
    cetz.draw.anchor("south", (0, -radius))
    cetz.draw.anchor("east", (radius, 0))
    cetz.draw.anchor("west", (-radius, 0))
    let diag_offset = radius * calc.cos(45deg)
    cetz.draw.anchor("north-east", (diag_offset, diag_offset))
    cetz.draw.anchor("north-west", (-diag_offset, diag_offset))
    cetz.draw.anchor("south-east", (diag_offset, -diag_offset))
    cetz.draw.anchor("south-west", (-diag_offset, -diag_offset))
  })
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
  ..styling
) = {
  cetz.draw.group(name: name, {

    cetz.draw.set-origin(position)
    cetz.draw.scale(scale)
    cetz.draw.rotate(rotate)

    let stem_top_y = stem_length
    let bar_half_width = bar_width / 2
    let bar_left_x = -bar_half_width
    let bar_right_x = bar_half_width

    cetz.draw.line((0, 0), (0, stem_top_y), ..styling)

    cetz.draw.line((bar_left_x, stem_top_y), (bar_right_x, stem_top_y), ..styling)

    cetz.draw.anchor("B", (0, 0))
    cetz.draw.anchor("south", (0, 0))
    cetz.draw.anchor("default", (0, 0))
    cetz.draw.anchor("T", (0, stem_top_y))
    cetz.draw.anchor("north", (0, stem_top_y))
    cetz.draw.anchor("TL", (bar_left_x, stem_top_y))
    cetz.draw.anchor("TR", (bar_right_x, stem_top_y))

    cetz.draw.anchor("west", (bar_left_x, stem_top_y))
    cetz.draw.anchor("east", (bar_right_x, stem_top_y))
    cetz.draw.anchor("center", (0, stem_top_y / 2))

    if label != none {
      cetz.draw.content(

        (rel: label_offset, to: label_pos),

        text(size: label_size, fill: text_fill, label),

        anchor: label_anchor
      )
    }
  })
}

#let current_source(
  position, name,
  label: none,
  label_pos: "west",
  label_anchor: "west",
  label_offset: (0.1, 0),
  label_size: 8pt,
  scale: 1.0, rotate: 0deg,
  radius: 0.3,
  lead_length: 0.3,
  arrow_dir: "up",
  arrow_scale: 1.0,
  arrow_fill: black,

  ..styling
) = {

  cetz.draw.group(name: name, ..styling, {
    cetz.draw.set-origin(position)
    cetz.draw.scale(scale)
    cetz.draw.rotate(rotate)

    let circle_top_y = radius
    let circle_bottom_y = -radius
    let top_lead_end_y = circle_top_y + lead_length
    let bottom_lead_end_y = circle_bottom_y - lead_length

    cetz.draw.circle((0, 0), radius: radius, ..styling)

    cetz.draw.line((0, circle_top_y), (0, top_lead_end_y), ..styling)
    cetz.draw.line((0, circle_bottom_y), (0, bottom_lead_end_y), ..styling)

    let arrow_v_extent = radius * 0.7
    assert(arrow_dir in ("up", "down"), message: "Arrow direction must be 'up' or 'down'.")
    let (arrow_start_y, arrow_end_y) = if arrow_dir == "up" {
      (-arrow_v_extent, arrow_v_extent)
    } else {
      (arrow_v_extent, -arrow_v_extent)
    }
    let arrow_start = (0, arrow_start_y)
    let arrow_end = (0, arrow_end_y)

    cetz.draw.line(
      arrow_start, arrow_end,
      ..styling,
      mark: (
        end: "stealth",
        scale: arrow_scale * 0.4,
        fill: arrow_fill,

      )
    )

    cetz.draw.anchor("T", (0, top_lead_end_y))
    cetz.draw.anchor("B", (0, bottom_lead_end_y))
    cetz.draw.anchor("center", (0, 0))
    cetz.draw.anchor("north", (0, top_lead_end_y))
    cetz.draw.anchor("south", (0, bottom_lead_end_y))
    cetz.draw.anchor("east", (radius, 0))
    cetz.draw.anchor("west", (-radius, 0))
    cetz.draw.anchor("default", (0, top_lead_end_y))

    if label != none {
      cetz.draw.content(
        (rel: label_offset, to: label_pos),
        text(size: label_size, label),
        anchor: label_anchor
      )
    }
  })
}

#let voltage_points(
  position, name,

  label: none,
  annotation_label_pos: "left",
  annotation_label_anchor: auto,
  annotation_label_offset: auto,
  annotation_label_size: 8pt,
  annotation_text_fill: black,

  show_voltage_annotation: true,
  voltage_arrow_pos: "left",
  voltage_arrow_dir: "down",
  arrow_length_factor: 1.0,
  arrow_offset: 0.3,
  arrow_scale: 1.0,
  arrow_fill: black,
  arrow_stroke: black,
  arrow_stroke_thickness: 0.6pt,

  point_separation: 0.6,
  point_radius: 0.05,
  point_fill: black,
  point_stroke: none,

  show_point_labels: false,
  top_label: $[+]$,
  bottom_label: $[-]$,
  point_label_size: 7pt,
  point_text_fill: black,
  top_label_offset: (0, 0.05),
  top_label_anchor: "south",
  bottom_label_offset: (0, -0.05),
  bottom_label_anchor: "north",

  scale: 1.0, rotate: 0deg,
  ..styling
) = {
  cetz.draw.group(name: name, {
    cetz.draw.set-origin(position)
    cetz.draw.scale(scale)
    cetz.draw.rotate(rotate)

    let half_sep = point_separation / 2
    let top_pos = (0, half_sep)
    let bottom_pos = (0, -half_sep)

    cetz.draw.circle(top_pos, radius: point_radius, fill: point_fill, stroke: point_stroke, ..styling)
    cetz.draw.circle(bottom_pos, radius: point_radius, fill: point_fill, stroke: point_stroke, ..styling)

    cetz.draw.anchor("T", top_pos)
    cetz.draw.anchor("B", bottom_pos)
    cetz.draw.anchor("center", (0, 0))
    cetz.draw.anchor("north", top_pos)
    cetz.draw.anchor("south", bottom_pos)

    cetz.draw.anchor("east", (point_radius, 0))
    cetz.draw.anchor("west", (-point_radius, 0))
    cetz.draw.anchor("default", top_pos)

    if show_voltage_annotation {
      let arrow_x = if voltage_arrow_pos == "left" {
         -arrow_offset
      } else {
         arrow_offset
      }
      let arrow_len = point_separation * arrow_length_factor
      let arrow_half_len = arrow_len / 2

      let (arrow_start_y, arrow_end_y) = if voltage_arrow_dir == "down" {
        (arrow_half_len, -arrow_half_len)
      } else {
        (-arrow_half_len, arrow_half_len)
      }
      let arrow_start = (arrow_x, arrow_start_y)
      let arrow_end = (arrow_x, arrow_end_y)
      let arrow_mid_pt = (arrow_x, 0)

      cetz.draw.line(
        arrow_start, arrow_end,
        stroke: (paint: arrow_stroke, thickness: arrow_stroke_thickness),
        ..styling,
        mark: (
          end: "stealth",
          scale: arrow_scale * 0.4,
          fill: arrow_fill,
          stroke: (paint: arrow_stroke, thickness: arrow_stroke_thickness)
        )
      )

      if label != none {
        let (default_anchor, default_offset) = if annotation_label_pos == "left" {
           ("east", (-0.05, 0))
        } else {
           ("west", (0.05, 0))
        }

        let final_anchor = if annotation_label_anchor == auto { default_anchor } else { annotation_label_anchor }
        let final_offset = if annotation_label_offset == auto { default_offset } else { annotation_label_offset }

        let arrow_dir_sgn = if voltage_arrow_dir == "down" { 1 } else { -1 }
        let adjusted_offset = (final_offset.at(0), final_offset.at(1) )

        cetz.draw.content(
          arrow_mid_pt,
          text(size: annotation_label_size, fill: annotation_text_fill, label),
          anchor: final_anchor,
          offset: adjusted_offset
        )
      }
    }

    if show_point_labels {
       cetz.draw.content(
         (rel: top_label_offset, to: "T"),
         text(size: point_label_size, fill: point_text_fill, top_label),
         anchor: top_label_anchor
       )
       cetz.draw.content(
         (rel: bottom_label_offset, to: "B"),
         text(size: point_label_size, fill: point_text_fill, bottom_label),
         anchor: bottom_label_anchor
       )
    }
  })
}

#let wire_hop(
  wire1_start, wire1_end,
  wire2_start, wire2_end,
  hopping_wire: 1,
  hop_radius: 0.15,
  hop_direction: 1,
  ..styling
) = {

  assert(hopping_wire in (1, 2), message: "hopping_wire must be 1 or 2.")
  assert(hop_direction in (1, -1), message: "hop_direction must be 1 or -1.")

  let intersection = cetz.intersection.line-line(
     wire1_start, wire1_end,
     wire2_start, wire2_end
  )
  assert(intersection != none, message: "Wires do not intersect, cannot hop.")

  let (straight_start, straight_end, hopping_start, hopping_end) = if hopping_wire == 1 {
    (wire2_start, wire2_end, wire1_start, wire1_end)
  } else {
    (wire1_start, wire1_end, wire2_start, wire2_end)
  }

  cetz.draw.line(straight_start, straight_end, ..styling)

  let hop_vec = cetz.vector.sub(hopping_end, hopping_start)
  let wire_angle = calc.atan2(..hop_vec)

  let hop_unit_vec = cetz.vector.norm(hop_vec)
  assert(hop_unit_vec != none, message: "Cannot get unit vector for zero-length hopping wire.")

  let offset_vec_neg = cetz.vector.scale(hop_unit_vec, -hop_radius)
  let offset_vec_pos = cetz.vector.scale(hop_unit_vec,  hop_radius)

  let arc_start_point = (rel: offset_vec_neg, to: intersection)
  let arc_end_point   = (rel: offset_vec_pos, to: intersection)

  let arc_start_angle = wire_angle
  let arc_stop_angle = wire_angle + (180deg *hop_direction)

  cetz.draw.line(hopping_start, arc_start_point, ..styling)

  cetz.draw.arc(
    (rel:cetz.vector.scale((calc.cos(arc_start_angle),calc.sin(arc_start_angle)),hop_radius*2),to:arc_start_point),
    start: arc_start_angle,
    stop: arc_stop_angle,
    radius: hop_radius,
    ..styling
  )

  cetz.draw.line(arc_end_point, hopping_end, ..styling)

}
#cetz.canvas({
   let default_stroke = (stroke: (thickness:.6pt))

  let x_vin = 0
  let x_r1 = 1.
  let x_m1 = 1.9
  let x_out_comps = x_m1 + 0.9
  let x_cl = x_out_comps + 2.0
  let x_vout = x_cl + 1.0

  let y_gate = 1.6
  let y_m1_base = 1.0
  let y_m1_s = y_m1_base
  let y_m1_d = y_m1_base + 1.2
  let y_m1_b = y_m1_base + 0.6
  let y_vdd = y_m1_d + 1.5
  let y_gnd = -1
  let y_cl_center = y_m1_s - 0.95

  voltage_source((x_vin, y_gate -1), "Vin",
    label: $V_"in"$,
    voltage_arrow_pos: "left",
    voltage_arrow_dir: "down",
    annotation_label_pos: "left",
    radius: 0.4,
    lead_length: 0.2,
    ..default_stroke
  )

  resistor((x_r1, y_gate ), "R1", label: $R_1$, label_pos: "north", label_offset: (0, 0.4), width: 1.0, ..default_stroke)

  nmos_transistor((x_m1, y_m1_base), "M1", label: $M_1$, label_pos: "east", label_anchor: "west", label_offset: (0.3, 0.3),..default_stroke)

  vdd_symbol((x_out_comps, y_vdd), "Vdd", label: $V_"DD"$, ..default_stroke)

  resistor((x_out_comps, y_m1_s -1), "R2", rotate: 90deg, label: $R_2$, label_pos: "west", label_offset: (0.5, 0.5), ..default_stroke)

  capacitor((x_cl, y_cl_center), "CL", rotate: 90deg, label: $C_L$, label_pos: "east", label_offset: (-0.2, -0.5), ..default_stroke)

  gnd_symbol((x_vin, y_gnd), "GND_Vin", ..default_stroke)
  gnd_symbol((x_m1 + 1.27, y_m1_b), "GND_M1B", ..default_stroke)
  gnd_symbol((x_out_comps, y_gnd), "GND_R2", ..default_stroke)
  gnd_symbol((x_cl, y_gnd), "GND_CL", ..default_stroke)

  node((x_vout, y_m1_b), "VoutNode", label:$V_"out"$,  label_offset: (0.15, 0), label_anchor: "west", ..default_stroke)

  connect-orthogonal("Vin.T", "R1.L", style: "hv", ..default_stroke)
  connect-orthogonal("Vin.B", "GND_Vin.T", style: "hv", ..default_stroke)
  connect-orthogonal("R1.R", "M1.G", style: "hv", ..default_stroke)
  connect-orthogonal("M1.D", "Vdd.B", style: "hv", ..default_stroke)
  connect-orthogonal("M1.B", "GND_M1B.T", style: "hv", ..default_stroke)
  connect-orthogonal("M1.S", "R2.R", style: "hv", ..default_stroke)
   connect-orthogonal("GND_R2.T", "R2.L", style: "hv", ..default_stroke)
   connect-orthogonal("GND_CL.T", "CL.L", style: "hv", ..default_stroke)
  connect-orthogonal("CL.R", "M1.S", style: "hv", ..default_stroke)
  connect-orthogonal("VoutNode", "M1.S", style: "hv", ..default_stroke)
})
