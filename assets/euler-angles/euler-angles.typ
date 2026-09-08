#import "@preview/cetz:0.5.2": canvas, draw

#set page(width: auto, height: auto, margin: 12pt, fill: none)
#set text(font: "New Computer Modern", size: 10pt, fill: rgb("243247"))

#let precession = 25deg
#let nutation = 25deg
#let rotation = 25deg
#let precession_color = rgb("2563eb")
#let nutation_color = rgb("c26418")
#let rotation_color = rgb("138579")
#let arrow(color) = (end: "stealth", fill: color, stroke: none, length: 5pt, width: 3.5pt)

#let axis(endpoint, label, anchor, color) = {
  draw.line((0, 0, 0), endpoint, stroke: color + 1pt, mark: arrow(color))
  draw.content(endpoint, text(fill: color, label), anchor: anchor, padding: 3pt)
}

#let rotation_angles(angle, label, color, anchors) = {
  draw.arc((0, 0), start: 0deg, stop: 360deg, anchor: "origin", radius: 1, stroke: (
    paint: color.transparentize(65%),
    thickness: 0.5pt,
    dash: "dashed",
  ))
  // Coincident axes have no rotation arc; CeTZ rejects equal endpoints.
  if angle == 0deg { return }
  for (stop, anchor) in (90deg, 0deg).zip(anchors) {
    let start = stop - angle
    let middle = (start + stop) / 2
    draw.content(
      (0.7 * calc.cos(middle), 0.7 * calc.sin(middle)),
      text(fill: color, label),
      anchor: anchor,
      padding: 3pt,
    )
    draw.arc(
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
  draw.content((0, 5.0), text(size: 16pt, weight: "bold")[Euler angles: three ordered rotations])
  draw.content((0, 4.58), [Intrinsic $Z$–$Y$–$Z$ convention · axes move with the frame])
  draw.scope({
    // Orthographic viewing transform; subsequent rotations act in the moving frame.
    draw.rotate(x: -70deg)
    draw.rotate(z: -130deg)
    draw.scale(3.8)
    axis((1, 0, 0), $x$, "north-east", rgb("697586"))
    axis((0, 1, 0), $y$, "north-west", rgb("697586"))
    axis((0, 0, 1), $z$, "south", rgb("697586"))

    draw.rotate(z: precession)
    axis((1, 0, 0), $u$, "north-east", precession_color)
    axis((0, 1, 0), $v$, "west", precession_color)
    rotation_angles(precession, $psi$, precession_color, ("north-east", "north-east"))

    draw.rotate(y: nutation)
    axis((1, 0, 0), $w$, "north-east", nutation_color)
    axis((0, 0, 1), $z_1$, "south-east", nutation_color)
    draw.scope({
      // The nutation plane has local x along z, local y along x, local z along y.
      draw.transform(((0, 1, 0, 0), (0, 0, 1, 0), (1, 0, 0, 0), (0, 0, 0, 1)))
      rotation_angles(nutation, $theta$, nutation_color, ("south-west", "south"))
    })

    draw.rotate(z: rotation)
    axis((1, 0, 0), $x_1$, "north", rotation_color)
    axis((0, 1, 0), $y_1$, "west", rotation_color)
    rotation_angles(rotation, $phi$, rotation_color, ("west", "north"))
  })

  for (position, color, heading, detail) in (
    (-3, precession_color, [1. Precession $psi$], [Rotate about $z$]),
    (0, nutation_color, [2. Nutation $theta$], [Tilt about $v$]),
    (3, rotation_color, [3. Spin $phi$], [Rotate about $z_1$]),
  ) {
    draw.content((position, -4.35), text(fill: color, weight: "bold", heading))
    draw.content((position, -4.78), text(size: 8pt, detail))
  }
  draw.content((0, -5.35), $R = R_z (psi) R_y (theta) R_z (phi)$)
  draw.content((0, -5.78), text(
    size: 8pt,
    fill: rgb("697586"),
  )[The final basis is $(x_1, y_1, z_1)$. Changing the rotation order changes the orientation.])
})
