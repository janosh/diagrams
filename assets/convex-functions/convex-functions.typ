#import "@preview/cetz:0.5.2": canvas
#import "@preview/cetz-plot:0.1.4": plot
#import "../_shared/plot.typ": style-axes

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#canvas({
  style-axes(x-label: (anchor: "north", offset: 0.1))
  plot.plot(
    size: (8, 5),
    x-label: $x$,
    y-tick-step: 1,
    x-tick-step: 1,
    x-grid: true,
    y-grid: true,
    legend: "inner-north-west",
    legend-style: (stroke: .5pt),
    axis-style: "left",
    {
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
