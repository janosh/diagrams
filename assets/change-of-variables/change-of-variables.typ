// Spherical geometry based on Juan Falgueras-Cano's volume-element illustration.
#import "@preview/cetz:0.5.2": canvas, draw
#import draw: arc, circle, content, line, merge-path, on-xy, on-xz, rect, rotate, scope

#let ink = rgb("172b4d")
#let muted = rgb("64748b")
#let blue = rgb("2563eb")
#let teal = rgb("0f766e")
#let amber = rgb("b45309")
#let guide = rgb("cbd5e1")
#set page(width: 1000pt, height: auto, margin: 28pt, fill: none)
#set text(font: "Avenir Next", size: 14pt, fill: ink)
#set par(leading: .45em, spacing: 0pt)

#let arrow(paint) = (end: "stealth", fill: paint, stroke: none, length: 5pt, width: 3.5pt)
#let card(title, mapping, artwork, factors, result, caption) = block(
  width: 100%,
  inset: 16pt,
  radius: 10pt,
  stroke: rgb("e2e8f0") + .7pt,
  fill: rgb("f8fafc"),
  breakable: false,
)[
  #text(size: 21pt, weight: "bold", title)
  #v(9pt)
  #box(height: 54pt, width: 100%)[#align(center + horizon, text(size: 18pt, mapping))]
  #v(6pt)
  #box(height: 220pt, width: 100%)[
    #align(center + horizon, layout(size => {
      let artwork = text(size: 14pt, artwork)
      let bounds = measure(artwork)
      let factor = calc.min(size.width / bounds.width, 210pt / bounds.height)
      std.scale(factor * 100%, reflow: true, artwork)
    }))
  ]
  #v(8pt)
  #align(center, text(size: 18pt, factors))
  #v(11pt)
  #block(width: 100%, inset: 10pt, radius: 6pt, fill: rgb("e8eef8"))[
    #align(center, text(size: 24pt, result))
  ]
  #v(11pt)
  #box(height: 100pt, width: 100%)[#text(size: 17pt, caption)]
]

// theta is colatitude from +z; phi is azimuth in the xy plane.
#let spherical(radius, theta, phi) = (
  radius * calc.sin(theta) * calc.cos(phi),
  radius * calc.sin(theta) * calc.sin(phi),
  radius * calc.cos(theta),
)
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


// === Linear scaling: the original square example ===
#let linear_artwork = canvas(length: 1cm, {
  let axis_stroke = (paint: muted, thickness: .7pt)
  for (origin_x, extent, horizontal, vertical) in (
    (0, 1.3, $u$, $v$),
    (3, 2.3, $x$, $y$),
  ) {
    line((origin_x - .2, 0), (origin_x + extent, 0), stroke: axis_stroke, mark: arrow(muted))
    line((origin_x, -.2), (origin_x, extent), stroke: axis_stroke, mark: arrow(muted))
    content((origin_x + extent, -.18), horizontal, anchor: "north", padding: 0)
    content((origin_x - .18, extent - .5), vertical, anchor: "east", padding: 0)
  }
  rect((0, 0), (1, 1), fill: blue.transparentize(88%), stroke: blue + 1.3pt)
  rect((3, 0), (5, 2), fill: blue.transparentize(88%), stroke: blue + 1.3pt)
  content((.5, .5), text(blue)[$1$])
  content((4, 1), text(blue)[$4$])
  content((.5, 1.4), $"unit area"$, anchor: "south")
  content((4, 2.4), $"scaled area"$, anchor: "south")
  line((1.45, .65), (2.5, .65), stroke: ink + .9pt, mark: arrow(ink))
  content((1.97, .92), $f$, anchor: "south")
  line((3, -.5), (5, -.5), stroke: teal + 1.2pt, mark: (start: arrow(teal).end, ..arrow(teal)))
  content((4, -.7), text(teal)[$2 dif u$], anchor: "north")
  line((5.5, 0), (5.5, 2), stroke: blue + 1.2pt)
  content((5.7, 1), text(blue)[$2 dif v$], anchor: "west")
})

