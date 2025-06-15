#import "@preview/cetz:0.4.0": canvas, draw
#import draw: line, content, circle, polygon

#set page(width: auto, height: auto, margin: 8pt)
#set text(weight: "bold")

// TODO replace draw-star with n-star once released https://github.com/cetz-package/cetz/pull/886

// Draw a star directly with lines
#let draw-star(pos, size: 0.3, fill: red) = {
  let outer-r = size
  let inner-r = size * 0.4

  let points = ()
  for idx in range(10) {
    let angle = idx * 36deg
    let radius = if calc.rem(idx, 2) == 0 { outer-r } else { inner-r }
    points.push((
      pos.at(0) + radius * calc.cos(angle),
      pos.at(1) + radius * calc.sin(angle),
    ))
  }

  // Draw connected lines to form a star
  for idx in range(10) {
    let next = if idx == 9 { 0 } else { idx + 1 }
    line(
      points.at(idx),
      points.at(next),
      stroke: 1.5pt,
      fill: fill,
    )
  }

  if fill != none {
    line(..points, close: true, stroke: none, fill: fill)
  }
}

// Draw a triangle using polygon function
#let draw-triangle(pos, size: 0.275, fill: green) = {
  polygon(
    pos,
    3,
    radius: size,
    angle: 90deg, // Point up
    fill: fill,
    stroke: .5pt,
  )
}

#canvas({
  // Set up coordinate system
  let arrow-style = (mark: (end: "stealth", fill: black, scale: 0.7))
  let axis-length = 6

  // Draw axes
  line(
    (0, 0),
    (axis-length, 0),
    ..arrow-style,
    name: "x-axis",
  )
  content((rel: (-0.1, 0.2), to: "x-axis.end"), [$x$ axis], anchor: "south-east")

  line((0, 0), (0, axis-length), ..arrow-style, name: "y-axis")
  content((rel: (0.2, -0.1), to: "y-axis.end"), [$y$ axis], anchor: "north-west")

  // Draw Class A (red stars)
  draw-star((1.6, 4.0))
  draw-star((1.3, 3.5))
  draw-star((2.3, 3.8))
  draw-star((1.8, 3.0))
  draw-star((1.6, 2.7))
  draw-star((2.5, 2.5))
  draw-star((2, 2.2))

  // Draw Class B (green triangles)
  draw-triangle((4.2, 3.5))
  draw-triangle((3.6, 2.8))
  draw-triangle((3.4, 2.2))
  draw-triangle((4.0, 2.2))
  draw-triangle((5.2, 2.5))
  draw-triangle((4.7, 3.5))
  draw-triangle((4, 1.5))
  draw-triangle((4.7, 1.8))

  // Draw the new example to classify (yellow square with question mark)
  content(
    (3, 2.5),
    (rel: (0.4, 0.4)),
    align(center, text(baseline: 1.5pt)[?]),
    anchor: "center",
    frame: "rect",
    fill: yellow,
    padding: 1pt,
    name: "new-example",
  )

  // Draw the k=3 and k=7 circles centered at the new example
  circle(
    "new-example.center",
    radius: 0.8,
    stroke: (dash: "dashed"),
    name: "k3-circle",
  )
  content((rel: (0, -0.3), to: "k3-circle.south"), $k = 3$, anchor: "north")

  circle(
    "new-example.center",
    radius: 2.0,
    stroke: (dash: "dashed"),
    name: "k7-circle",
  )
  content((rel: (0, -0.3), to: "k7-circle.south"), $k = 7$, anchor: "north")

  // Add class labels in the upper right corner
  content((5.4, 4.8), text(fill: red, size: 12pt)[Class A])
  content((5.4, 4.3), text(fill: green, size: 12pt)[Class B])

  // Add arrow pointing to the new example
  content((4, 5.5), [New example\ to classify], name: "new-example-label")
  line(
    "new-example-label",
    "new-example.north",
    stroke: 0.6pt,
    mark: (end: "stealth", fill: black, offset: 0.05),
  )
})
