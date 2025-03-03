#import "@preview/cetz:0.3.3": canvas, draw
#import draw: line, content

#set page(width: auto, height: auto, margin: 8pt)

#let neuron(pos, fill: white, text: none) = {
  draw.content(pos, text, frame: "circle", fill: fill, stroke: 0.5pt, padding: 1pt)
}

#let connect-layers(start-pos, start-count, end-pos, end-count) = {
  let start-y = start-count / 2 * 0.8
  let end-y = end-count / 2 * 0.8

  for ii in range(start-count) {
    for jj in range(end-count) {
      let start = (start-pos, start-y - ii * 0.8)
      let end = (end-pos, end-y - jj * 0.8)
      draw.line(start, end, stroke: rgb("#aaa") + .5pt)
    }
  }
}

#canvas({
  // Define layer configurations
  let layers = (
    // (x-pos, neuron-count, fill-color, label-prefix, label-superscript, y-offset)
    (0, 8, rgb("#f6db71"), "x", none, 3.2), // Input layer
    (2, 5, rgb("#eee"), "h", "1", 2), // First hidden layer
    (4, 3, rgb("#eee"), "z", none, 1.2), // Latent layer
    (6, 5, rgb("#eee"), "h", "2", 2), // Third hidden layer
    (8, 8, rgb("#cecef9"), "hat(x)", none, 3.2), // Output layer
  )

  // Draw connections first (so they appear behind nodes)
  for idx in range(layers.len() - 1) {
    let (x1, n1, ..) = layers.at(idx)
    let (x2, n2, ..) = layers.at(idx + 1)
    connect-layers(x1, n1, x2, n2)
  }

  // Layer labels
  content((layers.at(0).at(0), 4), align(center)[Input Layer])
  content((layers.at(2).at(0), 2.2), align(center)[Latent\ Representation])
  content((layers.at(-1).at(0), 4), align(center)[Output Layer])

  // Draw all layers
  for (x, count, fill, prefix, sup, y-offset) in layers {
    for idx in range(count) {
      let y-pos = y-offset - idx * 0.8
      let label = if sup != none {
        $prefix^sup_idx$
      } else if prefix == "hat(x)" {
        $hat(x)_idx$
      } else {
        $prefix_idx$
      }
      neuron((x, y-pos), fill: fill, text: label)
    }
  }
})
