#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, line
#import "../_shared/feynman.typ" as fey

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#let radius = 1 // \radius in original
#let vertex = fey.dressed-vertex.with(radius: 0.25 * radius, stroke: auto, anchor: "south")

#canvas({
  // Gamma^(3) loop: two dressed three-point vertices on the external legs
  circle((0, 0), radius: radius, stroke: 1pt, name: "loop")
  line((-2 * radius, 0), (-radius, 0), stroke: 1pt, name: "left-external")
  line((radius, 0), (2 * radius, 0), stroke: 1pt, name: "right-external")
  vertex(
    (-radius, 0),
    label: $Gamma_k^((3))$,
    rel-label: (-0.3, 0.3),
    name: "vertex-left",
  )
  vertex(
    (radius, 0),
    label: $Gamma_k^((3))$,
    rel-label: (0.3, 0.3),
    name: "vertex-right",
  )

  content((3 * radius, 0), $-$)

  // Gamma^(4) tadpole: one dressed four-point vertex on a single external line
  circle((5 * radius, 0), radius: radius, stroke: 1pt, name: "loop2")
  line((3 * radius, -radius), (7 * radius, -radius), stroke: 1pt, name: "external2")
  vertex(
    (5 * radius, -radius),
    label: $Gamma_k^((4))$,
    rel-label: (0, 0.35),
    name: "vertex-four",
  )
})
