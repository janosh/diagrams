#import "@preview/cetz:0.5.2": canvas, draw
#import draw: arc, circle, content, line

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 12pt)

#canvas({
  let radius = 1.5
  let dark-blue = rgb("#4040d9")
  let arrow-style = (
    mark: (end: "stealth", fill: dark-blue, scale: .5),
    stroke: (paint: dark-blue, thickness: 0.75pt),
  )

  circle((0, 0), radius: radius, name: "loop")

  content("loop.0%", $m_1^2, gamma_1^2$, anchor: "south", padding: 3pt)
  content("loop.50%", $m_2^2, gamma_2^2$, anchor: "north", padding: 3pt)

  arc(
    (rel: (.23, 0), to: "loop.15%"),
    radius: 0.85 * radius,
    start: 140deg,
    stop: 40deg,
    ..arrow-style,
    name: "momentum-arrow",
  )
  content(
    "momentum-arrow.mid",
    text(fill: dark-blue)[$q_0$],
    anchor: "north",
  )

  let ext-len = 2.2 * radius
  circle("loop.25%", radius: 2pt, fill: black, name: "left-vertex")
  circle("loop.75%", radius: 2pt, fill: black, name: "right-vertex")
  for (start, end) in (((-ext-len, 0), "left-vertex"), ("right-vertex", (ext-len, 0))) {
    line(start, end, stroke: 1pt, name: "external")
    line(
      (rel: (0.15, 0.15), to: "external.start"),
      (rel: (-0.15, 0.15), to: "external.end"),
      ..arrow-style,
      name: "momentum",
    )
    content("momentum", text(fill: dark-blue)[$q_0$], anchor: "south", padding: 3pt)
  }
})
