#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, line, rect

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#canvas({
  let arrow-style = (
    mark: (end: "stealth", fill: black, scale: 0.5, offset: 1pt),
    stroke: .5pt,
  )
  let node-style = (stroke: 0.7pt)
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

  let connect-layers(from-prefix, to-prefix, from-nodes, to-nodes) = {
    for i in range(from-nodes) {
      for j in range(to-nodes) {
        line(from-prefix + str(i), to-prefix + str(j), ..arrow-style)
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
    connect-layers(
      "fcnn" + str(from-idx) + "-",
      "fcnn" + str(to-idx) + "-",
      from-nodes,
      to-nodes,
    )
    let mid-y = (from-idx + 0.5) * spacing.layer
    content(
      (fcnn-x + 2.1 + if layer-label == $W_2$ { 0.3 } else { 0 }, mid-y),
      layer-label,
    )
  }

  // === Mask matrices (middle) ===
  let mask-base-size = 1.25
  let mask-sep = 2.5

  let draw-mask(x, y, rows, cols, filled-cells) = {
    let width = mask-base-size * cols / 3
    let height = mask-base-size * rows / 3
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

  // bounding box + left label + the mask grid
  let mask-box(x, y, rows, cols, filled, label) = {
    let width = mask-base-size * cols / 3
    let height = mask-base-size * rows / 3
    rect((x - width / 2, y), (x + width / 2, y + height))
    content((x - width / 2 - 0.8, y + height / 2), label)
    draw-mask(x, y, rows, cols, filled)
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

  for (from, tos) in ((0, ()), (1, (0, 1, 2, 3)), (2, (0, 2, 3))) {
    for to in tos {
      line("made0-" + str(from), "made1-" + str(to), ..arrow-style)
    }
  }
  for (from, tos) in (
    (0, (1, 2)),
    (1, (0, 1, 2, 3)),
    (2, (1, 2)),
    (3, (1, 2)),
  ) {
    for to in tos {
      line("made1-" + str(from), "made2-" + str(to), ..arrow-style)
    }
  }
  for (from, tos) in ((0, (0, 2)), (1, (0,)), (2, (0,)), (3, (0, 2))) {
    for to in tos {
      line("made2-" + str(from), "made3-" + str(to), ..arrow-style)
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
  content((fcnn-x, bottom-y), text(
    weight: "bold",
    size: label-size,
  )[autoencoder])
  content((mask-x - 2, bottom-y), text(
    weight: "bold",
    size: label-size,
  )[$times$])
  content((mask-x, bottom-y), text(weight: "bold", size: label-size)[masks])
  content((mask-x + 2, bottom-y), text(
    weight: "bold",
    size: label-size,
  )[$arrow.r$])
  content((made-x, bottom-y), text(weight: "bold", size: label-size)[MADE])
})
