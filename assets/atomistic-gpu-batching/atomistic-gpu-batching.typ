#import "@preview/cetz:0.5.2": canvas, draw
#import draw: content, line, rect
#import "../_shared/theme.typ": annotation-size

#set page(width: auto, height: auto, margin: 15pt, fill: none)

#canvas({
  // === Layout constants ===
  let plot-width = 24
  let timeline-width = 16
  let time-tick-spacing = 1.0
  let cell = time-tick-spacing - 0.1
  let box-width-factor = 0.9
  let rect-height = 0.3
  let border-radius = 0.05
  let gap = 0.15
  let strategy-y-positions = (11, 6.5, 2.0)

  // === Palette ===
  let dark-gray = rgb("#5D6B7A")
  let cpu-color = rgb("#8899AA")
  let gpu-color = rgb("#6A7A8A")
  let section-bg = rgb("#F7FAFC")
  let cpu-light-gray = cpu-color.lighten(70%)
  let mid-blue = rgb("#90CAF9")
  let dark-blue = rgb("#64B5F6")
  let light-green = rgb("#C8E6C9")
  let mid-green = rgb("#A5D6A7")
  let dark-green = rgb("#81C784")
  let light-orange = rgb("#FFE0B2")
  let mid-orange = rgb("#FFCC80")
  let dark-orange = rgb("#FFB74D")
  let light-red = rgb("#FFCDD2")
  let mid-red = rgb("#EF9A9A")
  let dark-red = rgb("#E57373")

  // structure colors/labels shared by the binning and in-flight GPU grids
  let struct-colors = (
    dark-blue,
    dark-green,
    dark-orange,
    dark-red,
    dark-blue.darken(10%),
    dark-green.darken(10%),
    dark-orange.darken(10%),
    dark-red.darken(10%),
    dark-blue.darken(20%),
    dark-green.darken(20%),
  )
  let struct-labels = range(1, 11).map(n => "S" + str(n))

  // === Helpers ===
  // @typstyle off
  let draw-sim-block(x-pos, y-pos, width, color, label, task-label: "", opacity: 100%) = {
    rect(
      (x-pos, y-pos - rect-height / 2),
      (x-pos + width, y-pos + rect-height / 2),
      fill: color.transparentize(100% - opacity),
      stroke: color.darken(10%),
      radius: border-radius,
    )
    if task-label != "" {
      content(
        (x-pos + width / 2, y-pos),
        text(size: annotation-size)[#task-label],
      )
    }
  }

  let draw-structure-rect(x-pos, y-pos, width, color, label, struct-name) = {
    rect(
      (x-pos, y-pos),
      (x-pos + 0.95 * width, y-pos + 0.1),
      fill: color.transparentize(20%),
      stroke: none,
    )
    content(
      (x-pos + width / 2, y-pos + 0.15),
      text(size: annotation-size)[#label],
      anchor: "south",
    )
  }

  let draw-util-bar(x-pos, y-pos, percentage, label, is-bad: false) = {
    let (width, height) = (2.8, 0.4)
    rect(
      (x-pos, y-pos - height / 2),
      (x-pos + width, y-pos + height / 2),
      fill: rgb("#E2E8F0"),
      stroke: 0.5pt,
      radius: 0.1,
      name: "bar-bg-" + label,
    )
    let fill-color = if is-bad { light-red.darken(20%) } else if percentage < 30 {
      light-red
    } else if percentage < 70 { light-orange } else { light-green }
    rect(
      (x-pos, y-pos - height / 2),
      (x-pos + width * percentage / 100, y-pos + height / 2),
      fill: fill-color,
      stroke: none,
      radius: (north-west: 0.1, south-west: 0.1),
    )
    content(
      (rel: (0.03, 0), to: "bar-bg-" + label),
      text(size: annotation-size, weight: "bold")[#label #percentage%],
      anchor: "center",
    )
  }

  // one GPU grid slot: filled box with label when color != none, else a dotted idle placeholder
  let draw-cell(x-start, y, w, name, color: none, label: none) = {
    let empty = color == none
    rect(
      (x-start, y - rect-height / 2),
      (x-start + w, y + rect-height / 2),
      fill: if empty { light-red.transparentize(90%) } else { color },
      stroke: if empty {
        (dash: "dotted", paint: light-red.transparentize(30%))
      } else { color.darken(20%) },
      radius: border-radius,
      name: if empty { name + "-empty" } else { name },
    )
    if not empty {
      content(
        (x-start + w / 2, y),
        text(size: annotation-size)[#label],
        anchor: "center",
      )
    }
  }

  // === Title and subtitle ===
  content(
    (plot-width / 2, 15.0),
    text(
      weight: "bold",
      size: 16pt,
    )[GPU Batching Strategies for Atomistic Simulations],
    name: "main-title",
  )
  content(
    (rel: (0, -1), to: "main-title"),
    text(
      size: 12pt,
    )[Comparison of Unbatched vs. BinningAutoBatcher vs. InFlightAutoBatcher],
  )

  // === Per-strategy backgrounds, labels, utilization meters, timelines ===
  let strategies = (
    (strategy-y-positions.at(0), "Unbatched\nSimulations", (80, 5)),
    (strategy-y-positions.at(1), "Binning\nAutoBatcher", (40, 60)),
    (strategy-y-positions.at(2), "InFlight\nAutoBatcher", (60, 90)),
  )

  for (idx, (y-pos, label, (cpu-util, gpu-util))) in strategies.enumerate() {
    rect(
      (0.5, y-pos - 2.0),
      (plot-width - 0.5, y-pos + 2.0),
      fill: section-bg,
      stroke: none,
      radius: border-radius * 3,
    )
    content(
      (2, y-pos + 1.0),
      text(weight: "bold", size: 12pt)[#label],
    )

    draw-util-bar(.8, y-pos - 0.1, cpu-util, "CPU Utilization")
    draw-util-bar(.8, y-pos - 1, gpu-util, "GPU Utilization", is-bad: idx == 0)

    content(
      (4.6, y-pos + 1.3),
      text(fill: cpu-color, size: 10pt, weight: "bold")[CPU],
      anchor: "east",
    )
    content(
      (4.6, y-pos - 0.5),
      text(fill: gpu-color, size: 10pt, weight: "bold")[GPU],
      anchor: "east",
    )

    line(
      (4.8, y-pos - 1.5),
      (4.8 + timeline-width, y-pos - 1.5),
      stroke: 0.8pt,
      mark: (end: "stealth", fill: black, scale: 0.5),
    )

    for tick in range(1, 17) {
      let x-pos = 4 + tick * time-tick-spacing
      line(
        (x-pos, y-pos - 1.55),
        (x-pos, y-pos - 1.45),
        stroke: 0.8pt,
        name: "tick-" + str(idx) + "-" + str(tick),
      )
      content(
        (rel: (0, -0.2), to: "tick-" + str(idx) + "-" + str(tick)),
        text(size: annotation-size)[t=#tick],
        anchor: "north",
      )
    }

    let separator-y = if idx == 0 { y-pos + 0.6 } else { y-pos + 0.95 }
    line(
      (4, separator-y),
      (4 + timeline-width, separator-y),
      stroke: (dash: "dotted", paint: dark-gray.lighten(30%)),
    )
  }

  // === 1. Unbatched: per-structure bars + sequential CPU/GPU blocks ===
  let unbatched-cpu-y = strategy-y-positions.at(0) + 1.4
  let unbatched-gpu-y = strategy-y-positions.at(0) - 0.5

  let unbatched-structures = (
    (5.0, 2.0, mid-blue, "Structure 1"),
    (7.0, 2.3, mid-green, "Structure 2"),
    (9.3, 1.8, mid-orange, "Structure 3"),
    (11.1, 2.1, mid-red, "Structure 4"),
    (13.2, 1.8, dark-green, "Structure 5"),
    (15.0, 2.0, dark-green.darken(10%), "Structure 6"),
    (17.0, 1.6, dark-green.darken(15%), "Structure 7"),
    (18.6, 1.5, dark-green.darken(20%), "Structure 8"),
  )
  for (idx, (x-pos, width, color, label)) in unbatched-structures.enumerate() {
    draw-structure-rect(
      x-pos,
      unbatched-cpu-y,
      width,
      color,
      label,
      "unbatched-" + str(idx + 1) + "-cpu",
    )
  }
  content(
    (21.8, unbatched-cpu-y - 1.9),
    text(size: 10pt, weight: "bold")[... continues],
    anchor: "center",
  )

  for idx in range(22) {
    draw-sim-block(
      5.25 + idx * 0.7,
      unbatched-cpu-y - 0.4,
      0.4,
      cpu-light-gray,
      "unbatched-cpu-op-" + str(idx),
      opacity: 90%,
    )
  }

  let gpu-blocks = (
    (1, dark-blue, (5.5, 6.5)),
    (2, dark-green, (7.5, 8.5)),
    (3, dark-orange, (9.8, 10.6)),
    (4, dark-red, (11.5, 12.5)),
    (5, dark-green, (13.8, 14.6, 15.4)),
    (6, dark-green.darken(10%), (16.2, 16.8, 17.4, 18.0, 18.6)),
    (7, dark-green.darken(15%), (19.2, 19.8)),
  )
  for (struct-num, color, positions) in gpu-blocks {
    for (idx, pos) in positions.enumerate() {
      draw-sim-block(
        pos,
        unbatched-gpu-y,
        0.3 * box-width-factor,
        color,
        "unbatched-" + str(struct-num) + "-gpu-" + str(idx + 1),
        task-label: "S" + str(struct-num),
      )
    }
  }

  // === 2. BinningAutoBatcher: two fixed batches; activity matrix marks active slots per step ===
  let binning-cpu-y = strategy-y-positions.at(1) + 1.3
  let binning-gpu-y = strategy-y-positions.at(1) - 0.85

  for (idx, (x-pos, label)) in (
    (5.0, "Prep batch"),
    (10.4, "Prep batch"),
  ).enumerate() {
    draw-sim-block(
      x-pos,
      binning-cpu-y,
      1.3,
      cpu-light-gray,
      "binning-op-" + str(idx),
      task-label: label,
    )
  }

  // Each bin: (first step, index of its first structure, per-step slot occupancy read
  // bottom-to-top; "1" = still running, "0" = already finished)
  let bins = (
    (0, 0, ("11111", "11111", "01111", "00111", "00010", "00010")),
    (6, 5, ("11111", "11111", "01011", "01001", "01000", "01000")),
  )

  let box-width = cell * box-width-factor
  for (bin-idx, (start-step, first-struct, patterns)) in bins.enumerate() {
    for (step, occupancy) in patterns.enumerate() {
      let box-x-start = 5.0 + (start-step + step) * cell + (cell - box-width) / 2

      for slot in range(5) {
        let running = occupancy.at(slot) == "1"
        draw-cell(
          box-x-start,
          binning-gpu-y - 0.3 + slot * (rect-height + gap),
          box-width,
          "binning-block-" + str(start-step) + "-" + str(step) + "-" + str(slot),
          color: if running { struct-colors.at(slot) },
          label: if running { struct-labels.at(slot + first-struct) },
        )
      }

      if step == patterns.len() - 1 {
        content(
          (box-x-start - 0.25, binning-gpu-y - 0.45),
          text(
            size: 8pt,
            fill: dark-gray,
            style: "italic",
          )[Batch #(bin-idx + 1) Complete],
          anchor: "center",
        )
      }
    }
  }

  for (x-pos, percentage) in (
    (5.6, 100),
    (8.0, 60),
    (9.8, 30),
    (11, 100),
    (13.5, 60),
    (15.5, 20),
  ) {
    content(
      (x-pos, binning-gpu-y + 2.7),
      text(size: 8pt, fill: dark-gray)[#percentage% GPU],
      anchor: "center",
    )
  }

  content(
    (10.5, binning-gpu-y - 1.5),
    text(
      size: 7pt,
      fill: dark-red,
      style: "italic",
    )[Must wait for batch to complete, resulting in underutilized GPU],
    anchor: "center",
    name: "must-wait",
  )
  line(
    "must-wait.north",
    (5.0 + 6 * cell, strategy-y-positions.at(1) - 1.5),
    stroke: (dash: "dotted", paint: dark-red),
    mark: (end: "stealth", fill: dark-red, scale: 0.4, offset: 0.05),
  )

  // === 3. InFlightAutoBatcher: structures swapped in as others finish (-1 = idle slot) ===
  let inflight-cpu-y = strategy-y-positions.at(2) + 1.3
  let inflight-gpu-y = strategy-y-positions.at(2) - 0.9

  let structures-by-step = (
    (0, 1, 2, 3, 4),
    (0, 1, 2, 3, 4),
    (0, 6, 2, 3, 4),
    (5, 6, 7, 3, 4),
    (5, 6, 7, 8, 4),
    (5, 6, 7, 8, 9),
    (5, 6, 7, 8, 9),
    (5, 6, 7, -1, -1),
  )

  for step in range(structures-by-step.len()) {
    let prep-width = cell * box-width-factor * 0.7
    let prep-x = 5.0 + step * cell + (cell - prep-width) * 0.1
    draw-sim-block(
      prep-x,
      inflight-cpu-y,
      prep-width,
      cpu-light-gray,
      "inflight-prep-" + str(step),
      task-label: "Prep",
    )

    let box-width = cell * box-width-factor
    let box-x-start = 5.0 + step * cell + (cell - box-width) / 2
    let structures = structures-by-step.at(step)

    for slot in range(5) {
      let struct-idx = structures.at(slot)
      let block-y = inflight-gpu-y - 0.3 + slot * (rect-height + gap)
      let name = "inflight-block-" + str(step) + "-" + str(slot)

      draw-cell(
        box-x-start,
        block-y,
        box-width,
        name,
        color: if struct-idx != -1 { struct-colors.at(struct-idx) },
        label: if struct-idx != -1 { struct-labels.at(struct-idx) },
      )
      // dotted indicator when this slot's structure changed from the previous step
      if (
        struct-idx != -1 and step > 0 and structures-by-step.at(step - 1).at(slot) != struct-idx
      ) {
        line(
          (rel: (0, 0), to: name + ".south-west"),
          (rel: (-0.25, -0.3), to: name + ".south-west"),
          stroke: (dash: "dotted", paint: dark-green),
          mark: (start: "stealth", fill: dark-green, scale: 0.3),
        )
      }
    }

    if step == structures-by-step.len() - 1 {
      content(
        (rel: (box-width + 1.7, 0.2), to: "inflight-block-" + str(step) + "-0"),
        text(
          size: 8pt,
          fill: dark-gray,
          style: "italic",
        )[Final batch partially filled],
        anchor: "center",
      )
    }
  }

  // === Verdict + summary ===
  content(
    (plot-width / 2, -0.8),
    text(
      size: 9pt,
      weight: "bold",
      fill: dark-green,
    )[In-flight batching achieves highest GPU utilization and maximizes predictions per unit time],
    frame: "rect",
    fill: light-green.transparentize(70%),
    stroke: dark-green,
    padding: 3pt,
    radius: border-radius,
  )

  content(
    (plot-width / 2, -3),
    box(width: 50em)[
      *Unbatched:* Each simulation runs sequentially with most calculations on CPU and minimal GPU utilization\
      *Binning:* Fixed-size batches improve GPU utilization but can't adapt to varying simulation completion times\
      *In-flight:* Dynamic reallocation eliminates GPU idle time by immediately adding new structures when others complete. Color changes indicate in-flight structure replacement.
    ],
    frame: "rect",
    fill: section-bg,
    stroke: 0.5pt,
    padding: (10pt, 10pt, 0pt),
    radius: border-radius,
  )
})
