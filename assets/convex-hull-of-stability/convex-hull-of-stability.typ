#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, intersections, line, rect

#set page(width: auto, height: auto, margin: 3pt, fill: none)
#set text(size: 12pt)

#canvas({
  // Diagram dimensions and styles
  let width = 12
  let height = 8
  let point-radius = 0.15
  let line-thickness = 1.5pt
  let arrow-style = (mark: (end: "stealth"), stroke: line-thickness, fill: black)
  let hull-color = blue.darken(20%)
  let green = rgb("#4d8000")

  // Draw axes first to establish named positions
  line((0, 0), (0, height), ..arrow-style, name: "y-axis-left")
  line((0, 0), (width, 0), stroke: line-thickness, name: "x-axis")
  line((width, 0), (width, height), ..arrow-style, name: "y-axis-right")

  // Stable phases at x = 0, 1/2, 5/7, 1. Both elemental references sit at Delta E_f = 0.
  for (pos, label, anchor, padding, name) in (
    ((0, height - 1), "A", "west", (left: 10pt), "a"),
    ((width / 2, 2), "AX", "north", (top: 10pt), "ax"),
    ((width * 5 / 7, 1.5), $A_2X_5$, "north", (top: 10pt), "a2x5"),
    ((width, height - 1), "X", "east", (right: 10pt), "x"),
  ) {
    circle(pos, radius: point-radius, fill: hull-color, name: name)
    content(pos, label, anchor: anchor, padding: padding)
  }

  // Unstable phases at x = 1/3, 7/9
  for (pos, label, name, anchor) in (
    ((width / 3, height - 1.5), $A_2X$, "a2x", "south"),
    // Upper-left label keeps clear of the hypothetical hull leaving A₂X₇ to the upper right
    ((width * 7 / 9, 3.7), $A_2X_7$, "a2x7", "south-east"),
  ) {
    rect((rel: (-0.15, -0.15), to: pos), (rel: (0.3, 0.3)), fill: red, stroke: .5pt, name: name)
    content(pos, label, anchor: anchor, padding: (bottom: 8pt))
  }

  for (start, end) in (("a", "ax"), ("ax", "a2x5"), ("a2x5", "x")) {
    line(start, end, stroke: hull-color + 2.5pt, name: "hull-" + start + "-" + end)
  }
  content(
    (rel: (-1.8, -.8), to: "ax"),
    text(fill: hull-color)[convex hull\ of stability],
    frame: "rect",
    stroke: none,
    padding: (left: 5pt),
    fill: rgb("#cdd3da"),
    name: "hull-label",
  )
  line(
    "hull-label.north",
    "hull-a-ax.90%",
    stroke: (paint: hull-color, thickness: .5pt),
    padding: 1pt,
  )

  for (start, end) in (("ax", "a2x7"), ("a2x7", "x")) {
    line(
      start,
      end,
      stroke: (paint: gray, thickness: line-thickness, dash: "dashed"),
      name: "hyp-hull-" + start + "-" + end,
    )
  }
  content(
    (rel: (0, 0.3), to: "hyp-hull-a2x7-x.mid"),
    text(fill: gray, size: 13pt)[hypothetical hull for\ evaluating $A_2X_5$],
    anchor: "east",
  )

  // Vertical arrow from the (hypothetical) hull down or up to a phase: its decomposition energy
  let decomposition-arrow(phase, hull-segments, color) = {
    // Intersection helpers must not expand the visible diagram's bounds.
    draw.hide(line((rel: (0, 3), to: phase), (rel: (0, -3), to: phase), name: phase + "-vertical"))
    intersections(phase + "-isect", phase + "-vertical", ..hull-segments)
    line(
      phase + "-isect.0",
      phase,
      mark: (end: "stealth", fill: color),
      stroke: color + line-thickness,
      name: "arrow-" + phase,
    )
  }
  let reaction-box = (frame: "rect", padding: (1pt, 3pt), anchor: "west")

  decomposition-arrow("a2x", ("hull-a-ax", "hull-ax-a2x5"), red)
  content((rel: (-0.5, 0), to: "arrow-a2x.60%"), text(fill: red)[$Delta E_d$])
  content(
    (rel: (.2, 0), to: "arrow-a2x.30%"),
    text(fill: red)[A + AX → A₂X],
    stroke: red + .3pt,
    fill: red.lighten(90%),
    ..reaction-box,
  )

  decomposition-arrow("a2x5", ("hyp-hull-ax-a2x7", "hyp-hull-a2x7-x"), green)
  content("arrow-a2x5.mid", text(fill: green)[$Delta E_d$], anchor: "east", padding: (right: 3pt))
  content(
    (rel: (0.1, 0), to: "arrow-a2x5.mid"),
    text(fill: green)[4/5 AX + 3/5 A₂X₇ → A₂X₅],
    stroke: green + .3pt,
    fill: green.lighten(90%),
    ..reaction-box,
  )

  // The AX–A₂X₅ hull facet extended to x = 0 bounds μ_A from below; the A–AX facet from above.
  line(
    ("a2x5", 1000% / 3, "ax"),
    "ax",
    stroke: (paint: orange, thickness: line-thickness, dash: "dashed"),
    name: "mu-line",
  )
  content((rel: (2.5, 0.15), to: "mu-line.start"), rotate(11deg, text(
    fill: orange,
    size: 13pt,
  )[$μ_A$ range\ where AX is stable]))
  line(
    "hull-a-ax.2%",
    "mu-line.4%",
    mark: (symbol: "stealth", fill: orange, offset: 0.1, scale: 0.6),
    stroke: orange + line-thickness,
  )

  // Legend
  circle((0.5, 1), radius: point-radius, fill: hull-color, name: "legend-stable")
  content("legend-stable.east", "stable", anchor: "west", padding: (left: 5pt))
  rect((0.5 - 0.15, 1 - 0.6), (0.5 + 0.15, 1 - 0.3), fill: red, stroke: .5pt)
  content((0.5 + 0.15, 1 - 0.45), "unstable", anchor: "west", padding: (left: 5pt))

  content((rel: (-0.5, 0), to: "y-axis-left.mid"), rotate(
    -90deg,
    reflow: true,
  )[$Delta E_f$ (energy/atom)])
  content((width / 2, -0.5), $x "in" A_(1-x)X_x$)
})
