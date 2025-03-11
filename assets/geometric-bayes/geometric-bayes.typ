#import "@preview/cetz:0.3.4": canvas, draw
#import draw: rect, content, line

#set page(width: auto, height: auto, margin: 3pt)

#set text(fill: white)

#canvas({
  // Define dimensions
  let width = 8
  let height = 5
  let left-col-width = 2
  let right-col-width = 2
  let mid-col-width = width - left-col-width - right-col-width
  let gap = 1 // Gap between middle and right column

  let left-x = 0
  let mid-x = left-col-width
  let right-x = width - right-col-width

  // Define vertical divisions
  let p-e-height = height / 2
  let p-h-e-height = height * 3 / 8

  let colors = (
    orange: rgb("#FFA500"),
    teal: rgb("#008080"),
    dark-blue: rgb("#1E2F4F"),
    dark-gray: rgb("#404040"),
    darker-blue: rgb("#363399"),
    darkest-gray: rgb("#171717"),
  )

  // Left column - p(H)
  rect((left-x, 0), (mid-x, p-e-height), fill: colors.orange, stroke: white, name: "p-e-given-h")
  content("p-e-given-h", $p(E|H)$)

  rect((left-x, p-e-height), (mid-x, height), fill: colors.teal, stroke: white, name: "p-not-e-given-h")
  content("p-not-e-given-h", $p(not E|H)$)

  // Middle column - p(¬H)
  rect((mid-x, 0), (right-x - gap, p-e-height / 2), fill: colors.dark-blue, stroke: white, name: "p-e-given-not-h")
  content("p-e-given-not-h", $p(E|not H)$)

  rect(
    (mid-x, p-e-height / 2),
    (right-x - gap, height),
    fill: colors.dark-gray,
    stroke: white,
    name: "p-not-e-given-not-h",
  )
  content("p-not-e-given-not-h", $p(not E|not H)$)

  // Right column - posterior probabilities
  rect((right-x, 0), (width, p-h-e-height), fill: colors.darker-blue, stroke: white, name: "p-h-given-e")
  content("p-h-given-e", $p(H|E)$)

  rect((right-x, p-h-e-height), (width, height), fill: colors.darkest-gray, stroke: white, name: "p-not-h-given-e")
  content("p-not-h-given-e", $p(not H|E)$)

  // Left brace for p(H)
  content(
    "p-not-e-given-h.north",
    text(fill: black)[
      #math.overbrace(
        box(width: 5em),
        $p(H)$,
      )
    ],
    name: "brace-ph",
    padding: (5pt, 0, 15pt),
  )

  // Right brace for p(¬H)
  content(
    "p-not-e-given-not-h.north",
    text(fill: black)[
      #math.overbrace(
        box(width: 7.5em),
        $p(not H)$,
      )
    ],
    name: "brace-not-ph",
    padding: (5pt, 0, 15pt),
  )
})
