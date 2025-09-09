#import "@preview/cetz:0.4.2": canvas, draw
#import "@preview/modpattern:0.1.0": modpattern
#import draw: circle, content, line, mark

#set page(width: auto, height: auto, margin: 8pt)

// Constants
#let radius = 1.2 // Increased for better spacing
#let med-rad = 0.175 * radius // \mrad
#let small-rad = 0.15 * radius // \srad

// Styles
#let arrow-style = (
  mark: (end: "stealth", fill: black, scale: .5),
  stroke: (thickness: 0.75pt),
)
#let label-style = (stroke: gray + 0.3pt)
#let hatched = modpattern(
  (.1cm, .1cm),
  std.line(start: (0%, 100%), end: (100%, 0%), stroke: 0.5pt),
  background: white,
)

// Helper functions
#let cross(pos, label: none, rel-label: (6pt, 0), name: none, ..rest) = {
  let txt = text(size: 16pt, baseline: -0.25pt)[$times.circle$]
  content(pos, txt, stroke: none, fill: white, frame: "circle", padding: -2.7pt, name: name, ..rest)
  if label != none {
    content((rel: rel-label, to: pos), $#label$, anchor: "west")
  }
}

#let dressed-vertex(pos, label: none, rel-label: (3pt, 0), name: none, radius: small-rad, ..rest) = {
  circle(pos, radius: radius, fill: hatched, name: name, stroke: 0.5pt)
  if label != none {
    let label-pos = if rel-label != none { (rel: rel-label, to: pos) } else { pos }
    content(label-pos, $#label$, ..rest)
  }
}

#canvas({
  // Main loop with momentum labels
  circle((0, 0), radius: radius, stroke: 1pt, name: "loop")

  // Add momentum arrows and labels around loop
  for (ii, pos) in ((2, "0.125"), (3, "0.375"), (4, "0.625"), (1, "0.875")) {
    let angle = float(pos) * 360
    let label-angle = (angle - 3) * 1deg

    // Add momentum labels
    let rel-pos = (0.6 * radius * calc.cos(label-angle), 0.6 * radius * calc.sin(label-angle))
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

  // Add vertices with labels
  cross(
    (radius, 0),
    label: $partial_k R_(k,i j)(p_1,p_2)$,
    rel-label: (0.3, 0),
    name: "regulator",
  )

  dressed-vertex(
    (0, radius),
    label: $G_(k,j k)(p_2,p_3)$,
    rel-label: (0, 0.3),
    name: "vertex-top",
  )

  dressed-vertex(
    (0, -radius),
    label: $G_(k,l i)(p_4,p_1)$,
    rel-label: (0, -0.3),
    name: "vertex-bottom",
  )

  // External line
  line((-2.5 * radius, 0), (-radius, 0), stroke: 1pt, name: "external")
  content((rel: (-0.6 * radius, -0.3), to: "external"), $phi_a$)

  // External momentum arrow
  line(
    (-2.3 * radius, 0.15),
    (-1.5 * radius, 0.15),
    ..arrow-style,
    name: "q-arrow",
  )
  content((rel: (0, 0.3), to: "q-arrow.mid"), $q$)

  // Vertex label with connecting line
  content(
    (-2.2 * radius, 1.2 * radius),
    $Gamma_(k,a k l)^((3))(q,p_3,-p_4)$,
    name: "gamma-label",
  )
  line(
    "gamma-label",
    (-radius, 0),
    ..label-style,
  )

  // Dressed vertex at external line connection
  dressed-vertex(
    (-radius, 0),
    radius: med-rad,
    name: "vertex-external",
  )
})
