#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, group, hobby, line, rect, scale, set-origin

// Flat discs with a darker rim: a lit-sphere highlight would invert into a dark pit under the
// site's dark-mode filter.
#let sphere(pos, radius: 0.25, fill: luma(50), ..args) = circle(
  pos,
  radius: radius,
  fill: fill,
  stroke: fill.darken(35%) + 0.6pt,
  ..args,
)

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 12pt)

#canvas({
  let arrow-style = (mark: (end: "stealth", fill: black, scale: .75))
  let plot-height = 4
  let plot-width = 10
  let y-offset = 4.5
  // Both plots share the left edge; the top one sits y-offset above the bottom one.
  let (x0, y0) = (-5, 0)

  let draw-axes((x0, y0)) = {
    line((x0 - 0.3, y0), (x0 + plot-width, y0), ..arrow-style, name: "x-axis")
    line((x0, y0 - 0.3), (x0, y0 + plot-height), ..arrow-style, name: "y-axis")
  }

  // Top plot: double-well free energy as a hobby spline through both minima and the central barrier
  let (top-x, top-y) = (x0, y0 + y-offset)
  draw-axes((top-x, top-y))
  let well-points = ((.5, 4), (1.7, 0.4), (1.8, 0.3), (5, 1.5), (8.2, 0.3), (8.3, 0.4), (9.5, 4))
  hobby(
    ..well-points.map(((dx, dy)) => (top-x + dx, top-y + dy)),
    omega: 0,
    name: "potential-curve",
    stroke: 1.5pt,
  )
  content("y-axis.mid", [Free Energy], angle: 90deg, anchor: "south", padding: (0, 0, 2pt))

  // Bottom plot: polarization grows linearly with Ti displacement through the origin
  draw-axes((x0, y0))
  // zero lines
  line((x0, y0 + plot-height / 2), (x0 + plot-width, y0 + plot-height / 2), stroke: gray + 0.5pt)
  line((x0 + plot-width / 2, y0), (x0 + plot-width / 2, y0 + plot-height), stroke: gray + 0.5pt)
  for (dx, label) in ((0, [negative]), (8.5, [positive])) {
    content((x0 + dx, y0), label, anchor: "north-west", padding: (4pt, 2pt, 0))
  }
  line((x0, y0), (x0 + plot-width, y0 + plot-height), stroke: blue + 1.5pt)
  content("y-axis.mid", [Polarization], angle: 90deg, anchor: "south", padding: 4pt)
  content("x-axis.mid", [Ti Displacement], anchor: "north", padding: (10pt, 0, 0))

  let atom = sphere.with(radius: 0.20)
  // BaTiO3 perovskite cell around the origin: Ba on the corners, O on the face centers, Ti
  // displaced by ti_y.
  let draw-unit-cell(ti_y) = {
    let back = -1.0
    let corners = ((-1, -1), (1, -1), (-1, 1), (1, 1))
    let barium = atom.with(fill: rgb("#00ffff"))
    let oxygen = atom.with(fill: red)
    let ti-pos = (0, ti_y, back / 2)
    let bond(end) = line((ti-pos, 15%, end), (ti-pos, 85%, end), stroke: 1pt)

    rect((-1, -1, 0), (1, 1, 0), stroke: 0.7pt)
    for (start, end) in (
      ((-1, -1, 0), (-1, -1, back)),
      ((1, -1, 0), (1, -1, back)),
      ((-1, -1, back), (1, -1, back)),
      ((-1, 1, back), (1, 1, back)),
      ((-1, -1, back), (-1, 1, back)),
      ((1, -1, back), (1, 1, back)),
      ((1, 1), (1, 1, back)),
      ((-1, 1), (-1, 1, back)),
    ) {
      line(start, end, stroke: 0.7pt)
    }

    // Back plane, then the middle plane, then the front plane: preserve occlusion.
    for corner in corners { barium((..corner, back)) }
    oxygen((0, 0, back))
    bond((0, 0, back))

    // Ti bonds only to the apical O it moves toward (both when centered).
    if ti_y >= 0 { bond((0, 1, back / 2)) }
    if ti_y <= 0 { bond((0, -1, back / 2)) }
    bond((-1, 0, back / 2))
    bond((1, 0, back / 2))
    for offset in ((0, 1), (0, -1), (-1, 0), (1, 0)) { oxygen((..offset, back / 2)) }
    // Darker than Typst's gray so the displaced Ti stays visible under the dark-mode filter
    atom(ti-pos, fill: luma(130))

    bond((0, 0, 0))
    for corner in corners { barium((..corner, 0)) }
    oxygen((0, 0, 0))
  }

  scale(0.64)
  set-origin("potential-curve.mid")
  for (center_x, ti_y) in ((-4.5, -0.2), (-0.5, 0), (3.5, 0.2)) {
    group({
      set-origin((center_x, 2))
      draw-unit-cell(ti_y)
    })
  }
})
