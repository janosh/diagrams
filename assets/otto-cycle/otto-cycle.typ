#import "@preview/cetz:0.4.2": canvas, draw
#import draw: bezier, circle, content, line, set-style

#set page(width: auto, height: auto, margin: 8pt)

#let (V, p) = (9, 6)
#set-style(line: (mark: (scale: .5)))

#canvas({
  // Draw axes
  line((0, 0), (0, p), mark: (end: "stealth", fill: black), name: "y-axis")
  content((rel: (0.2, 0), to: "y-axis.end"), $p$, name: "p-label")

  line((0, 0), (V, 0), mark: (end: "stealth", fill: black), name: "x-axis")
  content((rel: (0.2, 0), to: "x-axis.end"), $V$, name: "V-label")

  // Define key values
  let (p-min, p-max) = (0.2 * p, 0.9 * p)
  let (V-min, V-max) = (0.2 * V, 0.9 * V)

  // Create reference points for min/max values
  content((0, p-max), name: "p-max-ref", [])
  content((0, p-min), name: "p-min-ref", [])
  content((V-min, 0), name: "V-min-ref", [])
  content((V-max, 0), name: "V-max-ref", [])

  // Horizontal dashed line for p-max
  line(
    "p-max-ref",
    (rel: (V-min, 0), to: "p-max-ref"),
    stroke: (dash: "dashed", thickness: 0.8pt),
    name: "p-max-line",
  )

  // Vertical dashed line for V-min
  line(
    "V-min-ref",
    (rel: (0, p-max), to: "V-min-ref"),
    stroke: (dash: "dashed", thickness: 0.8pt),
    name: "V-min-line",
  )

  // Labels for p-max and V-min
  content((rel: (-0.5, 0), to: "p-max-ref"), $p_"max"$, name: "p-max-label")
  content((rel: (0, -0.5), to: "V-min-ref"), $V_"min"$, name: "V-min-label")

  // Horizontal dashed line for p-min
  line(
    "p-min-ref",
    (rel: (V-max, 0), to: "p-min-ref"),
    stroke: (dash: "dashed", thickness: 0.8pt),
    name: "p-min-line",
  )

  // Vertical dashed line for V-max
  line(
    "V-max-ref",
    (rel: (0, p-min), to: "V-max-ref"),
    stroke: (dash: "dashed", thickness: 0.8pt),
    name: "V-max-line",
  )

  // Labels for p-min and V-max
  content((rel: (-0.5, 0), to: "p-min-ref"), $p_"min"$, name: "p-min-label")
  content((rel: (0, -0.5), to: "V-max-ref"), $V_"max"$, name: "V-max-label")

  // Define cycle points
  circle((V-min, p-max), radius: 3pt, fill: black, name: "point-a")

  circle((V-max, 0.5 * p), radius: 3pt, fill: black, name: "point-b")

  circle((V-max, p-min), radius: 3pt, fill: black, name: "point-c")

  circle((V-min, 0.45 * p), radius: 3pt, fill: black, name: "point-d")

  // Add point labels
  content("point-a", [1], anchor: "south", padding: (bottom: 5pt), name: "label-a")
  content("point-b", [2], anchor: "west", padding: (left: 5pt), name: "label-b")
  content("point-c", [3], anchor: "north-west", padding: (left: 5pt), name: "label-c")
  content("point-d", [4], anchor: "east", padding: (right: 5pt), name: "label-d")

  // Define styles for paths
  let arrow_style = (end: "stealth", fill: black, scale: .5)
  let stroke_style = (paint: rgb("#00008b"), thickness: 1.5pt)

  // Draw cycle paths with arrows and labels
  // a -> b (adiabatic expansion)
  bezier(
    "point-a",
    "point-b",
    (rel: (-5, 1), to: "point-b"),
    stroke: stroke_style,
    mark: arrow_style,
    name: "path-ab",
  )

  // Calculate midpoint for label using relative positioning
  // Create a midpoint reference
  content(
    ((V-min + V-max) / 2, (p-max + 0.5 * p) / 2 - 0.35),
    text(fill: blue.darken(25%), $Delta Q = 0$),
    name: "label-ab",
    anchor: "south",
    padding: (bottom: 5pt),
  )

  // b -> c (heat rejection)
  line("point-b", "point-c", mark: arrow_style, stroke: stroke_style, name: "path-bc")

  content(
    (rel: (0.1, 0), to: "path-bc"),
    text(fill: blue.darken(5%), $arrow.double.r Q_"out"$),
    name: "label-bc",
    anchor: "west",
  )

  // c -> d (adiabatic compression)
  bezier(
    "point-c",
    "point-d",
    (rel: (2.4, -1.3), to: "point-d"),
    stroke: stroke_style,
    mark: arrow_style,
    name: "path-cd",
  )

  content(
    ((V-max + V-min) / 2, (p-min + 0.45 * p) / 2 - 0.35),
    text(fill: blue.darken(15%), $Delta Q = 0$),
    name: "label-cd",
    anchor: "south",
    padding: (bottom: 5pt),
  )

  // d -> a (heat addition)
  line(
    "point-d",
    "point-a",
    mark: arrow_style,
    stroke: stroke_style,
    name: "path-da",
  )

  content(
    (rel: (-0.1, 0), to: "path-da"),
    text(fill: red)[$Q_"in" arrow.double.r$],
    name: "label-da",
    anchor: "east",
  )
})
