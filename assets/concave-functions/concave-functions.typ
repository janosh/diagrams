#import "@preview/cetz:0.3.1": canvas
#import "@preview/cetz-plot:0.1.0": plot

#set page(width: auto, height: auto, margin: 8pt)

#let size = (8, 5)

#canvas({
  plot.plot(
    size: size,
    x-min: 0,
    x-max: 1,
    x-label: $x$,
    y-tick-step: 0.2,
    x-tick-step: 0.2,
    x-grid: true,
    y-grid: true,
    legend: "inner-north-west",
    {
      plot.add-hline(0, style: (stroke: 0.5pt))
      plot.add-vline(0, style: (stroke: 0.5pt))

      // x function
      plot.add(
        style: (stroke: blue + 1.5pt),
        domain: (0, 1),
        label: $x$,
        x => x,
      )

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
