#import "@preview/cetz:0.3.3": canvas, draw
#import "@preview/cetz-plot:0.1.1": plot

#set page(width: auto, height: auto, margin: 8pt)

#let tc = 1

// Define the three functions
#let f1(x) = {
  if x == tc { return 0 }
  calc.sqrt(3) * calc.pow(tc / x - 1, 1 / 2)
}

#let f2(x) = calc.sqrt(3) * calc.pow(x / tc, 3 / 2)

#let f3(x) = {
  if x == tc { return 0 }
  calc.sqrt(3) * calc.pow(x / tc, 3 / 2) * calc.pow(tc / x - 1, 1 / 2)
}

#canvas({
  draw.set-style(
    axes: (
      y: (label: (anchor: "north-west", offset: -0.2), mark: (end: "stealth", fill: black)),
      x: (label: (anchor: "north", offset: 0.2), mark: (end: "stealth", fill: black)),
    ),
  )

  plot.plot(
    size: (10, 8),
    x-label: $T$,
    x-min: 0,
    x-max: 1.1,
    y-min: 0,
    y-max: 2.8,
    axis-style: "left",
    x-tick-step: 0.2,
    y-tick-step: 0.5,
    legend: (6.5, 8.5),
    legend-style: (item: (spacing: 0.15), padding: 0.25, stroke: .5pt),
    {
      // First function (blue)
      plot.add(
        style: (stroke: blue + 1.5pt),
        samples: 100,
        domain: (0.01, 1),
        f1,
        label: $sqrt(3)(T_c \/ T - 1)^(1 / 2)$,
      )

      // Second function (red)
      plot.add(
        style: (stroke: red + 1.5pt),
        samples: 50,
        domain: (0, 1.1),
        f2,
        label: $sqrt(3)(T \/ T_c)^(3 / 2)$,
      )

      // Third function (orange)
      plot.add(
        style: (stroke: orange + 1.5pt),
        samples: 125,
        domain: (0.01, 1),
        f3,
        label: $m_c(T)$,
      )
    },
  )
})
