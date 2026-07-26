#import "@preview/cetz:0.5.2": canvas, draw
#import draw: bezier, circle, content, line, rect
#import "../_shared/theme.typ": annotation-size

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#canvas({
  let arrow-style = (mark: (end: "stealth", fill: black, scale: 0.5))
  let plot = (width: 18, height: 8)
  let structure = (width: 2.4, row-height: 1.4)
  let step = (width: 3.5, padding: 0.3, spacing: 1.0, y-offset: 0.4)
  let title-height = plot.height + 1.5
  let step-x = idx => step.width / 2 + 0.5 + idx * (step.width + step.spacing)

  let blue = rgb("#8bc6f6")
  let green = rgb("#48BB78")
  let orange = rgb("#ED8936")
  let purple-1 = rgb("#cdbfea")
  let red = rgb("#F56565")
  let pink = rgb("#ED64A6")
  let yellow = rgb("#ECC94B")
  let teal = rgb("#81E6D9")
  let purple-2 = rgb("#9F7AEA")

  // solid arrow for a structure continuing into the next step
  let continuing(from, to, color) = bezier(
    from,
    to,
    (rel: (0.5, 0), to: from),
    (rel: (-0.5, 0), to: to),
    stroke: color + 0.8pt,
    mark: (end: "stealth", fill: color, scale: 0.6),
  )

  // dotted arrow for allocation from / convergence to a pool
  let pool-arrow(from, to, ctrl-from, ctrl-to, color, mark-pos) = bezier(
    from,
    to,
    (rel: ctrl-from, to: from),
    (rel: ctrl-to, to: to),
    stroke: (dash: "dotted", paint: color),
    mark: (pos: mark-pos, end: "stealth", fill: color, scale: 0.6, shorten-to: none),
  )

  content(
    (plot.width / 2, title-height),
    text(weight: "bold", size: 14pt)[
      Concurrent MLIP Structure Relaxations with In-Flight Auto-Batching
    ],
    name: "title",
  )

  for (x, label, fill, name, padding) in (
    (
      plot.width / 3 - 1,
      [Initial Structure Pool],
      rgb(230, 255, 230),
      "initial-pool",
      (7pt, 9pt, 8pt),
    ),
    (
      2 * plot.width / 3 + 1,
      [Converged Structure Pool],
      rgb(255, 230, 230),
      "relaxed-pool",
      (7pt, 9pt, 4pt),
    ),
  ) {
    content(
      (x, title-height - 1.2),
      text(size: 14pt, label),
      frame: "rect",
      padding: padding,
      stroke: none,
      fill: fill,
      name: name,
    )
  }

  line((0, 0), (plot.width, 0), ..arrow-style, name: "x-axis")
  line((0, 0), (0, plot.height), ..arrow-style, name: "y-axis")
  content(
    (rel: (-.4, 0), to: "y-axis.mid"),
    align(horizon, rotate(-90deg)[Memory Usage]),
    name: "y-label",
  )

  line((0, 7), (plot.width, 7), stroke: (dash: "dotted", thickness: 1pt), name: "memory-limit")
  content(
    (rel: (0.2, -0.1), to: "memory-limit.start"),
    text(size: 9pt)[Maximum memory threshold\ (based on GPU capacity)],
    anchor: "north-west",
  )

  // memory-usage region, atom total and step label per batch
  for (idx, (rows, total)) in ((3, "150"), (4, "160"), (3, "145"), (4, "170")).enumerate() {
    let name = "batch" + str(idx + 1)
    rect(
      (step-x(idx) - step.width / 2, step.y-offset),
      (step-x(idx) + step.width / 2, rows * structure.row-height + step.padding + step.y-offset),
      fill: rgb(240, 240, 240),
      stroke: none,
      radius: 0.5,
      name: name,
    )
    content(
      (rel: (0, 0.1), to: name + ".north"),
      text(size: annotation-size)[#total atoms total],
      anchor: "south",
    )
    content((rel: (0, -0.7), to: name + ".south"), [*Step #(idx + 1)*])
  }

  let base-y = step.y-offset + 0.8

  // (step, row, color, label, atoms, name suffix, converged); the suffix distinguishes
  // repeat appearances of a structure that has not relaxed yet
  for (step-idx, row, color, label, atoms, suffix, converged) in (
    (0, 0, blue, "1", 50, "", true),
    (0, 1, green, "2", 45, "", false),
    (0, 2, orange, "3", 55, "", false),
    (1, 0, purple-1, "4", 40, "", true),
    (1, 1, green, "2", 45, "-2", true),
    (1, 2, orange, "3", 55, "-2", false),
    (1, 3, red, "5", 20, "", true),
    (2, 0, orange, "3", 50, "-3", true),
    (2, 1, pink, "6", 60, "", false),
    (2, 2, yellow, "7", 35, "", false),
    (3, 0, pink, "6", 60, "-2", false),
    (3, 1, yellow, "7", 35, "-2", true),
    (3, 2, teal, "8", 45, "", false),
    (3, 3, purple-2, "9", 30, "", false),
  ) {
    let (x, y) = (step-x(step-idx), base-y + row * structure.row-height)
    let name = "struct-" + label + suffix
    rect(
      (x - structure.width / 2, y - 0.4),
      (x + structure.width / 2, y + 0.4),
      fill: color,
      stroke: 0.5pt,
      radius: 0.2, // max 0.2 due to CeTZ 0.5.0 border anchor bug with rounded rects
      name: name,
    )
    content(name, [Structure #label])
    content((rel: (0, -0.5), to: name), text(size: annotation-size)[#atoms atoms], anchor: "north")
    if converged {
      content(
        (rel: (0.1, 0), to: name + ".east"),
        text(size: 12pt, fill: rgb("#38A169"))[✓],
        anchor: "west",
      )
    }
  }

  // continuation dots after step 4
  for row in range(4) {
    for dot in range(3) {
      circle(
        (step-x(3) + 0.65 * step.width + dot * 0.25, base-y + row * structure.row-height),
        radius: 0.1,
        stroke: 0.2pt,
        fill: rgb("#CBD5E0"),
      )
    }
  }

  // structures that survive a step reappear in the next one
  for (from, to, color) in (
    ("struct-2", "struct-2-2", green),
    ("struct-3", "struct-3-2", orange),
    ("struct-3-2", "struct-3-3", orange),
    ("struct-6", "struct-6-2", pink),
    ("struct-7", "struct-7-2", yellow),
  ) {
    continuing(from + ".east", to + ".west", color)
  }

  // relaxed structures peel off to the converged pool
  for (anchor, ctrl-to, color, mark-pos) in (
    ("struct-1.north-east", (-0.25, -0.5), blue, 30%),
    ("struct-2-2.north-east", (0, -0.5), green, 50%),
    ("struct-4.north-east", (0.25, -0.5), purple-1, 50%),
    ("struct-5.north-east", (0.5, -0.5), red, 50%),
    ("struct-3-3.north-east", (0.25, -5), orange, 50%),
    ("struct-7-2.north-east", (0.75, -0.5), yellow, 25%),
  ) {
    pool-arrow(anchor, "relaxed-pool.south", (0, 0.5), ctrl-to, color, mark-pos)
  }

  // freed capacity is refilled from the initial pool
  for (anchor, ctrl-from, color, mark-pos) in (
    ("struct-4.north-west", (-0.5, -5), purple-2, 50%),
    ("struct-5.north-east", (0.15, -0.5), red, 50%),
    ("struct-6.north-west", (-0.15, -0.5), pink, 20%),
    ("struct-7.north-west", (-0.3, -0.5), yellow, 20%),
    ("struct-8.north-west", (-0.4, -0.5), teal, 50%),
    ("struct-9.north-west", (-0.25, -0.5), purple-2, 50%),
  ) {
    pool-arrow("initial-pool.south", anchor, ctrl-from, (0, 0.5), color, mark-pos)
  }
})
