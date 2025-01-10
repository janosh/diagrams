#import "@preview/cetz:0.3.1": canvas
#import "@preview/cetz-plot:0.1.0": plot

#set page(width: auto, height: auto, margin: 8pt)

#let size = (8, 5)

#canvas({
  plot.plot(
    size: size,
    x-min: 0,
    x-max: 2.7,
    x-label: $x$,
    y-tick-step: 1,
    x-tick-step: 0.5,
    x-grid: true,
    y-grid: true,
    legend: "inner-north-west",
    {
      plot.add-hline(0, style: (stroke: 0.5pt))
      plot.add-vline(0, style: (stroke: 0.5pt))

      // x ln(x) function
      plot.add(
        style: (stroke: blue + 1.5pt),
        domain: (0.01, 2.7), // avoid x=0 since ln(0) is undefined
        samples: 100,
        label: $x ln(x)$,
        x => x * calc.ln(x),
      )

      // x-1 function
      plot.add(
        style: (stroke: red + 1.5pt),
        domain: (0, 2.7),
        label: $x-1$,
        x => x - 1,
      )
    },
  )
})
