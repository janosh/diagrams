#import "@preview/cetz:0.4.2": canvas, draw
#import draw: arc, circle, content, line

#set page(width: auto, height: auto, margin: 8pt)

#canvas({
  // Define styles and constants
  let radius = 1.5
  let dark-blue = rgb("#4040d9")
  let arrow-style = (
    mark: (end: "stealth", fill: dark-blue, scale: .5),
    stroke: (paint: dark-blue, thickness: 0.75pt),
  )

  // Draw loop circle
  circle((0, 0), radius: radius, name: "loop")

  // Add labels for masses/widths
  content("loop.0%", $m_1^2, gamma_1^2$, anchor: "south", padding: 3pt)
  content("loop.50%", $m_2^2, gamma_2^2$, anchor: "north", padding: 3pt)

  // Draw momentum arrow on loop
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

  // Draw external lines
  let ext-len = 2.2 * radius

  // Left external line
  circle("loop.25%", radius: 2pt, fill: black, name: "left-vertex")
  line((-ext-len, 0), "left-vertex", stroke: 1pt, name: "left-line")

  // Right external line
  circle("loop.75%", radius: 2pt, fill: black, name: "right-vertex")
  line("right-vertex", (ext-len, 0), stroke: 1pt, name: "right-line")

  // Add momentum arrows on external lines
  line(
    (rel: (0.15, 0.15), to: "left-line.start"),
    (rel: (-0.15, 0.15), to: "left-line.end"),
    ..arrow-style,
    name: "left-momentum",
  )
  content("left-momentum", text(fill: dark-blue)[$q_0$], anchor: "south", padding: 3pt)

  line(
    (rel: (0.15, 0.15), to: "right-line.start"),
    (rel: (-0.15, 0.15), to: "right-line.end"),
    ..arrow-style,
    name: "right-momentum",
  )
  content("right-momentum", text(fill: dark-blue)[$q_0$], anchor: "south", padding: 3pt)
})
