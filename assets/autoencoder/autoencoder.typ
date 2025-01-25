#import "@preview/cetz:0.3.2": canvas, draw

#set page(width: auto, height: auto, margin: 8pt)

#let neuron(pos, fill: white, text: none) = {
  draw.content(pos, text, frame: "circle", fill: fill, stroke: black, padding: 1pt)
}

#let connect-layers(start-pos, start-count, end-pos, end-count) = {
  let start-y = start-count / 2 * 0.8
  let end-y = end-count / 2 * 0.8

  for ii in range(start-count) {
    for jj in range(end-count) {
      let start = (start-pos, start-y - ii * 0.8)
      let end = (end-pos, end-y - jj * 0.8)
      draw.line(
        start,
        end,
        stroke: rgb("#aaa"),
      )
    }
  }
}

#canvas({
  import draw: line, content

  let input-x = 0
  let h1-x = 2
  let h2-x = 4
  let h3-x = 6
  let output-x = 8

  // Draw connections first (so they appear behind nodes)
  connect-layers(input-x, 8, h1-x, 5)
  connect-layers(h1-x, 5, h2-x, 3)
  connect-layers(h2-x, 3, h3-x, 5)
  connect-layers(h3-x, 5, output-x, 8)

  // Layer labels
  content((input-x, 4), align(center)[Input Layer])
  content((h2-x, 2.2), align(center)[Latent#linebreak()Representation])
  content((output-x, 4), align(center)[Output Layer])

  // Input layer (8 neurons)
  for ii in range(8) {
    let y = 3.2 - ii * 0.8
    neuron(
      (input-x, y),
      fill: rgb("#f6db71"),
      text: $x_#ii$,
    )
  }

  // First hidden layer (5 neurons)
  for ii in range(5) {
    let y = 2 - ii * 0.8
    neuron(
      (h1-x, y),
      fill: rgb("#eee"),
      text: $h^1_#ii$,
    )
  }

  // Latent layer (3 neurons)
  for ii in range(3) {
    let y = 1.2 - ii * 0.8
    neuron(
      (h2-x, y),
      fill: rgb("#eee"),
      text: $z_#ii$,
    )
  }

  // Third hidden layer (5 neurons)
  for ii in range(5) {
    let y = 2 - ii * 0.8
    neuron(
      (h3-x, y),
      fill: rgb("#eee"),
      text: $h^2_#ii$,
    )
  }

  // Output layer (8 neurons)
  for ii in range(8) {
    let y = 3.2 - ii * 0.8
    neuron(
      (output-x, y),
      fill: rgb("#cecef9"),
      text: $hat(x)_#ii$,
    )
  }
})
