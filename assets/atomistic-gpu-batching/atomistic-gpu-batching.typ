#import "@preview/cetz:0.5.2": canvas, draw
#import draw: content, line, rect

#set page(width: auto, height: auto, margin: 15pt, fill: none)

#canvas({
  // === Layout constants ===
  let plot_width = 24
  let timeline_width = 16
  let time_tick_spacing = 1.0
  let cell = time_tick_spacing - 0.1
  let box_width_factor = 0.9
  let rect_height = 0.3
  let border_radius = 0.05
  let gap = 0.15
  let strategy_y_positions = (11, 6.5, 2.0)

  // === Palette ===
  let dark_gray = rgb("#5D6B7A")
  let cpu_color = rgb("#8899AA")
  let gpu_color = rgb("#6A7A8A")
  let section_bg = rgb("#F7FAFC")
  let cpu_light_gray = cpu_color.lighten(70%)
  let mid_blue = rgb("#90CAF9")
  let dark_blue = rgb("#64B5F6")
  let light_green = rgb("#C8E6C9")
  let mid_green = rgb("#A5D6A7")
  let dark_green = rgb("#81C784")
  let light_orange = rgb("#FFE0B2")
  let mid_orange = rgb("#FFCC80")
  let dark_orange = rgb("#FFB74D")
  let light_red = rgb("#FFCDD2")
  let mid_red = rgb("#EF9A9A")
  let dark_red = rgb("#E57373")

  // structure colors/labels shared by the binning and in-flight GPU grids
  let struct_colors = (
    dark_blue, dark_green, dark_orange, dark_red, dark_blue.darken(10%),
    dark_green.darken(10%), dark_orange.darken(10%), dark_red.darken(10%),
    dark_blue.darken(20%), dark_green.darken(20%),
  )
  let struct_labels = range(1, 11).map(n => "S" + str(n))

  // === Helpers ===
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
    let (width, height) = (2.8, 0.4)
    rect(
      (x_pos, y_pos - height / 2),
      (x_pos + width, y_pos + height / 2),
      fill: rgb("#E2E8F0"),
      stroke: 0.5pt,
      radius: 0.1,
      name: "bar-bg-" + label,
    )
    let fill_color = if is_bad { light_red.darken(20%) } else if percentage < 30 { light_red } else if percentage < 70 { light_orange } else { light_green }
    rect(
      (x_pos, y_pos - height / 2),
      (x_pos + width * percentage / 100, y_pos + height / 2),
      fill: fill_color,
      stroke: none,
      radius: (north-west: 0.1, south-west: 0.1),
      name: "bar-fill-" + label,
    )
    content(
      (rel: (0.03, 0), to: "bar-bg-" + label),
      text(size: 8pt, weight: "bold")[#label #percentage%],
      name: "bar-label-" + label,
      anchor: "center",
    )
  }

  // one GPU grid slot: filled box with label when color != none, else a dotted idle placeholder
  let draw_cell(x_start, y, w, name, color: none, label: none) = {
    let empty = color == none
    rect(
      (x_start, y - rect_height / 2),
      (x_start + w, y + rect_height / 2),
      fill: if empty { light_red.transparentize(90%) } else { color },
      stroke: if empty { (dash: "dotted", paint: light_red.transparentize(30%)) } else { color.darken(20%) },
      radius: border_radius,
      name: if empty { name + "-empty" } else { name },
    )
    if not empty {
      content((x_start + w / 2, y), text(size: 7pt)[#label], anchor: "center", name: name + "-label")
    }
  }

  // === Title and subtitle ===
  content(
    (plot_width / 2, 15.0),
    text(weight: "bold", size: 16pt)[GPU Batching Strategies for Atomistic Simulations],
    name: "main-title",
  )
  content(
    (rel: (0, -1), to: "main-title"),
    text(size: 12pt)[Comparison of Unbatched vs. BinningAutoBatcher vs. InFlightAutoBatcher],
    name: "subtitle",
  )

  // === Per-strategy backgrounds, labels, utilization meters, timelines ===
  let strategies = (
    (strategy_y_positions.at(0), "Unbatched\nSimulations", (80, 5)),
    (strategy_y_positions.at(1), "Binning\nAutoBatcher", (40, 60)),
    (strategy_y_positions.at(2), "InFlight\nAutoBatcher", (60, 90)),
  )

  for (idx, (y_pos, label, (cpu_util, gpu_util))) in strategies.enumerate() {
    rect(
      (0.5, y_pos - 2.0),
      (plot_width - 0.5, y_pos + 2.0),
      fill: section_bg,
      stroke: none,
      radius: border_radius * 3,
      name: "section-bg-" + str(idx),
    )
    content((2, y_pos + 1.0), text(weight: "bold", size: 12pt)[#label], name: "scenario-label-" + str(idx))

    draw_util_bar(.8, y_pos - 0.1, cpu_util, "CPU Utilization")
    draw_util_bar(.8, y_pos - 1, gpu_util, "GPU Utilization", is_bad: idx == 0)

    content((4.6, y_pos + 1.3), text(fill: cpu_color, size: 10pt, weight: "bold")[CPU], anchor: "east", name: "cpu-label-" + str(idx))
    content((4.6, y_pos - 0.5), text(fill: gpu_color, size: 10pt, weight: "bold")[GPU], anchor: "east", name: "gpu-label-" + str(idx))

    line(
      (4.8, y_pos - 1.5),
      (4.8 + timeline_width, y_pos - 1.5),
      stroke: 0.8pt,
      mark: (end: "stealth", fill: black, scale: 0.5),
      name: "timeline-" + str(idx),
    )

    for tick in range(1, 17) {
      let x_pos = 4 + tick * time_tick_spacing
      line(
        (x_pos, y_pos - 1.55),
        (x_pos, y_pos - 1.45),
        stroke: 0.8pt,
        name: "tick-" + str(idx) + "-" + str(tick),
      )
      content(
        (rel: (0, -0.2), to: "tick-" + str(idx) + "-" + str(tick)),
        text(size: 8pt)[t=#tick],
        anchor: "north",
        name: "tick-label-" + str(idx) + "-" + str(tick),
      )
    }

    let separator_y = if idx == 0 { y_pos + 0.6 } else { y_pos + 0.95 }
    line(
      (4, separator_y),
      (4 + timeline_width, separator_y),
      stroke: (dash: "dotted", paint: dark_gray.lighten(30%)),
      name: "separator-" + str(idx),
    )
  }

  // === 1. Unbatched: per-structure bars + sequential CPU/GPU blocks ===
  let unbatched_cpu_y = strategy_y_positions.at(0) + 1.4
  let unbatched_gpu_y = strategy_y_positions.at(0) - 0.5

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

  for idx in range(22) {
    draw_sim_block(5.25 + idx * 0.7, unbatched_cpu_y - 0.4, 0.4, cpu_light_gray, "unbatched-cpu-op-" + str(idx), opacity: 90%)
  }

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
      draw_sim_block(pos, unbatched_gpu_y, 0.3 * box_width_factor, color, "unbatched-" + str(struct_num) + "-gpu-" + str(idx + 1), task_label: "S" + str(struct_num))
    }
  }

  // === 2. BinningAutoBatcher: two fixed batches; activity matrix marks active slots per step ===
  let binning_cpu_y = strategy_y_positions.at(1) + 1.3
  let binning_gpu_y = strategy_y_positions.at(1) - 0.85

  for (idx, (x_pos, label)) in ((5.0, "Prep batch"), (10.4, "Prep batch")).enumerate() {
    draw_sim_block(x_pos, binning_cpu_y, 1.3, cpu_light_gray, "binning-op-" + str(idx), task_label: label)
  }

  // each bin: (start_step, label_offset, per-step 5-slot activity; 1 = active, 0 = finished)
  let bins = (
    (0, 0, (
      (1, 1, 1, 1, 1),
      (1, 1, 1, 1, 1),
      (0, 1, 1, 1, 1),
      (0, 0, 1, 1, 1),
      (0, 0, 0, 1, 0),
      (0, 0, 0, 1, 0),
    )),
    (6, 5, (
      (1, 1, 1, 1, 1),
      (1, 1, 1, 1, 1),
      (0, 1, 0, 1, 1),
      (0, 1, 0, 0, 1),
      (0, 1, 0, 0, 0),
      (0, 1, 0, 0, 0),
    )),
  )

  for (bin_idx, (start_step, label_offset, patterns)) in bins.enumerate() {
    let box_width = cell * box_width_factor
    for step in range(patterns.len()) {
      let box_x_start = 5.0 + (start_step + step) * cell + (cell - box_width) / 2
      let active = patterns.at(step)

      for slot in range(5) {
        let block_y = binning_gpu_y - 0.3 + slot * (rect_height + gap)
        let name = "binning-block-" + str(start_step) + "-" + str(step) + "-" + str(slot)
        let on = active.at(slot) == 1
        draw_cell(box_x_start, block_y, box_width, name, color: if on { struct_colors.at(slot) }, label: if on { struct_labels.at(slot + label_offset) })
      }

      if step == patterns.len() - 1 {
        content(
          (box_x_start - 0.25, binning_gpu_y - 0.45),
          text(size: 8pt, fill: dark_gray, style: "italic")[Batch #(bin_idx + 1) Complete],
          anchor: "center",
          name: "batch-" + str(bin_idx + 1) + "-complete-label",
        )
      }
    }
  }

  for (x_pos, percentage) in ((5.6, 100), (8.0, 60), (9.8, 30), (11, 100), (13.5, 60), (15.5, 20)) {
    content((x_pos, binning_gpu_y + 2.7), text(size: 8pt, fill: dark_gray)[#percentage% GPU], anchor: "center")
  }

  content(
    (10.5, binning_gpu_y - 1.5),
    text(size: 7pt, fill: dark_red, style: "italic")[Must wait for batch to complete, resulting in underutilized GPU],
    anchor: "center",
    name: "must-wait",
  )
  line(
    "must-wait.north",
    (5.0 + 6 * cell, strategy_y_positions.at(1) - 1.5),
    stroke: (dash: "dotted", paint: dark_red),
    mark: (end: "stealth", fill: dark_red, scale: 0.4, offset: 0.05),
    name: "must-wait-arrow",
  )

  // === 3. InFlightAutoBatcher: structures swapped in as others finish (-1 = idle slot) ===
  let inflight_cpu_y = strategy_y_positions.at(2) + 1.3
  let inflight_gpu_y = strategy_y_positions.at(2) - 0.9

  let structures_by_step = (
    (0, 1, 2, 3, 4),
    (0, 1, 2, 3, 4),
    (0, 6, 2, 3, 4),
    (5, 6, 7, 3, 4),
    (5, 6, 7, 8, 4),
    (5, 6, 7, 8, 9),
    (5, 6, 7, 8, 9),
    (5, 6, 7, -1, -1),
  )

  for step in range(structures_by_step.len()) {
    let prep_width = cell * box_width_factor * 0.7
    let prep_x = 5.0 + step * cell + (cell - prep_width) * 0.1
    draw_sim_block(prep_x, inflight_cpu_y, prep_width, cpu_light_gray, "inflight-prep-" + str(step), task_label: "Prep")

    let box_width = cell * box_width_factor
    let box_x_start = 5.0 + step * cell + (cell - box_width) / 2
    let structures = structures_by_step.at(step)

    for slot in range(5) {
      let struct_idx = structures.at(slot)
      let block_y = inflight_gpu_y - 0.3 + slot * (rect_height + gap)
      let name = "inflight-block-" + str(step) + "-" + str(slot)

      draw_cell(
        box_x_start, block_y, box_width, name,
        color: if struct_idx != -1 { struct_colors.at(struct_idx) },
        label: if struct_idx != -1 { struct_labels.at(struct_idx) },
      )
      // dotted indicator when this slot's structure changed from the previous step
      if struct_idx != -1 and step > 0 and structures_by_step.at(step - 1).at(slot) != struct_idx {
        line(
          (rel: (0, 0), to: name + ".south-west"),
          (rel: (-0.25, -0.3), to: name + ".south-west"),
          stroke: (dash: "dotted", paint: dark_green),
          mark: (start: "stealth", fill: dark_green, scale: 0.3),
          name: name + "-swap-indicator",
        )
      }
    }

    if step == structures_by_step.len() - 1 {
      content(
        (rel: (box_width + 1.7, 0.2), to: "inflight-block-" + str(step) + "-0"),
        text(size: 8pt, fill: dark_gray, style: "italic")[Final batch partially filled],
        anchor: "center",
        name: "final-batch-label",
      )
    }
  }

  // === Verdict + summary ===
  content(
    (plot_width / 2, -0.8),
    text(size: 9pt, weight: "bold", fill: dark_green)[In-flight batching achieves highest GPU utilization and maximizes predictions per unit time],
    frame: "rect",
    fill: light_green.transparentize(70%),
    stroke: dark_green,
    padding: 3pt,
    radius: border_radius,
  )

  content(
    (plot_width / 2, -3),
    box(width: 50em)[
      *Unbatched:* Each simulation runs sequentially with most calculations on CPU and minimal GPU utilization\
      *Binning:* Fixed-size batches improve GPU utilization but can't adapt to varying simulation completion times\
      *In-flight:* Dynamic reallocation eliminates GPU idle time by immediately adding new structures when others complete. Color changes indicate in-flight structure replacement.
    ],
    frame: "rect",
    fill: section_bg,
    stroke: 0.5pt,
    padding: (10pt, 10pt, 0pt),
    radius: border_radius,
  )
})
