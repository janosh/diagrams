#import "@preview/cetz:0.4.0": canvas, draw
#import draw: rect, content, line

#set page(width: auto, height: auto, margin: 8pt)

#canvas({
  // Define spacing variables
  let h-sep = 1.2 // horizontal separation between elements
  let v-sep = 0.8 // vertical separation between elements

  // Helper function for drawing a matrix with colored dimension indicators
  let matrix(
    pos, // (x, y) position of top-left corner
    size, // (width, height) of matrix
    label, // matrix label (e.g. Q, K, V)
    top-color: none, // color for top dimension line
    left-color: none, // color for left dimension line
    style: (stroke: rgb(50%, 50%, 50%), fill: white, thickness: 1.5pt), // matrix style
  ) = {
    let (x, y) = pos
    let (w, h) = size
    let offset = 0.1 // offset for dimension lines to avoid overlap

    // Draw matrix rectangle
    rect(pos, (x + w, y - h), ..style, name: label)
    content(label, $#label$)

    // Draw dimension indicators if colors specified
    if top-color != none {
      line(
        (x - 0.02, y + offset),
        (x + w + 0.02, y + offset),
        stroke: (paint: top-color, thickness: 2pt),
      )
    }
    if left-color != none {
      line(
        (x - offset, y + 0.02),
        (x - offset, y - h - 0.02),
        stroke: (paint: left-color, thickness: 2pt),
      )
    }
  }

  // Define styles
  let value-style = (
    stroke: rgb(50%, 50%, 50%),
    fill: white,
    thickness: 1.5pt,
  )

  let operation-style = (
    stroke: rgb(50%, 50%, 50%),
    fill: rgb(30%, 80%, 80%, 30%),
    thickness: 1.5pt,
  )

  let edge-style = (
    mark: (start: "|", offset: 0.075, scale: 1.3),
    stroke: rgb(50%, 50%, 50%),
    thickness: 1.5pt,
  )

  let arrow-style = (
    mark: (
      start: (symbol: "|", offset: 0.075, scale: 1.3),
      end: (symbol: "stealth", offset: 0.15, scale: 0.45),
      fill: rgb(50%, 50%, 50%),
    ),
    stroke: rgb(50%, 50%, 50%),
    thickness: 1.5pt,
  )

  // Title and equation
  content((4, 2.5), text(weight: "bold", size: 1.2em)[Single-head attention], name: "title")
  content(
    (4, -2.75),
    $"Attention"(Q, K, V) = "softmax"_"row" ( (Q K^top) / sqrt(d)) V$,
    name: "equation",
  )

  // Main nodes using helper function
  matrix(
    (0, 2.7),
    (0.7, 1.8),
    "Q",
    top-color: rgb("#FFFF00"),
    left-color: rgb("#00FFFF"),
    style: value-style,
  )

  matrix(
    (0, 0.4),
    (0.7, 0.8),
    "K",
    top-color: rgb("#FFFF00"),
    left-color: rgb("#FF0000"),
    style: value-style,
  )

  matrix(
    (0, -1),
    (1.0, 1.2),
    "V",
    top-color: rgb("#FFA500"),
    left-color: rgb("#FF0000"),
    style: value-style,
  )

  // Operation nodes with consistent spacing
  content(
    (h-sep + 0.4, 0),
    $dot.op^top$,
    frame: "rect",
    stroke: rgb(50%, 50%, 50%) + .75pt,
    fill: rgb(30%, 80%, 80%, 30%),
    padding: (5pt, 3pt, 1pt),
    name: "att",
  )

  content(
    (2 * h-sep + 0.6, 0),
    [softmax],
    frame: "rect",
    stroke: rgb(50%, 50%, 50%) + .75pt,
    fill: rgb(30%, 80%, 80%, 30%),
    padding: (2pt, 3pt, 3pt),
    name: "softmax",
  )

  matrix(
    (3 * h-sep + 0.7, 0.9),
    (0.8, 1.8),
    "A",
    top-color: rgb("#FF0000"),
    left-color: rgb("#00FFFF"),
    style: value-style,
  )

  content(
    (4 * h-sep + 1, 0),
    $dot.op$,
    frame: "rect",
    stroke: rgb(50%, 50%, 50%),
    fill: rgb(30%, 80%, 80%, 30%),
    padding: (1pt, 4pt, 2pt),
    name: "prod",
  )

  matrix(
    (5 * h-sep + 0.7, 0.9),
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
  line("Q.east", ("Q.east", "-|", "att.north"), "att.north", ..edge-style, name: "q-to-att")

  // V to prod (right angle)
  line("V.east", ("V.east", "-|", "prod.south"), "prod.south", ..edge-style, name: "v-to-prod")

  // Other straight connections
  line("att.east", "softmax.west", stroke: rgb(50%, 50%, 50%), name: "att-to-sm")
  line("softmax.east", "A.west", ..arrow-style, name: "sm-to-a")
  line("A.east", "prod.west", stroke: rgb(50%, 50%, 50%), name: "a-to-prod")
  line("prod.east", "Y.west", ..arrow-style, name: "prod-to-y")
})
