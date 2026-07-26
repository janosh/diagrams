#import "@preview/cetz:0.5.2": canvas, draw
#import draw: content, line, rect
#import "../_shared/theme.typ": annotation-size

#set page(width: auto, height: auto, margin: 15pt, fill: none)

// Ionic steps each structure needs before it converges. Every other number in this
// figure -- batch spans, idle slots, utilization, total runtime -- is derived from this
// one array, so the three strategies are compared on identical work.
#let steps-needed = (2, 6, 4, 3, 6, 5, 2, 4, 3, 2)
#let slots = 5
#let window = 16 // steps of timeline drawn; unbatched runs off the end

// Vega category10: ten hues that stay distinct, unlike shades of one hue.
#let struct-colors = (
  rgb("#4C78A8"),
  rgb("#F58518"),
  rgb("#54A24B"),
  rgb("#E45756"),
  rgb("#B279A2"),
  rgb("#72B7B2"),
  rgb("#B8A02E"),
  rgb("#9D755D"),
  rgb("#D6698E"),
  rgb("#7F7F7F"),
)

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

#canvas({
  let dark-gray = rgb("#5D6B7A")
  let section-bg = rgb("#F7FAFC")
  let idle-stroke = rgb("#C7D0D9")
  let good = rgb("#2E7D32")
  let bad = rgb("#C62828")

  let plot-width = 24
  let x0 = 5.0 // left edge of step 0
  let cell = 1.0 // one step per tick, so the grid never drifts off the axis
  let box-width = 0.88
  let row-height = 0.3
  let row-gap = 0.14
  let radius = 0.05

  // step i spans [x0 + i, x0 + i + 1]; its tick and label sit under the center
  let step-center(i) = x0 + (i + 0.5) * cell

  let slot-y(base, slot) = base + slot * (row-height + row-gap)

  let panels = (
    (11.2, "Unbatched\nSimulations", unbatched-schedule),
    (6.0, "Binning\nAutoBatcher", binning-schedule),
    (0.8, "InFlight\nAutoBatcher", inflight-schedule),
  )

  content(
    (plot-width / 2, 14.6),
    text(weight: "bold", size: 16pt)[GPU Batching Strategies for Atomistic Simulations],
    name: "main-title",
  )
  content(
    (rel: (0, -0.85), to: "main-title"),
    text(size: 11pt, fill: dark-gray)[
      Ten structures needing #steps-needed.map(str).join(", ") ionic steps, on #slots GPU slots
    ],
  )

  for (base-y, name, schedule) in panels {
    let rows-bottom = base-y - 0.6
    let axis-y = rows-bottom - 0.55
    rect(
      (0.5, axis-y - 0.75),
      (plot-width - 0.5, slot-y(rows-bottom, slots - 1) + 0.75),
      fill: section-bg,
      stroke: none,
      radius: radius * 3,
    )
    content((2.3, base-y + 0.9), text(weight: "bold", size: 12pt)[#name])

    // occupancy meter, sized to its own text so the label cannot overflow it
    let busy = utilization(schedule)
    let meter = 2.6
    rect(
      (1.0, base-y - 0.55),
      (1.0 + meter, base-y - 0.15),
      fill: rgb("#E2E8F0"),
      stroke: 0.5pt,
      radius: 0.08,
      name: "meter-" + name,
    )
    rect(
      (1.0, base-y - 0.55),
      (1.0 + meter * busy / 100, base-y - 0.15),
      fill: if busy < 40 { bad.lighten(60%) } else if busy < 75 {
        rgb("#F9A825").lighten(55%)
      } else { good.lighten(60%) },
      stroke: none,
      radius: (west: 0.08),
    )
    content("meter-" + name, text(size: annotation-size, weight: "bold")[#busy% slots busy])
    content(
      (1.0, base-y - 0.95),
      text(size: annotation-size, fill: dark-gray)[#schedule.len() steps to finish all 10],
      anchor: "west",
    )

    // slot grid
    for (step, occupants) in schedule.slice(0, calc.min(schedule.len(), window)).enumerate() {
      for slot in range(slots) {
        let who = occupants.at(slot)
        let (x, y) = (step-center(step), slot-y(rows-bottom, slot))
        let color = if who == -1 { none } else { struct-colors.at(who) }
        rect(
          (x - box-width / 2, y),
          (x + box-width / 2, y + row-height),
          fill: if color == none { none } else { color.lighten(60%) },
          stroke: if color == none {
            (dash: "dotted", paint: idle-stroke, thickness: 0.6pt)
          } else { color },
          radius: radius,
        )
        if who != -1 {
          content((x, y + row-height / 2), text(size: annotation-size)[S#(who + 1)])
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
      line(
        (step-center(step), axis-y - 0.05),
        (step-center(step), axis-y + 0.05),
        stroke: 0.8pt,
      )
      content(
        (step-center(step), axis-y - 0.12),
        text(size: annotation-size)[t=#(step + 1)],
        anchor: "north",
      )
    }
  }

  // each panel's dead space on the right carries its own verdict
  let (unbatched-y, binning-y, inflight-y) = panels.map(panel => panel.first())
  let mid-rows(base-y) = slot-y(base-y - 0.6, 2) + row-height / 2
  content(
    (step-center(16.9), slot-y(unbatched-y - 0.6, 0) + row-height / 2),
    text(size: annotation-size, fill: bad)[
      …#(unbatched-schedule.len() - window) more steps
    ],
    anchor: "west",
  )
  content(
    (step-center(13.8), mid-rows(binning-y)),
    text(size: annotation-size, fill: bad, style: "italic")[
      #align(
        center,
      )[holes open up as a batch\ drains, and stay open until\ its slowest member converges]
    ],
    anchor: "center",
  )
  content(
    (step-center(13.8), mid-rows(inflight-y)),
    text(size: annotation-size, fill: good, style: "italic")[
      #align(center)[all ten converged by t=#inflight-schedule.len()]
    ],
    anchor: "center",
  )

  content(
    (plot-width / 2, -3.4),
    box(width: 46em)[
      *Unbatched* runs one structure at a time, leaving four of five slots idle.
      *Binning* fills a batch once and holds every slot until the batch's slowest member
      converges, so the holes grow as the batch drains.
      *In-flight* refills a slot the moment its structure converges — the color and label
      changing mid-row is a new structure taking over — which finishes the same work in
      #inflight-schedule.len() steps instead of #binning-schedule.len().
    ],
    frame: "rect",
    fill: section-bg,
    stroke: 0.5pt,
    padding: 10pt,
    radius: radius,
  )
})
