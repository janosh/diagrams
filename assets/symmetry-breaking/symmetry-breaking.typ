#import "@preview/cetz:0.5.2": canvas, draw, matrix
#import draw: circle, content, line, on-layer, rotate, scale, set-style, set-transform, translate
#let label-size = 12pt
#let paragraph-size = 14pt
#let heading-size = 16pt

#let card_body(title, body, caption) = block(
  width: 100%,
  inset: 12pt,
  radius: 8pt,
  fill: rgb("#cdd3da"),
  breakable: false,
)[
  #text(size: heading-size, weight: "bold", title)
  #v(8pt)
  // Measure unconstrained artwork before scaling, including content wider than its card.
  #layout(size => {
    let artwork = text(size: label-size, body)
    std.scale(size.width / measure(artwork).width * 100%, reflow: true, artwork)
  })
  #v(7pt)
  #text(size: paragraph-size, caption)
]

#let card-grid(columns: 2, ..cards) = layout(size => {
  let rows = cards
    .pos()
    .chunks(columns)
    .map(row => {
      let ratios = row.map(card => {
        let bounds = measure(text(size: label-size, card.at(1)))
        bounds.width / bounds.height
      })
      let available = size.width - 12pt * (row.len() - 1) - 24pt * row.len()
      grid(
        columns: ratios.map(ratio => 24pt + available * ratio / ratios.sum()),
        gutter: 12pt,
        ..row.map(args => card_body(..args)),
      )
    })
  stack(dir: ttb, spacing: 12pt, ..rows)
})

#let takeaway(body) = block(
  width: 100%,
  inset: 12pt,
  radius: 6pt,
  fill: rgb("#c6d8d2"),
  breakable: false,
  text(size: paragraph-size, body),
)

#set page(width: 780pt, height: auto, margin: 22pt, fill: none)
#set text(font: "Avenir Next", size: paragraph-size, fill: rgb("#19324f"))
#set par(leading: 0.55em)

// === 1  A ring of minima ===
// Mexican-hat potential V = (r^2 - 1)^2 at polar coordinates (radius, theta in degrees)
#let surface-point(radius, theta-deg) = {
  let theta = theta-deg * 1deg
  (calc.sin(theta) * radius, calc.cos(theta) * radius, calc.pow(radius * radius - 1.0, 2))
}

