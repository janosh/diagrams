#import "@preview/cetz:0.5.2": canvas, decorations, draw
#import draw: circle, content, line, mark

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#let rad = 0.8
#canvas({
  let arrow-style = (stroke: (thickness: 0.5pt))

  decorations.wave(
    circle((0, 0), radius: rad),
    amplitude: .1,
    segments: 16,
    close: true,
    name: "loop",
    mark: (end: "stealth"),
    ..arrow-style,
  )

  // Left and right points on the loop (circle centered at origin with given radius)
  let loop-left = (-rad, 0)
  let loop-right = (rad, 0)

  circle(loop-left, radius: 0.075, fill: black, name: "dot")
  content(
    loop-right,
    text(size: 10pt)[$times.o$],
    name: "regulator",
    fill: white,
    frame: "circle",
    stroke: none,
    padding: -1.7pt,
  )

  line((rel: (-1, 0), to: "dot"), "dot", name: "input", ..arrow-style)

  content(
    "input.start",
    $ partial_t (partial V) / (partial chi) = $,
    anchor: "east",
    padding: (0, 5pt, 0),
  )

  let top-mark = (0, rad - 0.05)
  let bottom-mark = (0, -rad + 0.05)
  let mark-style = (
    length: .15,
    stroke: .7pt,
    angle: 60deg,
    scale: .7,
    fill: black,
  )
  mark(symbol: "stealth", top-mark, (0.1, rad - 0.05), ..mark-style)
  mark(symbol: "stealth", bottom-mark, (-0.1, -rad + 0.05), ..mark-style)
  content(top-mark, $q$, anchor: "south-east", padding: (0, 0, 5pt))
  content(bottom-mark, $q$, anchor: "north", padding: (2pt, 0, 0))
})
