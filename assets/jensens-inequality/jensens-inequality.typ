#import "@preview/cetz:0.4.2": canvas, draw
#import "@preview/cetz-plot:0.1.2": plot

#set page(width: auto, height: auto, margin: 8pt)

#canvas({
  let mark = (end: "stealth", fill: black, scale: 0.7)
  draw.set-style(axes: (
    y: (label: (anchor: "north-west", offset: -0.2), mark: mark),
    x: (label: (anchor: "south-east", offset: -0.25), mark: mark),
  ))

  plot.plot(
    size: (8, 6),
    x-label: $x$,
    y-label: $log x$,
    y-min: -1,
    x-tick-step: none,
    y-tick-step: none,
    axis-style: "school-book",
    {
      // Main logarithmic curve
      plot.add(style: (stroke: rgb(0%, 0%, 80%) + 1.5pt), domain: (11, 150), samples: 150, x => calc.ln(x - 10) - 2)

      // Dashed line
      plot.add(
        style: (
          stroke: (paint: orange, thickness: 1.5pt, dash: "dashed"),
        ),
        domain: (8, 120),
        x => 0.2 + (3 - 0.2) * (x - 8) / (120 - 8),
      )
    },
  )
})
