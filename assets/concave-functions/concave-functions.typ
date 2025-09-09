#import "@preview/cetz:0.4.2": canvas, draw
#import "@preview/cetz-plot:0.1.2": plot

#set page(width: auto, height: auto, margin: 8pt)

#canvas({
  draw.set-style(axes: (
    y: (label: (anchor: "north-west", offset: -0.2), mark: (end: "stealth", fill: black)),
    x: (mark: (end: "stealth", fill: black)),
  ))
  plot.plot(
    size: (8, 5),
    x-min: 0,
    x-max: 1,
    x-label: $x$,
    y-tick-step: 0.2,
    x-tick-step: 0.2,
    x-grid: true,
    y-grid: true,
    legend: "inner-north-west",
    legend-style: (stroke: .5pt),
    axis-style: "left",
    {
      // x function
      plot.add(style: (stroke: blue + 1.5pt), domain: (0, 1), label: $x$, x => x)

      // -x ln(x) function
      plot.add(
        style: (stroke: red + 1.5pt),
        domain: (0.01, 1), // avoid x=0 since ln(0) is undefined
        samples: 100,
        label: $-x ln(x)$,
        x => -x * calc.ln(x),
      )
    },
  )
})
