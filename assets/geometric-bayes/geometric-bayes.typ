#import "@preview/cetz:0.5.2": canvas, draw
#import draw: content, rect

#set page(width: auto, height: auto, margin: 3pt, fill: none)

#set text(fill: white)

#canvas({
  let width = 8
  let height = 5
  let left-col-width = 2
  let right-col-width = 2
  let gap = 1 // Gap between middle and right column

  let left-x = 0
  let mid-x = left-col-width
  let right-x = width - right-col-width

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

  for spec in (
    (
      start: (left-x, 0),
      end: (mid-x, p-e-height),
      fill: colors.orange,
      name: "p-e-given-h",
      label: $p(E|H)$,
    ),
    (
      start: (left-x, p-e-height),
      end: (mid-x, height),
      fill: colors.teal,
      name: "p-not-e-given-h",
      label: $p(not E|H)$,
    ),
    (
      start: (mid-x, 0),
      end: (right-x - gap, p-e-height / 2),
      fill: colors.dark-blue,
      name: "p-e-given-not-h",
      label: $p(E|not H)$,
    ),
    (
      start: (mid-x, p-e-height / 2),
      end: (right-x - gap, height),
      fill: colors.dark-gray,
      name: "p-not-e-given-not-h",
      label: $p(not E|not H)$,
    ),
    (
      start: (right-x, 0),
      end: (width, p-h-e-height),
      fill: colors.darker-blue,
      name: "p-h-given-e",
      label: $p(H|E)$,
    ),
    (
      start: (right-x, p-h-e-height),
      end: (width, height),
      fill: colors.darkest-gray,
      name: "p-not-h-given-e",
      label: $p(not H|E)$,
    ),
  ) {
    rect(spec.start, spec.end, fill: spec.fill, stroke: white, name: spec.name)
    content(spec.name, spec.label)
  }

  for (pos, width, label, name) in (
    ("p-not-e-given-h.north", 5em, $p(H)$, "brace-ph"),
    ("p-not-e-given-not-h.north", 7.5em, $p(not H)$, "brace-not-ph"),
  ) {
    content(
      pos,
      text(fill: black)[#math.overbrace(box(width: width), label)],
      name: name,
      padding: (5pt, 0, 15pt),
    )
  }
})