#let figure-0 = text(fill: black, canvas(length: 1.55cm, {
  set-transform(matrix.transform-rotate-dir((2.5, 0.6, -2), (0, 1, 0.3)))
  // z must scale positive: negating it turns the hat's central bump into a pit, which
  // puts the symmetric vacuum below the broken one and points the downhill arrow uphill
  scale(x: 3, y: 3, z: 2.5)
  rotate(z: -5deg)
  translate((0, -0.02, 0))

  // Surface mesh painted from the outer ring inward; the innermost ring degenerates into
  // triangles at the apex, drawn once more to keep the apex outlines crisp.
  let (radius-max, radius-steps, angle-steps) = (1.25, 24, 84)
  let radius-step = radius-max / radius-steps
  let angle-step = 360.0 / angle-steps
  set-style(stroke: rgb("#1a1a1a") + 0.22pt, fill: rgb("#cdd3da"))
  for radius-idx in range(radius-steps).rev() {
    let radius-inner = radius-idx * radius-step
    for angle-idx in range(angle-steps) {
      let theta-left = angle-idx * angle-step
      line(
        surface-point(radius-inner, theta-left),
        surface-point(radius-inner, theta-left + angle-step),
        surface-point(radius-inner + radius-step, theta-left + angle-step),
        surface-point(radius-inner + radius-step, theta-left),
        close: true,
      )
    }
  }
  let apex-point = surface-point(0.0, 0.0)
  for angle-idx in range(angle-steps) {
    let theta-left = angle-idx * angle-step
    line(
      apex-point,
      surface-point(radius-step, theta-left),
      surface-point(radius-step, theta-left + angle-step),
      close: true,
    )
  }

  // Axis lines centered at the origin.
  on-layer(-2, {
    let axis-color = rgb("#1f1f1f")
    set-style(stroke: axis-color + 0.22pt, mark: (
      fill: axis-color,
      stroke: axis-color,
      scale: 0.52,
      end: "stealth",
    ))
    line((-1.6, 0, 0), (1.6, 0, 0))
    line((0, -1.6, 0), (0, 1.6, 0))
    line((0, 0, 0.0), (0, 0, 1.3))
  })
  on-layer(8, {
    content((1.42, 0.6, 0.02), $phi_1$, anchor: "west")
    content((-0.7, -0.95, -0.02), $phi_2$, anchor: "north")
    content((0.02, 0.02, 1.47), $V(phi)$, anchor: "south")
  })

  // Symmetric (unstable) state at the apex and one selected minimum on the ring.
  circle(apex-point, radius: 0.09, fill: rgb("#00008b"), stroke: none)
  circle(surface-point(1.0, 30.0), radius: 0.09, fill: rgb("#8b0000"), stroke: none)

  // Double downhill arrow sampling the surface profile at fixed bearings, lifted clear of the mesh.
  on-layer(9, {
    let (radius-start, radius-stop, arrow-steps) = (0.03, 1.02, 40)
    let downhill-arrow(theta-deg) = line(
      ..range(arrow-steps + 1).map(step => {
        let (coord_x, coord_y, height) = surface-point(
          radius-start + step / arrow-steps * (radius-stop - radius-start),
          theta-deg,
        )
        (coord_x, coord_y, height + 0.05)
      }),
    )
    // stroked twice: a thick pale body, then a thin dark core to crisp the edges
    for (paint, thickness, scale) in (
      (rgb("#c4c4c4"), 1.1pt, 0.56),
      (rgb("#575757"), 0.42pt, 0.44),
    ) {
      set-style(
        stroke: (paint: paint, thickness: thickness),
        fill: none,
        mark: (fill: paint, stroke: paint, scale: scale, end: "stealth"),
      )
      for theta in (28.8, 32.8) { downhill-arrow(theta) }
    }
  })
}))

// === 2  Radial and angular directions ===
#let figure-1 = canvas(length: 1.63cm, {
  let (radial-color, angular-color) = (rgb("#c2570a"), blue)
  draw.circle((0, 0), radius: 2, stroke: rgb("#008580") + 2pt)
  draw.circle((0, 0), radius: .07, fill: gray)
  draw.circle((2, 0), radius: .12, fill: radial-color)
  draw.line((2, 0), (3.1, 0), stroke: radial-color + 1.5pt, mark: (end: "stealth"))
  draw.arc(
    (0, 0),
    radius: 2,
    start: 0deg,
    stop: 45deg,
    anchor: "origin",
    stroke: angular-color + 1.5pt,
    mark: (end: "stealth"),
  )
  draw.content((2.15, -.15), text(fill: radial-color)[radial: uphill], anchor: "north-west")
  draw.content((1.2, 2.3), text(fill: angular-color)[angular: along the valley])
  draw.content((0, -2.35), [$V=0$ on the ring])
})

A symmetric energy landscape can have an entire family of equally good minima. Choosing one ground state need not preserve the symmetry of the equations.
#v(14pt)
#card-grid(
  (
    [1  A ring of minima],
    figure-0,
    [The peak at zero field is unstable; all points around the valley have the same potential energy. The selected red point breaks the rotational symmetry of this picture.],
  ),
  (
    [2  Radial and angular directions],
    figure-1,
    [For a global continuous symmetry, angular motion along the valley gives a massless Goldstone mode. Radial motion climbs the potential and costs energy.],
  ),
)
#v(12pt)
#takeaway[*Higgs application:* in a gauge theory the would-be Goldstone modes supply longitudinal polarizations of massive gauge bosons; a radial Higgs excitation remains. The potential alone does not show the gauge-field dynamics.\ $V(phi)=lambda (abs(phi)^2-v^2)^2$, with $lambda>0$.]
