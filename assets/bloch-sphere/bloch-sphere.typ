#import "@preview/cetz:0.3.2": canvas, draw, angle
#import draw: line, content, circle

#set page(width: auto, height: auto, margin: 8pt)

#canvas({
  // Helper coordinates
  let rad = 2.5
  let vec-a = (rad / 3, rad / 2)
  let phi-point = (rad / 3, -rad / 5)

  // Bloch vector
  line((0, 0), vec-a)
  circle((0, 0), radius: 1pt, fill: black)
  circle(vec-a, radius: 1pt, fill: black)
  // content(vec-a + (0.1, 0.2), [$vec(a)$])

  // Dashed line forming angle
  line((0, 0), phi-point, style: "dashed")
  line(phi-point, vec-a, style: "dashed")
  // Axes
  let arrow-extend = 1.15
  line((0, 0), (-rad / 5, -rad / 3), mark: (end: "stealth", fill: black))
  content((-rad / 5 - 0.2, -rad / 3 - 0.2), [$x_1$])

  line((0, 0), (arrow-extend * rad, 0), mark: (end: "stealth", fill: black))
  content((arrow-extend * rad + 0.2, 0), [$x_2$])

  line((0, 0), (0, arrow-extend * rad), mark: (end: "stealth", fill: black))
  content((0, arrow-extend * rad + 0.2), [$x_3$])

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
