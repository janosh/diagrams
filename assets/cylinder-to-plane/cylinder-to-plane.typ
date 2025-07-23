#import "@preview/cetz:0.4.1": canvas, draw
#import draw: arc, circle, content, line

#set page(width: auto, height: auto, margin: 8pt)

// Constants
#let arrow-style = (
  mark: (end: "stealth", fill: black, scale: 0.7),
  stroke: 0.8pt,
)

#canvas({
  // Left side (cylinder)
  // Vertical lines
  arc(
    (2.6, 0),
    start: -90deg,
    stop: -270deg,
    radius: (0.5, 1.5),
    stroke: (dash: "dashed"),
    name: "tau2-arc",
  )
  arc(
    (1.4, 0),
    start: -90deg,
    stop: -270deg,
    radius: (0.5, 1.5),
    stroke: (dash: "dashed"),
    name: "tau1-arc",
  )
  arc(
    (-0.4, 0),
    start: -90deg,
    stop: -270deg,
    radius: (0.5, 1.5),
    ..arrow-style,
    name: "sigma-arc",
  )
  // Labels
  content("tau1-arc.mid", $tau_1$, anchor: "east", padding: 2pt)
  content("tau2-arc.mid", $tau_2$, anchor: "east", padding: 2pt)
  content("sigma-arc.mid", $sigma$, anchor: "east", padding: 2pt)


  // Draw cylinder: Horizontal lines
  line((0, 0), (4, 0), name: "bottom-line") // bottom
  line((0, 3), (4, 3), name: "top-line") // top
  // Left and right ellipses
  arc(
    (0, 0),
    start: 270deg,
    stop: 90deg,
    radius: (0.5, 1.5),
  )
  circle(
    (4, 1.5),
    radius: (0.5, 1.5),
    name: "right-ellipse",
  )

  // Bottom arrow and label
  line((0.5, -0.5), (3.5, -0.5), ..arrow-style, name: "tau-arrow")
  content("tau-arrow", $tau$, anchor: "north")

  // Transformation arrow
  line((5.0, 1.5), (6, 1.5), stroke: 1pt, ..arrow-style)

  // Right side (plane)
  // Dashed circles
  circle((9, 1.5), radius: 0.05, fill: black, name: "center-dot")
  circle((9, 1.5), radius: 0.8, stroke: (dash: "dashed"), name: "tau1-circle")
  circle((9, 1.5), radius: 1.8, stroke: (dash: "dashed"), name: "tau2-circle")

  // Quarter circle with arrow
  arc(
    "center-dot",
    radius: 2.2,
    start: -180deg,
    stop: -90deg,
    anchor: "origin",
    ..arrow-style,
    name: "sigma-arrow",
  )

  // Labels
  content("sigma-arrow.mid", $sigma$, anchor: "north-east", padding: 1pt)
  content("tau1-circle.-15%", $tau_1$, anchor: "south-west")
  content("tau2-circle.-15%", $tau_2$, anchor: "south-west")
})
