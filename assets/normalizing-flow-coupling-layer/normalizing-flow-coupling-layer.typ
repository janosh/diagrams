#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, line, polygon

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#canvas({
  let spacing = (node: 2.5, row: 2.5)

  // Node styles
  let arrow-style = (
    mark: (end: "stealth", fill: black, scale: 0.75),
    stroke: 0.7pt,
  )

  // Helper to draw diamond node with its label
  let diamond(pos, name, label, fill: none) = {
    polygon(
      pos,
      4,
      radius: 0.7,
      angle: 90deg,
      stroke: 0.7pt,
      fill: fill,
      name: name,
    )
    content(pos, label, anchor: "center")
  }

  // Helper to draw circle node with its label
  let circle-node(pos, name, label) = {
    circle(pos, radius: 0.4, name: name, stroke: 0.7pt, fill: rgb("#ffa64d").lighten(40%))
    content(pos, label, anchor: "center")
  }

  // Forward pass (left side)
  // First row
  let z1-pos = (0, 0)
  let eq1-pos = (spacing.node, 0)
  let x1-pos = (2 * spacing.node, 0)

  // Second row
  let z2-pos = (0, -spacing.row)
  let g1-pos = (spacing.node, -spacing.row)
  let x2-pos = (2 * spacing.node, -spacing.row)

  // Middle node
  let m1-pos = (spacing.node / 2, -spacing.row / 2)

  // Draw forward pass nodes
  diamond(z1-pos, "z1", $arrow(z)_(1:d)$, fill: rgb("#cce5ff"))
  circle-node(eq1-pos, "eq1", "=")
  diamond(x1-pos, "x1", $arrow(x)_(1:d)$, fill: rgb("#cce5ff"))
  diamond(z2-pos, "z2", $arrow(z)_(d+1:D)$, fill: rgb("#ccffcc"))
  circle-node(g1-pos, "g1", $arrow(g)$)
  diamond(x2-pos, "x2", $arrow(x)_(d+1:D)$, fill: rgb("#fff5cc"))
  circle-node(m1-pos, "m1", "m")

  // Forward pass arrows
  line("z1", "eq1", ..arrow-style)
  line("eq1", "x1", ..arrow-style)
  line("z2", "g1", ..arrow-style)
  line("g1", "x2", ..arrow-style)
  line("z1", "m1", ..arrow-style)
  line("m1", "g1", ..arrow-style)

  // Label under g1
  content(
    (rel: (0, -1), to: "g1"),
    [forward pass],
    anchor: "south",
  )

  // Inverse pass (right side)
  let right-x = 5 * spacing.node

  // First row
  let z1r-pos = (right-x, 0)
  let eq2-pos = (right-x + spacing.node, 0)
  let x1r-pos = (right-x + 2 * spacing.node, 0)

  // Second row
  let z2r-pos = (right-x, -spacing.row)
  let g2-pos = (right-x + spacing.node, -spacing.row)
  let x2r-pos = (right-x + 2 * spacing.node, -spacing.row)

  // Middle node
  let m2-pos = (right-x + 1.5 * spacing.node, -spacing.row / 2)

  // Draw inverse pass nodes
  diamond(z1r-pos, "z1r", $arrow(z)_(1:d)$, fill: rgb("#cce5ff"))
  circle-node(eq2-pos, "eq2", "=")
  diamond(x1r-pos, "x1r", $arrow(x)_(1:d)$, fill: rgb("#cce5ff"))
  diamond(z2r-pos, "z2r", $arrow(z)_(d+1:D)$, fill: rgb("#ccffcc"))
  circle-node(g2-pos, "g2", $arrow(g)^(-1)$)
  diamond(x2r-pos, "x2r", $arrow(x)_(d+1:D)$, fill: rgb("#fff5cc"))
  circle-node(m2-pos, "m2", "m")

  // Inverse pass arrows (reversed direction)
  line("eq2", "z1r", ..arrow-style)
  line("x1r", "eq2", ..arrow-style)
  line("g2", "z2r", ..arrow-style)
  line("x2r", "g2", ..arrow-style)
  line("x1r", "m2", ..arrow-style)
  line("m2", "g2", ..arrow-style)

  // Label under g2
  content(
    (rel: (0, -1), to: "g2"),
    [inverse pass],
    anchor: "south",
  )
})
