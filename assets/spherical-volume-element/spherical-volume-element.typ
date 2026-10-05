// Spherical differential volume by Juan Falgueras-Cano, 2026-10-04.
#import "@preview/cetz:0.5.2": canvas, draw
#import draw: arc, circle, content, get-ctx, hide, line, merge-path, on-xy, on-xz, rect, rotate, scope

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 12pt)

// theta is colatitude from +z; phi is azimuth in the xy plane.
#let spherical(radius, theta, phi) = (
  radius * calc.sin(theta) * calc.cos(phi),
  radius * calc.sin(theta) * calc.sin(phi),
  radius * calc.cos(theta),
)
// === Curves and volume-element geometry ===
#let (radius_min, radius_max) = (3, 3.5)
#let (theta_min, theta_max) = (55deg, 67deg)
#let (phi_min, phi_max) = (50deg, 64deg)
// Boundary and the two inner projected corners for the fixed 30deg/10deg view.
#let ring = (
  (radius_max, theta_min, phi_max),
  (radius_max, theta_max, phi_max),
  (radius_min, theta_max, phi_max),
  (radius_min, theta_max, phi_min),
  (radius_min, theta_min, phi_min),
  (radius_max, theta_min, phi_min),
)
#let far_corner = (radius_min, theta_min, phi_max)
#let near_corner = (radius_max, theta_max, phi_min)
// Draw an edge along one changing spherical coordinate: radius, theta or phi.
#let edge(start, end, ..style) = {
  let (radius, theta, phi) = start
  if radius != end.at(0) {
    line(spherical(..start), spherical(..end), ..style)
  } else {
    let polar = theta != end.at(1)
    scope({
      if polar { rotate(z: phi) }
      let plane = if polar { on-xz } else { on-xy.with(z: radius * calc.cos(theta)) }
      plane({
        arc(
          (0, 0),
          radius: if polar { radius } else { radius * calc.sin(theta) },
          start: if polar { 90deg - theta } else { phi },
          stop: if polar { 90deg - end.at(1) } else { end.at(2) },
          anchor: "origin",
          ..style,
        )
      })
    })
  }
}

// === Crop window ===
// (x-min, y-min, x-max, y-max) in cm from the origin of the axes; `none` shows everything.
// CeTZ cannot clip, so the canvas is padded to a known extent (larger than the whole
// figure) and then cut with a clipping box at these limits.
#let crop = (-2.75, -1.45, 5.4, 5.2)
#let extent = 7

