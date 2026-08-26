#import "@preview/cetz:0.5.2": canvas, draw
#import draw: bezier, circle, content, line, set-style

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#let (V, p) = (9, 6)

#canvas({
  // must live inside the canvas; at document level Typst prints the returned closure
  set-style(line: (mark: (scale: .5)))

  line((0, 0), (0, p), mark: (end: "stealth", fill: black), name: "y-axis")
  content((rel: (0.2, 0), to: "y-axis.end"), $p$, name: "p-label")

  line((0, 0), (V, 0), mark: (end: "stealth", fill: black), name: "x-axis")
  content((rel: (0.2, 0), to: "x-axis.end"), $V$, name: "V-label")

  let (p-min, p-max) = (0.2 * p, 0.9 * p)
  let (V-min, V-max) = (0.2 * V, 0.9 * V)

  for (name, pos) in (
    ("p-max-ref", (0, p-max)),
    ("p-min-ref", (0, p-min)),
    ("V-min-ref", (V-min, 0)),
    ("V-max-ref", (V-max, 0)),
  ) { content(pos, name: name, []) }

  for spec in (
    (ref: "p-max-ref", delta: (V-min, 0), label-rel: (-0.5, 0), label: $p_"max"$, prefix: "p-max"),
    (ref: "V-min-ref", delta: (0, p-max), label-rel: (0, -0.5), label: $V_"min"$, prefix: "V-min"),
    (ref: "p-min-ref", delta: (V-max, 0), label-rel: (-0.5, 0), label: $p_"min"$, prefix: "p-min"),
    (ref: "V-max-ref", delta: (0, p-min), label-rel: (0, -0.5), label: $V_"max"$, prefix: "V-max"),
  ) {
    line(
      spec.ref,
      (rel: spec.delta, to: spec.ref),
      stroke: (dash: "dashed", thickness: 0.8pt),
      name: spec.prefix + "-line",
    )
    content(
      (rel: spec.label-rel, to: spec.ref),
      spec.label,
      name: spec.prefix + "-label",
    )
  }

  let points = (
    (suffix: "a", pos: (V-min, p-max), label: [1], args: (anchor: "south", padding: (bottom: 5pt))),
    (suffix: "b", pos: (V-max, 0.5 * p), label: [2], args: (anchor: "west", padding: (left: 5pt))),
    (
      suffix: "c",
      pos: (V-max, p-min),
      label: [3],
      args: (anchor: "north-west", padding: (left: 5pt)),
    ),
    (
      suffix: "d",
      pos: (V-min, 0.45 * p),
      label: [4],
      args: (anchor: "east", padding: (right: 5pt)),
    ),
  )
  for point in points {
    circle(point.pos, radius: 3pt, fill: black, name: "point-" + point.suffix)
  }
  for point in points {
    content(
      "point-" + point.suffix,
      point.label,
      ..point.args,
      name: "label-" + point.suffix,
    )
  }

  let arrow-style = (end: "stealth", fill: black, scale: .5)
  let stroke-style = (paint: rgb("#00008b"), thickness: 1.5pt)

  // a -> b (adiabatic expansion)
  bezier(
    "point-a",
    "point-b",
    (rel: (-5, 1), to: "point-b"),
    stroke: stroke-style,
    mark: arrow-style,
    name: "path-ab",
  )

  // Calculate midpoint for label using relative positioning
  content(
    ((V-min + V-max) / 2, (p-max + 0.5 * p) / 2 - 0.35),
    text(fill: blue.darken(25%), $Delta Q = 0$),
    name: "label-ab",
    anchor: "south",
    padding: (bottom: 5pt),
  )

  // b -> c (heat rejection)
  line("point-b", "point-c", mark: arrow-style, stroke: stroke-style, name: "path-bc")

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
    stroke: stroke-style,
    mark: arrow-style,
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
  line("point-d", "point-a", mark: arrow-style, stroke: stroke-style, name: "path-da")

  content(
    (rel: (-0.1, 0), to: "path-da"),
    text(fill: red)[$Q_"in" arrow.double.r$],
    name: "label-da",
    anchor: "east",
  )
})
