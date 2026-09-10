#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, line, rect

// Outline weight of network units.
#let node-stroke = 0.8pt

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#canvas({
  let arrow-style = (
    mark: (end: "stealth", fill: black, scale: 0.5, offset: 1pt),
    stroke: .5pt,
  )
  let node-style = (stroke: node-stroke)
  let spacing = (layer: 2, horizontal: 1.3)

  let draw-layer(y, nodes, prefix: "", masks: none, x-offset: 0) = {
    for i in range(nodes) {
      let x = (
        (nodes - 1) * spacing.horizontal / 2 - i * spacing.horizontal + x-offset
      )
      circle((x, y), radius: 0.3, name: prefix + str(i), ..node-style)
      if masks != none {
        content((x, y), str(masks.at(i)))
      }
    }
  }

  let fcnn-x = -5
  let mask-x = 0
  let made-x = 5

  // === Autoencoder (left): fully-connected layers + weight labels ===
  for (idx, (y, nodes)) in (
    (0, 3),
    (spacing.layer, 4),
    (2 * spacing.layer, 4),
    (3 * spacing.layer, 3),
  ).enumerate() {
    draw-layer(y, nodes, prefix: "fcnn" + str(idx) + "-", x-offset: fcnn-x)
  }
  for (from-idx, to-idx, layer-label) in (
    (0, 1, $W_1$),
    (1, 2, $W_2$),
    (2, 3, $V$),
  ) {
    let from-nodes = if from-idx == 0 { 3 } else { 4 }
    let to-nodes = if to-idx == 3 { 3 } else { 4 }
    // Connect each pair of successive layers using their node-name prefixes.
    for from-node in range(from-nodes) {
      for to-node in range(to-nodes) {
        line(
          "fcnn" + str(from-idx) + "-" + str(from-node),
          "fcnn" + str(to-idx) + "-" + str(to-node),
          ..arrow-style,
        )
      }
    }
    let mid-y = (from-idx + 0.5) * spacing.layer
    content(
      (fcnn-x + 2.1 + if layer-label == $W_2$ { 0.3 } else { 0 }, mid-y),
      layer-label,
    )
  }

  // === Mask matrices (middle) ===
  let mask-base-size = 1.25
  let mask-sep = 2.5

  // Bounding box, label, and mask grid share one set of dimensions.
  let mask-box(x, y, rows, cols, filled-cells, label) = {
    let width = mask-base-size * cols / 3
    let height = mask-base-size * rows / 3
    rect((x - width / 2, y), (x + width / 2, y + height))
    content((x - width / 2 - 0.8, y + height / 2), label)
    let cell-width = width / cols
    let cell-height = height / rows
    for i in range(cols + 1) {
      line(
        (x - width / 2 + i * cell-width, y),
        (x - width / 2 + i * cell-width, y + height),
        stroke: .2pt,
      )
    }
    for i in range(rows + 1) {
      line(
        (x - width / 2, y + i * cell-height),
        (x + width / 2, y + i * cell-height),
        stroke: .2pt,
      )
    }
    for (row, col) in filled-cells {
      rect(
        (x - width / 2 + col * cell-width, y + (rows - row - 1) * cell-height),
        (
          x - width / 2 + (col + 1) * cell-width,
          y + (rows - row) * cell-height,
        ),
        fill: black,
      )
    }
  }

  mask-box(
    mask-x,
    2 * mask-sep,
    2,
    4,
    ((0, 1), (0, 2), (1, 0), (1, 1), (1, 2), (1, 3)),
    $M_V =$,
  )
  mask-box(
    mask-x,
    mask-sep,
    4,
    4,
    ((0, 0), (0, 2), (0, 3), (3, 0), (3, 2), (3, 3)),
    $M_(W_2) =$,
  )
  mask-box(
    mask-x,
    0,
    4,
    3,
    ((0, 0), (1, 0), (2, 0), (3, 0), (2, 2)),
    $M_(W_1) =$,
  )

  // === MADE (right): masked autoregressive connections ===
  for (idx, (y, nodes, masks)) in (
    (0, 3, (3, 1, 2)),
    (spacing.layer, 4, (2, 1, 2, 2)),
    (2 * spacing.layer, 4, (1, 2, 2, 1)),
    (3 * spacing.layer, 3, (3, 1, 2)),
  ).enumerate() {
    draw-layer(
      y,
      nodes,
      prefix: "made" + str(idx) + "-",
      masks: masks,
      x-offset: made-x,
    )
  }

  for (layer_idx, connections) in (
    ((), (0, 1, 2, 3), (0, 2, 3)),
    ((1, 2), (0, 1, 2, 3), (1, 2), (1, 2)),
    ((0, 2), (0,), (0,), (0, 2)),
  ).enumerate() {
    for (from_idx, destinations) in connections.enumerate() {
      for to_idx in destinations {
        line(
          "made" + str(layer_idx) + "-" + str(from_idx),
          "made" + str(layer_idx + 1) + "-" + str(to_idx),
          ..arrow-style,
        )
      }
    }
  }

  // === Labels ===
  for i in range(3) {
    content((rel: (0, -0.6), to: "fcnn0-" + str(i)), $x_#i$)
    content((rel: (0, 0.6), to: "fcnn3-" + str(i)), $hat(x)_#i$)
    content((rel: (0, -0.6), to: "made0-" + str(i)), $x_#i$)
  }
  content((rel: (0, 0.6), to: "made3-0"), $p(x_3|x_2)$)
  content((rel: (0, 0.6), to: "made3-1"), $p(x_2)$)
  content((rel: (-.2, 0.6), to: "made3-2"), $p(x_1|x_2,x_3)$)

  let label-size = 1.5em
  let bottom-y = -1.5
  for (center_x, label) in (
    (fcnn-x, [autoencoder]),
    (mask-x - 2, [$times$]),
    (mask-x, [masks]),
    (mask-x + 2, [$arrow.r$]),
    (made-x, [MADE]),
  ) {
    content((center_x, bottom-y), text(weight: "bold", size: label-size, label))
  }
})
