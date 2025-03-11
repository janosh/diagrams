#import "@preview/cetz:0.3.4": canvas, draw, decorations
#import draw: line, content, circle, intersections, hide, mark

#set page(width: auto, height: auto, margin: 8pt)

#let equation = $partial_t (diff V) / (diff chi) =$
#let rad = 0.8
#canvas({
  // Define styles
  let arrow-style = (stroke: (thickness: 0.5pt))

  // Draw the loop using wave decoration
  decorations.wave(
    circle((0, 0), radius: rad),
    amplitude: .1,
    segments: 16,
    close: true,
    name: "loop",
    mark: (end: "stealth"),
    ..arrow-style,
  )

  // Find left and right position on the loop
  intersections(
    "loop-points",
    "loop",
    hide(
      line(
        (rel: (-2 * rad, 0), to: "loop.centroid"),
        (rel: (+2 * rad, 0), to: "loop.centroid"),
      ),
    ),
  )

  // Add vertices
  circle("loop-points.0", radius: 0.075, fill: black, name: "dot")
  content(
    "loop-points.1",
    text(size: 10pt)[$times.circle$],
    name: "regulator",
    fill: white,
    frame: "circle",
    stroke: none,
    padding: -1.7pt,
  )

  // Draw input line
  line((rel: (-1, 0), to: "dot"), "dot", name: "input", ..arrow-style)

  content(
    "input.start",
    $ partial_t (diff V) / (diff chi) = $,
    anchor: "east",
    padding: (0, 5pt, 0),
  )

  // Add momentum arrows
  let top-mark = (0, rad - 0.05)
  let bottom-mark = (0, -rad + 0.05)
  let mark-style = (length: .15, stroke: .7pt, angle: 60deg, scale: .7, fill: black)
  mark(symbol: "stealth", top-mark, (0.1, rad - 0.05), ..mark-style)
  mark(symbol: "stealth", bottom-mark, (-0.1, -rad + 0.05), ..mark-style)
  // Add momentum labels
  content(top-mark, $q$, anchor: "south-east", padding: (0, 0, 5pt))
  content(bottom-mark, $q$, anchor: "north", padding: (2pt, 0, 0))
})
