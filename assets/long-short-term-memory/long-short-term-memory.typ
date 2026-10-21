#import "@preview/cetz:0.5.3": canvas, draw
#import draw: bezier, circle, content, line, rect

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 12pt)

#canvas({
  let arr = (mark: (end: "stealth", fill: black, scale: .7), stroke: black + 1pt)

  // === gate stack on the left ===
  for (center-y, height, label, name) in (
    (1.32, .56, [forget gate], "fg"),
    (.76, .56, [input gate], "ig"),
    (0, 1.0, [new fts.], "ft"),
    (-.76, .56, [output gate], "og"),
  ) {
    rect((-1.1, center-y - height / 2), (1.1, center-y + height / 2), stroke: 1pt, name: name)
    content(name, label)
  }

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
  for (pos, label, name) in (
    ((2.55, 0), $times$, "t1"),
    ((4.24, 0), $+$, "pl"),
    ((7.4, 0), $times$, "t2"),
    ((rel: (0, 1.7), to: "pl"), $times$, "t3"),
  ) {
    circle(pos, radius: .3, stroke: 1pt, name: name)
    content(name, label)
  }
  rect((5.38, -.24), (6.34, .24), stroke: 1pt, name: "th")
  content("th", $tanh$)
  content((8.95, 0), $arrow(y)_t$, name: "y1")
  rect((rel: (-.75, 1.36), to: "t3"), (rel: (1.5, 1.5)), stroke: 1.4pt, name: "M")
  content("M", $M$)

  for (from, to) in (
    ("ft", "t1"),
    ("t1", "pl"),
    ("pl", "th"),
    ("th", "t2"),
    ("t2", "y1"),
    ("M", "t3"),
    ("t3", "pl"),
  ) {
    line(from, to, ..arr)
  }
  content((rel: (-.29, .8), to: "t3"), $arrow(c)_(t - 1)$, anchor: "east")

  // input gate bends up into the first product
  bezier("ig.east", (rel: (-.21, .21), to: "t1"), (2.3, .76), ..arr)
  // forget gate bends into the memory product
  bezier("fg.east", "t3.west", (2.7, 1.78), ..arr)
  // output gate runs along the bottom then bends up into the last product
  line("og.east", (5.37, -.76), stroke: black + 1pt)
  bezier((), (rel: (-.21, -.21), to: "t2"), (6.7, -.72), ..arr)
  // cell state feeds back into the memory
  bezier("pl.east", "M.east", (6.7, .5), (6.6, 3.6), ..arr)
  content((6.5, 2.55), $arrow(c)_t$, anchor: "west")

  rect((-1.5, -1.5), (8.4, 4.8), stroke: (paint: gray, thickness: 1.8pt, dash: "dashed"))
})
