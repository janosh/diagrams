#import "@preview/cetz:0.5.2": canvas, draw
#import draw: arc, circle, content, line

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#let arrow-style = (
  mark: (end: "stealth", fill: black, scale: 0.7),
  stroke: 0.8pt,
)

#canvas({
  let vertical-arcs = (
    (x: 2.6, name: "tau2-arc", label: $tau_2$, style: (stroke: (dash: "dashed"))),
    (x: 1.4, name: "tau1-arc", label: $tau_1$, style: (stroke: (dash: "dashed"))),
    (x: -0.4, name: "sigma-arc", label: $sigma$, style: arrow-style),
  )
  for spec in vertical-arcs {
    arc(
      (spec.x, 0),
      start: -90deg,
      stop: -270deg,
      radius: (0.5, 1.5),
      ..spec.style,
      name: spec.name,
    )
  }
  for spec in vertical-arcs {
    content(spec.name + ".mid", spec.label, anchor: "east", padding: 2pt)
  }

  for (y, name) in ((0, "bottom-line"), (3, "top-line")) {
    line((0, y), (4, y), name: name)
  }
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

  circle((9, 1.5), radius: 0.05, fill: black, name: "center-dot")
  let tau-circles = ((1, 0.8), (2, 1.8))
  for (idx, radius) in tau-circles {
    circle(
      (9, 1.5),
      radius: radius,
      stroke: (dash: "dashed"),
      name: "tau" + str(idx) + "-circle",
    )
  }

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

  content("sigma-arrow.mid", $sigma$, anchor: "north-east", padding: 1pt)
  for (idx, _) in tau-circles {
    content("tau" + str(idx) + "-circle.-15%", $tau_#idx$, anchor: "south-west")
  }
})
