#import "@preview/cetz:0.5.2": canvas
#import "@preview/cetz-plot:0.1.4": plot
#import "../_shared/plot.typ": legend-box, style-axes
#import "../_shared/theme.typ": series

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#let tc = 1

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
  style-axes(x-label: (anchor: "north", offset: 0.2))

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
    legend: "inner-north-east",
    legend-style: legend-box,
    {
      // First function (blue)
      plot.add(
        style: (stroke: series(0)),
        samples: 100,
        domain: (0.01, 1),
        f1,
        label: $sqrt(3)(T_c \/ T - 1)^(1 / 2)$,
      )

      // Second function (red)
      plot.add(
        style: (stroke: series(1)),
        samples: 50,
        domain: (0, 1.1),
        f2,
        label: $sqrt(3)(T \/ T_c)^(3 / 2)$,
      )

      // Third function (orange)
      plot.add(
        style: (stroke: series(2)),
        samples: 125,
        domain: (0.01, 1),
        f3,
        label: $m_c(T)$,
      )
    },
  )
})
