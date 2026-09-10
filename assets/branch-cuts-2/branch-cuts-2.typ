#import "@preview/cetz:0.5.2": canvas, draw
#import draw: bezier, content, line

#set page(width: auto, height: auto, margin: 8pt, fill: none)

// Functions for the branch cuts - adjusted to better match the original
// Increased vertical scaling to spread the curves further apart
#let f1(x) = 5 / (calc.sqrt(x) + 2)
#let f2(x) = 5 * (1 / (x + 2) + 1 / 3)
#let f3(x) = -5 / (calc.sqrt(x) + 2)
#let f4(x) = -5 * (1 / (x + 2) + 1 / 3)

#canvas({
  // Set up the coordinate system
  let (width, height) = (10, 8)

  line(
    (0, 0),
    (width, 0),
    mark: (end: "stealth", fill: black),
    stroke: 1.2pt,
    name: "x-axis",
  )
  content((rel: (0, -0.2), to: "x-axis.end"), $"Re"(q_0)$, anchor: "north-east")

  line(
    (0, -height / 2),
    (0, height / 2),
    mark: (end: "stealth", fill: black),
    stroke: 1.2pt,
    name: "y-axis",
  )
  content((rel: (0.2, 0), to: "y-axis.end"), $"Im"(q_0)$, anchor: "north-west")

  let draw-curve(func, domain: (1, 9), samples: 100, stroke: black) = {
    let step = (domain.at(1) - domain.at(0)) / samples
    let points = range(samples + 1).map(idx => {
      let coord = domain.at(0) + idx * step
      (coord, func(coord))
    })
    for (start, end) in points.windows(2) {
      line(start, end, stroke: stroke)
    }
  }

  draw-curve(f1, stroke: red + 2pt)
  draw-curve(f2, stroke: red + 2pt)

  draw-curve(f3, stroke: blue + 2pt)
  draw-curve(f4, stroke: blue + 2pt)

  // Dashed arrows start on the outer curves and approach the real axis.
  for (func, name, offset, anchor) in (
    (f2, "arrow1", 0.15, "west"),
    (f4, "arrow2", -0.15, "east"),
  ) {
    let height = func(4)
    bezier(
      (4, height),
      (3.5, 0),
      (3.6, height * 0.7),
      stroke: (dash: "dashed", thickness: 1pt),
      mark: (end: "stealth", fill: black, scale: 0.8),
      name: name,
    )
    content((rel: (offset, 0), to: name + ".80%"), $k arrow.r 0$, anchor: anchor)
  }
})
