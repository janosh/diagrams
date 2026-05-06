#import "@preview/cetz:0.5.2": canvas, decorations, draw
#import decorations: wave, zigzag
#import draw: bezier, circle, content, line

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#let mauve = rgb(148, 0, 209)
#let green2 = rgb(0, 153, 0)
#let pure-blue = rgb(0, 0, 255)
#let node-r = .52

#let dir-vec(ang) = (calc.cos(ang * 1deg), calc.sin(ang * 1deg))

#canvas({
  let nodes = (
    h1: (0, 0),
    h2: (-2.04, 2.0),
    h3: (-3.4, 0),
    h4: (-2.0, -2.0),
    h5: (0, -3.4),
    h6: (2.04, -2.0),
    hp: (5.7, 0),
  )
  let on-ring(name, ang, rr: node-r) = {
    let (cx, cy) = nodes.at(name)
    let (dx, dy) = dir-vec(ang)
    (cx + dx * rr, cy + dy * rr)
  }

  // apply wave/zigzag decoration to a body element (or pass it through for "line")
  let decorate(kind, body, paint, thickness) = {
    let deco = (wave: wave, zigzag: zigzag).at(kind, default: none)
    if deco == none { body } else {
      deco(body, amplitude: .07, segment-length: .2, segments: none, stroke: paint + thickness)
    }
  }

  // straight final segment carrying the arrowhead
  let arrow-tip(from, to, paint, thickness) = line(
    from,
    to,
    stroke: paint + thickness,
    mark: (end: "stealth", fill: paint, scale: .6),
  )

  // decorated arrow: wavy/zigzag body with a straight arrowhead segment at the end
  let deco-arrow(kind, from, to, color, thickness: 1.1pt, opacity: 100%) = {
    let paint = color.transparentize(100% - opacity)
    let (x0, y0) = from
    let (x1, y1) = to
    let len = calc.sqrt((x1 - x0) * (x1 - x0) + (y1 - y0) * (y1 - y0))
    let tip-len = calc.min(.3, len / 3)
    let break-pt = (x1 - (x1 - x0) / len * tip-len, y1 - (y1 - y0) / len * tip-len)
    decorate(kind, line(from, break-pt, stroke: paint + thickness), paint, thickness)
    arrow-tip(break-pt, to, paint, thickness)
  }

  // === attention arrows from each neighbor into h1 ===
  let triples = (
    (from: "h2", out: (285, 300, 315), into: (150, 135, 120)),
    (from: "h3", out: (-15, 0, 15), into: (195, 180, 165)),
    (from: "h4", out: (15, 30, 45), into: (240, 225, 210)),
    (from: "h5", out: (75, 90, 105), into: (-75, -90, -105)),
    (from: "h6", out: (120, 135, 150), into: (-30, -45, -60)),
  )
  let heads = (("wave", mauve), ("line", pure-blue), ("zigzag", green2))
  for spec in triples {
    for (idx, (kind, color)) in heads.enumerate() {
      deco-arrow(kind, on-ring(spec.from, spec.out.at(idx)), on-ring("h1", spec.into.at(idx)), color)
    }
  }

  // === self-attention loop on h1 ===
  let offset(pt, ang, dist) = {
    let (dx, dy) = dir-vec(ang)
    (pt.at(0) + dx * dist, pt.at(1) + dy * dist)
  }
  let self-loop(kind, ang-out, ang-in, reach, color) = {
    let start = on-ring("h1", ang-out)
    let stop = on-ring("h1", ang-in)
    // end the decorated body just outside the node, then a straight arrowhead segment
    let tip-base = offset(stop, ang-in, .25)
    let body = bezier(start, tip-base, offset(start, ang-out, reach), offset(stop, ang-in, reach), stroke: color + 1.1pt)
    decorate(kind, body, color, 1.1pt)
    arrow-tip(tip-base, stop, color, 1.1pt)
  }
  self-loop("wave", 40, 95, 2.0, mauve)
  self-loop("line", 45, 90, 1.45, pure-blue)
  self-loop("zigzag", 57, 78, 1.05, green2)

  // === aggregated output: three half-transparent thick arrows to h1' ===
  // wave/zigzag legs converge at mid as continuous lines (no intermediate
  // arrowheads); only the final segment into h1' carries a head
  let mid = (2.85, 0)
  for (kind, color, ang) in (("wave", mauve, 20), ("zigzag", green2, -20)) {
    let paint = color.transparentize(50%)
    decorate(kind, line(on-ring("h1", ang), mid, stroke: paint + 2.2pt), paint, 2.2pt)
    deco-arrow(kind, mid, on-ring("hp", 180), color, thickness: 2.2pt, opacity: 50%)
  }
  deco-arrow("line", on-ring("h1", 0), on-ring("hp", 180), pure-blue, thickness: 2.2pt, opacity: 50%)

  // === nodes ===
  for (name, label) in (
    h1: $arrow(h)_1$,
    h2: $arrow(h)_2$,
    h3: $arrow(h)_3$,
    h4: $arrow(h)_4$,
    h5: $arrow(h)_5$,
    h6: $arrow(h)_6$,
    hp: $arrow(h)'_1$,
  ).pairs() {
    circle(nodes.at(name), radius: node-r, fill: white, stroke: 1.1pt, name: name)
    content(name, label)
  }

  // === labels ===
  content((.05, 2.15), $arrow(alpha)_11$, angle: -15deg)
  content((-1.55, .82), $arrow(alpha)_12$, angle: -44deg)
  content((-1.69, -.45), $arrow(alpha)_13$)
  content((-.72, -1.32), $arrow(alpha)_14$, angle: 45deg)
  content((.45, -1.75), $arrow(alpha)_15$, angle: 90deg)
  content((1.45, -.65), $arrow(alpha)_16$, angle: -45deg)
  content((3.96, .42), [concat/avg])
})
