#import "@preview/cetz:0.5.2": canvas, decorations, draw
#import draw: circle, content, line

#set page(width: auto, height: auto, margin: 4pt, fill: none)
#set text(size: 12pt)

#let pt-cm = 0.03528

// Match original TikZ geometry and label distances.
#let line-len = 8.0
#let x-anchor = (0.0, 3.0, 5.0, 8.0) // -infty, 0, 1, infty
#let tick-labels = ($-infinity$, $0$, $1$, $infinity$)
#let line-thickness = 0.8pt

// Numbered real line with y_1, y_2, y_3 above the points 0, 1, infty
// and a brace over the interval holding y_4.
#let real-line(ox, oy, above-labels, ordering-num, brace-span) = {
  line((ox, oy), (ox + line-len, oy), stroke: line-thickness)
  content((ox - 0.2, oy), str(ordering-num) + ".", anchor: "east")
  content((ox + line-len + 0.4, oy), [$bb(R)$], anchor: "west")

  for (dx, below-label) in x-anchor.zip(tick-labels) {
    circle((ox + dx, oy), radius: 0.1, fill: black)
    content((ox + dx, oy - 0.22), below-label, anchor: "north")
  }
  for (dx, label) in x-anchor.slice(1).zip(above-labels) {
    content((ox + dx, oy + 12.0 * pt-cm), label, anchor: "south")
  }

  let (start-x, end-x) = brace-span.map(x => ox + x)
  let brace-y = oy + 5.0 * pt-cm
  decorations.flat-brace(
    (start-x, brace-y),
    (end-x, brace-y),
    stroke: line-thickness,
    amplitude: 5.0 * pt-cm,
  )
  content(((start-x + end-x) / 2, brace-y + 8.0 * pt-cm), $y_4$, anchor: "south")
}

#canvas(length: 1cm, {
  // Row i puts y_4 in the i-th interval; the right column swaps y_1 and y_2.
  for (row-idx, brace-span) in x-anchor.windows(2).enumerate() {
    let row-y = -row-idx * 1.8
    real-line(0, row-y, ($y_1$, $y_2$, $y_3$), 2 * row-idx + 1, brace-span)
    real-line(line-len + 2.1, row-y, ($y_2$, $y_1$, $y_3$), 2 * row-idx + 2, brace-span)
  }
})
