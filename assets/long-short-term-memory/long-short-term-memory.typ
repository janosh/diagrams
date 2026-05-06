#import "@preview/cetz:0.5.2": canvas, draw
#import draw: bezier, circle, content, line, rect

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#canvas({
  let arr = (mark: (end: "stealth", fill: black, scale: .7), stroke: black + 1pt)
  let box-w = 2.2
  let gate-h = .56

  // === gate stack on the left ===
  let gate(center-y, height, label, name) = {
    rect(
      (-box-w / 2, center-y - height / 2),
      (box-w / 2, center-y + height / 2),
      stroke: 1pt,
      name: name,
    )
    content((0, center-y), label)
  }
  gate(1.32, gate-h, [forget gate], "fg")
  gate(.76, gate-h, [input gate], "ig")
  gate(0, 1.0, [new fts.], "ft")
  gate(-.76, gate-h, [output gate], "og")

  // === inputs fanning into all four gates ===
  content((-2.4, 1.0), $arrow(x)_t$, name: "x")
  content((-2.5, -.24), $arrow(y)_(t - 1)$, name: "y")
  for (src, dy) in (("x", .21), ("y", -.21)) {
    line(src, (rel: (0, dy), to: "ft.west"), ..arr)
    for tgt in ("fg", "ig", "og") {
      line(src, (rel: (0, dy / 2), to: tgt + ".west"), ..arr)
    }
  }

  // === cell pipeline ===
  let op(pos, label, name) = {
    circle(pos, radius: .3, stroke: 1pt, name: name)
    content(name, label)
  }
  op((2.55, 0), $times$, "t1")
  op((4.24, 0), $+$, "pl")
  op((7.4, 0), $times$, "t2")
  op((4.24, 1.7), $times$, "t3")
  rect((5.62, -.24), (6.1, .24), stroke: 1pt, name: "th")
  content("th", $sigma$)
  content((8.95, 0), $arrow(y)_t$, name: "y1")
  rect((3.49, 3.06), (4.99, 4.56), stroke: 1.4pt, name: "M")
  content("M", $M$)

  for (from, to) in (
    ("ft", "t1"), ("t1", "pl"), ("pl", "th"), ("th", "t2"), ("t2", "y1"),
    ("M", "t3"), ("t3", "pl"),
  ) { line(from, to, ..arr) }
  content((3.95, 2.5), $arrow(c)_(t - 1)$, anchor: "east")

  // input gate bends up into the first product
  bezier("ig.east", (rel: (-.21, .21), to: "t1"), (2.3, .76), ..arr)
  // forget gate bends into the memory product
  bezier("fg.east", "t3.west", (2.7, 1.78), ..arr)
  // output gate runs along the bottom then bends up into the last product
  line("og.east", (5.37, -.76), stroke: black + 1pt)
  bezier((5.37, -.76), (rel: (-.21, -.21), to: "t2"), (6.7, -.72), ..arr)
  // cell state feeds back into the memory
  bezier("pl.east", "M.east", (6.7, .5), (6.6, 3.6), ..arr)
  content((6.5, 2.55), $arrow(c)_t$, anchor: "west")

  // === enclosing dashed border ===
  rect((-1.5, -1.5), (8.4, 4.8), stroke: (paint: gray, thickness: 1.8pt, dash: "dashed"))
  content((-.55, 4.3), text(size: 14pt, weight: "bold")[LSTM])
})