#let drawing = canvas(length: 1cm, {
  if crop != none { hide(rect((-extent, -extent), (extent, extent)), bounds: true) }
  let sphere_radius = 4
  let axis_mark = (end: "stealth", fill: black, scale: .6)
  let length_arrow = (end: "stealth", start: "stealth", fill: blue, scale: .4)
  let guide = (paint: gray, thickness: .5pt)
  let hidden_guide = (paint: gray.lighten(25%), thickness: .5pt, dash: "dotted")
  let angle_stroke = (paint: red, thickness: .5pt, cap: "round")
  let visible_edge = (paint: blue, thickness: 1pt, cap: "round", join: "round")
  let hidden_edge = (paint: blue.lighten(60%), thickness: .6pt, dash: "dotted", cap: "round")
  let length_stroke = (paint: blue, thickness: .5pt, cap: "round", join: "round")

  circle((0, 0), radius: sphere_radius, stroke: guide)
  scope({
    rotate(x: -80deg)
    rotate(z: -120deg)
    // === Volume fill and sphere guides ===
    merge-path(close: true, fill: blue.transparentize(90%), stroke: none, {
      for (idx, start) in ring.enumerate() {
        edge(start, ring.at(calc.rem(idx + 1, ring.len())))
      }
    })
    // Use the drawing transform itself to split the guides into front/back halves.
    get-ctx(ctx => {
      let view = ctx.transform.at(2)
      for (base, axis, center) in (
        ((sphere_radius, 90deg, 0deg), 2, calc.atan2(view.at(0), view.at(1))),
        ((sphere_radius, 0deg, 0deg), 1, calc.atan2(view.at(2), view.at(0))),
        ((sphere_radius, 0deg, 90deg), 1, calc.atan2(view.at(2), view.at(1))),
      ) {
        for (offset, stroke) in ((90deg, hidden_guide), (-90deg, guide)) {
          let start = base
          start.at(axis) = center + offset
          let end = start
          end.at(axis) += 180deg
          edge(start, end, stroke: stroke)
        }
      }
    })

    // === Angles and axes ===
    edge((.5, 0deg, phi_min), (.5, theta_max, phi_min), stroke: angle_stroke)
    content(spherical(.3, theta_max / 2, phi_min), text(red)[$theta$], anchor: "east", padding: .1)
    // Draw -z before phi so it cannot cover the angle arc.
    line((0, 0), (0, 0, -1.1 * sphere_radius), stroke: hidden_guide)
    edge((1.2, 90deg, 0deg), (1.2, 90deg, phi_min), stroke: angle_stroke)
    content(spherical(1, 90deg, phi_min / 2), text(red)[$phi$], anchor: "north", padding: 0)
    for (direction, label) in (((1, 0, 0), $x$), ((0, 1, 0), $y$), ((0, 0, 1), $z$)) {
      if direction != (0, 0, 1) {
        line(
          (0, 0),
          direction.map(value => -1.1 * sphere_radius * value),
          stroke: hidden_guide,
        )
      }
      line((0, 0), direction.map(value => (sphere_radius + .8) * value), mark: axis_mark)
      content(direction.map(value => (sphere_radius + 1.1) * value), label)
    }

    // === Volume edges, hidden ones first ===
    for idx in (0, 2, 4) {
      edge(far_corner, ring.at(idx), stroke: hidden_edge)
    }
    // Extend inner radial edges without duplicating the position vector.
    for point in (ring.at(4), far_corner, ring.at(2)) {
      line((0, 0), spherical(..point), stroke: (
        paint: gray.lighten(60%),
        thickness: .6pt,
        dash: "dotted",
      ))
    }

    for (idx, start) in ring.enumerate() {
      edge(start, ring.at(calc.rem(idx + 1, ring.len())), stroke: visible_edge)
      if calc.odd(idx) { edge(start, near_corner, stroke: visible_edge) }
    }

    // === Edge lengths and position vector ===
    edge(
      (radius_min, theta_max * 1.03, phi_min),
      (radius_min, theta_max * 1.03, phi_max),
      stroke: length_stroke,
      mark: length_arrow,
    )
    edge(
      (radius_max, theta_min, phi_max * 1.03),
      (radius_max, theta_max, phi_max * 1.03),
      stroke: length_stroke,
      mark: length_arrow,
    )
    let vector_tip = spherical(radius_min, theta_max, phi_min)
    let foot = spherical(radius_min * calc.sin(theta_max), 90deg, phi_min)
    let projection_stroke = (dash: "dashed", paint: gray, thickness: .3pt)
    line(vector_tip, foot, stroke: projection_stroke)
    line((0, 0), foot, stroke: projection_stroke)
    line((0, 0), vector_tip, stroke: 1.2pt, mark: axis_mark)
    for (position, label, paint, anchor, padding) in (
      ((2, 90deg, phi_min), $r sin theta$, gray, "north", 0),
      ((2, theta_max, phi_min), $arrow(r)$, black, "south-east", 0),
      ((radius_max, theta_min, phi_min), $d r$, blue, "east", .1),
      ((radius_max, (theta_min + theta_max) / 2, phi_max), $r d theta$, blue, "west", .15),
      (
        (radius_min, theta_max, (phi_min + phi_max) / 2),
        $r sin theta d phi$,
        blue,
        "north-west",
        .08,
      ),
      (
        ((radius_min + radius_max) / 2, theta_min, (phi_min + phi_max) / 2),
        $d V = r^2 sin theta d r d theta d phi$,
        blue,
        "south-west",
        .3,
      ),
    ) {
      content(spherical(..position), text(paint, label), anchor: anchor, padding: padding)
    }
  })
})

#if crop == none { drawing } else {
  let (x-min, y-min, x-max, y-max) = crop
  // The canvas top-left corner is the point (-extent, +extent).
  box(
    clip: true,
    width: (x-max - x-min) * 1cm,
    height: (y-max - y-min) * 1cm,
    place(top + left, dx: -(x-min + extent) * 1cm, dy: -(extent - y-max) * 1cm, drawing),
  )
}
