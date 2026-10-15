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
  let blue-fill = rgb("#7a7aff")
  let red-fill = rgb("#ff4a4a")

  let mix(from, to, ratio) = from.zip(to).map(((start, end)) => start + (end - start) * ratio)
  let red-path-arrow(from, to) = line(
    (rel: (0.18, 0), to: mix(from, to, 0.3)),
    (rel: (0.18, 0), to: mix(from, to, 0.78)),
    ..red-arrow-style,
  )

  let node-box(position, body, name) = content(
    position,
    body,
    frame: "rect",
    stroke: 0.1pt,
    fill: rgb("#cdd3da"),
    inset: 3pt,
    radius: 3pt,
    padding: (3pt, 5pt, 2pt),
    name: name,
  )

  // A tree is a list of (name, parent, horizontal offset) with each node one row below its
  // parent. Red nodes and arrows trace the path one sample takes from the root to its leaf.
  let rows = (-1.55, -2.9, -4.4, -6.0)
  let draw-tree(box-name, x, label-inset, label, nodes, path) = {
    let (at, depth) = ((:), (:))
    for (name, parent, dx) in nodes {
      depth.insert(name, if parent == none { 0 } else { depth.at(parent) + 1 })
      at.insert(name, (x + dx, rows.at(depth.at(name))))
    }
    group(name: box-name, padding: (0.45, 0.5, 0.35, 0.35), {
      content((x - label-inset, rows.at(0) + 0.23), text(size: 16pt, label), anchor: "west")
      for (name, parent, _) in nodes.slice(1) {
        line(at.at(parent), at.at(name), ..edge-style)
        if name in path and parent in path { red-path-arrow(at.at(parent), at.at(name)) }
      }
      for (name, ..) in nodes {
        circle(
          at.at(name),
          radius: 0.22,
          fill: if name in path { red-fill } else { blue-fill },
          stroke: none,
        )
      }
    })
    rect(box-name + ".north-west", box-name + ".south-east", stroke: 0.5pt, fill: none, radius: 3pt)
  }

  draw-tree(
    "tree1",
    -6.8,
    2.85,
    [Tree 1],
    (
      ("root", none, 0),
      ("left", "root", -1.25),
      ("right", "root", 1.25),
      ("left-left", "left", -1.9),
      ("left-right", "left", -0.75),
      ("right-left", "right", 0.35),
      ("right-right", "right", 2.1),
      ("mid-left", "right-left", -0.35),
      ("mid-right", "right-left", 0.75),
      ("red-leaf", "right-right", 1.85),
      ("blue-leaf", "right-right", 2.95),
    ),
    ("root", "right", "right-right", "red-leaf"),
  )

  draw-tree(
    "tree2",
    -0.3,
    2.35,
    [Tree 2],
    (
      ("root", none, 0),
      ("left", "root", -1.15),
      ("right", "root", 1.15),
      ("left-left", "left", -1.55),
      ("red-leaf", "left", -0.45),
      ("right-left", "right", 0.75),
      ("right-right", "right", 1.65),
      ("left-leaf-a", "left-left", -2.0),
      ("left-leaf-b", "left-left", -1.1),
      ("right-leaf-a", "right-right", 1.3),
      ("right-leaf-b", "right-right", 2.2),
    ),
    ("root", "left", "red-leaf"),
  )

  draw-tree(
    "tree3",
    6.0,
    1.95,
    [Tree $n$],
    (
      ("root", none, 0),
      ("left", "root", -1.15),
      ("right", "root", 1.15),
      ("left-left", "left", -1.55),
      ("left-right", "left", -0.55),
      ("red-child", "right", 0.55),
      ("right-leaf", "right", 1.55),
      ("blue-leaf", "red-child", 0.05),
      ("red-leaf", "red-child", 1.05),
    ),
    ("root", "right", "red-child", "red-leaf"),
  )

  node-box((0, 1.75), [Training Data], "training")
  node-box((rel: (0, -1.2), to: "training"), [sample and feature bagging], "bagging")
  content((3.2, -3.55), text(size: 1.8em)[$dots.c$])
  node-box(
    (0, -7.8),
    text(size: 14pt)[mean in regression or majority vote in classification],
    "mean",
  )
  node-box((rel: (0, -1.4), to: "mean"), [prediction], "pred")

  line("training", "bagging", ..edge-style)
  for tree in ("tree1", "tree2", "tree3") {
    line("bagging", tree + ".north", ..arrow-style)
    line(tree + ".south", "mean", ..arrow-style)
  }
  line("mean", "pred", ..arrow-style)
})
