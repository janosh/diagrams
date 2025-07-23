#import "@preview/cetz:0.4.1": canvas, draw
#import draw: arc, content, line, rect

#set page(width: auto, height: auto, margin: 1pt)

#let (xmin, xmax) = (-1, 1)
#let (ymin, ymax) = (-0.5, 2.4)

// Set global styles
#let arrow-style = (
  mark: (end: "stealth", fill: black, scale: 0.2),
  stroke: (thickness: 0.4pt),
)
#set text(size: 8pt)

// TODO this figure needs revisiting to get the gray-shaded areas right without overlaying white fills once CaTZ implements path clipping
// https://github.com/cetz-package/cetz/discussions/813#discussioncomment-12218646
#canvas({
  draw.set-style(stroke: (thickness: 0.4pt))
  draw.set-viewport((0, 0), (20, 20), bounds: (12, 12))


  // Light gray vertical strip
  rect(
    (-0.5, 0),
    (0.5, ymax),
    fill: rgb(128, 128, 128).lighten(80%),
    stroke: none,
  )
  // Draw semicircle B and B' (dark red)
  arc(
    (0, 0),
    radius: 1,
    start: 0deg,
    stop: 180deg,
    stroke: (paint: red),
    fill: gray.transparentize(30%),
    name: "B-arc",
    anchor: "origin",
  )
  // Draw the extended green arcs (C and C') first
  arc(
    (0, 0),
    radius: 1,
    start: 0deg,
    stop: 90deg,
    mode: "PIE",
    stroke: (paint: green),
    fill: white,
    name: "C-arc",
    anchor: "start",
  )
  content("C-arc.20%", $C$, fill: green, anchor: "north-east", padding: 2pt)

  arc(
    (0, 0),
    radius: 1,
    start: 90deg,
    stop: 180deg,
    mode: "PIE",
    stroke: (paint: green),
    fill: white,
    name: "C-prime-arc",
    anchor: "arc-end",
  )
  content("C-prime-arc.25%", $C'$, fill: green, anchor: "north-west", padding: 2pt)
  // Draw semicircle B and B' (dark red)
  arc(
    (0, 0),
    radius: 1,
    start: 0deg,
    stop: 180deg,
    stroke: (paint: red),
    name: "B-arc",
    anchor: "origin",
  )

  // Draw axes
  line((xmin, 0), (xmax, 0), ..arrow-style, name: "x-axis")
  line((0, ymin), (0, ymax), ..arrow-style, name: "y-axis")

  // Draw tick marks with labels
  line((-0.5, -0.02), (-0.5, 0.02), name: "x-tick")
  content((-0.5, -0.1), $-1 / 2$, anchor: "north")

  line((0.5, -0.02), (0.5, 0.02), name: "x-tick")
  content((0.5, -0.1), $1 / 2$, anchor: "north")

  line((-0.02, 1), (0.02, 1), name: "i-tick", stroke: (thickness: 0.6pt))
  content("i-tick", $i$, anchor: "north-west", padding: 1pt)

  content("B-arc.60%", $B$, fill: red, anchor: "south", padding: (0, 0, 3pt))
  content("B-arc.40%", $B'$, fill: red, anchor: "south", padding: (0, 0, 3pt))

  // Draw vertical lines A and A' (dark blue)
  line(
    (-0.5, 0),
    (-0.5, ymax),
    stroke: (paint: blue),
    mark: (end: "stealth", fill: blue, scale: 0.2),
    name: "A-line",
  )
  content("A-line.80%", $A$, fill: blue, anchor: "east", padding: (0, 4pt, 0, 0))

  line(
    (0.5, 0),
    (0.5, ymax),
    stroke: (paint: blue),
    mark: (end: "stealth", fill: blue, scale: 0.2),
    name: "A-prime-line",
  )
  content("A-prime-line.80%", $A'$, fill: blue, anchor: "west", padding: (0, 0, 0, 4pt))

  // Add F₀ labels
  content("y-axis.80%", $F_0$, anchor: "west", padding: (0, 0, 0, 2pt))
  content((rel: (-0.2, -0.2), to: "B-arc.50%"), $F_0'$)
})
