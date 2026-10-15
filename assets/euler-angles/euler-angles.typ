#import "@preview/cetz:0.5.2": canvas, draw
#import draw: arc, content, line, rotate, scope

#set page(width: auto, height: auto, margin: 12pt, fill: none)
#set text(font: "New Computer Modern", size: 12pt, fill: rgb("243247"))

#let precession = 25deg
#let nutation = 25deg
#let rotation = 25deg
#let precession_color = rgb("2563eb")
#let nutation_color = rgb("c26418")
#let rotation_color = rgb("138579")
#let axis_color = rgb("697586")
#let arrow(color) = (end: "stealth", fill: color, stroke: none, length: 5pt, width: 3.5pt)

#let axis(endpoint, label, anchor, color) = {
  line((0, 0, 0), endpoint, stroke: color + 1pt, mark: arrow(color))
  content(endpoint, text(size: 16pt, fill: color, label), anchor: anchor, padding: 3pt)
}

#let rotation_angles(angle, label, color, anchors) = {
  let guide_stroke = (paint: color.transparentize(65%), thickness: 0.5pt, dash: "dashed")
  arc((0, 0), start: 0deg, stop: 360deg, anchor: "origin", radius: 1, stroke: guide_stroke)
  // Coincident axes have no rotation arc; CeTZ rejects equal endpoints.
  if angle == 0deg { return }
  for (stop, anchor) in (90deg, 0deg).zip(anchors) {
    let start = stop - angle
    let middle = (start + stop) / 2
    content(
      (0.7 * calc.cos(middle), 0.7 * calc.sin(middle)),
      text(size: 16pt, fill: color, label),
      anchor: anchor,
      padding: 3pt,
    )
    arc(
      (0, 0),
      start: start,
      stop: stop,
      anchor: "origin",
      radius: 0.7,
      stroke: color + 1pt,
      mark: arrow(color),
    )
  }
}

#canvas({
  content((0, 7.0), text(size: 18pt, weight: "bold")[Euler angles: three ordered rotations])
  content((0, 6.35), text(size: 14pt)[Intrinsic $Z$–$Y$–$Z$ convention · axes move with the frame])
  scope({
    // Orthographic viewing transform; subsequent rotations act in the moving frame.
    rotate(x: -70deg)
    rotate(z: -130deg)
    draw.scale(5.6)
    axis((1, 0, 0), $x$, "north-east", axis_color)
    axis((0, 1, 0), $y$, "north-west", axis_color)
    axis((0, 0, 1), $z$, "south", axis_color)

    rotate(z: precession)
    axis((1, 0, 0), $u$, "north-east", precession_color)
    axis((0, 1, 0), $v$, "west", precession_color)
    rotation_angles(precession, $psi$, precession_color, ("north-east", "north-east"))

    rotate(y: nutation)
    axis((1, 0, 0), $w$, "north-east", nutation_color)
    axis((0, 0, 1), $z_1$, "south-east", nutation_color)
    scope({
      // The nutation plane has local x along z, local y along x, local z along y.
      draw.transform(((0, 1, 0, 0), (0, 0, 1, 0), (1, 0, 0, 0), (0, 0, 0, 1)))
      rotation_angles(nutation, $theta$, nutation_color, ("south-west", "south"))
    })

    rotate(z: rotation)
    axis((1, 0, 0), $x_1$, "north", rotation_color)
    axis((0, 1, 0), $y_1$, "west", rotation_color)
    rotation_angles(rotation, $phi$, rotation_color, ("west", "north"))
  })

  for (position, color, heading, detail) in (
    (-4.6, precession_color, [1. Precession $psi$], [Rotate about $z$]),
    (0, nutation_color, [2. Nutation $theta$], [Tilt about $v$]),
    (4.6, rotation_color, [3. Spin $phi$], [Rotate about $z_1$]),
  ) {
    content((position, -6.2), text(size: 16pt, fill: color, weight: "bold", heading))
    content((position, -6.8), text(size: 14pt, detail))
  }
  content((0, -7.6), text(size: 18pt)[$R = R_z (psi) R_y (theta) R_z (phi)$], name: "formula")
  let footer = [The final basis is $(x_1, y_1, z_1)$. \ Changing the rotation order changes the orientation.]
  content(
    (rel: (0, -0.15), to: "formula.south"),
    text(size: 14pt, fill: axis_color, align(center, footer)),
    anchor: "north",
  )
})
