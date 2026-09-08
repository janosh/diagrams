#import "@preview/cetz:0.5.2": canvas, draw
#import "@preview/cetz-plot:0.1.4": plot

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#canvas({
  let axis-mark = (end: "stealth", fill: black)
  draw.set-style(axes: (
    x: (mark: axis-mark, label: (anchor: "north", offset: 0.1)),
    y: (mark: axis-mark, label: (anchor: "north-west", offset: -0.2)),
  ))
  plot.plot(
    size: (8, 5),
    x-label: $x$,
    y-tick-step: 1,
    x-tick-step: 1,
    x-grid: true,
    y-grid: true,
    legend: "inner-north-west",
    // Compact legend with a thin border.
    legend-style: (item: (spacing: 0.15), padding: 0.15, stroke: 0.5pt),
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
