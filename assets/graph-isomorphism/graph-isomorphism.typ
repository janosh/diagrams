#import "@preview/cetz:0.5.2": canvas, draw
#import draw: content, line, set-style

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#let node(pos, label, color, name) = {
  content(
    pos,
    $n_#label$,
    frame: "circle",
    radius: 0.25,
    fill: color,
    stroke: 0.8pt,
    name: name,
    padding: 1pt,
  )
}

#canvas({
  let light-red = rgb("#f9c5c5")
  let light-orange = rgb("#f2ceaa")
  let light-blue = rgb("#b9d6f2")
  let light-teal = rgb("#b1e2d8")

  set-style(line: (stroke: 0.8pt))
  let graphs = (
    (
      offset: 0,
      nodes: (
        ((0, 0), light-red),
        ((0, 2), light-orange),
        ((2, 2), light-blue),
        ((2, 0), light-teal),
      ),
    ),
    (
      offset: 4,
      nodes: (
        ((0, 0), light-red),
        ((2, 2), light-orange),
        ((0, 2), light-blue),
        ((2, 0), light-teal),
      ),
    ),
    (
      offset: 8,
      nodes: (
        ((0, 0), light-red),
        ((2, 2), light-orange),
        ((2, 0), light-teal),
        ((0, 2), light-blue),
      ),
    ),
    (
      offset: 12.5,
      nodes: (
        ((-0.5, 0), light-red),
        ((0.25, 2.2), light-orange),
        ((2, 1.6), light-blue),
        ((-0.7, 1.4), light-teal),
      ),
    ),
  )
  for (graph-idx, graph) in graphs.enumerate(start: 1) {
    for (node-idx, (pos, color)) in graph.nodes.enumerate(start: 1) {
      node(
        (pos.at(0) + graph.offset, pos.at(1)),
        node-idx,
        color,
        "g" + str(graph-idx) + "n" + str(node-idx),
      )
    }
    for node-idx in range(1, 5) {
      let next-idx = calc.rem(node-idx, 4) + 1
      line("g" + str(graph-idx) + "n" + str(node-idx), "g" + str(graph-idx) + "n" + str(next-idx))
    }
  }
})
