#import "@preview/cetz:0.3.3": canvas, draw

#let size = 8
#let gap = 0.15 // gap between squares
#let axes-extend = 0.3
#set page(width: auto, height: auto, margin: 8pt)

#canvas({
  // Draw axes
  draw.line((-size / 2, 0), (size / 2 + axes-extend, 0), mark: (end: "stealth", fill: black), name: "x-axis")
  draw.line((0, -size / 2), (0, size / 2 + axes-extend), mark: (end: "stealth", fill: black), name: "y-axis")

  // Add axis labels
  draw.content((rel: (.4, .2), to: "x-axis.end"), $"Re"(p_0)$)
  draw.content((rel: (.7, 0), to: "y-axis.end"), $"Im"(p_0)$)

  for (s1, s2, color) in ((1, 1, red), (-1, 1, blue), (1, -1, blue), (-1, -1, red)) {
    // Draw squares with gap
    draw.rect((gap * s1, gap * s2), (s1 * size / 2, s2 * size / 2), fill: color.lighten(80%), stroke: color.darken(40%))
    // Add labels
    draw.content((size / 4 * s1, size / 4 * s2), $s(p_0) = #calc.quo(s1, s2)$)
  }
})
