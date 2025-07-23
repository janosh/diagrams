#import "@preview/cetz:0.4.1": canvas, draw
#import draw: bezier, circle, content, group, line, rect

#set page(width: auto, height: auto, margin: 15pt)

#canvas({
  // Core constants and reusable values
  let plot_width = 24
  let timeline_width = 16
  let time_tick_spacing = 1.0
  let step_width = time_tick_spacing
  let step_gap = 0.1
  let box_width_factor = 0.9
  let rect_height = 0.3
  let border_radius = 0.05
  let gap = 0.15
  let strategy_y_positions = (11, 6.5, 2.0) // Further compressed y-positions

  // Colors - more pastel version for better text readability
  // Grays
  let dark_gray = rgb("#5D6B7A")
  let cpu_color = rgb("#8899AA")
  let gpu_color = rgb("#6A7A8A")
  let section_bg = rgb("#F7FAFC")
  // Define a consistent CPU light gray color for all strategies
  let cpu_light_gray = cpu_color.lighten(70%)

  // Blues with pastel tones
  let light_blue = rgb("#BBDEFB")
  let mid_blue = rgb("#90CAF9")
  let dark_blue = rgb("#64B5F6")

  // Greens with pastel tones
  let light_green = rgb("#C8E6C9")
  let mid_green = rgb("#A5D6A7")
  let dark_green = rgb("#81C784")

  // Oranges with pastel tones
  let light_orange = rgb("#FFE0B2")
  let mid_orange = rgb("#FFCC80")
  let dark_orange = rgb("#FFB74D")

  // Reds with pastel tones
  let light_red = rgb("#FFCDD2")
  let mid_red = rgb("#EF9A9A")
  let dark_red = rgb("#E57373")

  // Helper functions
  let draw_sim_block(x_pos, y_pos, width, color, label, task_label: "", opacity: 100%) = {
    rect(
      (x_pos, y_pos - rect_height / 2),
      (x_pos + width, y_pos + rect_height / 2),
      fill: color.transparentize(100% - opacity),
      stroke: color.darken(10%),
      radius: border_radius,
      name: "block-" + label,
    )
    if task_label != "" {
      content((x_pos + width / 2, y_pos), text(size: 8pt)[#task_label], name: "label-" + label)
    }
  }

  let draw_structure_rect(x_pos, y_pos, width, color, label, struct_name) = {
    rect(
      (x_pos, y_pos),
      (x_pos + 0.95 * width, y_pos + 0.1),
      fill: color.transparentize(20%),
      stroke: none,
      name: "block-" + struct_name,
    )
    content((x_pos + width / 2, y_pos + 0.15), text(size: 8pt)[#label], name: "label-" + struct_name, anchor: "south")
  }

  let draw_util_bar(x_pos, y_pos, percentage, label, is_bad: false) = {
    // Bar showing CPU or GPU utilization - consolidated function
    let width = 2.8
    let height = 0.4

    // Background bar
    rect(
      (x_pos, y_pos - height / 2),
      (x_pos + width, y_pos + height / 2),
      fill: rgb("#E2E8F0"),
      stroke: 0.5pt,
      radius: 0.1,
      name: "bar-bg-" + label,
    )

    // Filled portion with appropriate color
    let fill_width = width * percentage / 100

    // Determine color based on percentage and is_bad flag
    let fill_color = if is_bad {
      light_red.darken(20%) // Use darker red for explicitly marked "bad" utilization
    } else if percentage < 30 {
      light_red
    } else if percentage < 70 {
      light_orange
    } else {
      light_green
    }

    rect(
      (x_pos, y_pos - height / 2),
      (x_pos + fill_width, y_pos + height / 2),
      fill: fill_color,
      stroke: none,
      radius: (north-west: 0.1, south-west: 0.1),
      name: "bar-fill-" + label,
    )

    // Label
    content(
      (rel: (0.03, 0), to: "bar-bg-" + label),
      text(size: 8pt, weight: "bold")[#label #percentage%],
      name: "bar-label-" + label,
      anchor: "center",
    )
  }

  // Title, subtitle and legend
  let title_y = 15.0
  content(
    (plot_width / 2, title_y),
    text(weight: "bold", size: 16pt)[GPU Batching Strategies for Atomistic Simulations],
    name: "main-title",
  )
  content(
    (rel: (0, -1), to: "main-title"),
    text(size: 12pt)[Comparison of Unbatched vs. BinningAutoBatcher vs. InFlightAutoBatcher],
    name: "subtitle",
  )


  // Add section backgrounds and scenario setups
  let strategies = (
    (strategy_y_positions.at(0), "Unbatched\nSimulations", (80, 5)),
    (strategy_y_positions.at(1), "Binning\nAutoBatcher", (40, 60)),
    (strategy_y_positions.at(2), "InFlight\nAutoBatcher", (60, 90)),
  )

  for (idx, (y_pos, label, (cpu_util, gpu_util))) in strategies.enumerate() {
    // Background
    rect(
      (0.5, y_pos - 2.0),
      (plot_width - 0.5, y_pos + 2.0),
      fill: section_bg,
      stroke: none,
      radius: border_radius * 3,
      name: "section-bg-" + str(idx),
    )

    // Scenario label
    content((2, y_pos + 1.0), text(weight: "bold", size: 12pt)[#label], name: "scenario-label-" + str(idx))

    // Utilization meters
    draw_util_bar(.8, y_pos - 0.1, cpu_util, "CPU Utilization")

    // GPU utilization - mark as bad for unbatched simulations (idx == 0)
    draw_util_bar(.8, y_pos - 1, gpu_util, "GPU Utilization", is_bad: idx == 0)

    // CPU/GPU labels
    content(
      (4.6, y_pos + 1.3),
      text(fill: cpu_color, size: 10pt, weight: "bold")[CPU],
      anchor: "east",
      name: "cpu-label-" + str(idx),
    )
    content(
      (4.6, y_pos - 0.5),
      text(fill: gpu_color, size: 10pt, weight: "bold")[GPU],
      anchor: "east",
      name: "gpu-label-" + str(idx),
    )

    // Timeline axis with ticks
    line(
      (4.8, y_pos - 1.5),
      (4.8 + timeline_width, y_pos - 1.5),
      stroke: 0.8pt,
      mark: (end: "stealth", fill: black, scale: 0.5),
      name: "timeline-" + str(idx),
    )

    for t in range(1, 17) {
      let x_pos = 4 + t * time_tick_spacing
      if x_pos <= 4 + timeline_width {
        line(
          (x_pos, y_pos - 1.5 - 0.05),
          (x_pos, y_pos - 1.5 + 0.05),
          stroke: 0.8pt,
          name: "tick-" + str(idx) + "-" + str(t),
        )
        content(
          (rel: (0, -0.2), to: "tick-" + str(idx) + "-" + str(t)),
          text(size: 8pt)[t=#t],
          anchor: "north",
          name: "tick-label-" + str(idx) + "-" + str(t),
        )
      }
    }

    // CPU/GPU separator
    let separator_y = if idx == 0 { y_pos + 0.6 } else { y_pos + 0.95 }
    line(
      (4, separator_y),
      (4 + timeline_width, separator_y),
      stroke: (dash: "dotted", paint: dark_gray.lighten(30%)),
      name: "separator-" + str(idx),
    )
  }

  // 1. Unbatched Simulations
  let unbatched_cpu_y = strategy_y_positions.at(0) + 1.4
  let unbatched_gpu_y = strategy_y_positions.at(0) - 0.5

  // Structure rectangles with consistent pattern
  let unbatched_structures = (
    (5.0, 2.0, mid_blue, "Structure 1"),
    (7.0, 2.3, mid_green, "Structure 2"),
    (9.3, 1.8, mid_orange, "Structure 3"),
    (11.1, 2.1, mid_red, "Structure 4"),
    (13.2, 1.8, dark_green, "Structure 5"),
    (15.0, 2.0, dark_green.darken(10%), "Structure 6"),
    (17.0, 1.6, dark_green.darken(15%), "Structure 7"),
    (18.6, 1.5, dark_green.darken(20%), "Structure 8"),
  )

  for (idx, (x_pos, width, color, label)) in unbatched_structures.enumerate() {
    draw_structure_rect(x_pos, unbatched_cpu_y, width, color, label, "unbatched-" + str(idx + 1) + "-cpu")
  }

  content((21.8, unbatched_cpu_y - 1.9), text(size: 10pt, weight: "bold")[... continues], anchor: "center")

  // CPU operation blocks in a loop
  for x in range(22) {
    let x_offset = 5.25 + x * 0.7
    if x_offset < 20 {
      draw_sim_block(
        x_offset,
        unbatched_cpu_y - 0.4,
        0.4,
        cpu_light_gray,
        "unbatched-cpu-op-" + str(x),
        task_label: "",
        opacity: 90%,
      )
    }
  }

  // GPU blocks with structure IDs and positions
  let gpu_blocks = (
    (1, dark_blue, (5.5, 6.5)),
    (2, dark_green, (7.5, 8.5)),
    (3, dark_orange, (9.8, 10.6)),
    (4, dark_red, (11.5, 12.5)),
    (5, dark_green, (13.8, 14.6, 15.4)),
    (6, dark_green.darken(10%), (16.2, 16.8, 17.4, 18.0, 18.6)),
    (7, dark_green.darken(15%), (19.2, 19.8)),
  )

  for (struct_num, color, positions) in gpu_blocks {
    for (idx, pos) in positions.enumerate() {
      draw_sim_block(
        pos,
        unbatched_gpu_y,
        0.3 * box_width_factor,
        color,
        "unbatched-" + str(struct_num) + "-gpu-" + str(idx + 1),
        task_label: "S" + str(struct_num),
      )
    }
  }

  // 2. BinningAutoBatcher
  let binning_cpu_y = strategy_y_positions.at(1) + 1.3
  let binning_gpu_y = strategy_y_positions.at(1) - 0.85

  // CPU processing blocks - simplified to only show prep batch operations
  let cpu_blocks = (
    (5.0, "Prep batch"),
    (10.4, "Prep batch"),
  )

  for (idx, (x_pos, label)) in cpu_blocks.enumerate() {
    draw_sim_block(x_pos, binning_cpu_y, 1.3, cpu_light_gray, "binning-op-" + str(idx), task_label: label)
  }


  // Batch visualization setup
  let s_colors = (
    dark_blue,
    dark_green,
    dark_orange,
    dark_red,
    dark_blue.darken(10%),
  )

  let s_labels = ("S1", "S2", "S3", "S4", "S5")

  // Bin parameters and active patterns
  let bins = (
    (
      // Bin 1: 6 steps with completion patterns
      0,
      false,
      (
        (1, 1, 1, 1, 1), // Step 0: all active
        (1, 1, 1, 1, 1), // Step 1: all active
        (0, 1, 1, 1, 1), // Step 2: structure 1 completes earlier
        (0, 0, 1, 1, 1), // Step 3: structures 1,2 complete
        (0, 0, 0, 1, 0), // Step 4: structures 1,2,3,5 complete
        (0, 0, 0, 1, 0), // Step 5: only 4 remains
      ),
    ),
    (
      // Bin 2: 6 steps with different completion pattern
      6,
      true,
      (
        (1, 1, 1, 1, 1), // Step 0: all active
        (1, 1, 1, 1, 1), // Step 1: structure 3 completes early
        (0, 1, 0, 1, 1), // Step 2: structures 1,3 complete
        (0, 1, 0, 0, 1), // Step 3: only 4,5 remain
        (0, 1, 0, 0, 0), // Step 4: only 5 remains
        (0, 1, 0, 0, 0), // Step 5: all complete
      ),
    ),
  )

  // Draw both bins with common function
  for (start_step, is_second_bin, patterns) in bins {
    for step in range(patterns.len()) {
      let x_pos = 5.0 + (start_step + step) * (step_width - step_gap)
      let box_width = (step_width - step_gap) * box_width_factor
      let box_x_start = x_pos + ((step_width - step_gap) - box_width) / 2

      // Draw each structure slot
      for i in range(5) {
        let block_y = binning_gpu_y - 0.3 + i * (rect_height + gap)
        let binning_block_name = "binning-block-" + str(start_step) + "-" + str(step) + "-" + str(i)

        if patterns.at(step).at(i) == 1 {
          let color = s_colors.at(i)
          let label = if is_second_bin { "S" + str(i + 6) } else { s_labels.at(i) }

          rect(
            (box_x_start, block_y - rect_height / 2),
            (box_x_start + box_width, block_y + rect_height / 2),
            fill: color,
            stroke: color.darken(20%),
            radius: border_radius,
            name: binning_block_name,
          )

          content(
            (box_x_start + box_width / 2, block_y),
            text(size: 7pt)[#label],
            anchor: "center",
            name: binning_block_name + "-label",
          )
        } else {
          // Empty placeholder
          rect(
            (box_x_start, block_y - rect_height / 2),
            (box_x_start + box_width, block_y + rect_height / 2),
            fill: light_red.transparentize(90%),
            stroke: (dash: "dotted", paint: light_red.transparentize(30%)),
            radius: border_radius,
            name: binning_block_name + "-empty",
          )
        }
      }

      // Add completion label for the last step
      if step == patterns.len() - 1 {
        content(
          (box_x_start - 0.25, binning_gpu_y - 0.45),
          text(size: 8pt, fill: dark_gray, style: "italic")[Batch #if is_second_bin [2] else [1] Complete],
          anchor: "center",
          name: "batch-" + str(if is_second_bin { 2 } else { 1 }) + "-complete-label",
        )
      }
    }
  }

  for (x_pos, percentage) in ((5.6, 100), (8.0, 60), (9.8, 30), (11, 100), (13.5, 60), (15.5, 20)) {
    content(
      (x_pos, binning_gpu_y + 2.7),
      text(size: 8pt, fill: dark_gray)[#percentage% GPU],
      anchor: "center",
    )
  }

  // Explanatory arrows and labels - removing the isolated red arrow
  content(
    (10.5, binning_gpu_y - 1.5),
    text(size: 7pt, fill: dark_red, style: "italic")[Must wait for batch to complete, resulting in underutilized GPU],
    anchor: "center",
    name: "must-wait",
  )

  let batch_end_x = 5.0 + 6 * (step_width - step_gap)
  let timeline_y = strategy_y_positions.at(1) - 1.5

  line(
    "must-wait.north",
    (batch_end_x, timeline_y),
    stroke: (dash: "dotted", paint: dark_red),
    mark: (end: "stealth", fill: dark_red, scale: 0.4, offset: 0.05),
    name: "must-wait-arrow",
  )

  // 3. In-flightAutoBatcher
  let inflight_cpu_y = strategy_y_positions.at(2) + 1.3
  let inflight_gpu_y = strategy_y_positions.at(2) - 0.9

  // Structure colors and labels
  let all_colors = (
    dark_blue,
    dark_green,
    dark_orange,
    dark_red,
    dark_blue.darken(10%),
    dark_green.darken(10%),
    dark_orange.darken(10%),
    dark_red.darken(10%),
    dark_blue.darken(20%),
    dark_green.darken(20%),
  )
  let all_labels = ("S1", "S2", "S3", "S4", "S5", "S6", "S7", "S8", "S9", "S10")

  // Structure placement by time step - fix structure continuity
  let structures_by_step = (
    (0, 1, 2, 3, 4), // t=1: S1-S5
    (0, 1, 2, 3, 4), // t=2: S1-S5 (S1 continues for longer)
    (0, 6, 2, 3, 4), // t=3: S1 continues, S6 replaces S2, S3-S5 continue
    (5, 6, 7, 3, 4), // t=4: S5, S6-S8, S4 continue (S1 completed, S5 swapped in)
    (5, 6, 7, 8, 4), // t=5: S5-S9, S4 (S3 completed, S8 swapped in)
    (5, 6, 7, 8, 9), // t=6: S5-S10 (S4 completed, S9 swapped in)
    (5, 6, 7, 8, 9), // t=7: still fully filled
    (5, 6, 7, -1, -1), // t=8: final step, partially filled (about 50%) - using S6 instead of isolated S4
  )

  // Place CPU operations equidistant, one for each time step
  // Create the same number of prep boxes as structure steps (8 steps)

  // Draw CPU operations - one per time step
  for step in range(structures_by_step.len()) {
    let x_pos = 5.0 + step * (step_width - step_gap)
    let box_width = (step_width - step_gap) * box_width_factor * 0.7 // Make boxes 10% wider (70% instead of 60%)

    // Left align by using 10% of remaining space as left margin instead of centering
    let box_x_start = x_pos + ((step_width - step_gap) - box_width) * 0.1

    // Use the same generic gray for all prep blocks
    draw_sim_block(
      box_x_start,
      inflight_cpu_y,
      box_width,
      cpu_light_gray,
      "inflight-prep-" + str(step),
      task_label: "Prep",
    )
  }

  // Draw all structures by step
  for step in range(structures_by_step.len()) {
    let x_pos = 5.0 + step * (step_width - step_gap)
    let box_width = (step_width - step_gap) * box_width_factor
    let box_x_start = x_pos + ((step_width - step_gap) - box_width) / 2

    // Create a batch name for this step
    let batch_name = "inflight-batch-" + str(step)

    // Draw each structure position
    for pos in range(5) {
      let struct_idx = structures_by_step.at(step).at(pos)
      let block_y = inflight_gpu_y - 0.3 + pos * (rect_height + gap)
      let block_name = "inflight-block-" + str(step) + "-" + str(pos)

      if struct_idx != -1 {
        let color = all_colors.at(struct_idx)
        let label = all_labels.at(struct_idx)

        // Structure box
        rect(
          (box_x_start, block_y - rect_height / 2),
          (box_x_start + box_width, block_y + rect_height / 2),
          fill: color,
          stroke: color.darken(20%),
          radius: border_radius,
          name: block_name,
        )

        content(
          (box_x_start + box_width / 2, block_y),
          text(size: 7pt)[#label],
          name: block_name + "-label",
          anchor: "center",
        )

        // Swap-in indicator
        if step > 0 {
          let prev_structures = structures_by_step.at(step - 1)
          let prev_block_name = "inflight-block-" + str(step - 1) + "-" + str(pos)

          if pos < prev_structures.len() and prev_structures.at(pos) != struct_idx {
            // Simple diagonal line for swap-in indicator
            line(
              (rel: (0, 0), to: block_name + ".south-west"), // End at the block edge
              (rel: (-0.25, -0.3), to: block_name + ".south-west"), // Start from outside
              stroke: (dash: "dotted", paint: dark_green),
              mark: (start: "stealth", fill: dark_green, scale: 0.3),
              name: block_name + "-swap-indicator",
            )
          }
        }
      } else {
        // Empty placeholders with dotted lines to indicate unused GPU cycles
        rect(
          (box_x_start, block_y - rect_height / 2),
          (box_x_start + box_width, block_y + rect_height / 2),
          fill: light_red.transparentize(90%),
          stroke: (dash: "dotted", paint: light_red.transparentize(30%)),
          radius: border_radius,
          name: block_name + "-empty",
        )
      }
    }

    // Mark the last batch specially
    if step == structures_by_step.len() - 1 {
      // Store a reference to the last batch for later reference
      let final_block_name = "inflight-block-" + str(step) + "-0"

      // Instead of using absolute positioning, use relative positioning
      // based on the named elements we just created
      content(
        (rel: (box_width + 1.7, 0.2), to: final_block_name),
        text(size: 8pt, fill: dark_gray, style: "italic")[Final batch partially filled],
        anchor: "center",
        name: "final-batch-label",
      )
    }
  }

  // First label with frame
  content(
    (plot_width / 2, -0.8),
    text(
      size: 9pt,
      weight: "bold",
      fill: dark_green,
    )[In-flight batching achieves highest GPU utilization and maximizes predictions per unit time],
    frame: "rect",
    fill: light_green.transparentize(70%),
    stroke: dark_green,
    padding: 3pt,
    radius: border_radius,
  )

  // Summary notes
  content(
    (plot_width / 2, -3),
    box(width: 50em)[
      *Unbatched:* Each simulation runs sequentially with most calculations on CPU and minimal GPU utilization\
      *Binning:* Fixed-size batches improve GPU utilization but can't adapt to varying simulation completion times\
      *In-flight:* Dynamic reallocation eliminates GPU idle time by immediately adding new structures when others complete. Color changes indicate in-flight structure replacement.
    ],
    frame: "rect",
    fill: rgb("#F7FAFC"),
    stroke: 0.5pt,
    padding: (10pt, 10pt, 0pt),
    radius: border_radius,
  )
})
