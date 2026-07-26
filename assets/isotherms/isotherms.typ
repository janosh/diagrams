#import "@preview/cetz:0.5.2": canvas
#import "@preview/cetz-plot:0.1.4": plot
#import "../_shared/plot.typ": legend-box, style-axes
#import "../_shared/theme.typ": series

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#let gas-constant = 8.31 // Gas constant
#let temperature = 300 // Temperature
#let B1 = 1000 // First virial coefficient
#let B2 = -1000 // Second virial coefficient

// Pressure functions
#let p0(v) = gas-constant * temperature / v
#let p1(v) = p0(v) + B1 / calc.pow(v, 2)
#let p2(v) = p1(v) + B2 / calc.pow(v, 3)

#canvas({
  style-axes(x-label: (anchor: "south-east", offset: -0.25), mark: none)

  plot.plot(
    size: (8, 7),
    x-label: [$v$ (m³/mol)],
    y-label: [$p$ (Pa)],
    x-min: 0.5,
    x-max: 5.5,
    x-tick-step: 1,
    y-tick-step: 1000,
    axis-style: "left",
    legend: "inner-north-east",
    legend-style: legend-box,
    {
      // Plot p0 (ideal gas)
      plot.add(
        style: (stroke: series(0)),
        domain: (0.5, 5.5),
        samples: 100,
        p0,
        label: $p_0 = (R T) / v$,
      )

      // Plot p1 (first virial correction)
      plot.add(
        style: (stroke: series(1)),
        domain: (0.5, 5.5),
        samples: 100,
        p1,
        label: $p_1 = p_0 + B_1 / v^2$,
      )

      // Plot p2 (second virial correction)
      plot.add(
        style: (stroke: series(2)),
        domain: (0.5, 5.5),
        samples: 100,
        p2,
        label: $p_2 = p_1 + B_2 / v^3$,
      )
    },
  )
})
