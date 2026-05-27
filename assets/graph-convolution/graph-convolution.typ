#import "@preview/cetz:0.5.1": canvas, draw
#import draw: bezier, circle, content, line

#set page(width: auto, height: auto, margin: 8pt)

#canvas({
  let green = rgb("#009900")
  let base = (
    a: (0, 2), b: (2, 1), c: (4, 1), d: (0, 0), e: (3, 0), f: (2, -1), g: (4, -1),
  )
  let edge-set = (("b", "a"), ("c", "b"), ("d", "a"), ("d", "b"), ("e", "b"), ("e", "c"), ("e", "d"), ("f", "d"), ("f", "e"), ("g", "e"), ("g", "f"))
  let selected = (("b", "c"), ("d", "b"), ("a", "b"), ("b", "e"))
  let node-radius = .32

  let node(name, pos, label: none, fill: gray.lighten(35%)) = {
    circle(pos, radius: node-radius, fill: fill, stroke: none, name: name)
    if label != none { content(name, label) }
  }

  for (from, to) in selected {
    line(base.at(from), base.at(to), stroke: red.lighten(50%) + 2.6pt)
  }
  for (from, to) in edge-set { line(base.at(from), base.at(to), stroke: black + .55pt) }
  for key in ("a", "c", "d", "e") { node(key, base.at(key), label: $arrow(h)_#key$, fill: blue.lighten(75%)) }
  node("b", base.b, label: $arrow(h)_b$, fill: red.lighten(75%))
  for key in ("f", "g") { node(key, base.at(key)) }

  let x-shift = 5.6
  let moved(name) = (rel: (x-shift, 0), to: name)
  for (from, to) in edge-set { line(moved(from), moved(to), stroke: black + .55pt) }
  for key in ("a", "c", "d", "e", "f", "g") { node(key + "1", moved(key)) }
  node("b1", moved("b"), label: $arrow(h)'_b$, fill: green.lighten(75%))

  bezier(
    (rel: (0, node-radius), to: "b"),
    (rel: (-node-radius, 0), to: "b1"),
    (rel: (1.0, 2.2), to: "b"),
    (rel: (-.9, 2.2), to: "b1"),
    mark: (end: "stealth", fill: green, scale: .6),
    stroke: (paint: green, dash: (array: (1pt, 2pt), phase: 0pt), thickness: 1.2pt),
  )
})
