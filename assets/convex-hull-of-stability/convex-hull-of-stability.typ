#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, intersections, line, rect

#set page(width: auto, height: auto, margin: 3pt, fill: none)

#canvas({
  // Diagram dimensions and styles
  let width = 12
  let height = 8
  let point-radius = 0.15
  let line-thickness = 1.5pt
  let arrow-style = (
    mark: (end: "stealth"),
    stroke: line-thickness,
    fill: black,
  )
  let hull-style = (stroke: blue.darken(20%) + 2.5pt)
  let hyp-hull-style = (
    stroke: (paint: gray, thickness: line-thickness, dash: "dashed"),
  )

  // Draw axes first to establish named positions
  line((0, 0), (0, height), ..arrow-style, name: "y-axis-left")
  line((0, 0), (width, 0), stroke: line-thickness, name: "x-axis")
  line((width, 0), (width, height), ..arrow-style, name: "y-axis-right")

  let stable-point(pos, label, anchor: "north", padding: none, ..rest) = {
    circle(pos, radius: point-radius, fill: blue.darken(20%), ..rest)
    content(pos, label, anchor: anchor, padding: padding)
  }

  for spec in (
    (pos: (0, height - 1), label: "A", args: (anchor: "west", padding: (left: 10pt), name: "a")),
    (pos: (width / 2, 2), label: "AX", args: (anchor: "north", padding: (top: 10pt), name: "ax")),
    (
      pos: (width * 5 / 7, 1.5),
      label: $A_2X_5$,
      args: (anchor: "north", padding: (top: 10pt), name: "a2x5"),
    ),
    (
      pos: (width, height - 1.5),
      label: "X",
      args: (anchor: "east", padding: (right: 10pt), name: "x"),
    ),
  ) { stable-point(spec.pos, spec.label, ..spec.args) }

  let unstable-point(pos, label, ..rest) = {
    let (x, y) = pos
    rect((x, y - 0.15), (x + 0.3, y + 0.15), fill: red, stroke: .5pt, ..rest)
    content(pos, label, anchor: "south", padding: (bottom: 8pt))
  }

  for (pos, label, name) in (
    ((width / 3, height - 1.5), $A_2X$, "a2x"),
    ((width * 7 / 9, 3.7), $A_2X_7$, "a2x7"),
  ) { unstable-point(pos, label, name: name) }

  for (start, end, name) in (
    ("a", "ax", "hull-a-ax"),
    ("ax", "a2x5", "hull-ax-a2x5"),
    ("a2x5", "x", "hull-a2x5-x"),
  ) { line(start, end, ..hull-style, name: name) }
  content(
    (rel: (-1.8, -.8), to: "ax"),
    text(fill: blue.darken(20%), size: 12pt)[convex hull\ of stability],
    frame: "rect",
    stroke: none,
    padding: (left: 5pt),
    fill: white,
    name: "hull-label",
  )
  line(
    "hull-label.north",
    "hull-a-ax.90%",
    stroke: (paint: blue.darken(20%), thickness: .5pt),
    padding: 1pt,
    name: "hull-label-line",
  )

  for (start, end, name) in (
    ("ax", "a2x7", "hyp-hull-ax-a2x7"),
    ("a2x7", "x", "hyp-hull-a2x7-x"),
  ) { line(start, end, ..hyp-hull-style, name: name) }
  content(
    (rel: (0, 0.3), to: "hyp-hull-a2x7-x.mid"),
    text(fill: gray, size: 13pt)[hypothetical hull for\ evaluating $A_2X_5$],
    anchor: "east",
  )

  // First draw invisible lines to find intersections
  line(
    (rel: (0, 3), to: "a2x"),
    (rel: (0, -3), to: "a2x"),
    stroke: none,
    name: "a2x-vertical",
  )
  intersections("a2x-isect", "a2x-vertical", "hull-a-ax", "hull-ax-a2x5")

  line(
    "a2x-isect.0",
    "a2x",
    mark: (end: "stealth", fill: red),
    stroke: red + line-thickness,
    name: "arrow-a2x",
  )
  content((rel: (-0.5, 0), to: "arrow-a2x.60%"), text(fill: red)[$Delta E_d$])
  content(
    (rel: (.2, 0), to: "arrow-a2x.30%"),
    text(fill: red, size: 12pt)[A + AX → A₂X],
    frame: "rect",
    padding: (1pt, 3pt),
    stroke: red + .3pt,
    name: "box1",
    anchor: "west",
    fill: red.lighten(90%),
  )

  // Second arrow - find intersections first
  line(
    (rel: (0, 3), to: "a2x5"),
    (rel: (0, -3), to: "a2x5"),
    stroke: none,
    name: "a2x5-vertical",
  )
  intersections("a2x5-isect", "a2x5-vertical", "hyp-hull-ax-a2x7", "hyp-hull-a2x7-x")

  line(
    "a2x5-isect.0",
    "a2x5",
    mark: (end: "stealth", fill: rgb("#4d8000")),
    stroke: rgb("#4d8000") + line-thickness,
    name: "arrow-a2x5",
  )
  content(
    "arrow-a2x5.mid",
    text(fill: rgb("#4d8000"))[$Delta E_d$],
    anchor: "east",
    padding: (right: 3pt),
  )
  content(
    (rel: (0.1, 0), to: "arrow-a2x5.mid"),
    text(fill: rgb("#4d8000"), size: 10pt)[4/5 AX + 3/5 A₂X₇ → A₂X₅],
    frame: "rect",
    padding: (1pt, 3pt),
    stroke: rgb("#4d8000") + .3pt,
    name: "box2-label",
    anchor: "west",
    fill: rgb("#4d8000").lighten(90%),
  )

  line(
    (0, height - 4.5),
    "ax",
    stroke: (paint: orange, thickness: line-thickness, dash: "dashed"),
    name: "mu-line",
  )
  content((rel: (2.4, 0), to: "mu-line.start"), rotate(14deg)[#text(
    fill: orange,
    size: 13pt,
  )[$μ_A$ range\ where AX is stable]])

  line(
    "hull-a-ax.2%",
    "mu-line.4%",
    mark: (symbol: "stealth", fill: orange, offset: 0.1, scale: 0.6),
    stroke: orange + line-thickness,
    name: "mu-arrow",
  )

  circle(
    (0.5, 1),
    radius: point-radius,
    fill: blue.darken(20%),
    name: "legend-stable",
  )
  content("legend-stable.east", "stable", anchor: "west", padding: (left: 5pt))
  rect(
    (0.5 - 0.15, 1 - 0.6),
    (0.5 + 0.15, 1 - 0.3),
    fill: red,
    stroke: red,
    name: "legend-unstable",
  )
  content((0.5 + 0.15, 1 - 0.45), "unstable", anchor: "west", padding: (
    left: 5pt,
  ))

  content((rel: (-0.5, 0), to: "y-axis-left.mid"), [#rotate(
    -90deg,
  )[$Delta E_f$ (energy/atom)]])
  content((width / 2, -0.5), $x "in" A_(1-x)X_x$)
})
