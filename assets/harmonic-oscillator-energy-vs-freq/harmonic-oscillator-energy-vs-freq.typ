#import "@preview/cetz:0.4.2": canvas, draw
#import "@preview/cetz-plot:0.1.3": plot

#set page(width: auto, height: auto, margin: 8pt)

#canvas({
  draw.set-style(axes: (
    y: (label: (anchor: "north-west", offset: -0.2), mark: (end: "stealth", fill: black)),
    x: (label: (anchor: "north", offset: 0.1), mark: (end: "stealth", fill: black)),
  ))

  plot.plot(
    size: (8, 5),
    x-min: 0,
    x-max: 11,
    y-min: 0,
    x-label: $omega = sqrt(k/m)$,
    y-label: $chevron.l E chevron.r \/ k_"B" T$,
    x-tick-step: 2,
    y-tick-step: 2,
    axis-style: "left",
    {
      let (hbar, beta) = (1, 1)

      // Add the energy expectation value curve
      plot.add(
        style: (stroke: blue + 1.5pt),
        domain: (0.01, 11), // Avoid x=0 due to division
        samples: 200, // More samples for smoother curve
        omega => {
          // E = (1/2)hω(1 + 4/(exp(βhω) - 1))
          let exp_term = calc.exp(beta * hbar * omega)
          (1 / 2) * hbar * omega * (1 + 4 / (exp_term - 1))
        },
      )
    },
  )
})
