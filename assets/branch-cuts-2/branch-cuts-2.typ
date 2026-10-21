#import "@preview/cetz:0.5.3": canvas, draw
#import draw: bezier, content, line

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 12pt)

// Inner and outer branch cuts in the upper half-plane, mirrored below the real axis
#let inner-cut(x) = 5 / (calc.sqrt(x) + 2)
#let outer-cut(x) = 5 * (1 / (x + 2) + 1 / 3)

#canvas({
  let axis-style = (mark: (end: "stealth", fill: black), stroke: 1.2pt)
  line((0, 0), (10, 0), ..axis-style, name: "x-axis")
  content((rel: (0, -0.2), to: "x-axis.end"), $"Re"(q_0)$, anchor: "north-east")
  line((0, -4), (0, 4), ..axis-style, name: "y-axis")
  content((rel: (0.2, 0), to: "y-axis.end"), $"Im"(q_0)$, anchor: "north-west")

  for (sign, color) in ((1, red), (-1, blue)) {
    for cut in (inner-cut, outer-cut) {
      let points = range(101).map(idx => (1 + idx * 0.08, sign * cut(1 + idx * 0.08)))
      line(..points, stroke: color + 2pt)
    }
  }

  // Dashed arrows start on the outer curves and approach the real axis.
  for (sign, anchor) in ((1, "west"), (-1, "east")) {
    let height = sign * outer-cut(4)
    bezier(
      (4, height),
      (3.5, 0),
      (3.6, height * 0.7),
      stroke: (dash: "dashed", thickness: 1pt),
      mark: (end: "stealth", fill: black, scale: 0.8),
      name: "k-arrow",
    )
    content((rel: (sign * 0.15, 0), to: "k-arrow.80%"), $k arrow.r 0$, anchor: anchor)
  }
})
