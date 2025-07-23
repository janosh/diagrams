#import "@preview/cetz:0.4.1": canvas, draw
#import "@preview/cetz-plot:0.1.2": plot
#import draw: bezier, content, line

#set page(width: auto, height: auto, margin: 8pt)

// Bose-Einstein distribution function
#let n_B(x, T) = {
  if x == 0 or T == 0 { return 0.5 }
  let ratio = x / T
  1 / (calc.exp(ratio) - 1) + 0.5
}

#canvas({
  let mark = (end: "stealth", fill: black, scale: 0.7)
  draw.set-style(axes: (
    y: (label: (anchor: "north-west", offset: -0.2), mark: mark),
    x: (label: (anchor: "south-east", offset: -0.15), mark: mark),
  ))

  plot.plot(
    size: (8, 7),
    x-label: $"Re"(p_0)$,
    y-label: $n_"B" (p_0)$,
    x-min: 0,
    y-min: 0,
    y-max: 5,
    x-tick-step: none,
    y-tick-step: none,
    axis-style: "left",
    {
      // Plot distributions for different temperatures
      for (T, color) in ((0.5, red), (1, orange), (2, blue)) {
        plot.add(style: (stroke: color + 1.5pt), domain: (0.01, 2), samples: 150, x => n_B(x, T))
      }
    },
  )

  // Add curved arrows between intersection points
  // We approximate the intersection points since CeTZ doesn't have direct intersection support
  let arrow-style = (end: "stealth", stroke: 1pt, fill: black)

  // First arrow (T=0.5 to T=1)
  bezier(
    (1.8, 1.7), // start point
    (2.4, 2.4), // end point
    (2, 2.3), // control point
    mark: arrow-style,
    name: "arrow1",
  )
  content("arrow1.mid", text(size: 8pt)[$2 dot T$], anchor: "south-east")

  // Second arrow (T=1 to T=2)
  bezier(
    (2.4, 2.5), // start point
    (3.5, 3.2), // end point
    (2.9, 3.3), // control point
    mark: arrow-style,
    name: "arrow2",
  )
  content("arrow2.mid", text(size: 8pt)[$2 dot T$], anchor: "south-east")
})
