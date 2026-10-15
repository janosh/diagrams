#import "@preview/cetz:0.5.2": canvas, draw
#import "@preview/cetz-plot:0.1.4": plot

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 12pt)

// Onsager's 2D Ising magnetization m = (1 - sinh(2J / k_B T)^-4)^(1/8) with x = T / T_c,
// using sinh(2J / k_B T_c) = 1, i.e. 2J / k_B T_c = arcsinh(1) = ln(1 + sqrt(2))
#let magnetization(x) = if x < 1 {
  calc.pow(1 - calc.pow(calc.sinh(calc.ln(1 + calc.sqrt(2)) / x), -4), 1 / 8)
} else { 0 }

#canvas({
  let axis-mark = (end: "stealth", fill: black)
  draw.set-style(axes: (
    x: (mark: axis-mark, label: (anchor: "south-east", offset: -0.2)),
    y: (mark: axis-mark, label: (anchor: "north-west", offset: -0.2)),
  ))

  plot.plot(
    size: (8, 5),
    x-label: $T \/ T_c$,
    y-label: $m(0,T)$,
    y-max: 1.5,
    x-tick-step: 0.5,
    y-tick-step: 0.5,
    axis-style: "left",
    x-grid: true,
    y-grid: true,
    {
      plot.add(style: (stroke: blue + 1.5pt), domain: (0.01, 2), samples: 300, magnetization)
    },
  )
})
