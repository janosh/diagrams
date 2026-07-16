#import "@preview/cetz:0.5.2": canvas, draw
#import draw: bezier, circle, content, line, rect

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#canvas({
  let arrow_style = (mark: (end: "stealth", fill: black, scale: 0.5))
  let plot_size = 18
  let plot_height = 8
  let title_height = plot_height + 1.5

  let struct_width = 2.4
  let vert_spacing = 1.4
  let step_width = 3.5
  let step_padding = 0.3
  let step_spacing = 1.0
  let y_offset = 0.4

  let step1_x = step_width / 2 + 0.5
  let step2_x = step1_x + step_width + step_spacing
  let step3_x = step2_x + step_width + step_spacing
  let step4_x = step3_x + step_width + step_spacing

  let structure_colors = (
    rgb("#8bc6f6"), // blue
    rgb("#48BB78"), // green
    rgb("#ED8936"), // orange
    rgb("#cdbfea"), // purple
    rgb("#F56565"), // red
    rgb("#ED64A6"), // pink
    rgb("#ECC94B"), // yellow
    rgb("#81E6D9"), // teal
    rgb("#9F7AEA"), // purple 2
  )

  // solid arrow for a structure continuing into the next step
  let continuing(from, to, color, name) = bezier(
    from,
    to,
    (rel: (0.5, 0), to: from),
    (rel: (-0.5, 0), to: to),
    stroke: color + 0.8pt,
    mark: (end: "stealth", fill: color, scale: 0.6),
    name: name,
  )

  // dotted arrow for allocation from / convergence to a pool
  let dotted_arrow(from, to, ctrl_from, ctrl_to, color, mark_pos, name) = bezier(
    from,
    to,
    (rel: ctrl_from, to: from),
    (rel: ctrl_to, to: to),
    stroke: (dash: "dotted", paint: color),
    mark: (pos: mark_pos, end: "stealth", fill: color, scale: 0.6, shorten-to: none),
    name: name,
  )

  content(
    (plot_size / 2, title_height),
    text(weight: "bold", size: 14pt)[Concurrent MLIP Structure Relaxations with In-Flight Auto-Batching],
    name: "title",
  )

  let pool_label(pos, label, fill, name, padding) = content(
    pos,
    text(size: 14pt)[#label],
    frame: "rect",
    padding: padding,
    stroke: none,
    fill: fill,
    name: name,
  )
  pool_label((plot_size / 3 - 1, title_height - 1.2), [Initial Structure Pool], rgb(230, 255, 230), "initial-pool", (7pt, 9pt, 8pt))
  pool_label((2 * plot_size / 3 + 1, title_height - 1.2), [Converged Structure Pool], rgb(255, 230, 230), "relaxed-pool", (7pt, 9pt, 4pt))

  line((0, 0), (plot_size, 0), ..arrow_style, name: "x-axis")
  line((0, 0), (0, plot_height), ..arrow_style, name: "y-axis")
  content((rel: (-.4, 0), to: "y-axis.mid"), [#align(horizon, rotate(-90deg, [Memory Usage]))], name: "y-label")

  line((0, 7), (plot_size, 7), stroke: (dash: "dotted", thickness: 1pt), name: "memory-limit")
  content(
    (rel: (0.2, -0.1), to: "memory-limit.start"),
    text(size: 9pt)[Maximum memory threshold\ (based on GPU capacity)],
    anchor: "north-west",
  )

  let draw_structure(x_pos, y_pos, color, label, atom_count, name_suffix: "", converged: false) = {
    rect(
      (x_pos - struct_width / 2, y_pos - 0.4),
      (x_pos + struct_width / 2, y_pos + 0.4),
      fill: color,
      stroke: 0.5pt,
      radius: 0.2, // max 0.2 due to CeTZ 0.5.0 border anchor bug with rounded rects
      name: "struct-" + label + name_suffix,
    )
    content(("struct-" + label + name_suffix), [Structure #label])
    if atom_count != none {
      content((rel: (0, -0.5), to: "struct-" + label + name_suffix), text(size: 8pt)[#atom_count atoms], anchor: "north")
    }
    if converged {
      content(
        (rel: (0.1, 0), to: "struct-" + label + name_suffix + ".east"),
        text(size: 12pt, fill: rgb("#38A169"))[✓],
        anchor: "west",
      )
    }
  }

  let calc_height(structure_count) = structure_count * vert_spacing + step_padding

  // memory-usage region + atom total + step label per batch
  let batches = (
    (step1_x, 3, "150"),
    (step2_x, 4, "160"),
    (step3_x, 3, "145"),
    (step4_x, 4, "170"),
  )
  for (idx, (x, count, total)) in batches.enumerate() {
    let bname = "batch" + str(idx + 1)
    rect(
      (x - step_width / 2, y_offset),
      (x + step_width / 2, calc_height(count) + y_offset),
      fill: rgb(240, 240, 240),
      stroke: none,
      radius: 0.5,
      name: bname,
    )
    content((rel: (0, 0.1), to: bname + ".north"), text(size: 8pt)[#total atoms total], anchor: "south")
    content((rel: (0, -0.7), to: bname + ".south"), [*Step #(idx + 1)*], name: "step" + str(idx + 1) + "-label")
  }

  let base_y = y_offset + 0.8

  // (step_x, row, color_idx, label, atoms, name_suffix, converged)
  let structures = (
    (step1_x, 0, 0, "1", 50, "", true),
    (step1_x, 1, 1, "2", 45, "", false),
    (step1_x, 2, 2, "3", 55, "", false),
    (step2_x, 0, 3, "4", 40, "", true),
    (step2_x, 1, 1, "2", 45, "-2", true),
    (step2_x, 2, 2, "3", 55, "-2", false),
    (step2_x, 3, 4, "5", 20, "", true),
    (step3_x, 0, 2, "3", 50, "-3", true),
    (step3_x, 1, 5, "6", 60, "", false),
    (step3_x, 2, 6, "7", 35, "", false),
    (step4_x, 0, 5, "6", 60, "-2", false),
    (step4_x, 1, 6, "7", 35, "-2", true),
    (step4_x, 2, 7, "8", 45, "", false),
    (step4_x, 3, 8, "9", 30, "", false),
  )
  for (sx, row, color_idx, label, atoms, suffix, converged) in structures {
    draw_structure(
      sx, base_y + row * vert_spacing, structure_colors.at(color_idx), label, atoms,
      name_suffix: suffix, converged: converged,
    )
  }

  // continuation dots after step 4
  for y_pos in (base_y, base_y + vert_spacing, base_y + 2 * vert_spacing, base_y + 3 * vert_spacing) {
    for x_pos in range(3) {
      circle((step4_x + 0.65 * step_width + x_pos * 0.25, y_pos), radius: 0.1, stroke: 0.2pt, fill: rgb("#CBD5E0"))
    }
  }

  // === Transition arrows ===
  for (from, to, color_idx, name) in (
    ("struct-2.east", "struct-2-2.west", 1, "s2-continuing"),
    ("struct-3.east", "struct-3-2.west", 2, "s3-continuing"),
    ("struct-3-2.east", "struct-3-3.west", 2, "s3-continuing-2"),
    ("struct-6.east", "struct-6-2.west", 5, "s6-continuing"),
    ("struct-7.east", "struct-7-2.west", 6, "s7-continuing"),
  ) {
    continuing(from, to, structure_colors.at(color_idx), name)
  }

  for (from, to, ctrl_from, ctrl_to, color, mark_pos, name) in (
    ("struct-1.north-east", "relaxed-pool.south", (0, 0.5), (-0.25, -0.5), structure_colors.at(0), 30%, "s1-converged"),
    ("struct-2-2.north-east", "relaxed-pool.south", (0, 0.5), (0, -0.5), structure_colors.at(1), 50%, "s2-converged"),
    ("struct-4.north-east", "relaxed-pool.south", (0, 0.5), (0.25, -0.5), structure_colors.at(3), 50%, "s4-converged"),
    ("struct-5.north-east", "relaxed-pool.south", (0, 0.5), (0.5, -0.5), structure_colors.at(4), 50%, "s5-converged"),
    ("struct-3-3.north-east", "relaxed-pool.south", (0, 0.5), (0.25, -5), structure_colors.at(2), 50%, "s3-converged"),
    ("struct-7-2.north-east", "relaxed-pool.south", (0, 0.5), (0.75, -0.5), structure_colors.at(6), 25%, "s7-2-converged"),
    ("initial-pool.south", "struct-4.north-west", (-0.5, -5), (0, 0.5), rgb("#9F7AEA"), 50%, "s4-new"),
    ("initial-pool.south", "struct-5.north-east", (0.15, -0.5), (0, 0.5), rgb("#F56565"), 50%, "s5-new"),
    ("initial-pool.south", "struct-6.north-west", (-0.15, -0.5), (0, 0.5), rgb("#ED64A6"), 20%, "s6-new"),
    ("initial-pool.south", "struct-7.north-west", (-0.3, -0.5), (0, 0.5), rgb("#ECC94B"), 20%, "s7-new"),
    ("initial-pool.south", "struct-8.north-west", (-0.4, -0.5), (0, 0.5), rgb("#81E6D9"), 50%, "s8-new"),
    ("initial-pool.south", "struct-9.north-west", (-0.25, -0.5), (0, 0.5), rgb("#9F7AEA"), 50%, "s9-new"),
  ) {
    dotted_arrow(from, to, ctrl_from, ctrl_to, color, mark_pos, name)
  }
})
