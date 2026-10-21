#import "@preview/cetz:0.5.3": canvas, draw
#import draw: circle, content, grid, line, rect

// Outline weight of network units.
#let node-stroke = 0.8pt

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 12pt)

// MADE degrees m(k) of the units in each layer (inputs, 2 hidden layers, outputs), left to right.
#let degrees = ((3, 1, 2), (2, 1, 2, 2), (1, 2, 2, 1), (3, 1, 2))
// Hidden unit j receives unit k of the layer below iff m(j) >= m(k); output d only iff m(d) > m(k),
// so p(x_d | ...) depends only on inputs with smaller degree.
#let connected(layer-idx, from-degree, to-degree) = if layer-idx == 2 {
  to-degree > from-degree
} else { to-degree >= from-degree }

#canvas({
  let arrow-style = (mark: (end: "stealth", fill: black, scale: 0.5, offset: 1pt), stroke: .5pt)
  let (layer-gap, node-gap) = (2, 1.3)
  let (fcnn-x, mask-x, made-x) = (-5, 0, 5)

  // === Autoencoder (left) and MADE (right): same units, MADE drops masked connections ===
  for (net, x-offset, masked) in (("fcnn", fcnn-x, false), ("made", made-x, true)) {
    for (layer-idx, layer) in degrees.enumerate() {
      for (idx, degree) in layer.enumerate() {
        let pos = (x-offset + (idx - (layer.len() - 1) / 2) * node-gap, layer-idx * layer-gap)
        circle(pos, radius: 0.3, name: net + str(layer-idx) + "-" + str(idx), stroke: node-stroke)
        if masked { content(pos, str(degree)) }
      }
    }
    for layer-idx in range(3) {
      for (from-idx, from-degree) in degrees.at(layer-idx).enumerate() {
        for (to-idx, to-degree) in degrees.at(layer-idx + 1).enumerate() {
          if not masked or connected(layer-idx, from-degree, to-degree) {
            line(
              net + str(layer-idx) + "-" + str(from-idx),
              net + str(layer-idx + 1) + "-" + str(to-idx),
              ..arrow-style,
            )
          }
        }
      }
    }
  }
  for (idx, (label, x)) in (($W_1$, 2.1), ($W_2$, 2.4), ($V$, 2.1)).enumerate() {
    content((fcnn-x + x, (idx + 0.5) * layer-gap), label)
  }

  // === Mask matrices (middle): rows = upper-layer units, columns = lower-layer units, black = 0 ===
  let (mask-base-size, mask-sep) = (1.25, 2.5)
  for (layer-idx, label) in ($M_(W_1) =$, $M_(W_2) =$, $M_V =$).enumerate() {
    let (lower, upper) = (degrees.at(layer-idx), degrees.at(layer-idx + 1))
    let (rows, cols) = (upper.len(), lower.len())
    let (width, height) = (mask-base-size * cols / 3, mask-base-size * rows / 3)
    let (x, y) = (mask-x - width / 2, layer-idx * mask-sep)
    let (cell-width, cell-height) = (width / cols, height / rows)
    rect((x, y), (x + width, y + height))
    content((x - 0.8, y + height / 2), label)
    grid(
      (x, y),
      (x + width, y + height),
      step: (cell-width, cell-height),
      stroke: .2pt,
    )
    for (row, to-degree) in upper.enumerate() {
      for (col, from-degree) in lower.enumerate() {
        if not connected(layer-idx, from-degree, to-degree) {
          let cell-y = y + (rows - row - 1) * cell-height
          rect(
            (x + col * cell-width, cell-y),
            (x + (col + 1) * cell-width, cell-y + cell-height),
            fill: black,
          )
        }
      }
    }
  }

  // === Labels ===
  for idx in range(3) {
    content((rel: (0, -0.6), to: "fcnn0-" + str(idx)), $x_#(idx + 1)$)
    content((rel: (0, 0.6), to: "fcnn3-" + str(idx)), $hat(x)_#(idx + 1)$)
    content((rel: (0, -0.6), to: "made0-" + str(idx)), $x_#(idx + 1)$)
  }
  content((rel: (-.35, 0.6), to: "made3-0"), $p(x_1|x_2,x_3)$)
  content((rel: (0, 0.6), to: "made3-1"), $p(x_2)$)
  content((rel: (.25, 0.6), to: "made3-2"), $p(x_3|x_2)$)

  for (center-x, label) in (
    (fcnn-x, [autoencoder]),
    (mask-x - 2, [$times$]),
    (mask-x, [masks]),
    (mask-x + 2, [$arrow.r$]),
    (made-x, [MADE]),
  ) {
    content((center-x, -1.5), text(weight: "bold", size: 1.5em, label))
  }
})
