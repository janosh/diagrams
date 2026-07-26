#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, line

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 10pt) // Set default text size

#canvas({
  let node-layout = (radius: 0.25, sep: (x: 1.2, y: 1.2))
  let tree-line-style = (stroke: (paint: gray, thickness: 0.6pt))

  let node-colors = (
    a: blue.lighten(70%).transparentize(50%),
    b: green.lighten(70%).transparentize(50%),
    c: green.lighten(70%).transparentize(50%),
    d: green.lighten(30%).transparentize(50%),
    e: green.lighten(30%).transparentize(50%),
    f: green.lighten(40%).transparentize(50%),
    g: orange.lighten(30%).transparentize(50%),
    h: orange.lighten(40%).transparentize(50%),
    i: green.lighten(40%).transparentize(50%),
    j: blue.lighten(30%).transparentize(50%),
  )

  // the nested balls, drawn parent first so children sit on top. every ball is placed
  // relative to a neighbor purely for convenience; containment is what the tree encodes
  for (label, anchor, offset, radius) in (
    ("a", none, (-3, 0), 3.0),
    ("b", "a", (-1.0, 0.5), 1.8),
    ("c", "a", (1.4, 0.3), 1.5),
    ("d", "b", (0.2, -0.95), 0.8),
    ("e", "c", (0.6, -0.5), 0.7),
    ("f", "b", (-0.7, 0.5), 0.6),
    ("g", "c", (-0.4, 0.3), 0.7),
    ("h", "g", (0.1, -0.9), 0.5),
    ("i", "e", (0.0, 1.1), 0.6),
    ("j", "a", (0.2, -1.8), 1.0),
  ) {
    let name = "circ-" + label
    let pos = if anchor == none { offset } else { (rel: offset, to: "circ-" + anchor) }
    circle(pos, radius: radius, fill: node-colors.at(label), name: name)
    // eval keeps the letter an italic math variable; $#label$ would set it upright
    content(name, eval(label, mode: "math"))
  }

  // --- Tree Structure (Right Side) ---
  let tree-offset = (3.5, 2.5)

  for (label, dx, dy) in (
    ("a", 0, 0),
    ("b", -1.5, -1),
    ("c", 2.0, -1),
    ("j", 0, -1.5),
    ("f", -2.0, -2),
    ("d", -1.0, -2),
    ("g", 1.0, -2),
    ("e", 2.0, -2),
    ("i", 3.0, -2),
    ("h", 1.0, -3),
  ) {
    let pos = (
      tree-offset.at(0) + dx * node-layout.sep.x,
      tree-offset.at(1) + dy * node-layout.sep.y,
    )
    circle(
      pos,
      radius: node-layout.radius,
      fill: node-colors.at(label),
      stroke: 0.5pt,
      name: "node-" + label,
    )
    content(pos, $#label$)
  }

  for (parent, child) in (
    ("a", "b"),
    ("a", "c"),
    ("a", "j"),
    ("b", "f"),
    ("b", "d"),
    ("c", "g"),
    ("c", "e"),
    ("c", "i"),
    ("g", "h"),
  ) {
    line("node-" + parent, "node-" + child, ..tree-line-style)
  }
})
