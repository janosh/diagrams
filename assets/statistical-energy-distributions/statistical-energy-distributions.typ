#import "@preview/cetz:0.5.2": canvas, draw
#import "@preview/cetz-plot:0.1.4": plot

#set page(width: auto, height: auto, margin: 8pt, fill: none)

// Distribution functions
#let bose-einstein(x) = 1 / (calc.exp(x) - 1)
#let boltzmann(x) = 1 / calc.exp(x)
#let fermi-dirac(x) = 1 / (calc.exp(x) + 1)

#canvas({
  let axis-mark = (end: "stealth", fill: black)
  draw.set-style(axes: (
    x: (mark: axis-mark, label: (anchor: "south-east", offset: -0.2)),
    y: (mark: axis-mark, label: (anchor: "north-west", offset: -0.2)),
  ))

  plot.plot(
    size: (8, 5),
    x-label: $beta (epsilon - mu)$,
    y-label: $chevron.l n chevron.r$,
    x-min: -7,
    x-max: 7,
    y-min: 0,
    y-max: 1.8,
    x-tick-step: 2,
    y-tick-step: 0.5,
    axis-style: "school-book",
    x-grid: true,
    y-grid: true,
    legend: "inner-north-east",
    // Compact legend with a thin border.
    legend-style: (item: (spacing: 0.15), padding: 0.15, stroke: 0.5pt),
    {
      // Bose-Einstein distribution
      plot.add(
        style: (stroke: rgb("#0B5FA5") + 1.5pt),
        domain: (0.1, 7), // Avoid x=0 since BE diverges there
        samples: 200,
        label: "Bose-Einstein",
        bose-einstein,
      )

      // Boltzmann distribution
      plot.add(
        style: (stroke: rgb("#C2570A") + 1.5pt),
        domain: (-1, 7),
        samples: 100,
        label: "Boltzmann",
        boltzmann,
      )

      // Fermi-Dirac distribution
      plot.add(
        style: (stroke: rgb("#12793F") + 1.5pt),
        domain: (-7, 7),
        samples: 100,
        label: "Fermi-Dirac",
        fermi-dirac,
      )
    },
  )
})
