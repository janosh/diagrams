#import "@preview/cetz:0.4.2": angle, canvas, draw
#import draw: circle, content, line

#set page(width: auto, height: auto, margin: 8pt)

#canvas({
  // Helper coordinates
  let rad = 2.5
  let vec-a = (rad / 3, rad / 2)
  let phi-point = (rad / 3, -rad / 5)
  let mark = (end: "stealth", fill: black)

  // Bloch vector
  line((0, 0), vec-a, mark: (start: "circle", end: "circle", fill: black, scale: .5, anchor: "center"))

  // Dashed line forming angle
  line((0, 0), phi-point, style: "dashed")
  line(phi-point, vec-a, style: "dashed")
  // Axes
  let arrow-extend = 1.15
  line((0, 0), (-rad / 5 * 1.2, -rad / 3 * 1.2), mark: mark, name: "x1")
  content("x1.end", [$x_1$], anchor: "north")

  line((0, 0), (arrow-extend * rad, 0), mark: mark, name: "x2")
  content("x2.end", [$x_2$], anchor: "west")

  line((0, 0), (0, arrow-extend * rad), mark: mark, name: "x3")
  content("x3.end", [$x_3$], anchor: "south")

  // Angles
  angle.angle(
    (0, 0),
    (-1, -calc.tan(60deg)),
    (1, -calc.tan(30deg)),
    label: [$phi$],
    stroke: (paint: gray, thickness: .5pt),
    mark: (end: "stealth", fill: gray, scale: .7),
  )

  angle.angle(
    (0, 0),
    (1, calc.tan(60deg)),
    (1, calc.tan(90deg)),
    label: [$theta$],
    stroke: (paint: gray, thickness: .5pt),
    mark: (start: "stealth", fill: gray, scale: .7),
    label-radius: 0.75,
  )

  // Sphere
  circle((0, 0), radius: rad)
  circle((0, 0), radius: (rad, rad / 3), stroke: (dash: "dashed"), fill: gray.transparentize(70%))
})
