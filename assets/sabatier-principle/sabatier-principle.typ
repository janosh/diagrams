#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, hobby, line, rect

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#canvas({
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

  let arrow-style = (mark: (end: "stealth", fill: black, scale: 0.7))
  let axis-overshoot = -0.75
  line((axis-overshoot, 0), (8, 0), ..arrow-style, name: "x-axis") // x-axis
  line((0, axis-overshoot), (0, 5), ..arrow-style, name: "y-axis") // y-axis

  content(
    (rel: (-axis-overshoot, -0.2), to: "x-axis.6%"),
    "weak",
    anchor: "north",
  )
  content(
    (rel: (-axis-overshoot, -0.25), to: "x-axis.50%"),
    text(weight: "bold")[bond strength],
    anchor: "north",
  )
  content((rel: (0, -0.2), to: "x-axis.95%"), "strong", anchor: "north")
  content(
    (rel: (0.1, 0), to: "y-axis.95%"),
    text(weight: "bold")[reaction rate],
    anchor: "west",
  )

  content((rel: (0, 1), to: "x-axis.37%"), [limited by\ desorption\ of product])
  content(
    (rel: (0, 1), to: "x-axis.77%"),
    [limited by\ activation\ of reactant],
  )

  let ellipse-center = (4.5, 4.2)
  let ellipse-width = 1.2
  let ellipse-height = ellipse-width / 2

  circle(
    ellipse-center,
    radius: (ellipse-width, ellipse-height),
    fill: teal,
    stroke: none,
  )

  hobby(
    (0, 1),
    (2, 2.6),
    (4.5, 3.7),
    (6, 2.8),
    (8, 1),
    stroke: 1.2pt,
    omega: 1,
  )
  content(
    ellipse-center,
    align(center)[Sabatier\ optimum],
    padding: 2pt,
  )
})
