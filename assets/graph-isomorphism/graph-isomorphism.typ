#import "@preview/cetz:0.3.1": canvas, draw
#import draw: content, circle, line

#set page(width: auto, height: auto, margin: 8pt)

// Helper function to draw a vertex with a name
#let vertex(pos, label, color, name) = {
  content(pos, $n_#label$, frame: "circle", radius: 0.25, fill: color, stroke: black + 0.8pt, name: name, padding: 1pt)
}

#canvas({
  // Define colors
  let colors = (
    rgb("#f9c5c5"), // light red
    rgb("#f2ceaa"), // light orange
    rgb("#b9d6f2"), // light blue
    rgb("#b1e2d8"), // light teal
  )

  // Draw first graph (square)
  let g1-y = 2
  vertex((0, g1-y), 1, colors.at(0), "g1n1")
  vertex((0, g1-y + 2), 2, colors.at(1), "g1n2")
  vertex((2, g1-y + 2), 3, colors.at(2), "g1n3")
  vertex((2, g1-y), 4, colors.at(3), "g1n4")

  line("g1n1", "g1n2", stroke: black + 0.8pt)
  line("g1n2", "g1n3", stroke: black + 0.8pt)
  line("g1n3", "g1n4", stroke: black + 0.8pt)
  line("g1n4", "g1n1", stroke: black + 0.8pt)

  // Draw second graph (trapezoid)
  let g2-x = 4
  vertex((g2-x, g1-y), 1, colors.at(0), "g2n1")
  vertex((g2-x + 2, g1-y + 2), 2, colors.at(1), "g2n2")
  vertex((g2-x, g1-y + 2), 3, colors.at(2), "g2n3")
  vertex((g2-x + 2, g1-y), 4, colors.at(3), "g2n4")

  line("g2n1", "g2n2", stroke: black + 0.8pt)
  line("g2n2", "g2n3", stroke: black + 0.8pt)
  line("g2n3", "g2n4", stroke: black + 0.8pt)
  line("g2n4", "g2n1", stroke: black + 0.8pt)

  // Draw third graph (kite)
  let g3-x = 8
  vertex((g3-x, g1-y), 1, colors.at(0), "g3n1")
  vertex((g3-x + 2, g1-y + 2), 2, colors.at(1), "g3n2")
  vertex((g3-x + 2, g1-y), 3, colors.at(3), "g3n3")
  vertex((g3-x, g1-y + 2), 4, colors.at(2), "g3n4")

  line("g3n1", "g3n2", stroke: black + 0.8pt)
  line("g3n2", "g3n3", stroke: black + 0.8pt)
  line("g3n3", "g3n4", stroke: black + 0.8pt)
  line("g3n4", "g3n1", stroke: black + 0.8pt)

  // Draw fourth graph (irregular)
  let g4-x = 12
  vertex((g4-x - 0.5, g1-y), 1, colors.at(0), "g4n1")
  vertex((g4-x + 0.25, g1-y + 2.2), 2, colors.at(1), "g4n2")
  vertex((g4-x + 2, g1-y + 1.6), 3, colors.at(2), "g4n3")
  vertex((g4-x - 0.7, g1-y + 1.4), 4, colors.at(3), "g4n4")

  line("g4n1", "g4n2", stroke: black + 0.8pt)
  line("g4n2", "g4n3", stroke: black + 0.8pt)
  line("g4n3", "g4n4", stroke: black + 0.8pt)
  line("g4n4", "g4n1", stroke: black + 0.8pt)
})
