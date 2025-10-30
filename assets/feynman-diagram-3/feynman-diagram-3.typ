#import "@preview/cetz:0.4.2": canvas, draw
#import draw: circle, content

#set page(width: auto, height: auto, margin: 8pt)

#let hatched = tiling(size: (.1cm, .1cm))[
  #place(rect(width: 100%, height: 100%, fill: white, stroke: none))
  #place(line(start: (0%, 100%), end: (100%, 0%), stroke: 0.4pt))
]

#canvas({
  // Define styles and constants
  let arrow-style = (
    mark: (end: "stealth", fill: black, scale: .3),
    stroke: (thickness: 0.5pt),
  )

  // Draw main lines
  draw.line((-2, 0), (0, 0), name: "in")
  draw.line((0, 0), (1.5, 1.5), name: "up")
  draw.line((0, 0), (1.5, -1.5), name: "down")

  // Add phi labels
  content("in.start", $phi_a$, anchor: "east", padding: 1pt)
  content("up.end", $phi_b$, anchor: "south-west", padding: 1pt)
  content("down.end", $phi_c$, anchor: "north-west", padding: 1pt)

  draw.line((-1.7, 0.15), (-0.7, 0.15), ..arrow-style, name: "p1")
  content((rel: (0, 0.3), to: "p1"), $p_1$)

  draw.line((1., 1.2), (0.3, 0.5), name: "p2", ..arrow-style)
  content((rel: (-0.3, 0.3), to: "p2"), $p_2$)

  draw.line((1.4, -1.2), (0.6, -0.4), name: "p3", ..arrow-style)
  content((rel: (0.3, 0.3), to: "p3"), $p_3$)

  // Draw vertex with hatched pattern
  circle((0, 0), radius: 0.25, fill: hatched, name: "vertex")
  content((rel: (0.35, -.05), to: "vertex"), $Gamma_(k,a b c)^((3))(p_1,p_2,p_3)$, anchor: "west")
})
