#import "@preview/cetz:0.5.2": canvas, decorations, draw
#import draw: circle, content, line

#set page(width: auto, height: auto, margin: 4pt, fill: none)
#set text(size: 10pt, fill: black)

#let pt-cm = 0.03528
#let mm-cm = 0.1

// Match original TikZ geometry and label distances.
#let line-len = 8.0
#let col-sep = 2.1 // increased gap between left and right groups
#let row-sep = 1.8
#let x-anchor = (0.0, 3.0, 5.0, 8.0) // -infty, 0, 1, infty
#let brace-spans = ((0.0, 3.0), (3.0, 5.0), (5.0, 8.0))

#let dot-radius = 0.1 // 1mm
#let line-thickness = 0.8pt
#let brace-raise = 5.0 * pt-cm
#let brace-amplitude = 5.0 * pt-cm
#let left-label-offset = 2.0 * mm-cm
#let right-label-offset = 4.0 * mm-cm
#let below-label-offset = 2.2 * mm-cm
#let above-label-offset = 12.0 * pt-cm
#let brace-label-offset = 8.0 * pt-cm
#let brace-style = (
  stroke: (thickness: line-thickness, paint: black),
  fill: none,
  amplitude: brace-amplitude,
  flip: false,
)
#let tick-labels = ($-infinity$, $0$, $1$, $infinity$)
#let interior-anchor = (x-anchor.at(1), x-anchor.at(2), x-anchor.at(3))

#let real-line(ox, oy, above-labels, ordering-num, name-prefix) = {
  // Main line
  line(
    (ox, oy),
    (ox + line-len, oy),
    stroke: line-thickness,
    name: name-prefix + "-line",
  )
  content(
    (ox - left-label-offset, oy),
    str(ordering-num) + ".",
    anchor: "east",
    name: name-prefix + "-num",
  )
  content(
    (ox + line-len + right-label-offset, oy),
    [$bb(R)$],
    anchor: "west",
    name: name-prefix + "-R",
  )

  // Dots at x anchors with labels below.
  for (idx, dx) in x-anchor.enumerate() {
    let below-label = tick-labels.at(idx)
    circle(
      (ox + dx, oy),
      radius: dot-radius,
      fill: black,
      name: name-prefix + "-dot-" + str(idx),
    )
    content(
      (ox + dx, oy - below-label-offset),
      below-label,
      anchor: "north",
      name: name-prefix + "-below-" + str(idx),
    )
  }

  // Labels above interior positions (3, 5, 8)
  for (idx, label) in above-labels.enumerate() {
    let dx = interior-anchor.at(idx)
    content(
      (ox + dx, oy + above-label-offset),
      label,
      anchor: "south",
      name: name-prefix + "-above-" + str(idx),
    )
  }
}

#let draw-brace-label(ox, oy, span-idx, name-prefix) = {
  let span = brace-spans.at(span-idx)
  let start-x = ox + span.at(0)
  let end-x = ox + span.at(1)
  let brace-y = oy + brace-raise
  decorations.flat-brace((start-x, brace-y), (end-x, brace-y), ..brace-style)
  content(
    ((start-x + end-x) / 2, brace-y + brace-label-offset),
    $y_4$,
    anchor: "south",
    name: name-prefix + "-brace-label",
  )
}

#canvas(length: 1cm, {
  let col-2 = line-len + col-sep
  let rows = (0, -row-sep, -2 * row-sep)
  for (row-idx, row-y) in rows.enumerate() {
    let span-idx = row-idx
    let left-num = 2 * row-idx + 1
    let right-num = left-num + 1
    let left-name = "A" + str(left-num)
    let right-name = "A" + str(right-num)
    real-line(0, row-y, ($y_1$, $y_2$, $y_3$), left-num, left-name)
    draw-brace-label(0, row-y, span-idx, left-name)
    real-line(col-2, row-y, ($y_2$, $y_1$, $y_3$), right-num, right-name)
    draw-brace-label(col-2, row-y, span-idx, right-name)
  }
})