// === Polar coordinates: a curved area cell ===
#let polar_point(radius, phi) = (radius * calc.cos(phi), radius * calc.sin(phi))
#let polar_artwork = canvas(length: 1cm, {
  let (radius_min, radius_max) = (2, 2.8)
  let (phi_min, phi_max) = (25deg, 58deg)
  let axis_stroke = (paint: muted, thickness: .7pt)
  line((0, 0), (3.4, 0), stroke: axis_stroke, mark: arrow(muted))
  line((0, 0), (0, 3.1), stroke: axis_stroke, mark: arrow(muted))
  content((3.5, 0), $x$, anchor: "west")
  content((0, 3.2), $y$, anchor: "south")
  merge-path(close: true, fill: blue.transparentize(87%), stroke: none, {
    line(polar_point(radius_min, phi_min), polar_point(radius_max, phi_min))
    arc((0, 0), radius: radius_max, start: phi_min, stop: phi_max, anchor: "origin")
    line(polar_point(radius_max, phi_max), polar_point(radius_min, phi_max))
    arc((0, 0), radius: radius_min, start: phi_max, stop: phi_min, anchor: "origin")
  })
  for phi in (phi_min, phi_max) {
    line((0, 0), polar_point(radius_min, phi), stroke: (
      paint: guide,
      dash: "dashed",
      thickness: .6pt,
    ))
    line(polar_point(radius_min, phi), polar_point(radius_max, phi), stroke: teal + 1.6pt)
  }
  for radius in (radius_min, radius_max) {
    arc(
      (0, 0),
      radius: radius,
      start: phi_min,
      stop: phi_max,
      anchor: "origin",
      stroke: blue + 1.6pt,
    )
  }
  line((0, 0), polar_point(radius_min, phi_max), stroke: muted + .8pt)
  content(polar_point(1.2, phi_max), $r$, anchor: "east", padding: .12)
  let point = polar_point(radius_min, phi_min)
  let foot = (point.at(0), 0)
  line((0, 0), foot, stroke: muted + .9pt)
  line(foot, point, stroke: (paint: muted, dash: "dotted", thickness: .7pt))
  circle(point, radius: .045, fill: ink, stroke: none)
  content(point, $P$, anchor: "south-east", padding: .08)
  content((point.at(0) / 2, 0), text(muted)[$x$], anchor: "north", padding: .12)
  content((point.at(0), point.at(1) / 2), text(muted)[$y$], anchor: "east", padding: .1)
  arc((0, 0), radius: .65, start: 0deg, stop: phi_min, anchor: "origin", stroke: amber + .9pt)
  content(polar_point(.9, phi_min / 2), text(amber)[$phi$], padding: 0)
  content(polar_point(2.4, phi_min), text(teal)[$dif r$], anchor: "north", padding: .2)
  content(
    polar_point(radius_max, (phi_min + phi_max) / 2),
    text(blue)[$r dif phi$],
    anchor: "south-west",
    padding: .18,
  )
  arc((0, 0), radius: 1.5, start: phi_min, stop: phi_max, anchor: "origin", stroke: amber + .9pt)
  content(polar_point(1.25, (phi_min + phi_max) / 2), text(amber)[$dif phi$], padding: 0)
})

