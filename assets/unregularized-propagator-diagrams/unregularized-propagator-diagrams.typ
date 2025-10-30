#import "@preview/cetz:0.4.2": canvas, draw
#import draw: circle, content

#set page(width: auto, height: auto, margin: 8pt)

// Define styles and constants
#let radius = 1 // \radius in original
#let vertex-rad = 0.25 * radius

// Create hatched pattern for vertices
#let hatched = tiling(size: (.1cm, .1cm))[
  #place(rect(width: 100%, height: 100%, fill: white, stroke: none))
  #place(line(start: (0%, 100%), end: (100%, 0%), stroke: 0.4pt))
]

// Helper function for dressed vertices
#let dressed-vertex(pos, label: none, rel-label: none, name: none, ..rest) = {
  circle(pos, radius: vertex-rad, fill: hatched, name: name)
  if label != none {
    let label-pos = if rel-label != none { (rel: rel-label, to: pos) } else { pos }
    content(label-pos, $#label$, ..rest)
  }
}

#canvas({
  // First diagram
  // Main loop
  circle((0, 0), radius: radius, stroke: 1pt, name: "loop")

  // External lines
  draw.line((-2 * radius, 0), (-radius, 0), stroke: 1pt, name: "left-external")
  draw.line((radius, 0), (2 * radius, 0), stroke: 1pt, name: "right-external")

  // Vertices with labels
  dressed-vertex(
    (-radius, 0),
    label: $Gamma_k^((3))$,
    rel-label: (-0.3, 0.3),
    name: "vertex-left",
    anchor: "south",
  )
  dressed-vertex(
    (radius, 0),
    label: $Gamma_k^((3))$,
    rel-label: (0.3, 0.3),
    name: "vertex-right",
    anchor: "south",
  )

  // Add minus sign between diagrams
  content((3 * radius, 0), $-$)

  // Second diagram
  // Main loop
  circle((5 * radius, 0), radius: radius, stroke: 1pt, name: "loop2")

  // External line
  draw.line((5 * radius - 2 * radius, -radius), (5 * radius + 2 * radius, -radius), stroke: 1pt, name: "external2")

  // Four-vertex with label
  dressed-vertex(
    (5 * radius, -radius),
    label: $Gamma_k^((4))$,
    rel-label: (0, 0.35),
    name: "vertex-four",
    anchor: "south",
  )
})
