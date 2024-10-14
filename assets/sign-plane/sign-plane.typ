#import "@preview/cetz:0.2.2": canvas, draw

#let size = 8
#let half_size = size / 2
#let quarter_size = size / 4
#let gap = 0.1 // gap between squares
#let axes-extend = 0.3
#set page(width: auto, height: auto, margin: 3pt)

#canvas({
  // Draw axes
  draw.line((-size / 2, 0), (size / 2 + axes-extend, 0), mark: (end: "stealth", fill: black), stroke: black + 0.6pt)
  draw.line((0, -size / 2), (0, size / 2 + axes-extend), mark: (end: "stealth", fill: black), stroke: black + 0.6pt)

  // Add axis labels
  draw.content((size / 2 + 0.5, axes-extend), $quad "Re"(p_0)$)
  draw.content((0.8, size / 2 + 0.3), $"Im"(p_0)$)

  for (s1, s2, color) in ((1, 1, red), (-1, 1, blue), (1, -1, blue), (-1, -1, red)) {
    // Draw squares with gap
    draw.rect((gap * s1, gap * s2), (s1 * size / 2, s2 * size / 2), fill: color.lighten(80%), stroke: color.darken(40%))
    // Add labels
    draw.content((quarter_size * s1, quarter_size * s2), [#text(8pt)[#align(center)[$s(p_0) = #s1#s2$]]])
  }
})
