#import "@preview/cetz:0.4.2": canvas, draw
#import draw: circle, content, group, line, on-layer, rect, set-style

#set page(width: auto, height: auto, margin: 8pt)

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

  let tree-node(position, fill) = circle(
    position,
    radius: node-radius,
    fill: fill,
    stroke: none,
  )

  let red-path-arrow(from, to) = line(
    (rel: (0.18, 0), to: mix(from, to, 0.3)),
    (rel: (0.18, 0), to: mix(from, to, 0.78)),
    ..red-arrow-style,
  )

  let tree-edge(from, to, arrow: false) = {
    line(from, to, ..edge-style)
    if arrow { red-path-arrow(from, to) }
  }
  let point(x-position, x-offset, y-position) = (x-position + x-offset, y-position)
  let red-node(position) = (position, red-fill)
  let blue-node(position) = (position, blue-fill)
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

  let draw-tree(box-name, label-position, label, nodes, edges) = {
    group(name: box-name, padding: (0.45, 0.5, 0.35, 0.35), {
      content(label-position, label, anchor: "west")
      for (from, to, arrow) in edges { tree-edge(from, to, arrow: arrow) }
      for (position, fill) in nodes { tree-node(position, fill) }
    })
    rect(
      box-name + ".north-west",
      box-name + ".south-east",
      stroke: 0.5pt,
      fill: none,
      radius: 3pt,
    )
  }

  let y-root = -1.55
  let y-child = -2.9
  let y-grandchild = -4.4
  let y-leaf = -6.0

  let tree1-x = -6.8
  let tree1-root = point(tree1-x, 0, y-root)
  let tree1-left = point(tree1-x, -1.25, y-child)
  let tree1-right = point(tree1-x, 1.25, y-child)
  let tree1-left-left = point(tree1-x, -1.9, y-grandchild)
  let tree1-left-right = point(tree1-x, -0.75, y-grandchild)
  let tree1-right-left = point(tree1-x, 0.35, y-grandchild)
  let tree1-right-right = point(tree1-x, 2.1, y-grandchild)
  let tree1-mid-left = point(tree1-x, -0.35, y-leaf)
  let tree1-mid-right = point(tree1-x, 0.75, y-leaf)
  let tree1-red-leaf = point(tree1-x, 1.85, y-leaf)
  let tree1-blue-leaf = point(tree1-x, 2.95, y-leaf)
  draw-tree(
    "tree1",
    (tree1-x - 2.85, -1.32),
    [Tree 1],
    (
      red-node(tree1-root),
      blue-node(tree1-left),
      red-node(tree1-right),
      blue-node(tree1-left-left),
      blue-node(tree1-left-right),
      blue-node(tree1-right-left),
      red-node(tree1-right-right),
      blue-node(tree1-mid-left),
      blue-node(tree1-mid-right),
      red-node(tree1-red-leaf),
      blue-node(tree1-blue-leaf),
    ),
    (
      edge(tree1-root, tree1-left),
      edge(tree1-root, tree1-right, arrow: true),
      edge(tree1-left, tree1-left-left),
      edge(tree1-left, tree1-left-right),
      edge(tree1-right, tree1-right-left),
      edge(tree1-right, tree1-right-right, arrow: true),
      edge(tree1-right-left, tree1-mid-left),
      edge(tree1-right-left, tree1-mid-right),
      edge(tree1-right-right, tree1-red-leaf, arrow: true),
      edge(tree1-right-right, tree1-blue-leaf),
    ),
  )

  let tree2-x = -0.3
  let tree2-root = point(tree2-x, 0, y-root)
  let tree2-left = point(tree2-x, -1.15, y-child)
  let tree2-right = point(tree2-x, 1.15, y-child)
  let tree2-left-left = point(tree2-x, -1.55, y-grandchild)
  let tree2-red-leaf = point(tree2-x, -0.45, y-grandchild)
  let tree2-right-left = point(tree2-x, 0.75, y-grandchild)
  let tree2-right-right = point(tree2-x, 1.65, y-grandchild)
  let tree2-left-leaf-a = point(tree2-x, -2.0, y-leaf)
  let tree2-left-leaf-b = point(tree2-x, -1.1, y-leaf)
  let tree2-right-leaf-a = point(tree2-x, 1.3, y-leaf)
  let tree2-right-leaf-b = point(tree2-x, 2.2, y-leaf)
  draw-tree(
    "tree2",
    (tree2-x - 2.35, -1.32),
    [Tree 2],
    (
      red-node(tree2-root),
      red-node(tree2-left),
      blue-node(tree2-right),
      blue-node(tree2-left-left),
      red-node(tree2-red-leaf),
      blue-node(tree2-right-left),
      blue-node(tree2-right-right),
      blue-node(tree2-left-leaf-a),
      blue-node(tree2-left-leaf-b),
      blue-node(tree2-right-leaf-a),
      blue-node(tree2-right-leaf-b),
    ),
    (
      edge(tree2-root, tree2-left, arrow: true),
      edge(tree2-root, tree2-right),
      edge(tree2-left, tree2-left-left),
      edge(tree2-left, tree2-red-leaf, arrow: true),
      edge(tree2-left-left, tree2-left-leaf-a),
      edge(tree2-left-left, tree2-left-leaf-b),
      edge(tree2-right, tree2-right-left),
      edge(tree2-right, tree2-right-right),
      edge(tree2-right-right, tree2-right-leaf-a),
      edge(tree2-right-right, tree2-right-leaf-b),
    ),
  )

  let tree3-x = 6.0
  let tree3-root = point(tree3-x, 0, y-root)
  let tree3-left = point(tree3-x, -1.15, y-child)
  let tree3-right = point(tree3-x, 1.15, y-child)
  let tree3-left-left = point(tree3-x, -1.55, y-grandchild)
  let tree3-left-right = point(tree3-x, -0.55, y-grandchild)
  let tree3-red-child = point(tree3-x, 0.55, y-grandchild)
  let tree3-right-leaf = point(tree3-x, 1.55, y-grandchild)
  let tree3-blue-leaf = point(tree3-x, 0.05, y-leaf)
  let tree3-red-leaf = point(tree3-x, 1.05, y-leaf)
  draw-tree(
    "tree3",
    (tree3-x - 1.95, -1.32),
    [Tree $n$],
    (
      red-node(tree3-root),
      blue-node(tree3-left),
      red-node(tree3-right),
      blue-node(tree3-left-left),
      blue-node(tree3-left-right),
      red-node(tree3-red-child),
      blue-node(tree3-right-leaf),
      blue-node(tree3-blue-leaf),
      red-node(tree3-red-leaf),
    ),
    (
      edge(tree3-root, tree3-left),
      edge(tree3-root, tree3-right, arrow: true),
      edge(tree3-left, tree3-left-left),
      edge(tree3-left, tree3-left-right),
      edge(tree3-right, tree3-red-child, arrow: true),
      edge(tree3-right, tree3-right-leaf),
      edge(tree3-red-child, tree3-blue-leaf),
      edge(tree3-red-child, tree3-red-leaf, arrow: true),
    ),
  )

  node-box((0, 1.75), [Training Data], "training")
  node-box((0, 0.55), [sample and feature bagging], "bagging")
  content((3.2, -3.55), text(size: 1.8em)[$dots.c$])
  node-box((0, -7.8), [mean in regression or majority vote in classification], "mean")
  node-box((0, -9.2), [prediction], "pred")

  line("training", "bagging", ..edge-style)
  line("bagging", "tree1.north", ..arrow-style)
  line("bagging", "tree2.north", ..arrow-style)
  line("bagging", "tree3.north", ..arrow-style)
  line("tree1.south", "mean", ..arrow-style)
  line("tree2.south", "mean", ..arrow-style)
  line("tree3.south", "mean", ..arrow-style)
  line("mean", "pred", ..arrow-style)
})
