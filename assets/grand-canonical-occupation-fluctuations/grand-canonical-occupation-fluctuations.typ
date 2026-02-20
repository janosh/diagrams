#import "@preview/cetz:0.4.2": canvas, draw
#import "@preview/cetz-plot:0.1.3": plot

#set page(width: auto, height: auto, margin: 8pt)

#let size = (8, 5)

#canvas({
  draw.set-style(axes: (
    y: (label: (anchor: "north-west", offset: -0.2), mark: (end: "stealth", fill: black)),
    x: (label: (anchor: "north", offset: 0.1), mark: (end: "stealth", fill: black)),
  ))

  // First plot (Bose fluctuations)
  plot.plot(
    size: size,
    x-min: 0,
    x-max: 4.2,
    y-min: 0,
    x-label: $T$,
    y-label: $Delta n_k^+$,
    x-tick-step: 1,
    y-tick-step: 10,
    axis-style: "left",
    name: "bose-plot",
    {
      let (ek, mu) = (1, 0)
      // Add the Bose fluctuation curve
      plot.add(
        style: (stroke: blue + 1.5pt),
        domain: (0.01, 4.2), // Avoid x=0 due to division
        samples: 200, // More samples for smoother curve
        x => {
          let beta = 1 / x
          let sinh_term = calc.sinh(beta / 2 * (ek - mu))
          1 / (2 * sinh_term * sinh_term)
        },
      )
    },
  )

  // Second plot (Fermi fluctuations)
  draw.translate((size.at(0) + 2.5, 0))

  plot.plot(
    size: size,
    x-min: 0,
    x-max: 4.2,
    y-min: 0,
    y-max: 0.28,
    x-label: $T$,
    y-label: $Delta n_k^-$,
    x-tick-step: 1,
    y-tick-step: 0.05,
    axis-style: "left",
    name: "fermi-plot",
    {
      let (ek, mu) = (1, 0)
      // Add the Fermi fluctuation curve
      plot.add(
        style: (stroke: blue + 1.5pt),
        domain: (0.01, 4.2), // Avoid x=0 due to division
        samples: 200, // More samples for smoother curve
        x => {
          let beta = 1 / x
          let cosh_term = calc.cosh(beta * (ek - mu))
          1 / (2 + 2 * cosh_term)
        },
      )
    },
  )
})
