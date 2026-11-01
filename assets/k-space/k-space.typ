#import "@preview/cetz:0.5.3": canvas, draw
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
  line((rel: (-1, 0), to: corner), corner, ..spacing-arrow, name: "x-spacing")
  content("x-spacing.mid", $2pi \/ L_x$, anchor: "north", padding: 0.2)
  line(corner, (rel: (0, ratio), to: corner), ..spacing-arrow, name: "y-spacing")
  content("y-spacing.mid", $2pi \/ L_y$, anchor: "west", padding: 0.2)

  let disk-ink = blue.darken(10%)
  content((130deg, 2.4), text(disk-ink)[$N(k)$])

  // radius of the disk
  let radius-end = (225deg, 2 / 3 * y-range)
  line((0, 0), radius-end, stroke: disk-ink + 1pt, mark: (
    end: "stealth",
    fill: disk-ink,
    scale: .6,
  ))
  content((225deg, 1), text(disk-ink)[$k$], anchor: "south-east", padding: 0.05)

  // legend below the grid
  let legend-x = -x-range
  circle((legend-x, -3.2), radius: 2pt, fill: black)
  content((legend-x + 0.25, -3.2), [allowed wave vector $bold(k)$], anchor: "west")
  circle((legend-x, -3.7), radius: 0.12, stroke: blue, fill: blue.lighten(80%))
  content((legend-x + 0.25, -3.7), [$N(k)$: number of states with $|bold(k)| < k$], anchor: "west")
})
