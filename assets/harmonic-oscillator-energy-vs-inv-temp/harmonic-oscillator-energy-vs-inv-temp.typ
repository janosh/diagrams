#import "@preview/cetz:0.5.2": canvas
#import "@preview/cetz-plot:0.1.4": plot
#import "../_shared/plot.typ": style-axes

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#let size = (8, 5)

#canvas({
  style-axes(x-label: (anchor: "north", offset: 0.1))

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

      plot.add(
        style: (stroke: blue + 1.5pt),
        domain: (1e-5, 11),
        samples: 200, // More samples for smoother curve
        beta => {
          let exp-term = calc.exp(beta * hbar * omega)
          (1 / 2) * hbar * omega * (1 + 4 / (exp-term - 1))
        },
      )
    },
  )
})
