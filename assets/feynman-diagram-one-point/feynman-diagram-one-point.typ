#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, line
#import "../_shared/feynman.typ" as fey

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#let radius = 1.2 // Increased for better spacing
#let med-rad = 0.175 * radius // \mrad
#let vertex = fey.dressed-vertex.with(radius: 0.15 * radius) // \srad

#canvas({
  circle((0, 0), radius: radius, stroke: 1pt, name: "loop")
  fey.loop-momenta(
    ((2, 0.125), (3, 0.375), (4, 0.625), (1, 0.875)),
    label-distance: 0.6 * radius,
  )

  fey.cross(
    (radius, 0),
    label: $partial_k R_(k,i j)(p_1,p_2)$,
    rel-label: (0.3, 0),
    baseline: -0.25pt,
    padding: -2.7pt,
    anchor: "west",
    name: "regulator",
  )
  vertex(
    (0, radius),
    label: $G_(k,j k)(p_2,p_3)$,
    rel-label: (0, 0.5),
    name: "vertex-top",
  )
  vertex(
    (0, -radius),
    label: $G_(k,l i)(p_4,p_1)$,
    rel-label: (0, -0.5),
    name: "vertex-bottom",
  )

  line((-2.5 * radius, 0), (-radius, 0), stroke: 1pt, name: "external")
  content((rel: (-0.6 * radius, -0.3), to: "external"), $phi_a$)
  line(
    (-2.3 * radius, 0.15),
    (-1.5 * radius, 0.15),
    ..fey.momentum-arrow,
    name: "q-arrow",
  )
  content((rel: (0, 0.3), to: "q-arrow.mid"), $q$)

  content(
    (-2.2 * radius, 1.2 * radius),
    $Gamma_(k,a k l)^((3))(q,p_3,-p_4)$,
    name: "gamma-label",
  )
  line("gamma-label", (-radius, 0), stroke: fey.leader)
  vertex((-radius, 0), radius: med-rad, name: "vertex-external")
})
