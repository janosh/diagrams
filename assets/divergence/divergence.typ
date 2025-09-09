#import "@preview/cetz:0.4.2": canvas, draw
#import "@preview/cetz-plot:0.1.2": plot

#set page(width: auto, height: auto, margin: 8pt)

#canvas({
  draw.set-style(axes: (
    y: (mark: (end: "stealth", fill: black, scale: 0.5)),
    x: (mark: (end: "stealth", fill: black, scale: 0.5)),
  ))

  plot.plot(
    size: (8, 5),
    x-label: $z$,
    x-max: 1.1,
    x-tick-step: 0.5,
    y-tick-step: 2,
    axis-style: "left",
    legend: "inner-north-west",
    legend-style: (item: (spacing: 0.2), padding: 0.15, stroke: .5pt),
    {
      plot.add(
        style: (stroke: blue + 1.5pt),
        domain: (0, 0.999), // avoid x=1 since ln(0) is undefined
        samples: 150,
        label: $-ln(1-z)$,
        x => -calc.ln(1 - x),
      )
    },
  )
})
