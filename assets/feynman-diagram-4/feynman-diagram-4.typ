#import "@preview/cetz:0.4.1": canvas, draw
#import "@preview/modpattern:0.1.0": modpattern
#import draw: circle, content, line

#set page(width: auto, height: auto, margin: 8pt)

// Create hatched pattern for vertices
#let hatched = modpattern(
  (.1cm, .1cm),
  std.line(start: (0%, 100%), end: (100%, 0%), stroke: 0.5pt),
  background: white,
)

#canvas({
  // Define styles and constants
  let arrow-style = (
    mark: (end: "stealth", fill: black, scale: .3),
    stroke: (thickness: 0.5pt),
  )

  // Apply 45-degree rotation to all coordinates
  let rot45(x, y) = ((x - y) / calc.sqrt(2), (x + y) / calc.sqrt(2))

  // Draw main lines
  line(rot45(-2, 0), rot45(2, 0), name: "horiz")
  line(rot45(0, 2), rot45(0, -2), name: "vert")

  // Add phi labels
  content("horiz.start", $phi_a$, anchor: "north-east", padding: -1pt)
  content("horiz.end", $phi_c$, anchor: "south-west", padding: 1pt)
  content("vert.start", $phi_b$, anchor: "south-east", padding: 1pt)
  content("vert.end", $phi_d$, anchor: "north-west", padding: 1pt)

  // Add momentum arrows
  let (x1, y1) = rot45(-1.7, 0.15)
  let (x2, y2) = rot45(-0.7, 0.15)
  line((x1, y1), (x2, y2), ..arrow-style, name: "p1")
  content((rel: (-0.1, 0.3), to: "p1"), $p_1$)

  let (x1, y1) = rot45(0.7, 0.15)
  let (x2, y2) = rot45(1.7, 0.15)
  line((x2, y2), (x1, y1), ..arrow-style, name: "p3")
  content((rel: (-0.1, 0.3), to: "p3"), $p_3$)

  let (x1, y1) = rot45(0.15, 1.7)
  let (x2, y2) = rot45(0.15, 0.7)
  line((x1, y1), (x2, y2), ..arrow-style, name: "p2")
  content((rel: (0.3, 0.2), to: "p2"), $p_2$)

  let (x1, y1) = rot45(0.15, -0.7)
  let (x2, y2) = rot45(0.15, -1.7)
  line((x2, y2), (x1, y1), ..arrow-style, name: "p4")
  content((rel: (0.3, 0.1), to: "p4"), $p_4$)

  // Draw vertex with hatched pattern
  circle(rot45(0, 0), radius: 0.25, fill: hatched, name: "vertex")
  content((rel: (0.35, -.05), to: "vertex"), $Gamma_(k,a b c d)^((4))(p_1,p_2,p_3,p_4)$, anchor: "west")
})
