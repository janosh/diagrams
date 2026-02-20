#import "@preview/cetz:0.4.2": canvas, draw
#import "@preview/cetz-plot:0.1.3": plot

#set page(width: auto, height: auto, margin: 8pt)

#let size = (8, 5)

#canvas({
  draw.set-style(axes: (
    y: (label: (anchor: "north-west", offset: -0.2), mark: (end: "stealth", fill: black)),
    x: (label: (anchor: "north", offset: 0.1), mark: (end: "stealth", fill: black)),
  ))

  plot.plot(
    size: size,
    x-min: 0,
    x-max: 11,
    y-min: 0,
    y-max: 2.3,
    x-label: $beta$,
    y-label: $chevron.l E chevron.r \/ planck omega$,
    x-tick-step: 2,
    y-tick-step: 0.5,
    axis-style: "left",
    {
      let (hbar, omega) = (1, 1)

      // Add the energy expectation value curve
      plot.add(
        style: (stroke: blue + 1.5pt),
        domain: (1e-5, 11),
        samples: 200, // More samples for smoother curve
        beta => {
          let exp_term = calc.exp(beta * hbar * omega)
          (1 / 2) * hbar * omega * (1 + 4 / (exp_term - 1))
        },
      )
    },
  )
})
