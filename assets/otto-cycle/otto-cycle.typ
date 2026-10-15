#import "@preview/cetz:0.5.2": canvas, draw
#import draw: bezier, circle, content, line, set-style

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 12pt)

#let (V, p) = (9, 6)

#canvas({
  // must live inside the canvas; at document level Typst prints the returned closure
  set-style(line: (mark: (scale: .5)))

  line((0, 0), (0, p), mark: (end: "stealth", fill: black), name: "y-axis")
  content((rel: (0.2, 0), to: "y-axis.end"), $p$)
  line((0, 0), (V, 0), mark: (end: "stealth", fill: black), name: "x-axis")
  content((rel: (0.2, 0), to: "x-axis.end"), $V$)

  let (p-min, p-max) = (0.2 * p, 0.9 * p)
  let (V-min, V-max) = (0.2 * V, 0.9 * V)

  // Dashed guides from each axis to the cycle's extreme pressures and volumes.
  for (start, end, label-pos, label) in (
    ((0, p-max), (V-min, p-max), (-0.5, p-max), $p_"max"$),
    ((V-min, 0), (V-min, p-max), (V-min, -0.5), $V_"min"$),
    ((0, p-min), (V-max, p-min), (-0.5, p-min), $p_"min"$),
    ((V-max, 0), (V-max, p-min), (V-max, -0.5), $V_"max"$),
  ) {
    line(start, end, stroke: (dash: "dashed", thickness: 0.8pt))
    content(label-pos, label)
  }

  let points = (
    (name: "a", pos: (V-min, p-max), label: [1], args: (anchor: "south", padding: (bottom: 5pt))),
    (name: "b", pos: (V-max, 0.5 * p), label: [2], args: (anchor: "west", padding: (left: 5pt))),
    (
      name: "c",
      pos: (V-max, p-min),
      label: [3],
      args: (anchor: "north-west", padding: (left: 5pt)),
    ),
    (name: "d", pos: (V-min, 0.45 * p), label: [4], args: (anchor: "east", padding: (right: 5pt))),
  )
  for point in points {
    circle(point.pos, radius: 3pt, fill: black, name: point.name)
  }
  for point in points {
    content(point.name, point.label, ..point.args)
  }

  let path-style = (
    mark: (end: "stealth", fill: black, scale: .5),
    stroke: (paint: rgb("#00008b"), thickness: 1.5pt),
  )
  let adiabat-label = text(fill: blue.darken(25%), $Delta Q = 0$)

  // 1 -> 2 adiabatic expansion
  bezier("a", "b", (rel: (-5, 1), to: "b"), ..path-style)
  content(
    ((V-min + V-max) / 2, (p-max + 0.5 * p) / 2 - 0.35),
    adiabat-label,
    anchor: "south",
    padding: (bottom: 5pt),
  )

  // 2 -> 3 isochoric heat rejection
  line("b", "c", ..path-style, name: "path-bc")
  content(
    (rel: (0.1, 0), to: "path-bc"),
    text(fill: blue.darken(5%), $arrow.double.r Q_"out"$),
    anchor: "west",
  )

  // 3 -> 4 adiabatic compression
  bezier("c", "d", (rel: (2.4, -1.3), to: "d"), ..path-style)
  content(
    ((V-max + V-min) / 2, (p-min + 0.45 * p) / 2 - 0.35),
    adiabat-label,
    anchor: "south",
    padding: (bottom: 5pt),
  )

  // 4 -> 1 isochoric heat addition
  line("d", "a", ..path-style, name: "path-da")
  content((rel: (-0.1, 0), to: "path-da"), text(fill: red)[$Q_"in" arrow.double.r$], anchor: "east")
})
