#import "@preview/cetz:0.4.2": canvas, draw
#import draw: circle, content

#set page(width: auto, height: auto, margin: 8pt)

// Create hatched pattern for vertices
#let hatched = tiling(size: (.1cm, .1cm))[
  #place(rect(width: 100%, height: 100%, fill: white, stroke: none))
  #place(line(start: (0%, 100%), end: (100%, 0%), stroke: 0.4pt))
]

#canvas({
  // Define styles and constants
  let arrow-style = (
    mark: (end: "stealth", fill: black, scale: .5),
    stroke: (thickness: 0.75pt),
  )

  // Draw main horizontal line
  draw.line((-2.25, 0), (2.25, 0), stroke: 1pt, name: "a-to-b")

  // Add phi labels
  content("a-to-b.start", $phi_a$, anchor: "east", padding: 3pt)
  content("a-to-b.end", $phi_b$, anchor: "west", padding: 3pt)

  // Add momentum arrows
  draw.line((-2, 0.15), (-1, 0.15), ..arrow-style, name: "p1")
  content((rel: (0, 0.3), to: "p1.mid"), $p_1$)

  draw.line((1, 0.15), (2, 0.15), ..arrow-style, name: "p2")
  content((rel: (0, 0.3), to: "p2.mid"), $p_2$)

  // Draw vertex with hatched pattern
  circle((0, 0), radius: 0.25, fill: hatched, name: "vertex")
  content((rel: (0, 0.5), to: "vertex"), $G_(k,a b)(p_1,p_2)$)
})
