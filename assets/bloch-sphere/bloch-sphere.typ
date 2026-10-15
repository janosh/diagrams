#import "@preview/cetz:0.5.2": angle, canvas, draw
#import draw: circle, content, line

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 12pt)

#canvas({
  let rad = 2.5
  let vec-a = (rad / 3, rad / 2)
  let phi-point = (rad / 3, -rad / 5)
  let x1-end = (-rad / 5 * 1.2, -rad / 3 * 1.2)

  // Bloch vector
  line((0, 0), vec-a, mark: (
    start: "circle",
    end: "circle",
    fill: black,
    scale: .5,
    anchor: "center",
  ))
  content((rel: (0.08, 0.08), to: vec-a), $arrow(a)$, anchor: "south-west")

  // Dashed projection onto the equatorial plane
  line((0, 0), phi-point, vec-a, style: "dashed")
  for (end, label, anchor) in (
    (x1-end, $x_1$, "north"),
    ((1.15 * rad, 0), $x_2$, "west"),
    ((0, 1.15 * rad), $x_3$, "south"),
  ) {
    line((0, 0), end, mark: (end: "stealth", fill: black))
    content(end, label, anchor: anchor)
  }

  // Angles
  draw.set-style(angle: (stroke: (paint: gray, thickness: .5pt), mark: (fill: gray, scale: .7)))
  angle.angle((0, 0), x1-end, phi-point, label: $phi$, mark: (end: "stealth"))
  angle.angle((0, 0), vec-a, (0, 1), label: $theta$, label-radius: 0.75, mark: (start: "stealth"))

  // Sphere
  circle((0, 0), radius: rad)
  circle((0, 0), radius: (rad, rad / 3), stroke: (dash: "dashed"), fill: gray.transparentize(70%))
})
