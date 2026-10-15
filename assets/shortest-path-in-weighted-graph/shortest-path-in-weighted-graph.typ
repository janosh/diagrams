#import "@preview/cetz:0.5.2": canvas, draw
#import draw: bezier, circle, content, line

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 12pt)

// Darker than Typst red (3.3:1 on the light page) so the path weights stay legible.
#let path-red = rgb("#d62a1e")

#canvas({
  let nodes = (
    s: (0, 0),
    a: (2, 2),
    b: (2, 0),
    c: (2, -2),
    d: (4, 2),
    e: (4, 0),
    f: (4, -2),
    t: (6, 0),
  )
  let fills = (s: red.lighten(50%), t: blue.lighten(50%))
  for (name, pos) in nodes {
    circle(
      pos,
      radius: .28,
      fill: fills.at(name, default: rgb("#cdd3da")),
      stroke: .7pt,
      name: name,
    )
    content(name, $upright(#name)$)
  }

  let arrow(color) = (mark: (end: "stealth", fill: color, scale: .55), stroke: color + .75pt)
  // red edges form the minimum-cost path s → c → f → e → t (total weight 8)
  for (from, to, weight, offset, shortest) in (
    ("s", "a", "6", (-.25, .2), false),
    ("s", "b", "2", (0, .28), false),
    ("s", "c", "2", (-.25, -.2), true),
    ("a", "d", "5", (0, .3), false),
    ("a", "e", "4", (.25, .05), false),
    ("c", "f", "1", (0, .3), true),
    ("d", "t", "1", (.25, .2), false),
    ("e", "t", "3", (0, .28), true),
    ("f", "e", "2", (-.32, 0), true),
    ("f", "t", "5", (.25, -.2), false),
  ) {
    let color = if shortest { path-red } else { black }
    let name = from + "-" + to
    line(from, to, ..arrow(color), name: name)
    content((rel: offset, to: name + ".mid"), text(fill: color)[$#weight$], padding: 1pt)
  }

  // opposing curved edges between b and e, bowing above (b → e) and below (e → b)
  for (from, to, weight, side) in (("b", "e", "4", 1), ("e", "b", "-2", -1)) {
    let name = from + "-" + to
    bezier(
      (rel: (side * .28, side * .05), to: from),
      (rel: (-side * .28, side * .05), to: to),
      (rel: (side * .7, side * .28), to: from),
      (rel: (-side * .7, side * .28), to: to),
      ..arrow(black),
      name: name,
    )
    content((rel: (0, side * .23), to: name + ".mid"), $#weight$, padding: 1pt)
  }
})
