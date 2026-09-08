#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, line

// Diagonal hatching marking a vertex as dressed rather than bare.
#let hatched = tiling(size: (.1cm, .1cm))[
  #place(std.rect(width: 100%, height: 100%, fill: white, stroke: none))
  #place(std.line(start: (0%, 100%), end: (100%, 0%), stroke: 0.4pt))
]

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#let radius = 1 // \radius in original
// Dressed vertices use hatching; trailing options position their labels.
#let vertex(pos, label, offset, radius: 0.25 * radius, name: none, ..style) = {
  circle(pos, radius: radius, fill: hatched, name: name, stroke: auto)
  content((rel: offset, to: pos), $#label$, anchor: "south", ..style)
}

#canvas({
  // Gamma^(3) loop: two dressed three-point vertices on the external legs
  circle((0, 0), radius: radius, stroke: 1pt, name: "loop")
  line((-2 * radius, 0), (-radius, 0), stroke: 1pt, name: "left-external")
  line((radius, 0), (2 * radius, 0), stroke: 1pt, name: "right-external")
  vertex((-radius, 0), $Gamma_k^((3))$, (-0.3, 0.3), name: "vertex-left")
  vertex((radius, 0), $Gamma_k^((3))$, (0.3, 0.3), name: "vertex-right")

  content((3 * radius, 0), $-$)

  // Gamma^(4) tadpole: one dressed four-point vertex on a single external line
  circle((5 * radius, 0), radius: radius, stroke: 1pt, name: "loop2")
  line((3 * radius, -radius), (7 * radius, -radius), stroke: 1pt, name: "external2")
  vertex((5 * radius, -radius), $Gamma_k^((4))$, (0, 0.35), name: "vertex-four")
})
