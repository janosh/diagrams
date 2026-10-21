#import "@preview/cetz:0.5.3": canvas, draw
#import draw: bezier, circle, content, line, rect
#let label-size = 12pt
#let paragraph-size = 14pt
#let heading-size = 16pt

#let card(title, body, caption) = grid(
  columns: (100%,),
  block(
    width: 100%,
    inset: 12pt,
    radius: 8pt,
    fill: rgb("#cdd3da"),
    breakable: false,
  )[
    #text(size: heading-size, weight: "bold", title)
    #v(8pt)
    // Measure unconstrained artwork before scaling, including content wider than its card.
    #layout(size => {
      let artwork = text(size: label-size, body)
      std.scale(size.width / measure(artwork).width * 100%, reflow: true, artwork)
    })
    #v(7pt)
    #text(size: paragraph-size, caption)
  ],
)

#let takeaway(body) = block(
  width: 100%,
  inset: 12pt,
  radius: 6pt,
  fill: rgb("#c6d8d2"),
  breakable: false,
  text(size: paragraph-size, body),
)

#set page(width: 780pt, height: auto, margin: 22pt, fill: none)
#set text(font: "Avenir Next", size: paragraph-size, fill: rgb("#19324f"))
#set par(leading: 0.55em)

// === 1  Compare scheduling strategies ===
#let figure-0 = [

  // Ionic steps each structure needs before it converges. Every other number in this
  // figure -- batch spans, idle slots, utilization, total runtime -- is derived from this
  // one array, so the three strategies are compared on identical work.
  #let steps-needed = (2, 6, 4, 3, 6, 5, 2, 4, 3, 2)
  #let slots = 5
  #let window = 16 // steps of timeline drawn; unbatched runs off the end

  // Vega category10: ten hues that stay distinct, unlike shades of one hue.
  #let struct-colors = (
    ("#4C78A8", "#F58518", "#54A24B", "#E45756", "#B279A2")
      + ("#72B7B2", "#B8A02E", "#9D755D", "#D6698E", "#7F7F7F")
  ).map(rgb)

  // Each schedule is a list of steps, each step listing which structure occupies each
  // slot, or -1 for an idle slot.

  // One structure at a time: four slots always idle.
  #let unbatched-schedule = {
    let timeline = ()
    for (idx, needed) in steps-needed.enumerate() {
      for _ in range(needed) { timeline.push((idx,) + (-1,) * (slots - 1)) }
    }
    timeline
  }

  // Fixed batches: every slot is held until the batch's slowest member converges, so a
  // finished structure leaves a hole rather than making room for the next one.
  #let binning-schedule = {
    let timeline = ()
    for first in range(0, steps-needed.len(), step: slots) {
      let batch = steps-needed.slice(first, first + slots)
      for step in range(calc.max(..batch)) {
        timeline.push(range(slots).map(s => if batch.at(s) > step { first + s } else { -1 }))
      }
    }
    timeline
  }

  // In-flight: a converged structure is replaced immediately, so slots stay busy until
  // the queue runs dry.
  #let inflight-schedule = {
    let occupant = range(slots)
    let left = steps-needed.slice(0, slots)
    let next = slots
    let timeline = ()
    while occupant.any(idx => idx != -1) {
      timeline.push(occupant)
      for slot in range(slots) {
        if occupant.at(slot) == -1 { continue }
        left.at(slot) -= 1
        if left.at(slot) > 0 { continue }
        if next == steps-needed.len() {
          occupant.at(slot) = -1
          continue
        }
        occupant.at(slot) = next
        left.at(slot) = steps-needed.at(next)
        next += 1
      }
    }
    timeline
  }

  // Share of slot-steps that did useful work over the whole run.
  #let utilization(timeline) = {
    let busy = timeline.map(step => step.filter(s => s != -1).len()).sum()
    calc.round(100 * busy / (timeline.len() * slots))
  }

  #canvas(length: .95cm, {
    // Secondary text stays dark enough that the site's dark-mode inversion turns it light gray.
    let muted = rgb("#404040")
    let section-bg = rgb("#d1d6db")
    let idle-stroke = rgb("#C7D0D9")
    let good = rgb("#1b5e20")
    let bad = rgb("#9b1c1c")

    let plot-width = 24
    let x0 = 5.0 // left edge of step 0
    let cell = 1.0 // one step per tick, so the grid never drifts off the axis
    let box-width = 0.88
    let row-height = 0.55
    let row-gap = 0.12
    let radius = 0.05

    // step i spans [x0 + i, x0 + i + 1]; its tick and label sit under the center
    let step-center(i) = x0 + (i + 0.5) * cell

    // slot rows start just below each panel's base-y
    let slot-y(base-y, slot) = base-y - 0.6 + slot * (row-height + row-gap)

    let panels = (
      (11.2, "Unbatched\nSimulations", unbatched-schedule),
      (6.0, "Binning\nAutoBatcher", binning-schedule),
      (0.8, "InFlight\nAutoBatcher", inflight-schedule),
    )

    content(
      (plot-width / 2, 14.2),
      text(
        fill: muted,
      )[Ten structures needing #steps-needed.map(str).join(", ") ionic steps, on #slots GPU slots],
    )

    for (base-y, name, schedule) in panels {
      let axis-y = slot-y(base-y, 0) - 0.55
      rect(
        (0.5, axis-y - 0.75),
        (plot-width - 0.5, slot-y(base-y, slots - 1) + 0.75),
        fill: section-bg,
        stroke: none,
        radius: radius * 3,
      )
      content((2.3, base-y + 0.9), text(weight: "bold")[#name])

      // occupancy meter, sized to its own text so the label cannot overflow it
      let busy = utilization(schedule)
      let (meter, meter-origin) = (3.6, (1.0, base-y - 0.65))
      rect(
        meter-origin,
        (rel: (meter, 0.6)),
        fill: rgb("#c6cdd6"),
        stroke: 0.5pt,
        radius: 0.08,
        name: "meter-" + name,
      )
      let meter-fill = if busy < 40 { bad.lighten(70%) } else if busy < 75 {
        rgb("#F9A825").lighten(55%)
      } else {
        good.lighten(70%)
      }
      rect(
        meter-origin,
        (rel: (meter * busy / 100, 0.6)),
        fill: meter-fill,
        stroke: none,
        radius: (west: 0.08),
      )
      content("meter-" + name, text(weight: "bold")[#busy% slots busy])
      content(
        (rel: (0, -0.65), to: meter-origin),
        text(fill: muted)[#schedule.len() steps\ to finish all 10],
        anchor: "west",
      )

      // slot grid
      for (step, occupants) in schedule.slice(0, calc.min(schedule.len(), window)).enumerate() {
        for slot in range(slots) {
          let who = occupants.at(slot)
          let (x, y) = (step-center(step), slot-y(base-y, slot))
          let (left, right, top) = (x - box-width / 2, x + box-width / 2, y + row-height)
          if who == -1 {
            rect(
              (left, y),
              (right, top),
              stroke: (dash: "dotted", paint: idle-stroke, thickness: 0.6pt),
              radius: radius,
            )
          } else {
            let color = struct-colors.at(who)
            rect((left, y), (right, top), fill: color.lighten(60%), stroke: color, radius: radius)
            content((x, y + row-height / 2))[S#(who + 1)]
          }
        }
      }

      line(
        (x0 - 0.2, axis-y),
        (x0 + window * cell + 0.4, axis-y),
        stroke: 0.8pt,
        mark: (end: "stealth", fill: black, scale: 0.5),
      )
      for step in range(window) {
        line((step-center(step), axis-y - 0.05), (step-center(step), axis-y + 0.05), stroke: 0.8pt)
        content((step-center(step), axis-y - 0.12), [t=#(step + 1)], anchor: "north")
      }
    }

    // each panel's dead space on the right carries its own verdict
    let (unbatched-y, binning-y, inflight-y) = panels.map(panel => panel.first())
    let mid-row(base-y, slot) = slot-y(base-y, slot) + row-height / 2
    content(
      (step-center(16.9), mid-row(unbatched-y, 0)),
      text(fill: bad)[…#(unbatched-schedule.len() - window) more steps],
      anchor: "west",
    )
    content(
      (step-center(13.8), mid-row(binning-y, 2)),
      text(fill: bad, style: "italic", align(center)[
        holes open up as a batch\ drains, and stay open until\ its slowest member converges
      ]),
    )
    content(
      (step-center(13.8), mid-row(inflight-y, 2)),
      text(fill: good, style: "italic", align(
        center,
      )[all ten converged by t=#inflight-schedule.len()]),
    )
  })
]

// === 2  Follow a replacement ===
// Atoms per structure, fixed while it stays in the batch
#let structure-atoms = (
  "1": 50,
  "2": 45,
  "3": 55,
  "4": 40,
  "5": 20,
  "6": 60,
  "7": 35,
  "8": 45,
  "9": 30,
)
// (step, row, structure, converged) of each occupied batch slot
#let batch-slots = (
  (0, 0, "1", true),
  (0, 1, "2", false),
  (0, 2, "3", false),
  (1, 0, "4", true),
  (1, 1, "2", true),
  (1, 2, "3", false),
  (1, 3, "5", true),
  (2, 0, "3", true),
  (2, 1, "6", false),
  (2, 2, "7", false),
  (3, 0, "6", false),
  (3, 1, "7", true),
  (3, 2, "8", false),
  (3, 3, "9", false),
)
#let figure-1 = [

  #canvas(length: 1.12cm, {
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
      let body = text(size: 14pt, label)
      content(
        (x, title-height - 1.2),
        body,
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
      [Maximum memory threshold\ (based on GPU capacity)],
      anchor: "north-west",
    )

    let colors = (
      "1": blue,
      "2": green,
      "3": orange,
      "4": purple-1,
      "5": red,
      "6": pink,
      "7": yellow,
      "8": teal,
      "9": purple-2,
    )

    // memory-usage region, atom total and step label per batch
    for idx in range(4) {
      let batch = batch-slots.filter(entry => entry.first() == idx)
      let name = "batch" + str(idx + 1)
      rect(
        (step-x(idx) - step.width / 2, step.y-offset),
        (rel: (step.width, batch.len() * structure.row-height + step.padding)),
        fill: rgb(240, 240, 240),
        stroke: none,
        radius: 0.5,
        name: name,
      )
      content(
        (rel: (0, 0.1), to: name + ".north"),
        [#batch.map(entry => structure-atoms.at(entry.at(2))).sum() atoms total],
        anchor: "south",
      )
      content((rel: (0, -0.7), to: name + ".south"), [*Step #(idx + 1)*])
    }

    let base-y = step.y-offset + 0.8
    for (step-idx, row, label, converged) in batch-slots {
      let (x, y) = (step-x(step-idx), base-y + row * structure.row-height)
      // repeat appearances of a structure that has not relaxed yet get a -2, -3, ... suffix
      let repeats = batch-slots.filter(entry => entry.at(2) == label and entry.first() < step-idx)
      let name = (
        "struct-" + label + if repeats.len() > 0 { "-" + str(repeats.len() + 1) } else { "" }
      )
      rect(
        (x - structure.width / 2, y - 0.4),
        (rel: (structure.width, 0.8)),
        fill: colors.at(label).lighten(50%),
        stroke: 0.5pt,
        radius: 0.2, // max 0.2 due to CeTZ 0.5.0 border anchor bug with rounded rects
        name: name,
      )
      content(name, [Structure #label])
      content((rel: (0, -0.5), to: name), [#structure-atoms.at(label) atoms], anchor: "north")
      if converged {
        content((rel: (0.1, 0), to: name + ".east"), text(fill: rgb("#2E7D32"))[✓], anchor: "west")
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
      ("struct-4.north-west", (-0.5, -5), purple-1, 50%),
      ("struct-5.north-east", (0.15, -0.5), red, 50%),
      ("struct-6.north-west", (-0.15, -0.5), pink, 20%),
      ("struct-7.north-west", (-0.3, -0.5), yellow, 20%),
      ("struct-8.north-west", (-0.4, -0.5), teal, 50%),
      ("struct-9.north-west", (-0.25, -0.5), purple-2, 50%),
    ) {
      pool-arrow("initial-pool.south", anchor, ctrl-from, (0, 0.5), color, mark-pos)
    }
  })
]

Small atomistic jobs can leave a GPU underused. Batching runs several together; replacing completed jobs keeps useful work in the batch.
#v(14pt)
#stack(
  dir: ttb,
  spacing: 12pt,
  card(
    [1  Compare scheduling strategies],
    figure-0,
    [*Unbatched* leaves four of five slots idle. *Binning* holds each slot until the batch's slowest member converges. *In-flight* immediately reuses freed slots: a color change within a row marks a new structure taking over.],
  ),
  card(
    [2  Follow a replacement],
    figure-1,
    [Each structure has its own convergence state. After a structure finishes, move it to the converged pool and fill the freed capacity from the initial pool.],
  ),
)
#v(12pt)
#takeaway[*Batch by resource use, not just job count.* Atom counts, neighbor counts, memory, and model cost constrain admission. Utilization percentages in the schematic are illustrative, not measured benchmarks.]
