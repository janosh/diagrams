#import "@preview/cetz:0.5.2": canvas, draw
#import draw: bezier, circle, content, line

#set page(width: auto, height: auto, margin: 8pt)

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
  let edge-color(shortest) = if shortest { red } else { black }
  let arrow(color) = (mark: (end: "stealth", fill: color, scale: .55), stroke: color + .75pt)

  let vertex(name, fill: white) = {
    circle(nodes.at(name), radius: .28, fill: fill, stroke: .7pt, name: name)
    content(name, $upright(#name)$)
  }
  let label(pos, value, color) = content(pos, text(fill: color)[$#value$], fill: white, padding: 1pt)
  let straight(from, to, weight, offset, shortest: false) = {
    let color = edge-color(shortest)
    let edge = from + "-" + to
    line(from, to, ..arrow(color), name: edge)
    label((rel: offset, to: edge + ".mid"), weight, color)
  }

  for (name, fill) in (
    ("s", red.lighten(50%)),
    ("a", white),
    ("b", white),
    ("c", white),
    ("d", white),
    ("e", white),
    ("f", white),
    ("t", blue.lighten(50%)),
  ) { vertex(name, fill: fill) }

  straight("s", "a", "6", (-.25, .2))
  straight("s", "b", "2", (0, .28))
  straight("s", "c", "2", (-.25, -.2), shortest: true)
  straight("a", "d", "5", (0, .3))
  straight("a", "e", "4", (.25, .05))
  straight("c", "f", "1", (0, .3), shortest: true)
  straight("d", "t", "1", (.25, .2))
  straight("e", "t", "3", (0, .28), shortest: true)
  straight("f", "e", "2", (-.32, 0), shortest: true)
  straight("f", "t", "5", (.25, -.2))

  bezier(
    (rel: (.28, .05), to: "b"),
    (rel: (-.28, .05), to: "e"),
    (rel: (.7, .28), to: "b"),
    (rel: (-.7, .28), to: "e"),
    ..arrow(black),
    name: "b-e",
  )
  label((rel: (0, .23), to: "b-e.mid"), "4", black)
  bezier(
    (rel: (-.28, -.05), to: "e"),
    (rel: (.28, -.05), to: "b"),
    (rel: (-.7, -.28), to: "e"),
    (rel: (.7, -.28), to: "b"),
    ..arrow(black),
    name: "e-b",
  )
  label((rel: (0, -.23), to: "e-b.mid"), "-2", black)
})
