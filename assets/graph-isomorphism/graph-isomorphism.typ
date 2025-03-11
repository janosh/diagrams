#import "@preview/cetz:0.3.4": canvas, draw
#import draw: content, circle, line, scope, translate, set-style

#set page(width: auto, height: auto, margin: 8pt)

// Helper function to draw a node with a name
#let node(pos, label, color, name) = {
  content(pos, $n_#label$, frame: "circle", radius: 0.25, fill: color, stroke: 0.8pt, name: name, padding: 1pt)
}

#canvas({
  // Define colors
  let light-red = rgb("#f9c5c5")
  let light-orange = rgb("#f2ceaa")
  let light-blue = rgb("#b9d6f2")
  let light-teal = rgb("#b1e2d8")

  set-style(line: (stroke: 0.8pt))

  // Draw first graph (square)
  scope({
    node((0, 0), 1, light-red, "g1n1")
    node((0, 2), 2, light-orange, "g1n2")
    node((2, 2), 3, light-blue, "g1n3")
    node((2, 0), 4, light-teal, "g1n4")

    line("g1n1", "g1n2")
    line("g1n2", "g1n3")
    line("g1n3", "g1n4")
    line("g1n4", "g1n1")
  })

  // Draw second graph (trapezoid)
  scope({
    translate((4, 0))

    node((0, 0), 1, light-red, "g2n1")
    node((2, 2), 2, light-orange, "g2n2")
    node((0, 2), 3, light-blue, "g2n3")
    node((2, 0), 4, light-teal, "g2n4")

    line("g2n1", "g2n2")
    line("g2n2", "g2n3")
    line("g2n3", "g2n4")
    line("g2n4", "g2n1")
  })

  // Draw third graph (kite)
  scope({
    translate((8, 0))

    node((0, 0), 1, light-red, "g3n1")
    node((2, 2), 2, light-orange, "g3n2")
    node((2, 0), 3, light-teal, "g3n3")
    node((0, 2), 4, light-blue, "g3n4")

    line("g3n1", "g3n2")
    line("g3n2", "g3n3")
    line("g3n3", "g3n4")
    line("g3n4", "g3n1")
  })

  // Draw fourth graph (irregular)
  scope({
    translate((12.5, 0))

    node((-0.5, 0), 1, light-red, "g4n1")
    node((0.25, 2.2), 2, light-orange, "g4n2")
    node((2, 1.6), 3, light-blue, "g4n3")
    node((-0.7, 1.4), 4, light-teal, "g4n4")

    line("g4n1", "g4n2")
    line("g4n2", "g4n3")
    line("g4n3", "g4n4")
    line("g4n4", "g4n1")
  })
})
