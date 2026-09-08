#import "@preview/cetz:0.5.2": canvas, draw

// TeX points are 1/72.27 inch; Typst points are 1/72 inch.
#let tex_pt = 72 / 72.27 * 1pt

// Preserve the page dimensions of the original exported figure.
#set page(width: 323.465pt, height: 319.899pt, margin: 0pt, fill: none)
#set text(font: "New Computer Modern", size: 10 * tex_pt)

// Same viewing direction, scale, and intrinsic Z-Y-Z rotations as the TikZ source.
#let view_theta = 70deg
#let view_phi = 130deg
#let precession = 15deg
#let nutation = 15deg
#let rotation = 15deg
#let angle_radius = 0.7
#let precession_color = rgb("0000ff")
#let nutation_color = rgb("ff0000")
#let rotation_color = rgb("00ff00")
// A full-width arrow matches \overrightarrow; Typst's arrow accent is shorter.
#let vector_label(body) = box(width: 1em, height: 0.8em, {
  place(bottom + center, body)
  place(top + center, text(top-edge: "bounds", bottom-edge: "bounds", math.stretch(
    sym.arrow.r,
    size: 1em,
  )))
})

#let axis(endpoint, label, anchor, color, tip: "stealth") = {
  draw.line((0, 0, 0), endpoint, stroke: color + 0.8 * tex_pt, mark: (
    end: tip,
    fill: color,
    stroke: none,
    length: 4.16 * tex_pt,
    width: 4.16 * tex_pt,
    inset: 1.56 * tex_pt,
  ))
  draw.floating(draw.content(
    endpoint,
    text(fill: color, label),
    anchor: anchor,
    padding: 3.533 * tex_pt,
  ))
}

#let rotation_circle(color) = draw.arc(
  (0, 0),
  start: 0deg,
  stop: 360deg,
  anchor: "origin",
  radius: 1,
  stroke: (paint: color, thickness: 0.4 * tex_pt, dash: (3 * tex_pt, 3 * tex_pt)),
)

#let angle_arc(start, stop, label, anchor, color) = {
  // Coincident axes have no rotation arc; CeTZ rejects equal endpoints.
  if start == stop { return }
  let middle = (start + stop) / 2
  draw.content(
    (angle_radius * calc.cos(middle), angle_radius * calc.sin(middle)),
    text(fill: color, label),
    anchor: anchor,
    padding: 3.533 * tex_pt,
  )
  draw.arc(
    (0, 0),
    start: start,
    stop: stop,
    anchor: "origin",
    radius: angle_radius,
    stroke: color + 0.8 * tex_pt,
    mark: (end: "latex", fill: color, stroke: none),
  )
}

#place(center + horizon, canvas({
  // PGF's original latex arrowhead, with its curved sides and 0.8 TeX pt shaft.
  draw.register-mark("latex", style => {
    let arrow_unit = 0.52 * tex_pt / 1cm
    draw.merge-path(fill: style.fill, stroke: none, close: true, {
      draw.bezier(
        (0, 0),
        (10 * arrow_unit, 3.75 * arrow_unit),
        (2.6667 * arrow_unit, 0.5 * arrow_unit),
        (7 * arrow_unit, 2 * arrow_unit),
      )
      draw.line((10 * arrow_unit, 3.75 * arrow_unit), (10 * arrow_unit, -3.75 * arrow_unit))
      draw.bezier(
        (10 * arrow_unit, -3.75 * arrow_unit),
        (0, 0),
        (7 * arrow_unit, -2 * arrow_unit),
        (2.6667 * arrow_unit, -0.5 * arrow_unit),
      )
    })
    draw.anchor("tip", (0, 0))
    draw.anchor("base", (9 * arrow_unit, 0))
  })
  // Orthographic projection from tikz-3dplot's main coordinate matrix.
  draw.set-transform((
    (calc.cos(view_phi), calc.sin(view_phi), 0, 0),
    (
      -calc.cos(view_theta) * calc.sin(view_phi),
      calc.cos(view_theta) * calc.cos(view_phi),
      calc.sin(view_theta),
      0,
    ),
    (
      calc.sin(view_theta) * calc.sin(view_phi),
      -calc.sin(view_theta) * calc.cos(view_phi),
      calc.cos(view_theta),
      0,
    ),
    (0, 0, 0, 1),
  ))
  draw.scale(5)

  // Initial basis.
  axis((1, 0, 0), $#vector_label($x$)$, "north-east", black)
  axis((0, 1, 0), $#vector_label($y$)$, "north-west", black)
  axis((0, 0, 1), $#vector_label($z$)$, "south", black)

  // Precession about the initial z axis.
  draw.rotate(z: precession)
  axis((1, 0, 0), $#vector_label($u$)$, "north-east", precession_color, tip: "latex")
  axis((0, 1, 0), $#vector_label($v$)$, "west", precession_color, tip: "latex")
  rotation_circle(precession_color)
  angle_arc(90deg - precession, 90deg, $psi$, "north-east", precession_color)
  angle_arc(-precession, 0deg, $psi$, "north-east", precession_color)

  // Nutation about the intermediate v axis.
  draw.rotate(y: nutation)
  axis((1, 0, 0), $#vector_label($w$)$, "north-east", nutation_color)
  axis((0, 0, 1), $#vector_label($z$) _1$, "south-east", nutation_color)
  draw.scope({
    // Draw in the nutation plane: local x points along z, local y along x, local z along y.
    draw.transform(((0, 1, 0, 0), (0, 0, 1, 0), (1, 0, 0, 0), (0, 0, 0, 1)))
    rotation_circle(nutation_color)
    angle_arc(90deg - nutation, 90deg, $theta$, "south-west", nutation_color)
    angle_arc(-nutation, 0deg, $theta$, "south", nutation_color)
  })

  // Proper rotation about the tilted z_1 axis.
  draw.rotate(z: rotation)
  axis((1, 0, 0), $#vector_label($x$) _1$, "north", rotation_color)
  axis((0, 1, 0), $#vector_label($y$) _1$, "west", rotation_color)
  rotation_circle(rotation_color)
  angle_arc(90deg - rotation, 90deg, $phi$, "west", rotation_color)
  angle_arc(-rotation, 0deg, $phi$, "north", rotation_color)
}))
