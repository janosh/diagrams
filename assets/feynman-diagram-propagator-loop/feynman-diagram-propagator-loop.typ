#import "@preview/cetz:0.5.2": canvas, draw
#import draw: arc, circle, content, line

#set page(width: auto, height: auto, margin: 8pt, fill: none)

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
  let external-lines = (
    (side: "left", vertex: "loop.25%", ends: ((-ext-len, 0), "left-vertex")),
    (side: "right", vertex: "loop.75%", ends: ("right-vertex", (ext-len, 0))),
  )
  for spec in external-lines {
    circle(spec.vertex, radius: 2pt, fill: black, name: spec.side + "-vertex")
  }
  for spec in external-lines {
    line(..spec.ends, stroke: 1pt, name: spec.side + "-line")
  }
  for spec in external-lines {
    let line-name = spec.side + "-line"
    let momentum-name = spec.side + "-momentum"
    line(
      (rel: (0.15, 0.15), to: line-name + ".start"),
      (rel: (-0.15, 0.15), to: line-name + ".end"),
      ..arrow-style,
      name: momentum-name,
    )
    content(momentum-name, text(fill: dark-blue)[$q_0$], anchor: "south", padding: 3pt)
  }
})
