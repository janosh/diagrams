#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, line
#import "../_shared/layout.typ": card-grid, takeaway

#set page(width: 780pt, height: auto, margin: 22pt, fill: none)
#set text(font: "Avenir Next", size: 10.5pt, fill: rgb("#19324f"))
#set par(leading: 0.55em)

#let neighborhood(mode) = canvas({
  let sites = ((-2, 1.3), (-2, -1.3), (0, 2), (0, -2))
  for (idx, pos) in sites.enumerate() {
    draw.circle(
      pos,
      radius: .35,
      fill: rgb("#d6e9f8"),
      stroke: rgb("#537da0") + .7pt,
      name: "neighbor" + str(idx),
    )
    draw.content(pos, $h_#(idx + 1)$)
  }
  draw.circle(
    (0, 0),
    radius: .42,
    fill: rgb("#d3ede5"),
    stroke: rgb("#008580") + 1pt,
    name: "center",
  )
  draw.content((0, 0), $h_v$)
  for (idx, pos) in sites.enumerate() {
    let width = if mode == "attention" { (.5, 1, 2, 3).at(idx) * 1pt } else { 1pt }
    draw.line("neighbor" + str(idx), "center", stroke: rgb("#008580") + width, mark: (
      end: "stealth",
      scale: .5,
    ))
  }
  draw.line("center", (3, 0), stroke: rgb("#008580") + 1.5pt, mark: (end: "stealth"))
  draw.content((3.6, 0), $h′_v$, frame: "circle", padding: 7pt, fill: rgb("#fbe4d4"), stroke: none)
  draw.content((2.2, .65), if mode == "attention" { [weighted sum] } else if mode == "message" {
    [message + update]
  } else { [aggregate + update] })
  if mode == "attention" {
    draw.content((-.8, -2.8), [thicker arrow = larger learned weight])
  } else if mode == "message" {
    draw.content((-.4, -2.8), $m_(u v)=M(h_u,h_v,e_(u v))$)
  } else {
    draw.content((-.4, -2.8), [sum or mean ignores neighbor ordering])
  }
})

// === 2  Stack layers to reach farther ===
#let figure-1 = canvas({
  let arrow-style = (
    mark: (end: "stealth", fill: black, scale: 0.5, offset: 2pt),
    stroke: 0.5pt,
  )
  let edge-style = (stroke: 0.4pt)
  let node-radius = 0.3
  let graph-sep = 4.5 // separation between input graph and aggregation

  // Node colors - ensure consistency
  let colors = (
    A: rgb("#ffd700"), // Gold
    B: rgb("#ff4d4d"), // Red
    C: rgb("#90ee90"), // Light green
    D: rgb("#4d94ff"), // Blue
    E: rgb("#9370db"), // Purple
    F: rgb("#ff69b4"), // Pink
  )

  let draw-node(pos, label, name) = {
    circle(
      pos,
      radius: node-radius,
      fill: colors.at(label),
      stroke: 0.5pt,
      name: name,
    )
    content(pos, label, anchor: "center")
  }

  // Input Graph (left side)
  for (pos, label, name) in (
    ((-1.5, 1.2), "A", "target"),
    ((0.5, 2), "B", "b"),
    ((1, 1), "C", "c"),
    ((-2.5, -.7), "D", "d"),
    ((-0.25, -1.25), "E", "e"),
    ((1.5, 0), "F", "f"),
  ) { draw-node(pos, label, name) }

  content((rel: (0, 1.5), to: "target"), "Target Node", name: "target-label")
  line("target-label.south", "target", ..arrow-style)

  for (start, end) in (
    ("target", "b"),
    ("target", "c"),
    ("b", "c"),
    ("target", "d"),
    ("c", "e"),
    ("c", "f"),
    ("e", "f"),
  ) {
    line(start, end, ..edge-style)
  }

  content((0.25, -1.8), [Input Graph])

  // Main aggregation box
  let box-pos = (graph-sep, 0.5)
  content(
    box-pos,
    [Aggregation\ for Node A],
    name: "agg-box",
    fill: rgb("ddd"),
    frame: "rect",
    stroke: 0.2pt,
    padding: (3pt, 7pt),
  )

  // First layer nodes - renamed to show they're neighbors of A
  let first-layer = (
    (2, 2, "B", "a-to-b"),
    (2, 0, "C", "a-to-c"),
    (2, -2, "D", "a-to-d"),
  )

  // Draw first layer nodes and arrows
  for (dx, dy, label, name) in first-layer {
    draw-node((rel: (dx, dy), to: "agg-box.east"), label, name)
    line(name, "agg-box.east", ..arrow-style)
  }

  content((rel: (0, .7), to: "a-to-b"), "Hop 1")

  // Draw aggregation boxes for each first layer node
  for (_, _, label, node) in first-layer {
    let letter = lower(label)
    content(
      (rel: (2, 0), to: node),
      [Aggr(#label)],
      fill: rgb("ddd"),
      frame: "rect",
      stroke: 0.2pt,
      padding: (2pt, 4pt),
      name: "aggr-" + letter,
    )
    line("aggr-" + letter, node, ..arrow-style)
  }

  // Second layer nodes and connections - renamed to show full path
  let second-layer = (
    // From B-aggregation (B's neighbors)
    ((2, 1), "A", "aggr-b", "b-to-a"),
    ((2, 0), "C", "aggr-b", "b-to-c"),
    // From C-aggregation (C's neighbors)
    ((2, 1), "A", "aggr-c", "c-to-a"),
    ((2, 0.25), "B", "aggr-c", "c-to-b"),
    ((2, -0.5), "E", "aggr-c", "c-to-e"),
    ((2, -1.25), "F", "aggr-c", "c-to-f"),
    // From D-aggregation (D's neighbors)
    ((2, 0), "A", "aggr-d", "d-to-a"),
  )

  for ((dx, dy), label, parent, name) in second-layer {
    draw-node((rel: (dx, dy), to: parent), label, name)
    line(name, parent + ".east", ..arrow-style)
  }

  content((rel: (0, .7), to: "b-to-a"), "Hop 2")
})

A node learns from its neighborhood. These views connect the local operation, the growth of its receptive field, and two ways to construct the information being combined.
#v(14pt)
#card-grid(
  (
    [1  Aggregate the neighbors],
    neighborhood("aggregate"),
    [Graph convolution mixes neighboring node features with shared parameters. A sum or mean is unchanged when the neighbors are reordered; include self-information in the update.],
  ),
  (
    [2  Stack layers to reach farther],
    figure-1,
    [One layer communicates across one edge; two layers can use two-hop information. The expanded tree shows computation paths, not duplicated physical nodes.],
  ),

  (
    [3  Construct messages],
    neighborhood("message"),
    [A message function $M$ can depend on sender features, receiver features, and edge attributes $e_(u v)$. Aggregate the messages, then update the receiving node.],
  ),
  (
    [4  Learn which neighbors matter],
    neighborhood("attention"),
    [Attention assigns normalized weights to neighbors before aggregation. Multiple heads learn different weightings, then concatenate or average their outputs.],
  ),
)
#v(12pt)
#takeaway[$h_v$ = features at node $v$; $h′_v$ = updated features. *Shared local rules preserve node relabeling symmetry.* A graph-level prediction can pool node features into one permutation-invariant representation.]
