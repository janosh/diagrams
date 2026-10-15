#import "@preview/cetz:0.5.2": canvas, draw
#import draw: content, hobby, line, rect

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 12pt)

#let limitations = ("activation of reactant", "desorption of product")
// Maximum of the Hobby spline below, rather than its nearby (4.5, 3.7) control point.
#let optimum = (4.210977, 3.723861)

#canvas({
  let (optimum-x, optimum-y) = optimum
  rect((0, 0), (optimum-x, 4), fill: rgb(200, 220, 255), stroke: none) // blue!20
  rect((optimum-x, 0), (8, 4), fill: rgb(255, 230, 200), stroke: none) // orange!20

  let arrow-style = (mark: (end: "stealth", fill: black, scale: 0.7))
  let axis-overshoot = -0.75
  line((axis-overshoot, 0), (8, 0), ..arrow-style, name: "x-axis")
  line((0, axis-overshoot), (0, 5), ..arrow-style, name: "y-axis")

  content((rel: (-axis-overshoot, -0.2), to: "x-axis.6%"), "weak", anchor: "north")
  content(
    (rel: (-axis-overshoot, -0.25), to: "x-axis.50%"),
    text(weight: "bold")[bond strength],
    anchor: "north",
  )
  content((rel: (0, -0.2), to: "x-axis.95%"), "strong", anchor: "north")
  content((rel: (0.1, 0), to: "y-axis.95%"), text(weight: "bold")[reaction rate], anchor: "west")

  for (position, limitation) in ("x-axis.37%", "x-axis.77%").zip(limitations) {
    content((rel: (0, 1), to: position), [limited by\ #box(width: 75pt, align(center, limitation))])
  }

  line((optimum-x, optimum-y + 0.04), (optimum-x, 4.15), stroke: teal + 0.8pt)
  content((optimum-x, 4.35), text(weight: "bold")[Sabatier optimum])
  hobby((0, 1), (2, 2.6), (4.5, 3.7), (6, 2.8), (8, 1), stroke: 1.2pt, omega: 1)
})
