#import "@preview/cetz:0.5.2": canvas, draw
#import draw: content, line, rect

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#let mid-gray = rgb(50%, 50%, 50%)

#canvas({
  let spacing = (horizontal: 1.2, vertical: 0.8)

  // Helper function for drawing a matrix with colored dimension indicators
  // (x, y) position of top-left corner
  // (width, height) of matrix
  // matrix label (e.g. Q, K, V)
  // color for top dimension line
  // color for left dimension line
  // matrix style
  let matrix(
    pos,
    size,
    label,
    top-color: none,
    left-color: none,
    style: (stroke: mid-gray, fill: white, thickness: 1.5pt),
  ) = {
    let (x, y) = pos
    let (w, h) = size
    let offset = 0.1 // offset for dimension lines to avoid overlap

    rect(pos, (x + w, y - h), ..style, name: label)
    // eval label as math so matrix names render italic (matching the formula below)
    content(label, eval(label, mode: "math"))

    if top-color != none {
      line((x - 0.02, y + offset), (x + w + 0.02, y + offset), stroke: (
        paint: top-color,
        thickness: 2pt,
      ))
    }
    if left-color != none {
      line((x - offset, y + 0.02), (x - offset, y - h - 0.02), stroke: (
        paint: left-color,
        thickness: 2pt,
      ))
    }
  }

  let value-style = (stroke: mid-gray, fill: white, thickness: 1.5pt)

  let edge-style = (
    mark: (start: "|", offset: 0.075, scale: 1.3),
    stroke: mid-gray,
    thickness: 1.5pt,
  )

  let arrow-style = (
    mark: (
      start: (symbol: "|", offset: 0.075, scale: 1.3),
      end: (symbol: "stealth", offset: 0.15, scale: 0.45),
      fill: mid-gray,
    ),
    stroke: mid-gray,
    thickness: 1.5pt,
  )
  let operation(pos, body, name, padding, stroke: mid-gray + .75pt) = content(
    pos,
    body,
    frame: "rect",
    stroke: stroke,
    fill: rgb(30%, 80%, 80%, 30%),
    padding: padding,
    name: name,
  )

  // Title and equation
  content(
    (4, 2.5),
    text(weight: "bold", size: 1.2em)[Single-head attention],
    name: "title",
  )
  content(
    (4, -2.75),
    $"Attention"(Q, K, V) = "softmax"_"row" ( (Q K^top) / sqrt(d)) V$,
    name: "equation",
  )

  for spec in (
    (pos: (0, 2.7), size: (0.7, 1.8), label: "Q", top: rgb("#FFFF00"), left: rgb("#00FFFF")),
    (pos: (0, 0.4), size: (0.7, 0.8), label: "K", top: rgb("#FFFF00"), left: rgb("#FF0000")),
    (pos: (0, -1), size: (1.0, 1.2), label: "V", top: rgb("#FFA500"), left: rgb("#FF0000")),
  ) {
    matrix(
      spec.pos,
      spec.size,
      spec.label,
      top-color: spec.top,
      left-color: spec.left,
      style: value-style,
    )
  }

  operation((spacing.horizontal + 0.4, 0), $dot.op^top$, "att", (5pt, 3pt, 1pt))
  operation((2 * spacing.horizontal + 0.6, 0), [softmax], "softmax", (2pt, 3pt, 3pt))

  matrix(
    (3 * spacing.horizontal + 0.7, 0.9),
    (0.8, 1.8),
    "A",
    top-color: rgb("#FF0000"),
    left-color: rgb("#00FFFF"),
    style: value-style,
  )

  operation((4 * spacing.horizontal + 1, 0), $dot.op$, "prod", (1pt, 4pt, 2pt), stroke: mid-gray)

  matrix(
    (5 * spacing.horizontal + 0.7, 0.9),
    (1.0, 1.8),
    "Y",
    top-color: rgb("#FFA500"),
    left-color: rgb("#00FFFF"),
    style: value-style,
  )

  // Arrows with proper right angles using perpendicular coordinates
  // K to att (straight)
  line("K.east", "att.west", ..edge-style, name: "k-to-att")

  // Q to att (right angle)
  line(
    "Q.east",
    ("Q.east", "-|", "att.north"),
    "att.north",
    ..edge-style,
    name: "q-to-att",
  )

  // V to prod (right angle)
  line(
    "V.east",
    ("V.east", "-|", "prod.south"),
    "prod.south",
    ..edge-style,
    name: "v-to-prod",
  )

  for (start, end, name) in (
    ("att.east", "softmax.west", "att-to-sm"),
    ("A.east", "prod.west", "a-to-prod"),
  ) { line(start, end, stroke: mid-gray, name: name) }
  for (start, end, name) in (
    ("softmax.east", "A.west", "sm-to-a"),
    ("prod.east", "Y.west", "prod-to-y"),
  ) { line(start, end, ..arrow-style, name: name) }
})
