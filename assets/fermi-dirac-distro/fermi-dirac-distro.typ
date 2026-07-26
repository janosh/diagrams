#import "@preview/cetz:0.5.2": canvas, draw
#import "@preview/cetz-plot:0.1.4": plot
#import "../_shared/plot.typ": legend-box, style-axes
#import "../_shared/theme.typ": series
#import draw: content

#set page(width: auto, height: auto, margin: 8pt, fill: none)

// Fermi-Dirac distribution function
#let n-F(x, beta, mu: 1) = {
  1 / (calc.exp(beta * (x - mu)) + 1)
}

#canvas({
  style-axes(x-label: (anchor: "north-east"), y-label: (anchor: "south-west"), mark: none)

  plot.plot(
    size: (8, 7),
    x-label: [$epsilon$ / $mu$],
    y-label: $n(epsilon)$,
    x-min: 0,
    x-max: 2.3,
    y-min: 0,
    y-max: 1.2,
    x-tick-step: .5,
    y-tick-step: .5,
    y-ticks: (0.5, 1),
    axis-style: "left",
    legend: "inner-south-west",
    legend-style: legend-box,
    {
      let chem-pot = 1

      // T = μ/5k_B (red curve)
      plot.add(
        style: (stroke: series(0)),
        domain: (0, 2.3),
        samples: 150,
        x => n-F(x, 5),
        label: $k_"B" T = 1 / 5 mu$,
      )

      // T = μ/25k_B (orange curve)
      plot.add(
        style: (stroke: series(1)),
        domain: (0, 2.3),
        samples: 150,
        x => n-F(x, 25),
        label: $k_"B" T = 1 / 25 mu$,
      )

      // T = 0 (blue step function)
      let points = ((0, 1), (chem-pot, 1), (chem-pot, 0), (2.3, 0))
      plot.add(
        style: (stroke: series(2)),
        points,
        label: $T = 0$,
      )

      plot.add-vline(0.8, style: (stroke: (dash: "dashed", thickness: 0.5pt)))
      plot.add-vline(1.2, style: (stroke: (dash: "dashed", thickness: 0.5pt)))

      plot.add-hline(1.1, min: 0.8, max: 1.2, style: (
        stroke: (thickness: 0.5pt),
        mark: (symbol: "stealth", stroke: 0.5pt, fill: black, scale: .1),
      ))
    },
  )

  content(
    (3.5, 6.5),
    $prop 1 / beta$,
    anchor: "south",
  )
})
