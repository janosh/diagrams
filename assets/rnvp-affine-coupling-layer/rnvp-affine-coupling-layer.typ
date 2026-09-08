#import "@preview/cetz:0.5.2": canvas, draw
#import draw: content, hobby, line, rect

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#canvas({
  let node-width = 1
  let node-height = 0.6
  let horiz-sep = 1.2
  let vert-sep = 4
  let arrow-style = (end: "stealth", fill: black, scale: .5)
  let (orange, blue, teal) = (rgb("#e8c268"), rgb("#63a7e390"), rgb("#008080"))

  // Helper function for boxes
  let box(pos, body, fill: none, name: none) = {
    rect(
      pos,
      (rel: (node-width, node-height)),
      fill: fill,
      stroke: 0.3pt,
      name: name,
    )
    content(name, body)
  }

  for (prefix, y-pos, labels) in (
    ("x", 0, ($x_1$, $x_2$, $x_d$, $x_(d+1)$, $x_D$)),
    ("z", -vert-sep, ($z_1$, $z_2$, $z_d$, $z_(d+1)$, $z_D$)),
  ) {
    let nodes = (
      (0, prefix + "1", labels.at(0), blue),
      (horiz-sep, prefix + "2", labels.at(1), blue),
      (3 * horiz-sep, prefix + "d", labels.at(2), blue),
      (5 * horiz-sep, prefix + "d-plus-1", labels.at(3), orange),
      (7 * horiz-sep, prefix + "D", labels.at(4), orange),
    )
    for (x-pos, name, label, fill) in nodes {
      box((x-pos, y-pos), label, fill: fill, name: name)
    }
    content((prefix + "2", 50%, prefix + "d"), text(size: 14pt)[$dots.c$], name: prefix + "dots1")
    content(
      (prefix + "d-plus-1", 50%, prefix + "D"),
      text(size: 14pt)[$dots.c$],
      name: prefix + "dots2",
    )
  }

  // Vertical connecting lines
  for (suffix, line-name) in (
    ("1", "line1"),
    ("2", "line2"),
    ("d", "lined"),
    ("d-plus-1", "line-d-plus-1"),
    ("D", "lineD"),
  ) { line("z" + suffix, "x" + suffix, mark: arrow-style, name: line-name) }

  // Scale and translate functions

  // Function triangles and circles
  content(
    (4.3 * horiz-sep, 0.4 * -vert-sep),
    text(fill: white)[t],
    frame: "circle",
    name: "t-circle",
    stroke: none,
    fill: teal,
    padding: 2pt,
  )
  line(
    "z1.north-west",
    "t-circle",
    "zd.north-east",
    fill: teal.transparentize(40%),
    close: true,
    stroke: none,
    name: "t-triangle",
  )

  content(
    (rel: (.6, -.75), to: "t-circle"),
    text(fill: white, baseline: -1pt)[s],
    frame: "circle",
    name: "s-circle",
    stroke: none,
    fill: orange,
    padding: 2pt,
  )
  line(
    "z1.north-west",
    "s-circle",
    "zd.north-east",
    fill: orange.transparentize(30%),
    close: true,
    stroke: none,
    name: "s-triangle",
  )

  // Operation circles
  for line-name in ("line-d-plus-1", "lineD") {
    for (op, (color, label, pos)) in (
      "odot": (orange, $dot.o$, "40%"),
      "oplus": (teal, $plus.o$, "70%"),
    ).pairs() {
      content(
        line-name + "." + pos,
        text(fill: white, baseline: -.2pt)[#label],
        frame: "circle",
        name: line-name + "-" + op,
        stroke: none,
        fill: color,
        padding: .1pt,
      )
    }
  }

  // Connect s and t to operations
  for line-name in ("line-d-plus-1", "lineD") {
    hobby(
      "s-circle",
      line-name + "-odot",
      mark: (..arrow-style, offset: 5pt),
      stroke: orange + 0.75pt,
    )
    hobby(
      "t-circle",
      line-name + "-oplus",
      mark: (..arrow-style, offset: 5pt),
      stroke: teal + 0.75pt,
    )
  }
})
