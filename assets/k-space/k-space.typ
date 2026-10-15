#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, line

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 12pt)

#let (x-range, y-range) = (3, 3)
#let ratio = 3 / 4 // L_x / L_y: vertical lattice spacing relative to horizontal

#canvas({
  circle((0, 0), radius: 2 / 3 * y-range, stroke: blue, fill: blue.lighten(80%), fill-opacity: 0.2)

  for x in range(-x-range, x-range + 1) {
    for y in range(-y-range, y-range + 1) {
      circle((x, ratio * y), radius: 2pt, fill: black)
    }
  }

  let arrow-style = (mark: (end: "stealth", fill: black))
  line((-x-range - 0.5, 0), (x-range + 0.5, 0), ..arrow-style, name: "x-axis")
  line((0, -ratio * y-range - 0.5), (0, ratio * y-range + 0.5), ..arrow-style, name: "y-axis")
  content("x-axis.end", $k_x$, anchor: "south-west")
  content((rel: (.55, 0), to: "y-axis.end"), $k_y$, anchor: "north-east")

  // Lattice spacings next to the bottom-right grid point
  let spacing-arrow = (
    mark: (symbol: "stealth", fill: black, scale: .3, offset: 0.1),
    stroke: 0.7pt,
  )
  let corner = (x-range, -ratio * y-range)
  line((x-range - 1, -ratio * y-range), corner, ..spacing-arrow, name: "x-spacing")
  content("x-spacing.mid", $2pi \/ L_x$, anchor: "north", padding: 0.2)
  line(corner, (x-range, -ratio * y-range + ratio), ..spacing-arrow, name: "y-spacing")
  content("y-spacing.mid", $2pi \/ L_y$, anchor: "west", padding: 0.2)

  let angle = 130deg
  content((calc.cos(angle) * 2.4, calc.sin(angle) * 2.4), text(blue)[$N(k)$])
})
