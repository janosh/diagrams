#import "@preview/cetz:0.4.0": canvas, draw
#import draw: line, circle, content, rect

#set page(width: auto, height: auto, margin: 8pt)

#canvas({
  let layer-sep = 2 // Horizontal separation between layers
  let node-sep = 1.4 // Vertical separation between nodes
  let arrow-style = (stroke: .5pt, mark: (end: "stealth", fill: black, scale: .3))

  // Helper function to draw a layer of nodes
  let draw-layer(x, nodes, prefix: "") = {
    let top-y = nodes / 2
    let bottom-y = nodes / 2 - node-sep * (nodes - 1)

    for ii in range(nodes) {
      circle(
        (x, nodes / 2 - node-sep * ii),
        radius: 0.3,
        name: prefix + str(ii + 1),
      )
    }
    // Create named points for the layer bounds
    circle((x, top-y), radius: 0, name: prefix + "-top", fill: none)
    circle((x, bottom-y), radius: 0, name: prefix + "-bottom", fill: none)
  }

  // Helper to connect all nodes between layers
  let connect-layers(from-prefix, to-prefix, from-nodes, to-nodes) = {
    for ii in range(from-nodes) {
      for jj in range(to-nodes) {
        line(
          (from-prefix + str(ii + 1)),
          (to-prefix + str(jj + 1)),
          ..arrow-style,
        )
      }
    }
  }

  // Draw encoder
  draw-layer(0, 5, prefix: "e1") // Input layer
  draw-layer(layer-sep, 4, prefix: "e2") // Hidden layer
  draw-layer(layer-sep * 2, 3, prefix: "e3") // Output layer

  // Connect encoder layers
  connect-layers("e1", "e2", 5, 4)
  connect-layers("e2", "e3", 4, 3)

  // Draw mu nodes
  let mu-x = layer-sep * 3
  for ii in range(3) {
    circle(
      (mu-x, 1.5 + ii),
      radius: 0.4,
      name: "mu" + str(ii + 1),
      fill: rgb(100%, 100%, 0%, 20%),
    )
  }

  // Draw sigma nodes
  for ii in range(3) {
    circle(
      (mu-x, -1.5 - ii),
      radius: 0.4,
      name: "sigma" + str(ii + 1),
      fill: rgb(0%, 0%, 100%, 10%),
    )
  }

  // Draw sample nodes
  let sample-x = mu-x + layer-sep
  for ii in range(3) {
    circle(
      (sample-x, ii - 1),
      radius: 0.4,
      name: "sample" + str(ii + 1),
      fill: rgb(0%, 100%, 0%, 10%),
    )
  }

  // Draw boxes around mu, sigma, sample nodes
  rect(
    (mu-x - 0.5, 1),
    (mu-x + 0.5, 4),
    fill: rgb(100%, 100%, 0%, 45%),
    name: "mu-box",
    stroke: .1pt,
  )
  content("mu-box.north", $mu$, anchor: "south", padding: 3pt)

  rect(
    (mu-x - 0.5, -4),
    (mu-x + 0.5, -1),
    fill: rgb(0%, 0%, 100%, 30%),
    name: "sigma-box",
    stroke: .1pt,
  )
  content("sigma-box.north", $sigma$, anchor: "south", padding: 3pt)

  rect(
    (sample-x - 0.5, -1.5),
    (sample-x + 0.5, 1.5),
    fill: rgb(0%, 100%, 0%, 30%),
    name: "sample-box",
    stroke: .1pt,
  )
  content("sample-box.north", text(size: 0.8em)[Sample], anchor: "south", padding: 3pt)

  // Connect encoder to mu and sigma
  for ii in range(3) {
    for jj in range(3) {
      line(("e3" + str(ii + 1)), ("mu" + str(jj + 1)), ..arrow-style)
      line(("e3" + str(ii + 1)), ("sigma" + str(jj + 1)), ..arrow-style)
    }
  }

  // Connect mu and sigma nodes to sample nodes
  line("mu-box", "sample-box", ..arrow-style)
  line("sigma-box", "sample-box", ..arrow-style)

  // Draw decoder (mirrored structure of encoder)
  let decoder-x = sample-x + layer-sep
  draw-layer(decoder-x, 3, prefix: "d1")
  draw-layer(decoder-x + layer-sep, 4, prefix: "d2")
  draw-layer(decoder-x + layer-sep * 2, 5, prefix: "d3")

  // Connect decoder layers
  connect-layers("d1", "d2", 3, 4)
  connect-layers("d2", "d3", 4, 5)

  // Connect sample to decoder
  for ii in range(3) {
    for jj in range(3) {
      line(("sample" + str(ii + 1)), ("d1" + str(jj + 1)), ..arrow-style)
    }
  }

  // Add input and output labels
  for ii in range(5) {
    content(
      "e1" + str(ii + 1) + ".west",
      $x_#(ii + 1)$,
      anchor: "east",
      padding: 3pt,
    )
    content(
      "d3" + str(ii + 1) + ".east",
      $hat(x)_#(ii + 1)$,
      anchor: "west",
      padding: 3pt,
    )
  }

  content("e11.north", text(weight: "regular")[Input], anchor: "south", padding: 5pt)
  content("d31.north", text(weight: "regular")[Output], anchor: "south", padding: 5pt)
})