// === Spherical coordinates: an enlarged local volume cell ===
#let spherical_artwork = canvas(length: 1cm, {
  let (radius_min, radius_max) = (2.3, 3.1)
  let (theta_min, theta_max) = (45deg, 75deg)
  let (phi_min, phi_max) = (42deg, 78deg)
  let ring = (
    (radius_max, theta_min, phi_max),
    (radius_max, theta_max, phi_max),
    (radius_min, theta_max, phi_max),
    (radius_min, theta_max, phi_min),
    (radius_min, theta_min, phi_min),
    (radius_max, theta_min, phi_min),
  )
  let far_corner = (radius_min, theta_min, phi_max)
  let near_corner = (radius_max, theta_max, phi_min)
  scope({
    rotate(x: -80deg)
    rotate(z: -120deg)
    merge-path(close: true, fill: blue.transparentize(90%), stroke: none, {
      for (idx, start) in ring.enumerate() {
        edge(start, ring.at(calc.rem(idx + 1, ring.len())))
      }
    })
    // All radial construction rays meet at the sphere's center, the coordinate origin.
    for point in (ring.at(4), far_corner, ring.at(2), ring.at(3)) {
      line((0, 0, 0), spherical(..point), stroke: (
        paint: guide,
        dash: "dotted",
        thickness: .7pt,
      ))
    }
    for (idx, start, end) in (
      (0, far_corner, ring.at(0)),
      (1, far_corner, ring.at(4)),
      (2, far_corner, ring.at(2)),
    ) {
      edge(start, end, stroke: (
        paint: (teal, blue, amber).at(idx).transparentize(55%),
        dash: "dashed",
        thickness: 1pt,
      ))
    }
    for (idx, start) in ring.enumerate() {
      let end = ring.at(calc.rem(idx + 1, ring.len()))
      let paint = if start.at(0) != end.at(0) { teal } else if start.at(1) != end.at(1) {
        amber
      } else { blue }
      edge(start, end, stroke: paint + 1.6pt)
      if calc.odd(idx) {
        let paint = if start.at(0) != near_corner.at(0) { teal } else if (
          start.at(1) != near_corner.at(1)
        ) { amber } else { blue }
        edge(start, near_corner, stroke: paint + 1.6pt)
      }
    }
    content(spherical(2.7, theta_min, phi_min), text(teal)[$dif r$], anchor: "east", padding: .2)
    content(
      spherical(radius_max, 60deg, phi_max),
      text(amber)[$r dif theta$],
      anchor: "west",
      padding: .2,
    )
    content(
      spherical(radius_min, theta_max, 60deg),
      text(blue)[$r sin theta dif phi$],
      anchor: "north",
      padding: .25,
    )
    content(spherical(2.7, 59deg, 58deg), text(ink)[$dif V$], padding: 0)
    content(spherical(1.3, theta_min, phi_min), text(muted)[$r$], anchor: "east", padding: .1)
  })
  circle((0, 0), radius: .035, fill: muted, stroke: none)
  content((0, 0), text(muted)[$O$], anchor: "north-east", padding: .1)
})

#text(size: 32pt, weight: "bold")[Change of variables]
#v(7pt)
#text(
  size: 16pt,
  fill: muted,
)[The Jacobian measures how a tiny coordinate cell changes area or volume.]
#v(18pt)
#block(width: 100%, inset: 14pt, radius: 8pt, fill: rgb("edf3fa"))[
  #align(center, text(size: 24pt)[$
    integral_(f(U)) g(bold(x)) dif bold(x)
    = integral_U g(f(bold(u))) abs(det J_f(bold(u))) dif bold(u)
  $])
]
#v(18pt)
#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 14pt,
  card(
    [Linear scaling],
    [$x = 2u, quad y = 2v$],
    linear_artwork,
    [#text(teal)[$2$] $times$ #text(blue)[$2$] $= abs(det J_f) = 4$],
    [$dif A = 4 dif u dif v$],
    [Each side doubles, so area grows by four. Reflecting one axis gives $det J_f = -4$; the area factor stays $4$.],
  ),
  card(
    [Polar coordinates],
    [$x = r cos phi, quad y = r sin phi$],
    polar_artwork,
    [#text(teal)[$1$] $times$ #text(blue)[$r$] $= abs(det J_f) = r$],
    [$dif A = r dif r dif phi$],
    [The angular side is arc length $r dif phi$. Multiply it by the radial thickness $dif r$ to get the area element.],
  ),
  card(
    [Spherical coordinates],
    [$x = r sin theta cos phi$ #linebreak() $y = r sin theta sin phi, quad z = r cos theta$],
    spherical_artwork,
    [#text(teal)[$1$] $times$ #text(amber)[$r$] $times$ #text(
        blue,
      )[$r sin theta$] $= r^2 sin theta$],
    [$dif V = r^2 sin theta dif r dif theta dif phi$],
    [Meridians have radius $r$; latitude circles have radius $r sin theta$. Their arc lengths supply the two angular factors.],
  ),
)
#v(17pt)
#grid(
  columns: (1fr, 1fr),
  gutter: 25pt,
  text(
    size: 15pt,
  )[*Use the absolute determinant.* Orientation can flip; an area or volume measure stays nonnegative. The map $f$ is one-to-one on $U$.],
  text(
    size: 15pt,
    fill: muted,
  )[Angles are in radians; $theta$ is measured from $+z$. Cells are enlarged for clarity; labeled lengths describe the infinitesimal limit.],
)
