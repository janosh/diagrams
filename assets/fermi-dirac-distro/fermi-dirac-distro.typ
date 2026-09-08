#import "@preview/cetz:0.5.2": canvas, draw
#import "@preview/cetz-plot:0.1.4": plot
#import draw: content

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#let n-F(x, beta, mu: 1) = 1 / (calc.exp(beta * (x - mu)) + 1)

#canvas({
  let axis-mark = (end: "stealth", fill: black)
  draw.set-style(axes: (
    x: (mark: axis-mark, label: (anchor: "north-east")),
    y: (mark: axis-mark, label: (anchor: "south-west")),
  ))

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
    // Compact legend with a thin border.
    legend-style: (item: (spacing: 0.15), padding: 0.15, stroke: 0.5pt),
    {
      let chem-pot = 1

      for (beta, color) in ((5, rgb("#0B5FA5")), (25, rgb("#C2570A"))) {
        plot.add(
          style: (stroke: color + 1.5pt),
          domain: (0, 2.3),
          samples: 150,
          x => n-F(x, beta),
          label: $k_"B" T = 1 / #beta mu$,
        )
      }

      // T = 0 (blue step function)
      let points = ((0, 1), (chem-pot, 1), (chem-pot, 0), (2.3, 0))
      plot.add(
        style: (stroke: rgb("#12793F") + 1.5pt),
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

  content((3.5, 6.5), $prop 1 / beta$, anchor: "south")
})
