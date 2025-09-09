#import "@preview/cetz:0.4.2": canvas, draw
#import draw: circle, content, line

#set page(width: auto, height: auto, margin: 8pt)

#canvas({
  let node-sep = 1.5 // Horizontal separation between nodes
  let level-sep = 1.5 // Vertical separation between levels
  let node-radius = 0.35
  let arrow-style = (mark: (end: "stealth", fill: black, scale: 0.2, offset: 0.03))

  // Helper to draw a node with label
  let draw-node(pos, label, name: none) = {
    circle(pos, radius: node-radius, name: name)
    content(pos, $#label$)
  }

  // Helper to draw edge label
  let draw-edge-label(from, to, label, left: true) = {
    let anchor = if left { "east" } else { "west" }
    content(
      (rel: (if left { -0.3 } else { 0.3 }, 0), to: from + "-" + to + ".mid"),
      $#label$,
      anchor: anchor,
    )
  }

  // Draw nodes level by level
  // Root (level 0)
  draw-node((0, 0), $P_0$, name: "p0")

  // Level 1
  draw-node((-node-sep, -level-sep), $P_1$, name: "p1")
  draw-node((node-sep, -level-sep), $P_2$, name: "p2")

  // Level 2
  draw-node((0, -2 * level-sep), $P_3$, name: "p3")
  draw-node((2 * node-sep, -2 * level-sep), $P_4$, name: "p4")

  // Level 3
  draw-node((-node-sep, -3 * level-sep), $P_5$, name: "p5")
  draw-node((node-sep, -3 * level-sep), $P_6$, name: "p6")

  // Draw edges
  line("p0", "p1", ..arrow-style, name: "p0-p1")
  line("p0", "p2", ..arrow-style, name: "p0-p2")
  line("p2", "p3", ..arrow-style, name: "p2-p3")
  line("p2", "p4", ..arrow-style, name: "p2-p4")
  line("p3", "p5", ..arrow-style, name: "p3-p5")
  line("p3", "p6", ..arrow-style, name: "p3-p6")

  // Draw edge labels
  draw-edge-label("p0", "p1", $x_1 <= 0$)
  draw-edge-label("p0", "p2", $x_1 >= 1$, left: false)
  draw-edge-label("p2", "p3", $x_2 <= 0$)
  draw-edge-label("p2", "p4", $x_2 >= 1$, left: false)
  draw-edge-label("p3", "p5", $x_3 <= 0$)
  draw-edge-label("p3", "p6", $x_3 >= 1$, left: false)
})
