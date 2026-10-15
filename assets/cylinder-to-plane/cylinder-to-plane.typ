#import "@preview/cetz:0.5.2": canvas, draw
#import draw: arc, circle, content, line

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 12pt)

#let arrow-style = (
  mark: (end: "stealth", fill: black, scale: 0.7),
  stroke: 0.8pt,
)

#canvas({
  // Cylinder: dashed constant-time slices and the sigma direction around it
  for (x, name, label, style) in (
    (2.6, "tau2-arc", $tau_2$, (stroke: (dash: "dashed"))),
    (1.4, "tau1-arc", $tau_1$, (stroke: (dash: "dashed"))),
    (-0.4, "sigma-arc", $sigma$, arrow-style),
  ) {
    arc((x, 0), start: -90deg, stop: -270deg, radius: (0.5, 1.5), ..style, name: name)
    content(name + ".mid", label, anchor: "east", padding: 2pt)
  }

  line((0, 0), (4, 0))
  line((0, 3), (4, 3))
  arc((0, 0), start: 270deg, stop: 90deg, radius: (0.5, 1.5))
  circle((4, 1.5), radius: (0.5, 1.5), name: "rim")

  line((0.5, -0.5), (3.5, -0.5), ..arrow-style, name: "tau-arrow")
  content("tau-arrow", $tau$, anchor: "north")

  // Conformal map to the plane
  line((rel: (0.5, 0), to: "rim.east"), (rel: (1, 0)), stroke: 1pt, ..arrow-style)

  // Plane: constant-time slices become concentric circles around the origin
  circle((rel: (3, 0)), radius: 0.05, fill: black, name: "center-dot")
  for (idx, radius) in ((1, 0.8), (2, 1.8)) {
    circle("center-dot", radius: radius, stroke: (dash: "dashed"), name: "tau-circle")
    content("tau-circle.-15%", $tau_#idx$, anchor: "south-west")
  }

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
})
