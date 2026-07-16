#import "@preview/cetz:0.5.2": canvas, decorations, draw
#import draw: content, line

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 14pt)

#let arrow-style = (
  mark: (end: "stealth", fill: black, scale: .75),
  stroke: 1pt,
)

#canvas({
  let box(pos, label, name) = content(
    pos,
    label,
    frame: "rect",
    stroke: 1.1pt,
    padding: (4pt, 8pt),
    name: name,
  )

  content((0, 1.25), [Training data, $arrow(s)$], anchor: "west", name: "train")
  content(
    (rel: (.15, -2.5), to: "train.west"),
    [Unseen data, $x$],
    anchor: "west",
    name: "unseen",
  )
  box((rel: (3.25, 0), to: "train.east"), [Learning algorithm, $L$], "learning")
  box((rel: (0, -2.5), to: "learning"), [Labeling function, $h$], "labeling")
  content(
    (rel: (1.85, 0), to: "labeling.east"),
    [Label, $y$],
    anchor: "west",
    name: "label",
  )

  line((rel: (.14, 0), to: "train.east"), "learning.west", ..arrow-style)
  line((rel: (.14, 0), to: "unseen.east"), "labeling.west", ..arrow-style)
  line("labeling.east", "label.west", ..arrow-style, name: "label-arrow")
  content((rel: (0, .18), to: "label-arrow.mid"), $h(x)$, anchor: "south")

  decorations.wave(
    line("learning.south", (rel: (0, .13), to: "labeling.north")),
    amplitude: .04,
    segments: 12,
    stroke: 1pt,
  )
  line(
    (rel: (0, .13), to: "labeling.north"),
    "labeling.north",
    ..arrow-style,
    name: "learned-map-end",
  )
  content(
    (rel: (.25, .9), to: "learned-map-end"),
    $L(arrow(s))$,
    anchor: "west",
  )
})
