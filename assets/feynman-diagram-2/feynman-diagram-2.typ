#import "@preview/cetz:0.4.0": canvas, draw
#import draw: line, content, circle

#set page(width: auto, height: auto, margin: 8pt)

#canvas({
  // Define styles and constants
  let arrow-style = (
    mark: (end: "stealth", fill: black, scale: .5),
    stroke: (thickness: 0.75pt),
  )

  // Draw main horizontal line
  line((-2.25, 0), (2.25, 0), stroke: 1pt, name: "a-to-b")

  // Add phi labels
  content("a-to-b.start", $phi_a$, anchor: "east", padding: 3pt)
  content("a-to-b.end", $phi_b$, anchor: "west", padding: 3pt)

  // Add momentum arrows
  line((-2, 0.15), (-1, 0.15), ..arrow-style, name: "p1")
  content((rel: (0, 0.3), to: "p1.mid"), $p_1$)

  line((1, 0.15), (2, 0.15), ..arrow-style, name: "p2")
  content((rel: (0, 0.3), to: "p2.mid"), $p_2$)

  // Draw vertex with cross
  content(
    (0, 0),
    text(size: 16pt, baseline: -0.3pt)[$times.circle$],
    stroke: none,
    fill: white,
    frame: "circle",
    padding: -2.4pt,
    name: "vertex",
  )
  content((rel: (0, 0.5), to: "vertex"), $partial_t R_(k,a b)(p_1,p_2)$)
})
