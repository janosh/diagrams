#import "@preview/cetz:0.2.2": canvas, plot, draw

#set page(width: auto, height: auto, margin: 3pt)

#let relu(x) = if x < 0 { 0 } else { x }
#let gelu(x) = 0.5 * x * (1 + calc.tanh(calc.sqrt(2 / calc.pi) * (x + 0.044715 * calc.pow(x,3))))
#let leaky_relu(x) = if x < 0 { 0.01 * x } else { x }
#let sigmoid(x) = 1 / (1 + calc.exp(-x))
#let tanh(x) = (calc.exp(x) - calc.exp(-x)) / (calc.exp(x) + calc.exp(-x))
#let size = (8, 5)

#canvas({
  plot.plot(
    size: size,
    y-tick-step: 2,
    x-tick-step: 2,
    legend: "legend.inner-north-west",
    legend-style: (item: (spacing: 0.18)),
    {
      plot.add-hline(0, style: (stroke: 0.5pt))
      plot.add-vline(0, style: (stroke: 0.5pt))
      for (key, (func, color)) in (
        "ReLU": (relu, red),
        "GELU": (gelu, blue),
        "Leaky ReLU": (leaky_relu, green),
        "Sigmoid": (sigmoid, orange),
        "Tanh": (tanh, purple)
      ).pairs() {
        plot.add(style: (stroke: color + 1.5pt), domain: (-4, 4), func, label: key)
      }
    }
  )
  draw.grid((0,0), size, stroke: 0.1pt)
})
