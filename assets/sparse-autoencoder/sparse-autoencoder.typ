#import "@preview/cetz:0.4.2": canvas, draw
#import "@preview/suiji:0.4.0"

#set page(width: auto, height: auto, margin: 8pt)


#canvas({
  import draw: *

  // Variables for input layer configuration
  let input-total-length = 20
  let n-input-neurons = 6
  let input-spacing = input-total-length / (n-input-neurons - 1)
  let rng = suiji.gen-rng(43)
  let (rng, input-activations) = suiji.uniform(rng, size: n-input-neurons)

  // Variables for hidden layer configuration
  let hidden-total-length = 30
  let n-hidden-neurons = 12
  let hidden-spacing = hidden-total-length / (n-hidden-neurons - 1)

  let hidden_rng = suiji.gen-rng(47)
  let p = 0.3
  let (hidden_rng, uniform-values) = suiji.uniform(hidden_rng, size: n-hidden-neurons)
  let (hidden_rng, hidden-activations) = suiji.uniform(hidden_rng, size: n-hidden-neurons)
  let is-alive = uniform-values.map(x => x < p)

  let output-total-lenght = input-total-length
  let n-output-neurons = n-input-neurons
  let output-spacing = input-spacing
  let output-activations = input-activations


  // Draw input layer neurons
  on-layer(1, {
    for i in range(n-input-neurons) {
      let y-coord = i * input-spacing
      circle(
        (0, y-coord),
        radius: 1,
        fill: blue.transparentize(input-activations.at(1-i) * 100%),
        stroke: blue.darken(30%) + 2pt,
        name: "in-" + str(i),
      )
    }
    // Draw hidden layer neurons
    for i in range(n-hidden-neurons) {
      let y-coord = i * hidden-spacing + (input-total-length - hidden-total-length) / 2
      circle(
        (10, y-coord),
        radius: 1,
        fill: green.transparentize(
          100%*(1 - (float(is-alive.at(i)) * hidden-activations.at(i)))
        ),
        stroke: green.darken(30%) + 2pt,
        name: "hidden-" + str(i),
      )
    }
    // Draw output layer neurons
    for i in range(n-output-neurons) {
      let y-coord = i * output-spacing
      circle(
        (20, y-coord),
        radius: 1,
        fill: blue.transparentize(output-activations.at(1-i) * 100%),
        stroke: blue.darken(30%) + 2pt,
        name: "out-" + str(i),
      )
    }
  })

  // Draw edges connecting input neurons to hidden neurons
  on-layer(0, {
    for i in range(n-input-neurons) {
      for j in range(n-hidden-neurons) {
        line("in-" + str(i), "hidden-" + str(j), stroke: gray + 1.5pt)
      }
    }
    // Draw edges connecting hidden neurons to outpu neurons
    for i in range(n-hidden-neurons) {
      for j in range(n-output-neurons) {
        line("hidden-" + str(i), "out-" + str(j), stroke: gray + 1.5pt)
      }
    }
  })
})
