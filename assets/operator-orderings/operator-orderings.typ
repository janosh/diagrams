#import "@preview/cetz:0.4.2": canvas, decorations, draw
#import draw: circle, content, line

#set page(width: auto, height: auto, margin: 4pt, fill: none)
#set text(size: 10pt, fill: black)

#let pt_cm = 0.03528
#let mm_cm = 0.1

// Match original TikZ geometry and label distances.
#let line_len = 8.0
#let col_sep = 2.1 // increased gap between left and right groups
#let row_sep = 1.8
#let x_anchor = (0.0, 3.0, 5.0, 8.0) // -infty, 0, 1, infty
#let brace_spans = ((0.0, 3.0), (3.0, 5.0), (5.0, 8.0))

#let dot_radius = 0.1 // 1mm
#let line_thickness = 0.8pt
#let brace_raise = 5.0 * pt_cm
#let brace_amplitude = 5.0 * pt_cm
#let left_label_offset = 2.0 * mm_cm
#let right_label_offset = 4.0 * mm_cm
#let below_label_offset = 2.2 * mm_cm
#let above_label_offset = 12.0 * pt_cm
#let brace_label_offset = 8.0 * pt_cm
#let brace_style = (
  stroke: (thickness: line_thickness, paint: black),
  fill: none,
  amplitude: brace_amplitude,
  flip: false,
)
#let tick_labels = ($-infinity$, $0$, $1$, $infinity$)
#let interior_anchor = (x_anchor.at(1), x_anchor.at(2), x_anchor.at(3))

// Draw one real number line with dots and labels
#let real-line(ox, oy, above_labels, ordering_num, name_prefix) = {
  // Main line
  line((ox, oy), (ox + line_len, oy), stroke: line_thickness, name: name_prefix + "-line")
  content((ox - left_label_offset, oy), str(ordering_num) + ".", anchor: "east", name: name_prefix + "-num")
  content((ox + line_len + right_label_offset, oy), [$bb(R)$], anchor: "west", name: name_prefix + "-R")

  // Dots at x anchors with labels below.
  for (idx, dx) in x_anchor.enumerate() {
    let below_label = tick_labels.at(idx)
    circle((ox + dx, oy), radius: dot_radius, fill: black, name: name_prefix + "-dot-" + str(idx))
    content((ox + dx, oy - below_label_offset), below_label, anchor: "north", name: name_prefix + "-below-" + str(idx))
  }

  // Labels above interior positions (3, 5, 8)
  for (idx, label) in above_labels.enumerate() {
    let dx = interior_anchor.at(idx)
    content((ox + dx, oy + above_label_offset), label, anchor: "south", name: name_prefix + "-above-" + str(idx))
  }
}

#let draw_brace_label(ox, oy, span_idx, name_prefix) = {
  let span = brace_spans.at(span_idx)
  let start_x = ox + span.at(0)
  let end_x = ox + span.at(1)
  let brace_y = oy + brace_raise
  decorations.flat-brace((start_x, brace_y), (end_x, brace_y), ..brace_style)
  content(
    ((start_x + end_x) / 2, brace_y + brace_label_offset),
    $y_4$,
    anchor: "south",
    name: name_prefix + "-brace-label",
  )
}

#canvas(length: 1cm, {
  let col_2 = line_len + col_sep
  let rows = (0, -row_sep, -2 * row_sep)
  for (row_idx, row_y) in rows.enumerate() {
    let span_idx = row_idx
    let left_num = 2 * row_idx + 1
    let right_num = left_num + 1
    let left_name = "A" + str(left_num)
    let right_name = "A" + str(right_num)
    real-line(0, row_y, ($y_1$, $y_2$, $y_3$), left_num, left_name)
    draw_brace_label(0, row_y, span_idx, left_name)
    real-line(col_2, row_y, ($y_2$, $y_1$, $y_3$), right_num, right_name)
    draw_brace_label(col_2, row_y, span_idx, right_name)
  }
})
