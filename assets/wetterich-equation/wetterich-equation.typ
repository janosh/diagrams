#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle
#import "../_shared/feynman.typ" as fey

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#let radius = 1.25 // \lrad in original
#let med-rad = 0.175 * radius // \mrad

#canvas({
  circle((0, 0), radius: radius, stroke: 1pt, name: "loop")
  fey.loop-momenta(((1, 0.25), (2, 0.75)), label-distance: 0.75 * radius)

  fey.cross(
    (-radius, 0),
    label: $partial_k R_(k,i j)(p_1,p_2)$,
    rel-label: (-0.25, 0),
    baseline: -0.2pt,
    padding: -2.75pt,
    name: "regulator",
    anchor: "east",
  )

  fey.dressed-vertex(
    (radius, 0),
    label: $[Gamma_k^((2)) + R_k]_(j i)^(-1)(p_2,p_1)$,
    rel-label: (0.25, 0),
    radius: med-rad,
    name: "vertex",
    anchor: "west",
  )
})
