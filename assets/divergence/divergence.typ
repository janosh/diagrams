#import "@preview/cetz:0.5.2": canvas, draw
#import "@preview/cetz-plot:0.1.4": plot

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#canvas({
  let axis-mark = (end: "stealth", fill: black, scale: 0.5)
  draw.set-style(axes: (
    x: (mark: axis-mark),
    y: (mark: axis-mark),
  ))

  plot.plot(
    size: (8, 5),
    x-label: $z$,
    x-max: 1.1,
    x-tick-step: 0.5,
    y-tick-step: 2,
    axis-style: "left",
    legend: "inner-north-west",
    // Compact legend with a thin border.
    legend-style: (item: (spacing: 0.15), padding: 0.15, stroke: 0.5pt),
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
