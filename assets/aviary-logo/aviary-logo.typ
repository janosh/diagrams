#import "@preview/cetz:0.5.2": canvas, draw
#import draw: bezier, circle, line, scale, set-style

// Transparent background so only the black circle is visible
#set page(width: auto, height: auto, margin: 5pt, fill: none)

#canvas(length: 1cm, {
  scale(2.5)

  // Node positions and colors: (position, color)
  let nodes = (
    ((0, 2), rgb("#2a9d8f")), // top - teal
    ((-2, -0.6), rgb("#f8961e")), // mid-left - orange
    ((2, -0.6), rgb("#6a7fdb")), // mid-right - blue
    ((-2, -3.2), rgb("#b565a7")), // bot-left - purple
    ((2, -3.2), rgb("#e05555")), // bot-right - red
  )

  // Black circle background
  circle((0, -0.6), radius: 4.5, fill: black, stroke: none)

  set-style(
    stroke: (paint: white, thickness: 6pt, cap: "round", join: "round"),
    mark: (fill: white, stroke: white, scale: 1.8, end: "stealth"),
  )

  // All edges: (start, end, ctrl1, ctrl2) for beziers, (start, end) for lines
  let edges = (
    ((-0.45, 2.45), (0.45, 2.45), (-1, 3.9), (1, 3.9)), // self-loop top
    ((0.5, 1.6), (1.9, 0.05), (1.5, 1.2), (1.8, 0.3)), // top → mid-right
    ((-1.9, 0.05), (-0.5, 1.6), (-1.8, 0.3), (-1.5, 1.2)), // mid-left → top
    ((1.4, -0.4), (-1.4, -0.4), (0.8, 0.15), (-0.8, 0.15)), // mid-right → mid-left (top)
    ((-1.4, -0.8), (1.4, -0.8), (-0.8, -1.35), (0.8, -1.35)), // mid-left → mid-right (bot)
    ((-2, -1.25), (-2, -2.55)), // mid-left → bot-left
    ((2, -1.25), (2, -2.55)), // mid-right → bot-right
    ((1.4, -3), (-1.4, -3), (0.8, -2.5), (-0.8, -2.5)), // bot-right → bot-left (top)
    ((-1.4, -3.4), (1.4, -3.4), (-0.8, -3.9), (0.8, -3.9)), // bot-left → bot-right (bot)
  )

  for edge in edges {
    if edge.len() == 4 { bezier(..edge) } else { line(..edge) }
  }

  for (pos, col) in nodes {
    circle(pos, radius: 0.65, fill: col, stroke: (paint: white, thickness: 5pt))
  }
})
