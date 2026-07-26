#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, line

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#canvas({
  let layout = (node: 1.5, level: 1.5, radius: 0.35)
  let arrow-style = (
    mark: (end: "stealth", fill: black, scale: 0.2, offset: 0.03),
  )

  let draw-node(pos, label, name: none) = {
    circle(pos, radius: layout.radius, name: name)
    content(pos, $#label$)
  }

  let draw-edge-label(from, to, label, left: true) = {
    let anchor = if left { "east" } else { "west" }
    content(
      (rel: (if left { -0.3 } else { 0.3 }, 0), to: from + "-" + to + ".mid"),
      $#label$,
      anchor: anchor,
    )
  }

  // Root (level 0)
  draw-node((0, 0), $P_0$, name: "p0")

  // Level 1
  draw-node((-layout.node, -layout.level), $P_1$, name: "p1")
  draw-node((layout.node, -layout.level), $P_2$, name: "p2")

  // Level 2
  draw-node((0, -2 * layout.level), $P_3$, name: "p3")
  draw-node((2 * layout.node, -2 * layout.level), $P_4$, name: "p4")

  // Level 3
  draw-node((-layout.node, -3 * layout.level), $P_5$, name: "p5")
  draw-node((layout.node, -3 * layout.level), $P_6$, name: "p6")

  for (parent, child) in (
    ("p0", "p1"),
    ("p0", "p2"),
    ("p2", "p3"),
    ("p2", "p4"),
    ("p3", "p5"),
    ("p3", "p6"),
  ) {
    line(parent, child, ..arrow-style, name: parent + "-" + child)
  }

  draw-edge-label("p0", "p1", $x_1 <= 0$)
  draw-edge-label("p0", "p2", $x_1 >= 1$, left: false)
  draw-edge-label("p2", "p3", $x_2 <= 0$)
  draw-edge-label("p2", "p4", $x_2 >= 1$, left: false)
  draw-edge-label("p3", "p5", $x_3 <= 0$)
  draw-edge-label("p3", "p6", $x_3 >= 1$, left: false)
})
