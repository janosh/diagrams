#import "@preview/cetz:0.5.2": canvas, draw
#import draw: content, line, rect

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#canvas({
  let arrow-style = (mark: (end: "stealth", fill: black, scale: 0.5))
  let plot-size = 6
  let plot-sep = 8

  let draw-axes(origin, label) = {
    line(
      (origin.at(0) - plot-size / 2, origin.at(1)),
      (origin.at(0) + plot-size / 2, origin.at(1)),
      ..arrow-style,
      name: label + "-x",
    )
    line(
      (origin.at(0), origin.at(1) - plot-size / 2),
      (origin.at(0), origin.at(1) + plot-size / 2),
      ..arrow-style,
      name: label + "-y",
    )

    content(
      (rel: (0, -0.3), to: label + "-x.end"),
      eval(lower(label) + "_1", mode: "math"),
      name: label + "-x-label",
    )
    content(
      (rel: (0.3, 0), to: label + "-y.end"),
      eval(lower(label) + "_2", mode: "math"),
      name: label + "-y-label",
    )

    content(
      (origin.at(0) - plot-size / 2, origin.at(1) + plot-size / 2),
      text(size: 1.2em)[#eval(label, mode: "math")],
      anchor: "south-west",
      name: label + "-title",
    )
  }

  // Draw left plot (Z space)
  let z-origin = (0, 0)
  draw-axes(z-origin, "Z")

  rect(
    (z-origin.at(0), z-origin.at(1)),
    (z-origin.at(0) + 1, z-origin.at(1) + 1),
    fill: blue.transparentize(60%),
    name: "z-square",
  )

  // Draw right plot (X space)
  let x-origin = (plot-sep, 0)
  draw-axes(x-origin, "X")

  for (idx, y, paint) in ((1, 2, red), (2, -2, green)) {
    rect(
      (x-origin.at(0), x-origin.at(1)),
      (x-origin.at(0) + 2, x-origin.at(1) + y),
      fill: paint.transparentize(60%),
      name: "x-square-" + str(idx),
    )
  }

  let mid-x = plot-sep / 2
  line(
    (mid-x - 0.3, 2.7),
    (mid-x + 0.3, 2.7),
    ..arrow-style,
    name: "f-arrow",
  )
  content("f-arrow.mid", $f$, name: "f-label", anchor: "south", padding: (
    bottom: 4pt,
  ))
  line(
    (mid-x + 0.3, -2.5),
    (mid-x - 0.3, -2.5),
    ..arrow-style,
    name: "f-inv-arrow",
  )
  content(
    "f-inv-arrow.mid",
    $f^(-1)$,
    name: "f-inv-label",
    anchor: "north",
    padding: (top: 4pt),
  )

  for spec in (
    (
      idx: 1,
      target: "x-square-1.north-east",
      paint: red,
      rel: (0.2, -0.2),
      angle: 5deg,
      label: $det J_f^(-1) = mat(delim: "|", 2, 0; 0, 2)^(-1) = 1 / 4$,
    ),
    (
      idx: 2,
      target: "x-square-2.south-east",
      paint: green,
      rel: (0.2, -0.3),
      angle: -19deg,
      label: $det J_f^(-1) = mat(delim: "|", 2, 0; 0, -2)^(-1) = -1 / 4$,
    ),
  ) {
    let arrow-name = "det-arrow-" + str(spec.idx)
    line(
      "z-square.north-east",
      spec.target,
      ..arrow-style,
      stroke: (dash: "dotted", paint: spec.paint),
      name: arrow-name,
    )
    content(
      (rel: spec.rel, to: arrow-name + ".mid"),
      text(spec.paint, spec.label),
      anchor: "north",
      angle: spec.angle,
      name: "det-label-" + str(spec.idx),
    )
  }
})
