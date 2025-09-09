#import "@preview/cetz:0.4.2": canvas, draw
#import "@preview/cetz-plot:0.1.2": plot

#set page(width: auto, height: auto, margin: 8pt)

#let arcsinh(x) = calc.ln(x + calc.sqrt(calc.pow(x, 2) + 1))

// Magnetization function
#let magnetization(x) = {
  if x >= 0 and x < 1 {
    calc.pow(1 - calc.pow(calc.sinh(arcsinh(1) / x), -4), 1 / 8)
  } else {
    0
  }
}

#canvas({
  draw.set-style(axes: (
    y: (mark: (end: "stealth", fill: black), label: (anchor: "north-west", offset: -0.2)),
    x: (mark: (end: "stealth", fill: black), label: (anchor: "south-east", offset: -0.2)),
  ))

  plot.plot(
    size: (8, 5),
    x-label: $T / T_c$,
    y-label: $m(0,T)$,
    y-max: 1.5,
    x-tick-step: 0.5,
    y-tick-step: 0.5,
    axis-style: "left",
    x-grid: true,
    y-grid: true,
    {
      // Main magnetization curve
      plot.add(
        style: (stroke: blue + 1.5pt),
        domain: (0.01, 2), // Avoid x=0 due to division
        samples: 300,
        magnetization,
      )

      // Dashed line y=x from 0 to 1
      plot.add(style: (stroke: (dash: "dashed", thickness: 1pt)), domain: (0, 1), x => x)
    },
  )
})
