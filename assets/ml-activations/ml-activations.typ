#import "@preview/cetz:0.4.0": canvas, draw
#import "@preview/cetz-plot:0.1.2": plot

#let vector(v) = $bold(#v)$
#set page(width: auto, height: auto, margin: 8pt)

#let relu(x) = if x < 0 { 0 } else { x }
#let gelu(x) = 0.5 * x * (1 + calc.tanh(calc.sqrt(2 / calc.pi) * (x + 0.044715 * calc.pow(x, 3))))
#let leaky_relu(x) = if x < 0 { 0.01 * x } else { x }
#let sigmoid(x) = 1 / (1 + calc.exp(-x))
#let tanh(x) = (calc.exp(x) - calc.exp(-x)) / (calc.exp(x) + calc.exp(-x))

#canvas({
  let arrow-style = (end: "stealth", fill: black)
  draw.set-style(
    axes: (
      y: (label: (anchor: "north-west", offset: -0.2), mark: arrow-style),
      x: (mark: arrow-style),
    ),
  )
  plot.plot(
    size: (8, 5),
    y-tick-step: 1,
    x-tick-step: 2,
    legend: "inner-north-west",
    legend-style: (item: (spacing: 0.1), padding: 0.1, stroke: .5pt),
    axis-style: "left",
    x-grid: true,
    y-grid: true,
    {
      for (key, (func, color)) in (
        "ReLU": (relu, red),
        "GELU": (gelu, blue),
        "Leaky ReLU": (leaky_relu, green),
        "Sigmoid": (sigmoid, orange),
        "Tanh": (tanh, purple),
      ).pairs() {
        plot.add(style: (stroke: color + 1.5pt), domain: (-4, 4), func, label: key)
      }
    },
  )
})

// #box(width: 30em)[
//   Popular ML activation functions.
//   $"ReLU"(vector(x)) = vector(x)^+ = max(vector(x), 0)$ is the most widely used activation function in deep learning due to its simplicity and computational efficiency.
//   $"GELU"(vector(x), mu=0, sigma=1) = vector(x) / 2 (1 + op("erf") (vector(x) \/ sqrt(2)))$ is a differentiable variant of ReLU.
//   $"Leaky ReLU"(vector(x)) = max(0, vector(x)) + alpha dot min(0, vector(x))$ with $alpha < 0$ is a variant of ReLU that adds a small gradient for negative activations.
//   $"Sigmoid"(vector(x)) = (1 + exp(-vector(x)))^(-1)$ smoothly squashes the input to the range (0, 1).
//   $"Tanh"(vector(x)) = (exp(vector(x))+exp(vector(−x))) / (vector(exp(x))−exp(vector(−x)))$ is a scaled and shifted version of the sigmoid function.
// ]
