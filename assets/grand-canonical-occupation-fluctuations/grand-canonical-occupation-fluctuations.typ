#import "@preview/cetz:0.5.2": canvas, draw
#import "@preview/cetz-plot:0.1.4": plot
#import "../_shared/plot.typ": style-axes

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#let size = (8, 5)

#canvas({
  style-axes(x-label: (anchor: "north", offset: 0.1))

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
      plot.add(
        style: (stroke: blue + 1.5pt),
        domain: (0.01, 4.2), // Avoid x=0 due to division
        samples: 200, // More samples for smoother curve
        x => {
          let beta = 1 / x
          let sinh-term = calc.sinh(beta / 2 * (ek - mu))
          1 / (2 * sinh-term * sinh-term)
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
      plot.add(
        style: (stroke: blue + 1.5pt),
        domain: (0.01, 4.2), // Avoid x=0 due to division
        samples: 200, // More samples for smoother curve
        x => {
          let beta = 1 / x
          let cosh-term = calc.cosh(beta * (ek - mu))
          1 / (2 + 2 * cosh-term)
        },
      )
    },
  )
})
