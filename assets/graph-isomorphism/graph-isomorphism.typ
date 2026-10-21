#import "@preview/cetz:0.5.3": canvas, draw
#import draw: content, line, set-style

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 12pt)

#canvas({
  set-style(line: (stroke: 0.8pt))
  // Node n_k has the same color in every graph so the colors trace the isomorphism.
  let colors = (rgb("#f9c5c5"), rgb("#f2ceaa"), rgb("#b9d6f2"), rgb("#b1e2d8"))
  // Positions of n_1..n_4, connected in the cycle n_1 n_2 n_3 n_4 n_1
  let graphs = (
    (offset: 0, nodes: ((0, 0), (0, 2), (2, 2), (2, 0))),
    (offset: 4, nodes: ((0, 0), (2, 2), (0, 2), (2, 0))),
    (offset: 8, nodes: ((0, 0), (2, 2), (2, 0), (0, 2))),
    (offset: 12.5, nodes: ((-0.5, 0), (0.25, 2.2), (2, 1.6), (-0.7, 1.4))),
  )
  for (graph-idx, graph) in graphs.enumerate(start: 1) {
    let node-name(node-idx) = "g" + str(graph-idx) + "n" + str(node-idx)
    for (node-idx, (x, y)) in graph.nodes.enumerate(start: 1) {
      content(
        (x + graph.offset, y),
        $n_#node-idx$,
        frame: "circle",
        radius: 0.25,
        fill: colors.at(node-idx - 1),
        stroke: 0.8pt,
        name: node-name(node-idx),
        padding: 1pt,
      )
    }
    for node-idx in range(1, 5) {
      line(node-name(node-idx), node-name(calc.rem(node-idx, 4) + 1))
    }
  }
})
