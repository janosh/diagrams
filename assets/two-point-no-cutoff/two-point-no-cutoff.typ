#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, line
#import "../_shared/feynman.typ" as fey

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#let radius = 1.25
#let med-rad = 0.175 * radius
#let vertex = fey.dressed-vertex.with(radius: 0.15 * radius)
#let momenta = fey.loop-momenta.with(label-distance: 0.75 * radius)

// Momentum arrow of length 0.6*radius, drawn just above height `y`.
#let momentum(idx, x-center, y) = {
  let half = 0.3 * radius
  line(
    (x-center - half, y + 0.15),
    (x-center + half, y + 0.15),
    ..fey.momentum-arrow,
    name: "q",
  )
  content((rel: (0, 0.3), to: "q.mid"), $q_#idx$)
}

// Gamma^(3) box: loop closed by two dressed propagators, one on each side
#canvas({
  circle((0, 0), radius: radius, stroke: 1pt, name: "loop")
  momenta(((1, 0.125), (2, 0.375), (3, 0.625), (4, 0.875)))

  vertex(
    (0, radius),
    label: $G_(k,i j)(p_1,p_2)$,
    rel-label: (0, 0.2),
    anchor: "south",
    name: "vertex-top",
  )
  vertex(
    (0, -radius),
    label: $G_(k,k l)(p_3,p_4)$,
    rel-label: (0, -0.3),
    anchor: "north",
    name: "vertex-bottom",
  )

  line((-2 * radius, 0), (-radius, 0), stroke: 1pt, name: "left-external")
  line((radius, 0), (2 * radius, 0), stroke: 1pt, name: "right-external")
  content("left-external.start", $phi_a$, anchor: "east", padding: 0.1)
  content("right-external.end", $phi_b$, anchor: "west", padding: 0.1)
  momentum(1, -1.6 * radius, 0)
  momentum(2, 1.6 * radius, 0)

  for (side, label) in (
    (-1, $Gamma_(k,a j k)^((3))(q_1,p_2,-p_3)$),
    (1, $Gamma_(k,b l i)^((3))(-q_2,-p_1,p_4)$),
  ) {
    content((side * 2.1 * radius, radius), label, name: "gamma")
    line("gamma", (side * radius, 0), ..fey.callout)
    vertex((side * radius, 0), radius: med-rad)
  }
})

#pagebreak()

// Gamma^(4) tadpole: single dressed propagator over a straight external line
#canvas({
  circle((0, 0), radius: radius, stroke: 1pt, name: "loop")
  momenta(((1, 0), (2, 0.5)))

  vertex(
    (0, radius),
    label: $G_(k,i j)(p_1,p_2)$,
    rel-label: (0, 0.2),
    anchor: "south",
    name: "vertex-top",
  )

  line((-2 * radius, -radius), (2 * radius, -radius), stroke: 1pt, name: "external")
  content((rel: (-0.1, 0), to: "external.start"), $phi_a$, anchor: "east")
  content((rel: (0.1, 0), to: "external.end"), $phi_b$, anchor: "west")
  momentum(1, -1.6 * radius, -radius)
  momentum(2, 1.6 * radius, -radius)

  vertex(
    (0, -radius),
    label: $Gamma_(k,a b j i)^((4))(q_1,-q_2,-p_1,p_2)$,
    rel-label: (0, -0.3),
    radius: med-rad,
    anchor: "north",
  )
})
