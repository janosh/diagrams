#import "@preview/cetz:0.4.2": canvas, draw
#import draw: circle, content, line

#set page(width: auto, height: auto, margin: 8pt)

#let x-range = 3
#let y-range = 3
#let ratio = 3 / 4

#canvas({
  // Set up coordinate system


  // Draw blue circle with fill in background
  circle(
    (0, 0),
    radius: 2 / 3 * y-range,
    stroke: blue,
    fill: blue.lighten(80%),
    fill-opacity: 0.2,
    name: "fermi-circle",
  )

  // Draw dot grid
  for x in range(-x-range, x-range + 1) {
    for y in range(-y-range, y-range + 1) {
      circle((x, ratio * y), radius: 2pt, fill: black)
    }
  }

  // Draw axes with arrows
  let arrow-style = (mark: (end: "stealth", fill: black))
  let x-end = (x-range + 0.5, 0)
  let y-end = (0, ratio * y-range + 0.5)

  line((-x-range - 0.5, 0), x-end, ..arrow-style)
  line((0, -ratio * y-range - 0.5), y-end, ..arrow-style, name: "y-axis")

  // Add axis labels
  content(x-end, $k_x$, anchor: "south-west")
  content((rel: (.55, 0), to: "y-axis.end"), $k_y$, anchor: "north-east")

  // Draw lattice spacing indicators with arrows
  let spacing-arrow = (mark: (symbol: "stealth", fill: black, scale: .3, offset: 0.1), stroke: 0.7pt)
  let x-start = (x-range - 1, -ratio * y-range)
  let x-end = (x-range, -ratio * y-range)
  let x-mid = ((x-start.at(0) + x-end.at(0)) / 2, x-start.at(1))

  line(x-start, x-end, ..spacing-arrow, name: "x-spacing")
  content("x-spacing.mid", $(2pi) / L_x$, anchor: "north", padding: 0.2)

  let y-start = (x-range, -ratio * y-range)
  let y-end = (x-range, -ratio * y-range + ratio)

  line(y-start, y-end, ..spacing-arrow, name: "y-spacing")
  content("y-spacing.mid", $(2pi) / L_y$, anchor: "west", padding: 0.2)

  // Add N(k) label
  let angle = 130deg
  let label-pos = (calc.cos(angle) * 2.4, calc.sin(angle) * 2.4)
  content(label-pos, text(blue)[$N(k)$])
})
