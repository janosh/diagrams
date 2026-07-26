#import "@preview/cetz:0.5.2": canvas
#import "@preview/cetz-plot:0.1.4": plot
#import "../_shared/plot.typ": style-axes

#set page(width: auto, height: auto, margin: 5pt, fill: none)

#canvas({
  style-axes()

  plot.plot(
    size: (8, 5),
    x-label: $x$,
    y-label: $tanh(x)$,
    y-max: 1.25,
    y-min: -1.25,
    x-max: 2,
    x-min: -2,
    x-tick-step: 1,
    y-tick-step: 0.5,
    axis-style: "school-book",
    {
      // Main tanh curve
      plot.add(
        style: (stroke: blue + 1.5pt),
        domain: (-2, 2),
        samples: 100,
        x => calc.tanh(x),
      )

      // Dashed line y=x from -1 to 1
      plot.add(
        style: (stroke: (dash: "dashed", paint: blue, thickness: 0.5pt)),
        samples: 2,
        domain: (-1.4, 1.4),
        x => { x },
      )
    },
  )
})
