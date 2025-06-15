#import "@preview/cetz:0.4.0": canvas, draw
#import draw: line, content, rect, hobby, circle

#set page(width: auto, height: auto, margin: 8pt)

#canvas({
  // Draw background rectangles
  rect(
    (0, 0),
    (4.5, 4),
    fill: rgb(200, 220, 255), // blue!20
    stroke: none,
  )
  rect(
    (4.5, 0),
    (8, 4),
    fill: rgb(255, 230, 200), // orange!20
    stroke: none,
  )

  // Draw axes
  let arrow-style = (mark: (end: "stealth", fill: black, scale: 0.7))
  let axis-overshoot = -0.75
  line((axis-overshoot, 0), (8, 0), ..arrow-style, name: "x-axis") // x-axis
  line((0, axis-overshoot), (0, 5), ..arrow-style, name: "y-axis") // y-axis

  // Add axis labels
  content((rel: (-axis-overshoot, -0.2), to: "x-axis.6%"), "weak", anchor: "north")
  content((rel: (-axis-overshoot, -0.25), to: "x-axis.50%"), text(weight: "bold")[bond strength], anchor: "north")
  content((rel: (0, -0.2), to: "x-axis.95%"), "strong", anchor: "north")
  content((rel: (0.1, 0), to: "y-axis.95%"), text(weight: "bold")[reaction rate], anchor: "west")

  // Add region labels
  content((2.5, 1), [limited by\ desorption\ of product])
  content((6, 1), [limited by\ activation\ of reactant])

  // Draw Sabatier optimum label
  let ellipse-center = (4.5, 4.2)
  let ellipse-width = 1.2
  let ellipse-height = ellipse-width / 2

  // Draw ellipse background
  circle(
    ellipse-center,
    radius: (ellipse-width, ellipse-height),
    fill: teal,
    stroke: none,
  )

  // Draw volcano curve using hobby spline
  hobby(
    (0, 1),
    (2, 2.6),
    (4.5, 3.7),
    (6, 2.8),
    (8, 1),
    stroke: 1.2pt,
    omega: 1,
  )
  // Add label
  content(
    ellipse-center,
    align(center)[Sabatier\ optimum],
    padding: 2pt,
  )
})
