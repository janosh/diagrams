#import "@preview/cetz:0.5.3": angle, canvas, draw
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
  // labeled outside the sphere: near the tip the x_3 axis and the outline leave no room
  let label-at = (0.8 * rad, 0.95 * rad)
  line(vec-a, label-at, stroke: luma(100) + 0.5pt)
  content(label-at, [Bloch vector $arrow(a)$], anchor: "south-west", padding: 2pt)

  // Dashed projection onto the equatorial plane
  line((0, 0), phi-point, vec-a, style: "dashed")
  // x_1 hangs below its arrow tip: anchors align ink bounds, so pad off the arrowhead
  for (end, label, anchor, pad) in (
    (x1-end, $x_1$, "north", 3pt),
    ((1.15 * rad, 0), $x_2$, "west", 0pt),
    ((0, 1.15 * rad), $x_3$, "south", 0pt),
  ) {
    line((0, 0), end, mark: (end: "stealth", fill: black))
    content(end, label, anchor: anchor, padding: pad)
  }

  // Angles
  // Darker than Typst gray so the angle arcs read on both page themes.
  let ink = luma(100)
  draw.set-style(angle: (stroke: (paint: ink, thickness: .5pt), mark: (fill: ink, scale: .7)))
  angle.angle((0, 0), x1-end, phi-point, label: $phi$, mark: (end: "stealth"))
  angle.angle((0, 0), vec-a, (0, 1), label: $theta$, label-radius: 0.75, mark: (start: "stealth"))

  // Sphere
  circle((0, 0), radius: rad)
  circle((0, 0), radius: (rad, rad / 3), stroke: (dash: "dashed"), fill: gray.transparentize(70%))
  content((0, -rad - 0.15), [$theta$: polar angle, $phi$: azimuthal angle], anchor: "north")
})
