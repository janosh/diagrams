#import "@preview/cetz:0.3.1": canvas, draw

#set page(width: auto, height: auto, margin: 5pt)

#let layer-sep = 2.5
#let node-sep = 1.5
#let node-radius = 0.3
#let cross-size = node-radius * 1.2

// Helper function to draw a neural network layer
#let draw-layer(x-pos, n-nodes, disabled: (), center: false) = {
  let y-coords = ()

  for idx in range(n-nodes) {
    // Center vertically if requested (for output layer)
    let y-offset = if center { (5 - n-nodes) * node-sep / 2 } else { 0 }
    let y-pos = idx * node-sep + y-offset

    // Draw node as filled circle with black outline
    draw.circle(
      (x-pos, y-pos),
      radius: node-radius,
      stroke: black + 1pt,
      fill: white,
    )

    // Add X if node is disabled
    if idx + 1 in disabled {
      // Draw red X with thicker lines
      draw.line(
        (x-pos - cross-size, y-pos - cross-size),
        (x-pos + cross-size, y-pos + cross-size),
        stroke: red + 2pt,
      )
      draw.line(
        (x-pos - cross-size, y-pos + cross-size),
        (x-pos + cross-size, y-pos - cross-size),
        stroke: red + 2pt,
      )
    } else {
      y-coords.push(y-pos)
    }
  }
  return y-coords
}

// Helper to draw connections between layers
#let connect-layers(x1, y1s, x2, y2s) = {
  for y1 in y1s {
    for y2 in y2s {
      draw.line(
        (float(x1), float(y1)),
        (float(x2), float(y2)),
        mark: (end: "stealth", fill: black),
        stroke: black + 1pt,
      )
    }
  }
}

#canvas({
  // Left network (before dropout)
  let x = 0.0
  let y1s = draw-layer(x, 5)

  x += layer-sep
  let y2s = draw-layer(x, 5)

  x += layer-sep
  let y3s = draw-layer(x, 5)

  x += layer-sep
  let y4s = draw-layer(x, 2, disabled: (), center: true) // vertically center output layer

  // Connect all nodes in adjacent layers
  connect-layers(0.0, y1s, layer-sep, y2s)
  connect-layers(layer-sep, y2s, 2 * layer-sep, y3s)
  connect-layers(2 * layer-sep, y3s, 3 * layer-sep, y4s)

  // Dropout arrow
  let arrow-x = 3.5 * layer-sep
  draw.line(
    (arrow-x, 2 * node-sep),
    (arrow-x + 2, 2 * node-sep),
    mark: (end: "stealth", fill: black),
    stroke: black + 1pt,
  )
  draw.content(
    (arrow-x + 1, 2 * node-sep + 0.3),
    text(weight: "bold", size: 1.2em, "dropout"),
  )

  // Right network (after dropout)
  x = arrow-x + 3
  let dy1s = draw-layer(x, 5, disabled: (1, 3))

  x += layer-sep
  let dy2s = draw-layer(x, 5, disabled: (1, 3, 4))

  x += layer-sep
  let dy3s = draw-layer(x, 5, disabled: (2, 4))

  x += layer-sep
  let dy4s = draw-layer(x, 2, center: true) // vertically center output layer

  // Connect only enabled nodes
  connect-layers(x - 3 * layer-sep, dy1s, x - 2 * layer-sep, dy2s)
  connect-layers(x - 2 * layer-sep, dy2s, x - layer-sep, dy3s)
  connect-layers(x - layer-sep, dy3s, x, dy4s)
})
