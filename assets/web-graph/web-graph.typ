#import "@preview/cetz:0.5.2": canvas, draw
#import draw: bezier, circle, content, line

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#canvas({
  let r = .42
  let (dx, dy) = (2.3, 1.85)
  let nodes = (
    d0: (0, 0),
    d1: (0, -dy),
    d2: (dx, 0),
    d3: (2 * dx, 0),
    d4: (3 * dx, -dy),
    d5: (3 * dx, dy),
    d6: (3 * dx, 0),
  )
  for (idx, (name, pos)) in nodes.pairs().enumerate() {
    circle(
      pos,
      radius: r,
      fill: white.transparentize(40%),
      stroke: 1.1pt,
      name: name,
    )
    content(name, $d_#idx$)
  }

  let arrow = (
    mark: (end: "stealth", fill: black, scale: .7),
    stroke: black + 1.4pt,
  )
  let straight(from, to) = line(from, to, ..arrow)

  // bezier doesn't clip at node borders like line does, so start/end curved
  // edges on the node rim in the direction of the control point
  let rim(name, toward) = {
    let (cx, cy) = nodes.at(name)
    let (tx, ty) = toward
    let len = calc.sqrt((tx - cx) * (tx - cx) + (ty - cy) * (ty - cy))
    (cx + (tx - cx) / len * r, cy + (ty - cy) / len * r)
  }
  let curved(from, to, ctrl) = bezier(
    rim(from, ctrl),
    rim(to, ctrl),
    ctrl,
    ..arrow,
  )

  // self loop drawn as a bezier starting/ending on the node boundary
  let self-loop(name, angle) = {
    let center = nodes.at(name)
    let endpoint(offset, dist) = (
      center.at(0) + dist * r * calc.cos(angle + offset),
      center.at(1) + dist * r * calc.sin(angle + offset),
    )
    bezier(
      endpoint(-14deg, 1),
      endpoint(14deg, 1),
      endpoint(-24deg, 3.3),
      endpoint(24deg, 3.3),
      ..arrow,
    )
  }

  for (from, to, ctrl) in (
    ("d2", "d0", (dx / 2, 1.0)),
    ("d0", "d2", (dx / 2, -1.0)),
    ("d1", "d2", (dx * .85, -dy * .85)),
  ) { curved(from, to, ctrl) }
  for (from, to) in (("d2", "d3"), ("d6", "d3"), ("d5", "d6")) {
    straight(from, to)
  }
  for (from, to, ctrl) in (
    ("d3", "d4", (2.35 * dx, -dy * .9)),
    ("d4", "d6", (3 * dx + .85, -dy / 2)),
    ("d6", "d4", (3 * dx - .85, -dy / 2)),
  ) { curved(from, to, ctrl) }

  for (name, angle) in (("d1", 180deg), ("d2", 90deg), ("d3", 90deg), ("d5", 0deg), ("d6", 0deg)) {
    self-loop(name, angle)
  }
})
