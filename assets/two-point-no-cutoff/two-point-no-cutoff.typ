#import "@preview/cetz:0.4.2": canvas, draw
#import "@preview/modpattern:0.1.0": modpattern
#import draw: circle, content, line, mark

#set page(width: auto, height: auto, margin: 8pt)

// Define styles and constants
#let radius = 1.25
#let med-rad = 0.175 * radius
#let small-rad = 0.15 * radius

// Create hatched pattern for vertices
#let hatched = modpattern(
  (.1cm, .1cm),
  std.line(start: (0%, 100%), end: (100%, 0%), stroke: 0.5pt),
  background: white,
)

// Helper function for dressed vertices
#let dressed-vertex(pos, label: none, rel-label: (0, 0), name: none, radius: small-rad, ..rest) = {
  circle(pos, radius: radius, fill: hatched, name: name, stroke: 0.5pt)
  if label != none {
    let label-pos = if rel-label != none { (rel: rel-label, to: pos) } else { pos }
    content(label-pos, $#label$, ..rest)
  }
}

#canvas({
  // First diagram
  // Main loop
  circle((0, 0), radius: radius, stroke: 1pt, name: "loop")

  // Add momentum arrows and labels around loop
  for (ii, pos) in ((1, "0.125"), (2, "0.375"), (3, "0.625"), (4, "0.875")) {
    let angle = float(pos) * 360
    let label-angle = (angle - 3) * 1deg

    // Add momentum labels
    let rel-pos = (0.75 * radius * calc.cos(label-angle), 0.75 * radius * calc.sin(label-angle))
    content(
      (rel: rel-pos, to: "loop"),
      $p_#ii$,
      size: 8pt,
    )

    // Add arrow marks
    mark(
      symbol: "stealth",
      (name: "loop", anchor: angle * 1deg),
      (name: "loop", anchor: (angle + 1) * 1deg),
      ..(width: .25, length: .15, stroke: .7pt, angle: 60deg, scale: .7, fill: black),
    )
  }

  // Add dressed vertices with propagators
  dressed-vertex(
    (0, radius),
    label: $G_(k,i j)(p_1,p_2)$,
    rel-label: (0, 0.2),
    name: "vertex-top",
    anchor: "south",
  )

  dressed-vertex(
    (0, -radius),
    label: $G_(k,k l)(p_3,p_4)$,
    rel-label: (0, -0.3),
    name: "vertex-bottom",
    anchor: "north",
  )

  // External lines
  line((-2 * radius, 0), (-radius, 0), stroke: 1pt, name: "left-external")
  line((radius, 0), (2 * radius, 0), stroke: 1pt, name: "right-external")

  // External line labels
  content("left-external.start", $phi_a$, anchor: "east", padding: 0.1)
  content("right-external.end", $phi_b$, anchor: "west", padding: 0.1)

  // External momentum arrows
  let arrow-style = (
    mark: (end: "stealth", fill: black, scale: .5),
    stroke: (thickness: 0.75pt),
  )
  line(
    (-1.9 * radius, 0.15),
    (-1.3 * radius, 0.15),
    ..arrow-style,
    name: "q1-arrow",
  )
  content((rel: (0, 0.3), to: "q1-arrow.mid"), $q_1$)

  line(
    (1.3 * radius, 0.15),
    (1.9 * radius, 0.15),
    ..arrow-style,
    name: "q2-arrow",
  )
  content((rel: (0, 0.3), to: "q2-arrow.mid"), $q_2$)

  // Vertex labels with connecting lines
  let label-style = (stroke: gray + 0.3pt)
  content(
    (-2.1 * radius, radius),
    $Gamma_(k,a j k)^((3))(q_1,p_2,-p_3)$,
    name: "left-gamma",
  )
  line(
    "left-gamma",
    (-radius, 0),
    ..label-style,
  )

  content(
    (2.1 * radius, radius),
    $Gamma_(k,b l i)^((3))(-q_2,-p_1,p_4)$,
    name: "right-gamma",
  )
  line(
    "right-gamma",
    (radius, 0),
    ..label-style,
  )

  // External vertices
  dressed-vertex(
    (-radius, 0),
    radius: med-rad,
    name: "vertex-left-external",
  )
  dressed-vertex(
    (radius, 0),
    radius: med-rad,
    name: "vertex-right-external",
  )
})

#pagebreak()

#canvas({
  // Second diagram
  // Main loop
  circle((0, 0), radius: radius, stroke: 1pt, name: "loop")

  // Add momentum arrows and labels around loop
  for (ii, pos) in ((1, "0"), (2, "0.5")) {
    let angle = float(pos) * 360
    let label-angle = (angle - 3) * 1deg

    // Add momentum labels
    let rel-pos = (0.75 * radius * calc.cos(label-angle), 0.75 * radius * calc.sin(label-angle))
    content(
      (rel: rel-pos, to: "loop"),
      $p_#ii$,
      size: 8pt,
    )

    // Add arrow marks
    mark(
      symbol: "stealth",
      (name: "loop", anchor: angle * 1deg),
      (name: "loop", anchor: (angle + 1) * 1deg),
      ..(width: .25, length: .15, stroke: .7pt, angle: 60deg, scale: .7, fill: black),
    )
  }

  // Add dressed vertex with propagator
  dressed-vertex(
    (0, radius),
    label: $G_(k,i j)(p_1,p_2)$,
    rel-label: (0, 0.2),
    name: "vertex-top",
    anchor: "south",
  )

  // External line
  line((-2 * radius, -radius), (2 * radius, -radius), stroke: 1pt, name: "external")

  // External line labels
  content((rel: (-0.1, 0), to: "external.start"), $phi_a$, anchor: "east")
  content((rel: (0.1, 0), to: "external.end"), $phi_b$, anchor: "west")

  // External momentum arrows
  let arrow-style = (
    mark: (end: "stealth", fill: black, scale: .5),
    stroke: (thickness: 0.75pt),
  )
  line(
    (-1.9 * radius, -radius + 0.15),
    (-1.3 * radius, -radius + 0.15),
    ..arrow-style,
    name: "q1-arrow",
  )
  content((rel: (0, 0.3), to: "q1-arrow.mid"), $q_1$)

  line(
    (1.3 * radius, -radius + 0.15),
    (1.9 * radius, -radius + 0.15),
    ..arrow-style,
    name: "q2-arrow",
  )
  content((rel: (0, 0.3), to: "q2-arrow.mid"), $q_2$)

  // Four-vertex with label
  dressed-vertex(
    (0, -radius),
    label: $Gamma_(k,a b j i)^((4))(q_1,-q_2,-p_1,p_2)$,
    rel-label: (0, -0.3),
    radius: med-rad,
    anchor: "north",
  )
})
