#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, line

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#let pure-blue = rgb(0, 0, 255)

#canvas({
  let nodes = (
    s: (0, 0),
    "2": (1.85, 1.55),
    "3": (1.85, 0),
    "4": (3.7, 1.55),
    "5": (3.7, 0),
    t: (5.55, 0),
  )
  let fills = (s: rgb(255, 0, 0).lighten(50%), t: pure-blue.lighten(50%))
  for (name, pos) in nodes {
    circle(
      pos,
      radius: .26,
      fill: fills.at(name, default: white),
      stroke: .9pt,
      name: name,
    )
    content(name, raw(name))
  }

  for (from, to, label, color) in (
    ("s", "2", "10/10", pure-blue),
    ("s", "3", "9/10", pure-blue.lighten(10%)),
    ("2", "3", "0/2", gray),
    ("2", "4", "4/4", pure-blue),
    ("2", "5", "6/8", pure-blue.lighten(25%)),
    ("3", "5", "9/9", pure-blue),
    ("4", "t", "10/10", pure-blue),
    ("5", "4", "6/6", pure-blue),
    ("5", "t", "9/10", pure-blue.lighten(10%)),
  ) {
    let name = from + "-" + to
    line(
      from,
      to,
      mark: (end: "stealth", fill: color, scale: .6),
      stroke: color + 1.1pt,
      name: name,
    )
    content(
      name + ".mid",
      text(fill: color, size: .85em, raw(label)),
      fill: white,
      frame: "rect",
      stroke: none,
      padding: 1.5pt,
    )
  }
})
