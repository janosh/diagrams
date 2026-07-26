#import "@preview/cetz:0.5.2": canvas, draw
#import draw: content, grid, line, rect
#import "/assets/_shared/theme.typ": annotation-size, neutral, series

#set page(width: auto, height: auto, margin: 10pt, fill: none)
#set text(size: 11pt)

// Each edge pair keeps its color through every stage, so it stays visible which edge of
// the square becomes which circle on the torus.
#let rim-color = series(0).paint // vertical edges -> the cylinder rims -> the short circle
#let seam-color = series(1).paint // horizontal edges -> the seam -> the long circle
#let surface-fill = rgb("#DFE6EF")
#let mesh-stroke = rgb("#A2AEBD") + 0.3pt
#let edge-weight = 2.2pt

// === orthographic camera, shared by both 3D panels ===
// The azimuth matters: viewed square-on, a tube's rims collapse to straight lines.
#let azimuth = 27deg
#let elevation = 20deg
#let light = (-0.42, -0.66, 0.62)
#let camera = (
  -calc.sin(azimuth) * calc.cos(elevation),
  -calc.cos(azimuth) * calc.cos(elevation),
  calc.sin(elevation),
)

#let project((x, y, z)) = (
  x * calc.cos(azimuth) - y * calc.sin(azimuth),
  (x * calc.sin(azimuth) + y * calc.cos(azimuth)) * calc.sin(elevation) + z * calc.cos(elevation),
)
#let view-depth((x, y, z)) = (
  (x * calc.sin(azimuth) + y * calc.cos(azimuth)) * calc.cos(elevation) - z * calc.sin(elevation)
)
#let dot(a, b) = a.zip(b).map(((p, q)) => p * q).sum()
#let place-at(point, origin) = project(point).zip(origin).map(((c, o)) => c + o)

// A tube is swept along an axis curve, which reports its center and its outward radial
// direction at each step; the tube's "up" is always z. A straight axis gives a cylinder,
// a closed ring gives a torus, and both then share the drawing and hiding code below.
#let straight-axis(span) = u => ((u * span - span / 2, 0.0, 0.0), (0.0, 1.0, 0.0))
#let ring-axis(ring) = u => {
  let sweep = u * 360deg - 90deg
  let (cos-s, sin-s) = (calc.cos(sweep), calc.sin(sweep))
  ((ring * cos-s, ring * sin-s, 0.0), (cos-s, sin-s, 0.0))
}

#let tube-point(axis, tube, u, v) = {
  let ((cx, cy, cz), (rx, ry, _)) = axis(u)
  let angle = v * 360deg
  let reach = tube * calc.cos(angle)
  (cx + reach * rx, cy + reach * ry, cz + tube * calc.sin(angle))
}

#let tube-normal(axis, u, v) = {
  let (_, (rx, ry, _)) = axis(u)
  let angle = v * 360deg
  (calc.cos(angle) * rx, calc.cos(angle) * ry, calc.sin(angle))
}

// CeTZ has no depth buffer, so quads get painted back to front by hand. Their edges double
// as the surface mesh, which carries the square's grid onto the rolled-up shapes.
#let draw-tube(axis, tube, u-steps, v-steps, origin) = {
  let quads = ()
  for iu in range(u-steps) {
    for iv in range(v-steps) {
      let (u0, u1) = (iu / u-steps, (iu + 1) / u-steps)
      let (v0, v1) = (iv / v-steps, (iv + 1) / v-steps)
      let corners = ((u0, v0), (u1, v0), (u1, v1), (u0, v1)).map(((u, v)) => tube-point(
        axis,
        tube,
        u,
        v,
      ))
      let mid = tube-normal(axis, (u0 + u1) / 2, (v0 + v1) / 2)
      let lambert = calc.max(0.0, dot(mid, light))
      // back faces are the inside of the tube, seen through its open rims: shading them
      // down keeps the cylinder from reading as a capped solid
      let lit = if dot(mid, camera) > 0 { 0.45 + 0.55 * lambert } else { 0.3 + 0.2 * lambert }
      quads.push((
        corners.map(view-depth).sum() / 4,
        corners.map(pt => place-at(pt, origin)),
        surface-fill.darken((1 - lit) * 45%),
      ))
    }
  }
  for (_, pts, fill) in quads.sorted(key: quad => quad.first()).rev() {
    line(..pts, close: true, fill: fill, stroke: mesh-stroke)
  }
}

// Polyline along a curve on the tube, dropping the stretches turned away from the camera
// so the far side stays hidden behind the surface.
#let draw-visible(sample, normal-at, steps, origin, stroke, arrows: ()) = {
  for idx in range(steps) {
    let (t0, t1) = (idx / steps, (idx + 1) / steps)
    if dot(normal-at((t0 + t1) / 2), camera) <= 0 { continue }
    line(..(t0, t1).map(t => place-at(sample(t), origin)), stroke: stroke)
  }
  // chevrons repeat the square's edge markings, so orientation survives the gluing
  for at in arrows {
    line(
      ..(at, at + 0.012).map(t => place-at(sample(t), origin)),
      stroke: stroke,
      mark: (end: "stealth", fill: stroke.paint, scale: 0.55),
    )
  }
}

#let caption(x, body) = content(
  (x, -2.35),
  text(size: annotation-size, fill: neutral.annotation)[#body],
  anchor: "north",
)

#let step-arrow(x, body, paint) = {
  line(
    (x, 0),
    (x + 1.45, 0),
    stroke: neutral.annotation + 0.9pt,
    mark: (end: "stealth", fill: neutral.annotation, scale: 0.55),
  )
  content(
    (x + 0.725, 0.2),
    text(size: annotation-size, fill: paint)[#body],
    anchor: "south",
  )
}

