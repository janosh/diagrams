#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, line
#let label-size = 12pt
#let paragraph-size = 14pt
#let heading-size = 16pt

#let card_body(title, body, caption) = block(
  width: 100%,
  inset: 12pt,
  radius: 8pt,
  fill: rgb("#cdd3da"),
  breakable: false,
)[
  #text(size: heading-size, weight: "bold", title)
  #v(8pt)
  // Measure unconstrained artwork before scaling, including content wider than its card.
  #layout(size => {
    let artwork = text(size: label-size, body)
    std.scale(size.width / measure(artwork).width * 100%, reflow: true, artwork)
  })
  #v(7pt)
  #text(size: paragraph-size, caption)
]

#let card-grid(columns: 2, ..cards) = layout(size => {
  let rows = cards
    .pos()
    .chunks(columns)
    .map(row => {
      let ratios = row.map(card => {
        let bounds = measure(text(size: label-size, card.at(1)))
        bounds.width / bounds.height
      })
      let available = size.width - 12pt * (row.len() - 1) - 24pt * row.len()
      grid(
        columns: ratios.map(ratio => 24pt + available * ratio / ratios.sum()),
        gutter: 12pt,
        ..row.map(args => card_body(..args)),
      )
    })
  stack(dir: ttb, spacing: 12pt, ..rows)
})

#let takeaway(body) = block(
  width: 100%,
  inset: 12pt,
  radius: 6pt,
  fill: rgb("#c6d8d2"),
  breakable: false,
  text(size: paragraph-size, body),
)

#set page(width: 780pt, height: auto, margin: 22pt, fill: none)
#set text(font: "Avenir Next", size: paragraph-size, fill: rgb("#19324f"))
#set par(leading: 0.55em)

#let neighborhood(mode) = canvas(
  length: if mode == "aggregate" { 1.08cm } else { 1.52cm },
  {
    let teal = rgb("#008580")
    circle((0, 0), radius: .42, fill: rgb("#d3ede5"), stroke: teal + 1pt, name: "center")
    content("center", $h_v$)
    for (idx, pos) in ((-2, 1.3), (-2, -1.3), (0, 2), (0, -2)).enumerate() {
      circle(
        pos,
        radius: .35,
        fill: rgb("#d6e9f8"),
        stroke: rgb("#537da0") + .7pt,
        name: "neighbor",
      )
      content(pos, $h_#(idx + 1)$)
      let width = if mode == "attention" { (.5, 1, 2, 3).at(idx) * 1pt } else { 1pt }
      line("neighbor", "center", stroke: teal + width, mark: (end: "stealth", scale: .5))
    }
    line("center", (3, 0), stroke: teal + 1.5pt, mark: (end: "stealth"))
    content((3.6, 0), $h′_v$, frame: "circle", padding: 7pt, fill: rgb("#fbe4d4"), stroke: none)
    let (arrow-label, note, note-x) = (
      aggregate: ([aggregate + update], [sum or mean ignores neighbor ordering], -.4),
      message: ([message + update], $m_(u v)=M(h_u,h_v,e_(u v))$, -.4),
      attention: ([weighted sum], [thicker arrow = larger learned weight], -.8),
    ).at(mode)
    content((2.2, .65), arrow-label)
    content((note-x, -2.8), note)
  },
)

// Receptive field of node A: the input graph and its two-hop computation tree.
#let receptive-field = canvas(length: .89cm, {
  let arrow-style = (
    mark: (end: "stealth", fill: black, scale: 0.5, offset: 2pt),
    stroke: 0.5pt,
  )
  // Light tints keep the node letters legible after the site's dark-mode inversion.
  let colors = (
    A: rgb("#ffd700"),
    B: rgb("#ffa8a8"),
    C: rgb("#90ee90"),
    D: rgb("#a3c8ff"),
    E: rgb("#c8b6f2"),
    F: rgb("#ffa8d4"),
  )
  let draw-node(pos, label, name) = {
    circle(pos, radius: 0.3, fill: colors.at(label), stroke: 0.5pt, name: name)
    content(pos, label)
  }
  let aggr-box(pos, body, padding, name) = content(
    pos,
    body,
    fill: rgb("ddd"),
    frame: "rect",
    stroke: 0.2pt,
    padding: padding,
    name: name,
  )

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
    line(start, end, stroke: 0.4pt)
  }

  content((0.25, -1.8), [Input Graph])

  aggr-box((4.5, 0.5), [Aggregation\ for Node A], (3pt, 7pt), "agg-box")
  // Hop 1: A's neighbors, each with its own aggregation box.
  for (dy, label) in ((2, "B"), (0, "C"), (-2, "D")) {
    let name = "a-to-" + lower(label)
    draw-node((rel: (2, dy), to: "agg-box.east"), label, name)
    line(name, "agg-box.east", ..arrow-style)
    aggr-box((rel: (2, 0), to: name), [Aggr(#label)], (2pt, 4pt), "aggr-" + lower(label))
    line("aggr-" + lower(label), name, ..arrow-style)
  }
  content((rel: (0, .7), to: "a-to-b"), "Hop 1")

  // Hop 2: the neighbors of B, C and D.
  for (dy, label, parent, name) in (
    (1, "A", "aggr-b", "b-to-a"),
    (0, "C", "aggr-b", "b-to-c"),
    (1, "A", "aggr-c", "c-to-a"),
    (0.25, "B", "aggr-c", "c-to-b"),
    (-0.5, "E", "aggr-c", "c-to-e"),
    (-1.25, "F", "aggr-c", "c-to-f"),
    (0, "A", "aggr-d", "d-to-a"),
  ) {
    draw-node((rel: (2, dy), to: parent), label, name)
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
    receptive-field,
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
