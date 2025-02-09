#import "@preview/cetz:0.3.2": canvas, draw
#import "@preview/modpattern:0.1.0": modpattern

#set page(width: auto, height: auto, margin: 8pt)

#let hatched = modpattern(
  (.1cm, .1cm),
  std.line(start: (0%, 100%), end: (100%, 0%), stroke: 0.5pt),
  background: white,
)

#canvas({
  import draw: line, content, circle, mark

  // Define styles and constants
  let radius = 1.25 // \lrad in original
  let small-rad = 0.1 * radius
  let med-rad = 0.13 * radius
  let arrow-style = (
    mark: (end: "barbed", fill: black, scale: .5, width: .25, length: .2, angle: 60deg),
    stroke: (paint: black, thickness: 0.75pt),
  )

  // Helper functions
  let cross(pos, label: none, rel-label: (0, 5pt), name: none) = {
    content(
      pos,
      text(size: 16pt)[$times.circle$],
      stroke: none,
      fill: white,
      frame: "circle",
      padding: -2.5pt,
      name: name,
    )
    if label != none {
      content((rel: rel-label, to: pos), $#label$)
    }
  }

  let dressed-vertex(pos, label: none, rel-label: none, name: none, radius: small-rad) = {
    circle(pos, radius: radius, fill: hatched, stroke: black, name: name)
    if label != none {
      content(
        if rel-label != none { (rel: rel-label, to: pos) } else { pos },
        label,
      )
    }
  }

  let momentum-label(pos, num) = {
    content(pos, $p_#num$, size: 8pt)
  }

  // Draw first diagram
  // Main loop with momentum labels
  circle(
    (0, 0),
    radius: radius,
    stroke: 1pt,
    name: "main-loop",
  )

  // Add momentum arrows and labels around loop
  for (ii, pos) in ((6, "0.0625"), (1, "0.1875"), (2, "0.3125"), (3, "0.4375"), (4, "0.625"), (5, "0.875")) {
    let percent = str(calc.round(float(pos) * 100, digits: 2)) + "%"
    let angle = float(pos) * 360
    let label-angle = (angle - 3) * 1deg

    // Name each momentum point for reference
    let rel-pos = (0.75 * radius * calc.cos(label-angle), 0.75 * radius * calc.sin(label-angle))
    content(
      (rel: rel-pos, to: "main-loop"),
      $p_#ii$,
      size: 8pt,
      name: "momentum-point-" + str(ii),
    )

    // Add arrow marks around the loop
    mark(
      symbol: "barbed",
      (name: "main-loop", anchor: angle * 1deg),
      (name: "main-loop", anchor: (angle + 0.1) * 1deg),
      ..(width: .25, length: .15, stroke: .7pt, angle: 70deg, scale: .7),
    )
  }

  // Add dressed vertices and cross with descriptive names
  cross(
    (rel: (0, radius), to: "main-loop"),
    label: $partial_k R_(k,i j) (p_1,p_2)$,
    rel-label: (0, 0.5),
    name: "regulator",
  )

  dressed-vertex(
    (
      rel: (
        -radius * calc.cos(45deg),
        radius * calc.cos(45deg),
      ),
      to: "main-loop",
    ),
    label: $G_(k,j k)(p_2,p_3)$,
    rel-label: (-1.2, 0.3),
    name: "vertex-top-left",
  )

  dressed-vertex(
    (
      rel: (
        radius * calc.cos(45deg),
        radius * calc.cos(45deg),
      ),
      to: "main-loop",
    ),
    label: $G_(k,n i)(p_6,p_1)$,
    rel-label: (1.2, 0.3),
    name: "vertex-top-right",
  )

  dressed-vertex(
    (rel: (0, -radius), to: "main-loop"),
    label: $G_(k,l m) (p_4,p_5)$,
    rel-label: (0, -.8),
    name: "vertex-bottom",
  )

  // External lines with names
  line(
    (rel: (-radius, 0), to: "main-loop"),
    (rel: (-2 * radius, 0), to: "main-loop"),
    stroke: 1pt,
    name: "left-external",
  )
  line(
    (rel: (radius, 0), to: "main-loop"),
    (rel: (2 * radius, 0), to: "main-loop"),
    stroke: 1pt,
    name: "right-external",
  )

  // Add dressed vertices at external line connections
  dressed-vertex(
    (rel: (-radius, 0), to: "main-loop"),
    name: "vertex-left-external",
    radius: med-rad,
  )
  dressed-vertex(
    (rel: (radius, 0), to: "main-loop"),
    name: "vertex-right-external",
    radius: med-rad,
  )

  // External line labels relative to their lines
  content(
    (rel: (-0.2, -0.3), to: "left-external.mid"),
    $phi_a$,
    name: "left-phi",
  )
  content(
    (rel: (0.2, -0.3), to: "right-external.mid"),
    $phi_b$,
    name: "right-phi",
  )

  // External momentum arrows relative to their lines
  line(
    (rel: (-2.3, 0.15), to: "main-loop"),
    (rel: (-1.4, 0.15), to: "main-loop"),
    ..arrow-style,
    stroke: .5pt,
    name: "q1-arrow",
  )
  content(
    "q1-arrow.mid",
    $q_1$,
    anchor: "south",
    padding: (0, 0, 2pt),
  )

  line(
    (rel: (1.4, 0.15), to: "main-loop"),
    (rel: (2.3, 0.15), to: "main-loop"),
    ..arrow-style,
    stroke: .5pt,
    name: "q2-arrow",
  )
  content(
    "q2-arrow.mid",
    $q_2$,
    anchor: "south",
    padding: (0, 0, 2pt),
  )

  // Vertex labels with connecting lines relative to vertices
  let label-style = (stroke: gray + 0.3pt)
  content(
    (rel: (-2, -1.5), to: "main-loop"),
    $Gamma_(k,a k l)^(3)(q_1,p_3,-p_4)$,
    name: "left-gamma",
  )
  line(
    "left-gamma",
    (rel: (-radius, 0), to: "main-loop"),
    ..label-style,
    name: "left-connector",
  )

  content(
    (rel: (2, -1.5), to: "main-loop"),
    $Gamma_(k,b m n)^(3)(-q_2,p_5,-p_6)$,
    name: "right-gamma",
  )
  line(
    "right-gamma",
    (rel: (radius, 0), to: "main-loop"),
    ..label-style,
    name: "right-connector",
  )
})
