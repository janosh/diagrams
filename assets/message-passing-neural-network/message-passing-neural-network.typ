#import "@preview/cetz:0.5.2": canvas, draw
#import draw: bezier, circle, content, line, rect

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#let echo-blue = rgb("#0099cc")
#let olive-green = rgb(0, 153, 0)
#let cam-dark = rgb(0, 62, 114)
#let pure-red = rgb(255, 0, 0)

#canvas({
  let node-r = .48

  // === graph on the left ===
  let vertex(pos, label, color, radius: node-r, weight: 1.4pt, name: none, label-shift: (0, 0)) = {
    circle(pos, radius: radius, stroke: color + weight, name: name)
    content(
      (pos.at(0) + label-shift.at(0), pos.at(1) + label-shift.at(1)),
      text(fill: color, label),
    )
  }
  for spec in (
    (pos: (.48, 4.04), label: $arrow(h)_1^ell$, color: gray, args: (name: "h1")),
    (pos: (2.28, 2.62), label: $arrow(h)_2^ell$, color: echo-blue, args: (name: "h2")),
    (pos: (2.4, 5.85), label: $arrow(h)_3^ell$, color: echo-blue, args: (name: "h3")),
    (
      pos: (4.18, 4.04),
      label: $arrow(h)_4^(ell + 1)$,
      color: olive-green,
      args: (radius: .6, weight: 2.2pt, name: "h4", label-shift: (.07, -.09)),
    ),
    (pos: (6.45, 6.14), label: $arrow(h)_5^ell$, color: echo-blue, args: (name: "h5")),
    (pos: (6.10, 2.14), label: $arrow(h)_6^ell$, color: echo-blue, args: (name: "h6")),
  ) { vertex(spec.pos, spec.label, spec.color, ..spec.args) }

  for (start, end) in (("h1", "h2"), ("h2", "h3")) {
    line(start, end, stroke: gray + 1.6pt)
  }

  // incoming messages
  let msg-arr = (
    mark: (end: "stealth", fill: pure-red, scale: .8),
    stroke: pure-red + 2.2pt,
  )
  for (num, label-pos) in (
    ("2", (3.45, 2.78)),
    ("3", (3.75, 5.35)),
    ("5", (5.95, 4.95)),
    ("6", (5.85, 3.05)),
  ) {
    line("h" + num, "h4", ..msg-arr)
    // padding keeps arrow anchors clear of the label glyphs
    content(
      label-pos,
      text(fill: pure-red, $arrow(h)_(#num -> 4)^ell$),
      name: "l" + num,
      padding: 4pt,
    )
  }

  // === vertex update through f_v ===
  rect((5.92, 3.74), (6.52, 4.34), stroke: cam-dark + 1.6pt, name: "fv")
  content("fv", text(fill: cam-dark, $f_v^ell$))
  content(
    (8.45, 4.12),
    text(fill: olive-green, $arrow(h)_4^(ell + 1)$),
    name: "h4-out",
    padding: 4pt,
  )
  let cam-arr = (
    mark: (end: "stealth", fill: cam-dark, scale: .8),
    stroke: cam-dark + 1.6pt,
  )
  line("h4", "fv", ..cam-arr)
  line("fv", "h4-out", ..cam-arr)

  // === message computation through f_e ===
  content(
    (8.93, 2.20),
    text(fill: echo-blue, $arrow(h)_3^ell$),
    name: "h3-in",
    padding: 4pt,
  )
  content(
    (9.93, 2.17),
    text(fill: echo-blue, $arrow(h)_4^ell$),
    name: "h4-in",
    padding: 4pt,
  )
  rect((9.08, 3.65), (9.68, 4.25), stroke: cam-dark + 1.6pt, name: "fe")
  content("fe", text(fill: cam-dark, $f_e^ell$))
  content(
    (9.35, 5.74),
    text(fill: pure-red, $arrow(h)_(3 -> 4)^ell$),
    name: "msg-out",
    padding: 4pt,
  )
  line("h3-in", "fe", ..cam-arr)
  line("h4-in", "fe", ..cam-arr)
  line("fe", "msg-out", ..cam-arr)

  // === dashed correspondence arrows ===
  let dash(color) = (
    mark: (end: "stealth", fill: color, scale: .8),
    stroke: (paint: color, thickness: 1.6pt, dash: "dashed"),
  )
  bezier("h3.east", "h3-in.north", (5.4, 5.7), (7.6, 4.4), ..dash(echo-blue))
  bezier(
    "h4.south",
    "h4-in.south-east",
    (4.9, -.2),
    (11.3, -.1),
    ..dash(echo-blue),
  )
  bezier("msg-out.north", "l3.north", (8.2, 7.9), (4.6, 7.2), ..dash(pure-red))
  bezier(
    "h4-out.south-west",
    (name: "h4", anchor: -38deg),
    (7.4, 3.2),
    (5.6, 3.3),
    ..dash(olive-green),
  )
})
