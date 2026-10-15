#import "@preview/cetz:0.5.2": canvas, draw
#import draw: content, line, rect

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 12pt)

#let mid-gray = rgb(50%, 50%, 50%)

#canvas({
  let spacing = 1.2

  // Draw a labeled matrix from its top-left corner with colored bars along its top (column
  // dimension) and left (row dimension) edges.
  let matrix(pos, size, label, top-color, left-color) = {
    let (x, y) = pos
    let (w, h) = size
    let offset = 0.1 // offset for dimension lines to avoid overlap
    rect(pos, (x + w, y - h), stroke: mid-gray, fill: rgb("#cdd3da"), name: label)
    // eval label as math so matrix names render italic (matching the formula below)
    content(label, eval(label, mode: "math"))
    line((x - 0.02, y + offset), (x + w + 0.02, y + offset), stroke: top-color + 2pt)
    line((x - offset, y + 0.02), (x - offset, y - h - 0.02), stroke: left-color + 2pt)
  }
  let operation(pos, body, name, padding, stroke: mid-gray + .75pt) = content(
    pos,
    body,
    frame: "rect",
    stroke: stroke,
    fill: rgb(30%, 80%, 80%, 30%),
    padding: padding,
    name: name,
  )

  content((4, -2.35), $"Attention"(Q, K, V) = "softmax"_"row" ( (Q K^top) / sqrt(d)) V$)

  // Colors mark tensor dimensions: teal = queries, red = keys, mustard = d, orange = d_v.
  // Deep tones keep the bars visible on the light page and after the dark-mode inversion.
  let (teal, red, mustard, orange) = (
    rgb("#009999"),
    rgb("#FF0000"),
    rgb("#9E8A00"),
    rgb("#D46A00"),
  )
  for (pos, size, label, top-color, left-color) in (
    ((0, 2.7), (0.7, 1.8), "Q", mustard, teal),
    ((0, 0.4), (0.7, 0.8), "K", mustard, red),
    ((0, -1), (1.0, 0.8), "V", orange, red),
    ((3 * spacing + 0.7, 0.9), (0.8, 1.8), "A", red, teal),
    ((5 * spacing + 0.7, 0.9), (1.0, 1.8), "Y", orange, teal),
  ) {
    matrix(pos, size, label, top-color, left-color)
  }

  operation((spacing + 0.4, 0), $dot.op^top$, "att", (5pt, 3pt, 1pt))
  operation((2 * spacing + 0.6, 0), [softmax], "softmax", (2pt, 3pt, 3pt))
  operation((4 * spacing + 1, 0), $dot.op$, "prod", (1pt, 4pt, 2pt), stroke: mid-gray)

  // Inputs start with a bar and enter their operation at right angles.
  let edge-style = (mark: (start: "|", offset: 0.075, scale: 1.3), stroke: mid-gray)
  line("K.east", "att.west", ..edge-style)
  line("Q.east", ("Q.east", "-|", "att.north"), "att.north", ..edge-style)
  line("V.east", ("V.east", "-|", "prod.south"), "prod.south", ..edge-style)
  line("att.east", "softmax.west", stroke: mid-gray)
  line("A.east", "prod.west", stroke: mid-gray)
  for (start, end) in (("softmax.east", "A.west"), ("prod.east", "Y.west")) {
    line(
      start,
      end,
      mark: (
        start: (symbol: "|", offset: 0.075, scale: 1.3),
        end: (symbol: "stealth", offset: 0.15, scale: 0.45),
        fill: mid-gray,
      ),
      stroke: mid-gray,
    )
  }
})
