#import "@preview/cetz:0.5.3": canvas, draw
#import draw: circle, content, line

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 12pt)

#let pure-blue = rgb(0, 0, 255)

#canvas({
  // (column, row) grid slots, spaced 1.85 apart horizontally and 1.55 vertically
  let nodes = (s: (0, 0), "2": (1, 1), "3": (1, 0), "4": (2, 1), "5": (2, 0), t: (3, 0))
  let fills = (s: rgb(255, 0, 0).lighten(50%), t: pure-blue.lighten(50%))
  for (name, (col, row)) in nodes {
    circle(
      (col * 1.85, row * 1.55),
      radius: .26,
      fill: fills.at(name, default: rgb("#cdd3da")),
      stroke: .9pt,
      name: name,
    )
    content(name, raw(name))
  }

  for (from, to, label, color) in (
    ("s", "2", "10/10", pure-blue),
    ("s", "3", "9/10", pure-blue.lighten(10%)),
    ("2", "3", "0/2", rgb("#595959")),
    ("2", "4", "4/4", pure-blue),
    ("2", "5", "6/8", pure-blue.lighten(25%)),
    ("3", "5", "9/9", pure-blue),
    ("4", "t", "10/10", pure-blue),
    ("5", "4", "6/6", pure-blue),
    ("5", "t", "9/10", pure-blue.lighten(10%)),
  ) {
    line(
      from,
      to,
      mark: (end: "stealth", fill: color, scale: .6),
      stroke: color + 1.1pt,
      name: "edge",
    )
    content(
      "edge.mid",
      text(fill: color, raw(label)),
      fill: rgb("#cdd3da"),
      frame: "rect",
      stroke: none,
      padding: 1.5pt,
    )
  }
})
