#import "@preview/cetz:0.4.2": canvas, draw
#import draw: bezier, content, line

#set page(width: auto, height: auto, margin: 8pt)

// Functions for the branch cuts - adjusted to better match the original
// Increased vertical scaling to spread the curves further apart
#let f1(x) = 5 / (calc.sqrt(x) + 2)
#let f2(x) = 5 * (1 / (x + 2) + 1 / 3)
#let f3(x) = -5 / (calc.sqrt(x) + 2)
#let f4(x) = -5 * (1 / (x + 2) + 1 / 3)

#canvas({
  // Set up the coordinate system
  let (width, height) = (10, 8)

  // Draw axes
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

  // Draw the curves
  // Helper function to draw a parametric curve
  let draw-curve(f, domain: (1, 9), samples: 100, stroke: black) = {
    let points = ()
    let step = (domain.at(1) - domain.at(0)) / samples

    for i in range(samples + 1) {
      let x = domain.at(0) + i * step
      let y = f(x)
      points.push((x, y))
    }

    for i in range(samples) {
      line(
        points.at(i),
        points.at(i + 1),
        stroke: stroke,
      )
    }
  }

  // Draw the red curves
  draw-curve(f1, stroke: red + 2pt)
  draw-curve(f2, stroke: red + 2pt)

  // Draw the blue curves
  draw-curve(f3, stroke: blue + 2pt)
  draw-curve(f4, stroke: blue + 2pt)

  // Calculate points on the curves for arrow start positions
  let top_red_x = 4
  let top_red_y = f2(top_red_x) // Use the second red curve (higher one)

  let bottom_blue_x = 4
  let bottom_blue_y = f4(bottom_blue_x) // Use the fourth curve (lower blue one)

  // Add the dashed arrows pointing to the origin
  // First arrow (from top red curve to origin) - flipped curve direction
  bezier(
    (top_red_x, top_red_y), // start point - on the red curve
    (3.5, 0), // end point - at the origin
    (3.6, top_red_y * 0.7), // control point - flipped direction
    stroke: (dash: "dashed", thickness: 1pt),
    mark: (end: "stealth", fill: black, scale: 0.8),
    name: "arrow1",
  )
  content((rel: (0.15, 0), to: "arrow1.80%"), $k arrow.r 0$, anchor: "west")

  // Second arrow (from bottom blue curve to origin) - flipped curve direction
  bezier(
    (bottom_blue_x, bottom_blue_y), // start point - on the lower blue curve
    (3.5, 0), // end point - at the origin
    (3.6, bottom_blue_y * 0.7), // control point - flipped direction
    stroke: (dash: "dashed", thickness: 1pt),
    mark: (end: "stealth", fill: black, scale: 0.8),
    name: "arrow2",
  )
  content((rel: (-0.15, 0), to: "arrow2.80%"), $k arrow.r 0$, anchor: "east")
})
