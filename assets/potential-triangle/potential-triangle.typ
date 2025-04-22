#import "@preview/cetz:0.3.4": canvas, draw
#import draw: circle, content, line

#set page(width: auto, height: auto, margin: 8pt)
#set text(size: 10pt)

#canvas({
  let node_radius = 0.8
  let colors = (
    "enthalpy": rgb("#FFA500"),
    "free-energy": rgb("#008080"),
    "entropy": rgb("#00008B").darken(40%),
  )

  for (name, label, pos) in (
    ("enthalpy", [$H$\ Enthalpy], (2, 0)),
    ("free-energy", [$G$\ Free\ Energy], (-2, 0)),
    ("entropy", [$S$\ Entropy], (0, -3)),
  ) {
    let fill = colors.at(name)
    circle(pos, radius: node_radius, fill: fill, name: name, stroke: none)
    content(pos, align(center, text(fill: white, label)))
  }

  for (start, end, name, dir) in (
    ("enthalpy", "free-energy", "h-g", rtl),
    ("entropy", "enthalpy", "s-h", btt),
    ("free-energy", "entropy", "g-s", ltr),
  ) {
    let stroke = 3pt + gradient.linear(dir: dir, colors.at(start), colors.at(end))
    line(start, end, stroke: stroke, name: name)
  }

  for (name, label, anchor) in (
    ("h-g", [reactivity], "south"),
    ("s-h", [heat], "west"),
    ("g-s", [disorder], "east"),
  ) {
    content(name, align(center, label), anchor: anchor, padding: 4pt)
  }
})
