#import "@preview/cetz:0.5.2": canvas, decorations, draw
#import draw: circle, content, line, mark

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 12pt)

#let rad = 0.8
#canvas({
  let arrow-style = (stroke: (thickness: 0.5pt))

  decorations.wave(
    circle((0, 0), radius: rad),
    amplitude: .1,
    segments: 16,
    close: true,
    mark: (end: "stealth"),
    ..arrow-style,
  )

  // Vertex on the left of the loop, regulator insertion on the right
  circle((-rad, 0), radius: 0.075, fill: black, name: "dot")
  content((rad, 0), $times.o$, fill: rgb("#cdd3da"), frame: "circle", stroke: none, padding: -1.7pt)

  line((rel: (-1, 0), to: "dot"), "dot", name: "input", ..arrow-style)
  content("input.start", $ partial_t (partial V) / (partial chi) = $, anchor: "east", padding: (
    0,
    5pt,
    0,
  ))

  // Momentum arrows circulating clockwise along the loop
  let mark-style = (length: .15, stroke: .7pt, angle: 60deg, scale: .7, fill: black)
  for (sign, label-style) in (
    (1, (anchor: "south-east", padding: (0, 0, 5pt))),
    (-1, (anchor: "north", padding: (2pt, 0, 0))),
  ) {
    let mark-pos = (0, sign * (rad - 0.05))
    mark(symbol: "stealth", mark-pos, (sign * 0.1, sign * (rad - 0.05)), ..mark-style)
    content(mark-pos, $q$, ..label-style)
  }
})
