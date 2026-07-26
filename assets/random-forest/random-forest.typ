#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, group, line, rect

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 13pt)

#let arrow-style = (
  mark: (end: "stealth", fill: black, scale: 0.5),
  stroke: 0.5pt,
)
#let edge-style = (stroke: 0.5pt)
#let red-arrow-style = (
  mark: (end: "stealth", fill: red, scale: 0.65),
  stroke: red + 1.2pt,
)

#canvas({
  let node-radius = 0.22
  let blue-fill = rgb("#7a7aff")
  let red-fill = rgb("#ff4a4a")

  let mix(from, to, ratio) = {
    let (from-x, from-y) = from
    let (to-x, to-y) = to
    (from-x + (to-x - from-x) * ratio, from-y + (to-y - from-y) * ratio)
  }

  let tree-node(position, fill) = circle(position, radius: node-radius, fill: fill, stroke: none)

  let red-path-arrow(from, to) = line(
    (rel: (0.18, 0), to: mix(from, to, 0.3)),
    (rel: (0.18, 0), to: mix(from, to, 0.78)),
    ..red-arrow-style,
  )

  let tree-edge(from, to, arrow: false) = {
    line(from, to, ..edge-style)
    if arrow { red-path-arrow(from, to) }
  }
  let edge(from, to, arrow: false) = (from, to, arrow)

  let node-box(position, body, name) = content(
    position,
    body,
    frame: "rect",
    stroke: 0.1pt,
    fill: white,
    inset: 3pt,
    radius: 3pt,
    padding: (3pt, 5pt, 2pt),
    name: name,
  )

  // a tree is a list of (name, horizontal offset, row, color) plus edges joining those
  // names; edges flagged as arrows trace the path one sample takes down to its leaf
  let draw-tree(box-name, x, label-inset, label, nodes, edges) = {
    let at = (:)
    for (name, dx, y, _) in nodes { at.insert(name, (x + dx, y)) }
    group(name: box-name, padding: (0.45, 0.5, 0.35, 0.35), {
      content((x - label-inset, -1.32), label, anchor: "west")
      for (from, to, arrow) in edges { tree-edge(at.at(from), at.at(to), arrow: arrow) }
      for (name, _, _, fill) in nodes { tree-node(at.at(name), fill) }
    })
    rect(box-name + ".north-west", box-name + ".south-east", stroke: 0.5pt, fill: none, radius: 3pt)
  }

  let y-root = -1.55
  let y-child = -2.9
  let y-grandchild = -4.4
  let y-leaf = -6.0

  draw-tree(
    "tree1",
    -6.8,
    2.85,
    [Tree 1],
    (
      ("root", 0, y-root, red-fill),
      ("left", -1.25, y-child, blue-fill),
      ("right", 1.25, y-child, red-fill),
      ("left-left", -1.9, y-grandchild, blue-fill),
      ("left-right", -0.75, y-grandchild, blue-fill),
      ("right-left", 0.35, y-grandchild, blue-fill),
      ("right-right", 2.1, y-grandchild, red-fill),
      ("mid-left", -0.35, y-leaf, blue-fill),
      ("mid-right", 0.75, y-leaf, blue-fill),
      ("red-leaf", 1.85, y-leaf, red-fill),
      ("blue-leaf", 2.95, y-leaf, blue-fill),
    ),
    (
      edge("root", "left"),
      edge("root", "right", arrow: true),
      edge("left", "left-left"),
      edge("left", "left-right"),
      edge("right", "right-left"),
      edge("right", "right-right", arrow: true),
      edge("right-left", "mid-left"),
      edge("right-left", "mid-right"),
      edge("right-right", "red-leaf", arrow: true),
      edge("right-right", "blue-leaf"),
    ),
  )

  draw-tree(
    "tree2",
    -0.3,
    2.35,
    [Tree 2],
    (
      ("root", 0, y-root, red-fill),
      ("left", -1.15, y-child, red-fill),
      ("right", 1.15, y-child, blue-fill),
      ("left-left", -1.55, y-grandchild, blue-fill),
      ("red-leaf", -0.45, y-grandchild, red-fill),
      ("right-left", 0.75, y-grandchild, blue-fill),
      ("right-right", 1.65, y-grandchild, blue-fill),
      ("left-leaf-a", -2.0, y-leaf, blue-fill),
      ("left-leaf-b", -1.1, y-leaf, blue-fill),
      ("right-leaf-a", 1.3, y-leaf, blue-fill),
      ("right-leaf-b", 2.2, y-leaf, blue-fill),
    ),
    (
      edge("root", "left", arrow: true),
      edge("root", "right"),
      edge("left", "left-left"),
      edge("left", "red-leaf", arrow: true),
      edge("left-left", "left-leaf-a"),
      edge("left-left", "left-leaf-b"),
      edge("right", "right-left"),
      edge("right", "right-right"),
      edge("right-right", "right-leaf-a"),
      edge("right-right", "right-leaf-b"),
    ),
  )

  draw-tree(
    "tree3",
    6.0,
    1.95,
    [Tree $n$],
    (
      ("root", 0, y-root, red-fill),
      ("left", -1.15, y-child, blue-fill),
      ("right", 1.15, y-child, red-fill),
      ("left-left", -1.55, y-grandchild, blue-fill),
      ("left-right", -0.55, y-grandchild, blue-fill),
      ("red-child", 0.55, y-grandchild, red-fill),
      ("right-leaf", 1.55, y-grandchild, blue-fill),
      ("blue-leaf", 0.05, y-leaf, blue-fill),
      ("red-leaf", 1.05, y-leaf, red-fill),
    ),
    (
      edge("root", "left"),
      edge("root", "right", arrow: true),
      edge("left", "left-left"),
      edge("left", "left-right"),
      edge("right", "red-child", arrow: true),
      edge("right", "right-leaf"),
      edge("red-child", "blue-leaf"),
      edge("red-child", "red-leaf", arrow: true),
    ),
  )

  node-box((0, 1.75), [Training Data], "training")
  node-box((0, 0.55), [sample and feature bagging], "bagging")
  content((3.2, -3.55), text(size: 1.8em)[$dots.c$])
  node-box(
    (0, -7.8),
    [mean in regression or majority vote in classification],
    "mean",
  )
  node-box((0, -9.2), [prediction], "pred")

  line("training", "bagging", ..edge-style)
  for tree in ("tree1", "tree2", "tree3") {
    line("bagging", tree + ".north", ..arrow-style)
    line(tree + ".south", "mean", ..arrow-style)
  }
  line("mean", "pred", ..arrow-style)
})
