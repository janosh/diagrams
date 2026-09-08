#import "@preview/cetz:0.5.2": canvas, draw
#import "@preview/cetz-plot:0.1.4": plot

#let vector(v) = $bold(#v)$
#set page(width: auto, height: auto, margin: 8pt, fill: none)

#let relu(x) = if x < 0 { 0 } else { x }
#let gelu(x) = (
  0.5 * x * (1 + calc.tanh(calc.sqrt(2 / calc.pi) * (x + 0.044715 * calc.pow(x, 3))))
)
#let leaky-relu(x) = if x < 0 { 0.01 * x } else { x }
#let sigmoid(x) = 1 / (1 + calc.exp(-x))
#let tanh(x) = (calc.exp(x) - calc.exp(-x)) / (calc.exp(x) + calc.exp(-x))

#canvas({
  let axis-mark = (end: "stealth", fill: black)
  draw.set-style(axes: (
    x: (mark: axis-mark),
    y: (mark: axis-mark, label: (anchor: "north-west", offset: -0.2)),
  ))
  plot.plot(
    size: (8, 5),
    y-tick-step: 1,
    x-tick-step: 2,
    legend: "inner-north-west",
    // Compact legend with a thin border.
    legend-style: (item: (spacing: 0.15), padding: 0.15, stroke: 0.5pt),
    axis-style: "left",
    x-grid: true,
    y-grid: true,
    {
      let curves = (
        ("ReLU", relu, rgb("#0B5FA5") + 1.5pt),
        ("GELU", gelu, rgb("#C2570A") + 1.5pt),
        ("Leaky ReLU", leaky-relu, rgb("#12793F") + 1.5pt),
        ("Sigmoid", sigmoid, rgb("#A81E7A") + 1.5pt),
        // Dashes distinguish the less separable purple curve.
        ("Tanh", tanh, (paint: rgb("#7A3E9D"), thickness: 1.5pt, dash: "dashed")),
      )
      for (key, func, stroke) in curves {
        plot.add(style: (stroke: stroke), domain: (-4, 4), func, label: key)
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
