#import "@preview/cetz:0.5.2": canvas, draw
#import draw: content, hobby, line, rect

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#canvas({
  let node-sep = 2.5 // Horizontal separation between nodes
  let arrow-style = (mark: (end: "stealth", fill: black, scale: 0.5))
  let box-node(pos, body, name, fill: none, padding: (0, 3pt)) = content(
    pos,
    body,
    fill: fill,
    name: name,
    frame: "rect",
    padding: padding,
    stroke: none,
  )

  box-node(
    (0, 0),
    [layer 1],
    "l1",
    fill: rgb("#ffd699"),
    padding: (3pt, 6pt),
  ) // orange!50
  box-node((node-sep, 0), $a(arrow(x))$, "act1")
  box-node(
    (2 * node-sep, 0),
    [layer 2],
    "l2",
    fill: rgb("#7dc3c3"),
    padding: (3pt, 6pt),
  ) // teal!50
  content((3 * node-sep, 0), text(size: 1.8em)[$plus.o$], name: "add")
  content((rel: (0, -0.3), to: "add.south"), "add")
  box-node((3.75 * node-sep, 0), $a(arrow(x))$, "act2")
  for name in ("act1", "act2") {
    content((rel: (0, -0.3), to: name + ".south"), "activation")
  }

  for (start, end) in (
    ("l1", "act1"),
    ("act1", "l2"),
    ("l2", "add.west"),
    ("add.east", "act2"),
  ) { line(start, end, ..arrow-style) }

  line(
    (rel: (-2, 0), to: "l1"),
    "l1",
    name: "input",
    ..arrow-style,
  )
  content((rel: (0, -0.2), to: "input.10%"), $arrow(x)$)

  hobby(
    (rel: (-1.5, 0), to: "l1"),
    (rel: (0, 2.2), to: "act1"),
    "add.north",
    close: false,
    tension: 0.8,
    ..arrow-style,
    name: "skip",
  )
  content((rel: (0, 0.3), to: "skip.mid"), $arrow(x)$)
  content(
    (rel: (0, -0.3), to: "skip.mid"),
    align(center)[skip connection\ (identity)],
    anchor: "north",
  )

  // Draw F(x) curly brace
  content(
    (rel: (0, -1.2), to: "act1"),
    [#math.underbrace(box(width: 17em), text(size: 1.4em)[$cal(F)(arrow(x))$])],
    name: "fx-brace",
  )

  // Add F(x) + x label
  content(
    (rel: (0.8, 0.8), to: "add"),
    $cal(F)(arrow(x)) + arrow(x)$,
    name: "fx-label",
    frame: "rect",
    stroke: none,
    padding: 1pt,
  )
  line("fx-label.south", "add.north-east", stroke: .2pt, name: "fx-arrow")
})
