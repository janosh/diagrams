#import "@preview/cetz:0.4.0": canvas, draw, decorations
#import draw: line, content, circle

#set page(width: auto, height: auto, margin: 5pt)

#let re-range = 5
#let im-range = 4
#let arrow-style = (end: "stealth", fill: black, scale: 0.5)

#canvas({
  // Axes
  // Real axis with zigzag decoration
  // TODO: add arrow at the end, requireshttps://github.com/cetz-package/cetz/issues/446
  decorations.zigzag(
    line(
      (-re-range, 0),
      (re-range, 0),
    ),
    amplitude: 0.1,
    segment-length: 0.2,
    name: "x-axis",
    mark: arrow-style,
  )
  content(
    "x-axis.end",
    $"Re"(omega)$,
    anchor: "north-east",
    padding: (top: 5pt),
  )

  // Imaginary axis
  line(
    (0, -im-range + 1),
    (0, im-range - 1),
    mark: arrow-style,
    name: "y-axis",
  )
  content(
    "y-axis.end",
    $"Im"(omega)$,
    anchor: "north-west",
    padding: (left: 5pt),
  )

  // Matsubara frequencies
  for n in range(-im-range, im-range + 1) {
    circle(
      (0, 2 / 3 * n),
      radius: 0.05,
      fill: black,
      name: "omega" + str(n),
    )
  }
  content(
    (-1.1, 2),
    align(right)[Matsubara\ frequencies],
  )

  // Propagators
  // Advanced propagator (red)
  line(
    (-re-range, -1),
    (re-range, -1),
    stroke: (paint: red, dash: "dashed"),
    name: "advanced",
  )
  content(
    (rel: (0, -0.4), to: "advanced.start"),
    text(red)[advanced],
    anchor: "south-west",
    padding: (left: 5pt),
  )

  // Retarded propagator (blue)
  line(
    (-re-range, 1),
    (re-range, 1),
    stroke: (paint: blue, dash: "dashed"),
    name: "retarded",
  )
  content(
    "retarded.start",
    text(blue)[retarded],
    anchor: "south-west",
    padding: 2pt,
  )

  // Feynman propagator (orange)
  line(
    (-re-range, -1),
    (re-range, 1),
    stroke: (paint: orange, dash: "dashed"),
    name: "feynman",
  )
  content(
    (rel: (-0.7, -0.55), to: "feynman.end"),
    text(orange)[Feynman],
    padding: 2pt,
  )
})