#canvas({
  // === 1. the periodic plane ===
  let cell = 1.3
  for idx in range(-1, 2) {
    let at = idx * cell
    line((at, -1.5 * cell), (at, 1.5 * cell), stroke: rim-color.transparentize(78%) + 0.9pt)
    line((-1.5 * cell, at), (1.5 * cell, at), stroke: seam-color.transparentize(78%) + 0.9pt)
  }
  for (from, to) in (
    ((-1.85 * cell, 0), (1.85 * cell, 0)),
    ((0, -1.85 * cell), (0, 1.85 * cell)),
  ) {
    line(
      from,
      to,
      stroke: neutral.annotation + 0.7pt,
      mark: (end: "stealth", fill: neutral.annotation, scale: 0.5),
    )
  }
  // shifting this cell by 2pi in either direction lands on a copy of itself
  rect((0, 0), (cell, cell), fill: seam-color.transparentize(90%), stroke: none)
  for (from, to, paint) in (
    ((0, 0), (cell, 0), seam-color),
    ((0, cell), (cell, cell), seam-color),
    ((0, 0), (0, cell), rim-color),
    ((cell, 0), (cell, cell), rim-color),
  ) { line(from, to, stroke: paint + 1.5pt) }
  content((cell / 2, -0.22), text(size: annotation-size)[$2pi$], anchor: "north")
  content((cell + 0.16, cell / 2), text(size: annotation-size)[$2pi$], anchor: "west")
  caption(0, [plane with $2pi$ periodicity])

  // === 2. the fundamental domain and its two identifications ===
  step-arrow(2.55, [one cell], neutral.annotation)

  let (square-x, side) = (4.75, 2.15)
  grid(
    (square-x, -side / 2),
    (square-x + side, side / 2),
    step: side / 4,
    stroke: neutral.hairline.lighten(58%) + 0.35pt,
  )
  // one chevron on the horizontal pair, two on the vertical: the usual shorthand for which
  // edge is glued to which, and in which direction
  for (from, to, paint, chevrons) in (
    ((0, 0), (side, 0), seam-color, 1),
    ((0, side), (side, side), seam-color, 1),
    ((0, 0), (0, side), rim-color, 2),
    ((side, 0), (side, side), rim-color, 2),
  ) {
    let at(t) = (
      square-x + from.at(0) + (to.at(0) - from.at(0)) * t,
      -side / 2 + from.at(1) + (to.at(1) - from.at(1)) * t,
    )
    line(at(0), at(1), stroke: paint + edge-weight)
    for idx in range(chevrons) {
      let base = 0.5 + (idx - (chevrons - 1) / 2) * 0.11
      line(
        at(base),
        at(base + 0.012),
        stroke: paint + edge-weight,
        mark: (end: "stealth", fill: paint, scale: 0.6),
      )
    }
  }
  content(
    (square-x - 0.24, 0),
    text(size: annotation-size, fill: rim-color)[$a$],
    anchor: "east",
  )
  content(
    (square-x + side / 2, -side / 2 - 0.16),
    text(size: annotation-size, fill: seam-color)[$b$],
    anchor: "north",
  )
  caption(square-x + side / 2, [fundamental domain])

  // === 3. glue the horizontal pair -> cylinder ===
  step-arrow(7.6, align(center)[glue\ top & bottom], seam-color)

  let (cyl-x, tube-r) = (11.3, 0.62)
  let cyl-axis = straight-axis(2.7)
  draw-tube(cyl-axis, tube-r, 20, 18, (cyl-x, 0))
  // the glued pair is now a single seam running the length of the tube
  draw-visible(
    t => tube-point(cyl-axis, tube-r, t, 0.25),
    t => tube-normal(cyl-axis, t, 0.25),
    24,
    (cyl-x, 0),
    seam-color + edge-weight,
    arrows: (0.46,),
  )
  // the rims are still open: they are the two vertical edges of the square
  for end-u in (0.0, 1.0) {
    draw-visible(
      t => tube-point(cyl-axis, tube-r, end-u, t),
      t => tube-normal(cyl-axis, end-u, t),
      44,
      (cyl-x, 0),
      rim-color + edge-weight,
      arrows: (0.60, 0.635),
    )
  }
  caption(cyl-x, [cylinder])

  // === 4. bend it round and glue the rims -> torus ===
  step-arrow(13.5, align(center)[glue\ rim to rim], rim-color)

  let (torus-x, torus-tube) = (17.1, 0.5)
  let torus-axis = ring-axis(1.32)
  draw-tube(torus-axis, torus-tube, 36, 16, (torus-x, 0))
  // the seam closed into the long way round; the two rims fused into one short circle
  draw-visible(
    t => tube-point(torus-axis, torus-tube, t, 0.25),
    t => tube-normal(torus-axis, t, 0.25),
    72,
    (torus-x, 0),
    seam-color + edge-weight,
    arrows: (0.60,),
  )
  draw-visible(
    t => tube-point(torus-axis, torus-tube, 0.2, t),
    t => tube-normal(torus-axis, 0.2, t),
    44,
    (torus-x, 0),
    rim-color + edge-weight,
    arrows: (0.86, 0.895),
  )
  content(
    (torus-x - 0.1, 1.02),
    text(size: annotation-size, fill: seam-color)[$b$],
    anchor: "south",
  )
  content(
    (torus-x + 1.62, -0.5),
    text(size: annotation-size, fill: rim-color)[$a$],
    anchor: "west",
  )
  caption(torus-x, [torus])
})
