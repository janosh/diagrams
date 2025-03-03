#import "@preview/cetz:0.3.3": canvas, draw, decorations
#import draw: line, content, circle

#set page(width: auto, height: auto, margin: 5pt)

#canvas({
  let (xr, yr) = (5, 1)
  let arrow-style = (mark: (end: "stealth", fill: black, scale: 0.5))

  // Draw axes
  line(
    (0, -yr),
    (0, yr),
    ..arrow-style,
    name: "y-axis",
  )
  content(
    (rel: (-0.7, -0.2), to: "y-axis.end"),
    $"Im"(p_0)$,
    name: "y-label",
  )

  // Draw branch points
  let left-point = (-xr / 2, 0)
  let right-point = (xr / 2, 0)

  // Draw branch cut line
  line(
    left-point,
    right-point,
    name: "x-axis",
    mark: (symbol: "circle", fill: blue, scale: 0.75),
  )
  // Add branch point labels
  content(
    (rel: (0, 0.3), to: "x-axis.start"),
    $-sqrt(arrow(p)^2)$,
    name: "left-label",
  )
  content(
    (rel: (0, 0.3), to: "x-axis.end"),
    $sqrt(arrow(p)^2)$,
    name: "right-label",
  )

  // Draw zigzag lines with decorations
  let zigzag-style = (
    stroke: blue.darken(20%),
    amplitude: 0.2,
    segment-length: 0.3,
  )

  // Left zigzag
  decorations.zigzag(
    line(
      (-xr - 0.5, 0),
      "x-axis.3%",
      ..arrow-style,
    ),
    ..zigzag-style,
    name: "left-zigzag",
  )

  // Right zigzag
  decorations.zigzag(
    line(
      "x-axis.end",
      (xr, 0),
      ..arrow-style,
    ),
    ..zigzag-style,
    name: "right-zigzag",
  )

  // Add Re axis label
  content(
    (rel: (-0.2, 0.3), to: "right-zigzag.end"),
    $"Re"(p_0)$,
    name: "x-label",
  )
})
