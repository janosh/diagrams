#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, line
#import "../_shared/network.typ": fully-connect, node-stroke

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#canvas({
  let spacing = (layer: 2.5, node: 1.5)
  let arrow-style = (mark: (end: "stealth", scale: 0.7), fill: black)

  let draw-layer(x, nodes, prefix: "") = {
    for ii in range(nodes) {
      circle(
        (x, spacing.node * (ii + 1)),
        radius: 0.3,
        stroke: node-stroke,
        name: prefix + str(ii + 1),
      )
    }
  }

  let connect-layers = fully-connect.with(..arrow-style)

  for (layer-idx, prefix) in ((0, "i"), (1, "h1"), (2, "h2")) {
    draw-layer(layer-idx * spacing.layer, 5, prefix: prefix)
  }
  for (output-idx, y-idx) in ((1, 2), (2, 4)) {
    circle(
      (3 * spacing.layer, y-idx * spacing.node),
      radius: 0.3,
      stroke: node-stroke,
      name: "o" + str(output-idx),
    )
  }

  // Connect all layers
  connect-layers("i", "h1", 5, 5)
  connect-layers("h1", "h2", 5, 5)

  // Connect to output nodes
  for ii in range(5) {
    line(("h2" + str(ii + 1)), "o1", ..arrow-style)
    line(("h2" + str(ii + 1)), "o2", ..arrow-style)
  }

  let mid-x = 4 * spacing.layer
  line(
    (3.5 * spacing.layer, 3 * spacing.node),
    (4.5 * spacing.layer, 3 * spacing.node),
    ..arrow-style,
    name: "dropout-arrow",
  )
  content(
    "dropout-arrow.mid",
    text(weight: "bold", size: 1.2em)[dropout],
    anchor: "south",
    padding: 3pt,
  )

  for (layer-idx, prefix) in ((1, "di"), (2, "dh1"), (3, "dh2")) {
    draw-layer(mid-x + layer-idx * spacing.layer, 5, prefix: prefix)
  }
  for (output-idx, y-idx) in ((1, 2), (2, 4)) {
    circle(
      (mid-x + 4 * spacing.layer, y-idx * spacing.node),
      radius: 0.3,
      name: "do" + str(output-idx),
    )
  }

  let x-style = (fill: red, weight: "bold", size: 4em, baseline: -4pt)
  for name in ("di1", "di3", "dh11", "dh13", "dh14", "dh22", "dh24") {
    content(name, text(..x-style)[×])
  }

  // Connect remaining nodes (after dropout)
  for ii in (2, 4, 5) {
    for jj in (2, 5) {
      line(("di" + str(ii)), ("dh1" + str(jj)), ..arrow-style)
    }
  }

  for ii in (2, 5) {
    for jj in (1, 3, 5) {
      line(("dh1" + str(ii)), ("dh2" + str(jj)), ..arrow-style)
    }
  }

  for ii in (1, 3, 5) {
    line(("dh2" + str(ii)), "do1", ..arrow-style)
    line(("dh2" + str(ii)), "do2", ..arrow-style)
  }
})
