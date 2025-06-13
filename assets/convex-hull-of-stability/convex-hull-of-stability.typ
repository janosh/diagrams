#import "@preview/cetz:0.4.0": canvas, draw, vector
#import draw: line, content, rect, circle, intersections

#set page(width: auto, height: auto, margin: 3pt)

#canvas({
  // Diagram dimensions and styles
  let width = 12
  let height = 8
  let point_radius = 0.15
  let line_thickness = 1.5pt
  let arrow_style = (mark: (end: "stealth"), stroke: line_thickness, fill: black)
  let hull_style = (stroke: blue.darken(20%) + 2.5pt)
  let hyp_hull_style = (stroke: (paint: gray, thickness: line_thickness, dash: "dashed"))


  // Draw axes first to establish named positions
  line((0, 0), (0, height), ..arrow_style, name: "y-axis-left")
  line((0, 0), (width, 0), stroke: line_thickness, name: "x-axis")
  line((width, 0), (width, height), ..arrow_style, name: "y-axis-right")

  // Draw stable points
  let stable_point(pos, label, anchor: "north", padding: none, ..rest) = {
    circle(pos, radius: point_radius, fill: blue.darken(20%), ..rest)
    content(pos, label, anchor: anchor, padding: padding)
  }

  stable_point((0, height - 1), "A", anchor: "west", padding: (left: 10pt), name: "a")
  stable_point((width / 2, 2), "AX", anchor: "north", padding: (top: 10pt), name: "ax")
  stable_point((width * 5 / 7, 1.5), $A_2X_5$, anchor: "north", padding: (top: 10pt), name: "a2x5")
  stable_point((width, height - 1.5), "X", anchor: "east", padding: (right: 10pt), name: "x")

  // Draw unstable points
  let unstable_point(pos, label, ..rest) = {
    let (x, y) = pos
    rect((x, y - 0.15), (x + 0.3, y + 0.15), fill: red, stroke: .5pt, ..rest)
    content(pos, label, anchor: "south", padding: (bottom: 8pt))
  }

  unstable_point((width / 3, height - 1.5), $A_2X$, name: "a2x")
  unstable_point((width * 7 / 9, 3.7), $A_2X_7$, name: "a2x7")

  // Draw convex hull
  line("a", "ax", ..hull_style, name: "hull-a-ax")
  line("ax", "a2x5", ..hull_style, name: "hull-ax-a2x5")
  line("a2x5", "x", ..hull_style, name: "hull-a2x5-x")
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

  // Draw hypothetical hull
  line("ax", "a2x7", ..hyp_hull_style, name: "hyp-hull-ax-a2x7")
  line("a2x7", "x", ..hyp_hull_style, name: "hyp-hull-a2x7-x")
  content(
    (rel: (0, 0.3), to: "hyp-hull-a2x7-x.mid"),
    text(fill: gray, size: 13pt)[hypothetical hull for\ evaluating $A_2X_5$],
    anchor: "east",
  )

  // Draw decomposition energy arrows
  // First draw invisible lines to find intersections
  line(
    (rel: (0, 3), to: "a2x"),
    (rel: (0, -3), to: "a2x"),
    stroke: none,
    name: "a2x-vertical",
  )
  intersections("a2x-isect", "a2x-vertical", "hull-a-ax", "hull-ax-a2x5")

  // Draw arrow between intersection points
  line(
    "a2x-isect.0",
    "a2x",
    mark: (end: "stealth", fill: red),
    stroke: red + line_thickness,
    name: "arrow-a2x",
  )
  content(
    (rel: (-0.5, 0), to: "arrow-a2x.60%"),
    text(fill: red)[$Delta E_d$],
  )
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

  // Draw arrow between intersection points
  line(
    "a2x5-isect.0",
    "a2x5",
    mark: (end: "stealth", fill: rgb("#4d8000")),
    stroke: rgb("#4d8000") + line_thickness,
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

  // Draw chemical potential range
  line(
    (0, height - 4.5),
    "ax",
    stroke: (paint: orange, thickness: line_thickness, dash: "dashed"),
    name: "mu-line",
  )
  content(
    (rel: (2.4, 0), to: "mu-line.start"),
    rotate(14deg)[#text(fill: orange, size: 13pt)[$μ_A$ range\ where AX is stable]],
  )

  // Draw orange double arrow
  line(
    "hull-a-ax.2%",
    "mu-line.4%",
    mark: (symbol: "stealth", fill: orange, offset: 0.1, scale: 0.6),
    stroke: orange + line_thickness,
    name: "mu-arrow",
  )

  // Draw legend
  circle((0.5, 1), radius: point_radius, fill: blue.darken(20%), name: "legend-stable")
  content(
    "legend-stable.east",
    "stable",
    anchor: "west",
    padding: (left: 5pt),
  )
  rect(
    (rel: (-0.15, -0.6), to: "legend-stable"),
    (rel: (0.15, -0.3), to: "legend-stable"),
    fill: red,
    stroke: red,
    name: "legend-unstable",
  )
  content(
    "legend-unstable.east",
    "unstable",
    anchor: "west",
    padding: (left: 5pt),
  )

  // Add axis labels
  content(
    (rel: (-0.5, 0), to: "y-axis-left.mid"),
    [#rotate(-90deg)[$Delta E_f$ (energy/atom)]],
  )
  content((width / 2, -0.5), $x "in" A_(1-x)X_x$)
})
