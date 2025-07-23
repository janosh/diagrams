#import "@preview/cetz:0.4.1": canvas, draw
#import draw: bezier, circle, content, line, rect

#set page(width: auto, height: auto, margin: 8pt)

#canvas({
  // Define styles and constants
  let arrow_style = (mark: (end: "stealth", fill: black, scale: 0.5))
  let plot_size = 18 // Width of the plot (increased from 14 to 18 to accommodate fourth step)
  let plot_height = 8 // Height of the plot
  let title_height = plot_height + 1.5

  // Define standard structure dimensions
  let struct_width = 2.4 // Standard width for all structures
  let vert_spacing = 1.4 // Standard vertical spacing between structures

  // Define step rectangle dimensions
  let step_width = 3.5 // Standard width for all step rectangles
  let step_padding = 0.3 // Additional vertical padding for step rectangles
  let step_spacing = 1.0 // Horizontal spacing between step rectangles
  let y_offset = 0.4 // Vertical offset from x-axis

  // Calculate step positions
  let step1_x = step_width / 2 + 0.5
  let step2_x = step1_x + step_width + step_spacing
  let step3_x = step2_x + step_width + step_spacing
  let step4_x = step3_x + step_width + step_spacing

  // Structure colors
  let structure_colors = (
    rgb("#8bc6f6"), // Blue
    rgb("#48BB78"), // Green
    rgb("#ED8936"), // Orange
    rgb("#cdbfea"), // Purple
    rgb("#F56565"), // Red
    rgb("#ED64A6"), // Pink
    rgb("#ECC94B"), // Yellow
    rgb("#81E6D9"), // Teal
    rgb("#9F7AEA"), // Purple 2
  )

  // Add title
  content(
    (plot_size / 2, title_height),
    text(weight: "bold", size: 14pt)[Concurrent MLIP Structure Relaxations with In-Flight Auto-Batching],
    name: "title",
  )

  // Add initial structure pool below title (left side)
  content(
    (plot_size / 3 - 1, title_height - 1.2),
    text(size: 14pt)[Initial Structure Pool],
    frame: "rect",
    padding: (7pt, 9pt, 8pt),
    stroke: none,
    fill: rgb(230, 255, 230), // Light green for initial structures
    name: "initial-pool",
  )

  // Add relaxed structure pool below title (right side)
  content(
    (2 * plot_size / 3 + 1, title_height - 1.2),
    text(size: 14pt)[Converged Structure Pool],
    frame: "rect",
    padding: (7pt, 9pt, 4pt),
    stroke: none,
    fill: rgb(255, 230, 230), // Light red for relaxed structures
    name: "relaxed-pool",
  )

  // Draw horizontal arrow for batch dimension
  line(
    (0, 0),
    (plot_size, 0),
    ..arrow_style,
    name: "x-axis",
  )

  // Draw vertical axis for MLIP batch relaxation
  line(
    (0, 0),
    (0, plot_height),
    ..arrow_style,
    name: "y-axis",
  )
  content(
    (rel: (-.4, 0), to: "y-axis.mid"),
    [#align(horizon, rotate(-90deg, [Memory Usage]))],
    name: "y-label",
  )

  // Draw memory limit line
  line(
    (0, 7),
    (plot_size, 7),
    stroke: (dash: "dotted", thickness: 1pt),
    name: "memory-limit",
  )
  content(
    (rel: (0.2, -0.1), to: "memory-limit.start"),
    text(size: 9pt)[Maximum memory threshold\ (based on GPU capacity)],
    anchor: "north-west",
  )

  // Helper to draw a structure box
  let draw_structure(x_pos, y_pos, color, label, atom_count, name_suffix: "", converged: false) = {
    rect(
      (x_pos - struct_width / 2, y_pos - 0.4),
      (x_pos + struct_width / 2, y_pos + 0.4),
      fill: color,
      stroke: 0.5pt,
      radius: 0.3,
      name: "struct-" + label + name_suffix,
    )
    content(("struct-" + label + name_suffix), [Structure #label])

    // Add atom count if provided
    if atom_count != none {
      content(
        (rel: (0, -0.5), to: "struct-" + label + name_suffix),
        text(size: 8pt)[#atom_count atoms],
        anchor: "north",
      )
    }

    // Add checkmark for converged structures
    if converged {
      content(
        (rel: (0.1, 0), to: "struct-" + label + name_suffix + ".east"),
        text(size: 12pt, fill: rgb("#38A169"))[✓],
        anchor: "west",
      )
    }
  }

  // Define structure counts for each step
  let step1_count = 3
  let step2_count = 4
  let step3_count = 3
  let step4_count = 4

  // Calculate heights for memory regions based on structure count
  let calc_height(structure_count) = {
    return structure_count * vert_spacing + step_padding
  }

  // Draw memory usage regions with dynamic heights and standardized widths
  rect(
    (step1_x - step_width / 2, y_offset),
    (step1_x + step_width / 2, calc_height(step1_count) + y_offset),
    fill: rgb(240, 240, 240),
    stroke: none,
    radius: 0.5,
    name: "batch1",
  )
  content((rel: (0, 0.1), to: "batch1.north"), text(size: 8pt)[150 atoms total], anchor: "south")

  rect(
    (step2_x - step_width / 2, y_offset),
    (step2_x + step_width / 2, calc_height(step2_count) + y_offset),
    fill: rgb(240, 240, 240),
    stroke: none,
    radius: 0.5,
    name: "batch2",
  )
  content((rel: (0, 0.1), to: "batch2.north"), text(size: 8pt)[160 atoms total], anchor: "south")

  rect(
    (step3_x - step_width / 2, y_offset),
    (step3_x + step_width / 2, calc_height(step3_count) + y_offset),
    fill: rgb(240, 240, 240),
    stroke: none,
    radius: 0.5,
    name: "batch3",
  )
  content((rel: (0, 0.1), to: "batch3.north"), text(size: 8pt)[145 atoms total], anchor: "south")

  rect(
    (step4_x - step_width / 2, y_offset),
    (step4_x + step_width / 2, calc_height(step4_count) + y_offset),
    fill: rgb(240, 240, 240),
    stroke: none,
    radius: 0.5,
    name: "batch4",
  )
  content((rel: (0, 0.1), to: "batch4.north"), text(size: 8pt)[170 atoms total], anchor: "south")

  // Base y-position for all structures
  let base_y = y_offset + 0.8

  // Step 1: Initial batch (3 structures of different sizes)
  draw_structure(step1_x, base_y, structure_colors.at(0), "1", 50, converged: true)
  draw_structure(step1_x, base_y + vert_spacing, structure_colors.at(1), "2", 45)
  draw_structure(step1_x, base_y + 2 * vert_spacing, structure_colors.at(2), "3", 55)

  // Add step label
  content(
    (rel: (0, -0.7), to: "batch1.south"),
    [*Step 1*],
    name: "step1-label",
  )

  // Step 2: Structure 1 converged, replaced by 4, added structure 5 (smaller)
  draw_structure(step2_x, base_y, structure_colors.at(3), "4", 40, converged: true)
  draw_structure(step2_x, base_y + vert_spacing, structure_colors.at(1), "2", 45, name_suffix: "-2", converged: true)
  draw_structure(step2_x, base_y + 2 * vert_spacing, structure_colors.at(2), "3", 55, name_suffix: "-2")
  draw_structure(
    step2_x,
    base_y + 3 * vert_spacing,
    structure_colors.at(4),
    "5",
    20,
    converged: true,
  ) // Smaller structure fits in the batch

  // Add step label
  content(
    (rel: (0, -0.7), to: "batch2.south"),
    [*Step 2*],
    name: "step2-label",
  )

  // Step 3: Structures 2, 4, 5 converged, only 3 continues with new structures
  draw_structure(step3_x, base_y, structure_colors.at(2), "3", 50, name_suffix: "-3", converged: true)
  draw_structure(step3_x, base_y + vert_spacing, structure_colors.at(5), "6", 60)
  draw_structure(step3_x, base_y + 2 * vert_spacing, structure_colors.at(6), "7", 35)

  // Add step label
  content(
    (rel: (0, -0.7), to: "batch3.south"),
    [*Step 3*],
    name: "step3-label",
  )

  // Step 4: Structure 3 converged, 6 and 7 continue, added 8 and 9 to maximize memory usage
  draw_structure(step4_x, base_y, structure_colors.at(5), "6", 60, name_suffix: "-2")
  draw_structure(step4_x, base_y + vert_spacing, structure_colors.at(6), "7", 35, name_suffix: "-2", converged: true)
  draw_structure(step4_x, base_y + 2 * vert_spacing, structure_colors.at(7), "8", 45)
  draw_structure(step4_x, base_y + 3 * vert_spacing, structure_colors.at(8), "9", 30)

  // Add step label
  content(
    (rel: (0, -0.7), to: "batch4.south"),
    [*Step 4*],
    name: "step4-label",
  )

  // Add dots to indicate continuation at the end of step 4
  for y_pos in (base_y, base_y + vert_spacing, base_y + 2 * vert_spacing, base_y + 3 * vert_spacing) {
    for x_pos in range(3) {
      circle((step4_x + 0.65 * step_width + x_pos * 0.25, y_pos), radius: 0.1, stroke: 0.2pt, fill: rgb("#CBD5E0"))
    }
  }

  // Draw curved transition arrows between steps
  // Step 1 to Step 2
  let transition_style = (stroke: rgb("#718096") + 0.8pt, mark: (end: "stealth", fill: rgb("#718096"), scale: 0.6))

  // Structure 2 continuing
  bezier(
    (rel: (0, 0), to: "struct-2.east"),
    (rel: (0, 0), to: "struct-2-2.west"),
    (rel: (0.5, 0), to: "struct-2.east"),
    (rel: (-0.5, 0), to: "struct-2-2.west"),
    stroke: structure_colors.at(1) + 0.8pt,
    mark: (end: "stealth", fill: structure_colors.at(1), scale: 0.6),
    name: "s2-continuing",
  )

  // Structure 3 continuing
  bezier(
    (rel: (0, 0), to: "struct-3.east"),
    (rel: (0, 0), to: "struct-3-2.west"),
    (rel: (0.5, 0), to: "struct-3.east"),
    (rel: (-0.5, 0), to: "struct-3-2.west"),
    stroke: structure_colors.at(2) + 0.8pt,
    mark: (end: "stealth", fill: structure_colors.at(2), scale: 0.6),
    name: "s3-continuing",
  )

  // Structure 1 converged - to relaxed pool (blue structure)
  bezier(
    (rel: (0, 0), to: "struct-1.north-east"),
    (rel: (0, 0), to: "relaxed-pool.south"),
    (rel: (0, 0.5), to: "struct-1.north-east"),
    (rel: (-0.25, -0.5), to: "relaxed-pool.south"),
    stroke: (dash: "dotted", paint: structure_colors.at(0)),
    mark: (pos: 30%, end: "stealth", fill: structure_colors.at(0), scale: 0.6, shorten-to: none),
    name: "s1-converged",
  )

  // New structure 4 allocated from initial pool
  bezier(
    (rel: (0, 0), to: "initial-pool.south"),
    (rel: (0, 0), to: "struct-4.north-west"),
    (rel: (-0.5, -5), to: "initial-pool.south"),
    (rel: (0, 0.5), to: "struct-4.north-west"),
    stroke: (dash: "dotted", paint: rgb("#9F7AEA")),
    mark: (pos: 50%, end: "stealth", fill: rgb("#9F7AEA"), scale: 0.6, shorten-to: none),
    name: "s4-new",
  )

  // New structure 5 allocated from initial pool
  bezier(
    (rel: (0, 0), to: "initial-pool.south"),
    (rel: (0, 0), to: "struct-5.north-east"),
    (rel: (0.15, -0.5), to: "initial-pool.south"),
    (rel: (0, 0.5), to: "struct-5.north-east"),
    stroke: (dash: "dotted", paint: rgb("#F56565")),
    mark: (pos: 50%, end: "stealth", fill: rgb("#F56565"), scale: 0.6, shorten-to: none),
    name: "s5-new",
  )

  // Step 2 to Step 3 transitions
  // Structure 3 continuing
  bezier(
    (rel: (0, 0), to: "struct-3-2.east"),
    (rel: (0, 0), to: "struct-3-3.west"),
    (rel: (0.5, 0), to: "struct-3-2.east"),
    (rel: (-0.5, 0), to: "struct-3-3.west"),
    stroke: structure_colors.at(2) + 0.8pt,
    mark: (end: "stealth", fill: structure_colors.at(2), scale: 0.6),
    name: "s3-continuing-2",
  )

  // Structures 2, 4, 5 converged - to relaxed pool (with matching colors)
  bezier(
    (rel: (0, 0), to: "struct-2-2.north-east"),
    (rel: (0, 0), to: "relaxed-pool.south"),
    (rel: (0, 0.5), to: "struct-2-2.north-east"),
    (rel: (0, -0.5), to: "relaxed-pool.south"),
    stroke: (dash: "dotted", paint: structure_colors.at(1)),
    mark: (pos: 50%, end: "stealth", fill: structure_colors.at(1), scale: 0.6, shorten-to: none),
    name: "s2-converged",
  )

  bezier(
    (rel: (0, 0), to: "struct-4.north-east"),
    (rel: (0, 0), to: "relaxed-pool.south"),
    (rel: (0, 0.5), to: "struct-4.north-east"),
    (rel: (0.25, -0.5), to: "relaxed-pool.south"),
    stroke: (dash: "dotted", paint: structure_colors.at(3)),
    mark: (pos: 50%, end: "stealth", fill: structure_colors.at(3), scale: 0.6, shorten-to: none),
    name: "s4-converged",
  )

  bezier(
    (rel: (0, 0), to: "struct-5.north-east"),
    (rel: (0, 0), to: "relaxed-pool.south"),
    (rel: (0, 0.5), to: "struct-5.north-east"),
    (rel: (0.5, -0.5), to: "relaxed-pool.south"),
    stroke: (dash: "dotted", paint: structure_colors.at(4)),
    mark: (pos: 50%, end: "stealth", fill: structure_colors.at(4), scale: 0.6, shorten-to: none),
    name: "s5-converged",
  )

  // New structures 6 and 7 allocated from initial pool
  bezier(
    (rel: (0, 0), to: "initial-pool.south"),
    (rel: (0, 0), to: "struct-6.north-west"),
    (rel: (-0.15, -0.5), to: "initial-pool.south"),
    (rel: (0, 0.5), to: "struct-6.north-west"),
    stroke: (dash: "dotted", paint: rgb("#ED64A6")),
    mark: (pos: 20%, end: "stealth", fill: rgb("#ED64A6"), scale: 0.6, shorten-to: none),
    name: "s6-new",
  )

  bezier(
    (rel: (0, 0), to: "initial-pool.south"),
    (rel: (0, 0), to: "struct-7.north-west"),
    (rel: (-0.3, -0.5), to: "initial-pool.south"),
    (rel: (0, 0.5), to: "struct-7.north-west"),
    stroke: (dash: "dotted", paint: rgb("#ECC94B")),
    mark: (pos: 20%, end: "stealth", fill: rgb("#ECC94B"), scale: 0.6, shorten-to: none),
    name: "s7-new",
  )

  // Step 3 to Step 4 transitions
  // Structure 6 continuing
  bezier(
    (rel: (0, 0), to: "struct-6.east"),
    (rel: (0, 0), to: "struct-6-2.west"),
    (rel: (0.5, 0), to: "struct-6.east"),
    (rel: (-0.5, 0), to: "struct-6-2.west"),
    stroke: structure_colors.at(5) + 0.8pt,
    mark: (end: "stealth", fill: structure_colors.at(5), scale: 0.6),
    name: "s6-continuing",
  )

  // Structure 7 continuing
  bezier(
    (rel: (0, 0), to: "struct-7.east"),
    (rel: (0, 0), to: "struct-7-2.west"),
    (rel: (0.5, 0), to: "struct-7.east"),
    (rel: (-0.5, 0), to: "struct-7-2.west"),
    stroke: structure_colors.at(6) + 0.8pt,
    mark: (end: "stealth", fill: structure_colors.at(6), scale: 0.6),
    name: "s7-continuing",
  )

  // Structure 3 converged - to relaxed pool
  bezier(
    (rel: (0, 0), to: "struct-3-3.north-east"),
    (rel: (0, 0), to: "relaxed-pool.south"),
    (rel: (0, 0.5), to: "struct-3-3.north-east"),
    (rel: (0.25, -5), to: "relaxed-pool.south"),
    stroke: (dash: "dotted", paint: structure_colors.at(2)),
    mark: (pos: 50%, end: "stealth", fill: structure_colors.at(2), scale: 0.6, shorten-to: none),
    name: "s3-converged",
  )

  // New structures 8 and 9 allocated from initial pool
  bezier(
    (rel: (0, 0), to: "initial-pool.south"),
    (rel: (0, 0), to: "struct-8.north-west"),
    (rel: (-0.4, -0.5), to: "initial-pool.south"),
    (rel: (0, 0.5), to: "struct-8.north-west"),
    stroke: (dash: "dotted", paint: rgb("#81E6D9")),
    mark: (pos: 50%, end: "stealth", fill: rgb("#81E6D9"), scale: 0.6, shorten-to: none),
    name: "s8-new",
  )

  bezier(
    (rel: (0, 0), to: "initial-pool.south"),
    (rel: (0, 0), to: "struct-9.north-west"),
    (rel: (-0.25, -0.5), to: "initial-pool.south"),
    (rel: (0, 0.5), to: "struct-9.north-west"),
    stroke: (dash: "dotted", paint: rgb("#9F7AEA")),
    mark: (pos: 50%, end: "stealth", fill: rgb("#9F7AEA"), scale: 0.6, shorten-to: none),
    name: "s9-new",
  )

  // Show convergence of structure 7 in step 4 with matching color
  bezier(
    (rel: (0, 0), to: "struct-7-2.north-east"),
    (rel: (0, 0), to: "relaxed-pool.south"),
    (rel: (0, 0.5), to: "struct-7-2.north-east"),
    (rel: (0.75, -0.5), to: "relaxed-pool.south"),
    stroke: (dash: "dotted", paint: structure_colors.at(6)),
    mark: (pos: 25%, end: "stealth", fill: structure_colors.at(6), scale: 0.6, shorten-to: none),
    name: "s7-2-converged",
  )
})
