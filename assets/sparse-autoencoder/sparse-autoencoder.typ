#import "@preview/cetz:0.4.2": canvas, draw
#import "@preview/suiji:0.4.0"

#set page(width: auto, height: auto, margin: 8pt)

#canvas({
  import draw: circle, line, on-layer

  // Layer configuration
  let (n-input-neurons, n-hidden-neurons) = (6, 12)
  let (input-len, hidden-len) = (20, 30)
  let sparsity = 0.3

  // Generate activations
  let input-rng = suiji.gen-rng(43)
  let (input-rng, input-activations) = suiji.uniform(input-rng, size: n-input-neurons)

  let hidden-rng = suiji.gen-rng(47)
  let (hidden-rng, uniform-values) = suiji.uniform(hidden-rng, size: n-hidden-neurons)
  let (hidden-rng, hidden-activations) = suiji.uniform(hidden-rng, size: n-hidden-neurons)
  let is-alive = uniform-values.map(x => x < sparsity)

  // Draw neurons
  on-layer(1, {
    // Input layer
    for ii in range(n-input-neurons) {
      circle(
        (0, ii * input-len / (n-input-neurons - 1)),
        radius: 1,
        fill: blue.transparentize(input-activations.at(1 - ii) * 100%),
        stroke: blue.darken(30%) + 2pt,
        name: "in-" + str(ii),
      )
    }
    // Hidden layer
    for ii in range(n-hidden-neurons) {
      let y-offset = (input-len - hidden-len) / 2
      circle(
        (10, ii * hidden-len / (n-hidden-neurons - 1) + y-offset),
        radius: 1,
        fill: green.transparentize(100% * (1 - float(is-alive.at(ii)) * hidden-activations.at(ii))),
        stroke: green.darken(30%) + 2pt,
        name: "hidden-" + str(ii),
      )
    }
    // Output layer
    for ii in range(n-input-neurons) {
      circle(
        (20, ii * input-len / (n-input-neurons - 1)),
        radius: 1,
        fill: blue.transparentize(input-activations.at(1 - ii) * 100%),
        stroke: blue.darken(30%) + 2pt,
        name: "out-" + str(ii),
      )
    }
  })

  // Draw connections
  on-layer(0, {
    for ii in range(n-input-neurons) {
      for jj in range(n-hidden-neurons) {
        line("in-" + str(ii), "hidden-" + str(jj), stroke: gray + 1.5pt)
      }
    }
    for ii in range(n-hidden-neurons) {
      for jj in range(n-input-neurons) {
        line("hidden-" + str(ii), "out-" + str(jj), stroke: gray + 1.5pt)
      }
    }
  })
})
