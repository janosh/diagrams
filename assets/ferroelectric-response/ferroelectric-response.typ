#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, hobby, line, rect, scale, set-origin

// The flat disc underneath is fully covered by the gradient, but drawing both
// doubles up the antialiased rim so the sphere keeps a crisp edge.
#let sphere(pos, radius: 0.25, fill: luma(50), ..args) = {
  circle(pos, radius: radius, stroke: none, fill: fill, ..args)
  circle(pos, radius: radius, stroke: none, fill: gradient.radial(
    fill.lighten(75%),
    fill,
    fill.darken(15%),
    // Offset the highlight to suggest a lit sphere.
    focal-center: (30%, 25%),
    focal-radius: 5%,
    center: (35%, 30%),
  ))
}

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 12pt)

#canvas({
  let arrow-style = (mark: (end: "stealth", fill: black, scale: .75))
  let plot-height = 4
  let plot-width = 10
  let y-offset = 4.5

  let draw-axes(origin, width, height) = {
    line(
      (origin.at(0) - 0.3, origin.at(1)),
      (origin.at(0) + width, origin.at(1)),
      ..arrow-style,
      name: "x-axis",
    )
    line(
      (origin.at(0), origin.at(1) - 0.3),
      (origin.at(0), origin.at(1) + height),
      ..arrow-style,
      name: "y-axis",
    )
  }

  // Top plot: Double-well potential
  let top-origin = (-5, y-offset)
  draw-axes(top-origin, plot-width, plot-height)

  // Draw double-well potential curve using hobby spline
  hobby(
    (top-origin.at(0) + .5, top-origin.at(1) + 4), // start high
    (top-origin.at(0) + 1.7, top-origin.at(1) + 0.4), // left minimum
    (top-origin.at(0) + 1.8, top-origin.at(1) + 0.3), // left minimum
    (top-origin.at(0) + 5, top-origin.at(1) + 1.5), // up to middle peak
    (top-origin.at(0) + 8.2, top-origin.at(1) + 0.3), // right minimum
    (top-origin.at(0) + 8.3, top-origin.at(1) + 0.4), // right minimum
    (top-origin.at(0) + 9.5, top-origin.at(1) + 4), // up high again
    omega: 0,
    name: "potential-curve",
    stroke: 1.5pt,
  )

  content("y-axis.mid", [Free Energy], angle: 90deg, anchor: "south", padding: (
    0,
    0,
    2pt,
  ))

  // Bottom plot: Polarization vs. displacement
  let bottom-origin = (-5, 0)
  draw-axes(bottom-origin, plot-width, plot-height)

  // zero lines
  line(
    (bottom-origin.at(0), bottom-origin.at(1) + plot-height / 2),
    (bottom-origin.at(0) + plot-width, bottom-origin.at(1) + plot-height / 2),
    stroke: gray + 0.5pt,
  )
  line(
    (bottom-origin.at(0) + plot-width / 2, bottom-origin.at(1)),
    (bottom-origin.at(0) + plot-width / 2, bottom-origin.at(1) + plot-height),
    stroke: gray + 0.5pt,
  )

  // Add x-axis labels
  content(
    (bottom-origin.at(0), bottom-origin.at(1)),
    [negative],
    anchor: "north-west",
    padding: (4pt, 2pt, 0),
    name: "neg-label",
  )
  content(
    (bottom-origin.at(0) + 8.5, bottom-origin.at(1)),
    [positive],
    anchor: "north-west",
    padding: (4pt, 2pt, 0),
    name: "pos-label",
  )

  line(
    (bottom-origin.at(0), bottom-origin.at(1)),
    (bottom-origin.at(0) + plot-width, bottom-origin.at(1) + plot-height),
    stroke: blue + 1.5pt,
    name: "polarization-line",
  )

  content("y-axis.mid", [Polarization], angle: 90deg, anchor: "south", padding: 4pt)
  content("x-axis.mid", [Ti Displacement], anchor: "north", padding: (
    10pt,
    0,
    0,
  ))

  let atom = sphere.with(radius: 0.20)
  let draw-unit-cell(center_x, center_y, ti_y) = {
    let back = -1.0
    let corners = ((-1, -1), (1, -1), (-1, 1), (1, 1))
    let barium = atom.with(fill: rgb("#00ffff"))
    let oxygen = atom.with(fill: red)
    let bond(end) = line(
      ((center_x, center_y + ti_y, back / 2), 15%, end),
      ((center_x, center_y + ti_y, back / 2), 85%, end),
      stroke: 1pt,
    )

    rect((center_x - 1, center_y - 1, 0), (center_x + 1, center_y + 1, 0), stroke: 0.7pt)
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
      let shift(pos) = (center_x + pos.at(0), center_y + pos.at(1), ..pos.slice(2))
      line(shift(start), shift(end), stroke: 0.7pt)
    }

    // Back plane, then the middle plane, then the front plane: preserve occlusion.
    for (offset_x, offset_y) in corners {
      barium((center_x + offset_x, center_y + offset_y, back))
    }
    oxygen((center_x, center_y, back))
    bond((center_x, center_y, back))

    if ti_y >= 0 { bond((center_x, center_y + 1, back / 2)) }
    if ti_y <= 0 { bond((center_x, center_y - 1, back / 2)) }
    bond((center_x - 1, center_y, back / 2))
    bond((center_x + 1, center_y, back / 2))
    for (offset_x, offset_y) in ((0, 1), (0, -1), (-1, 0), (1, 0)) {
      oxygen((center_x + offset_x, center_y + offset_y, back / 2))
    }
    atom((center_x, center_y + ti_y, back / 2), fill: gray)

    bond((center_x, center_y, 0))
    for (offset_x, offset_y) in corners {
      barium((center_x + offset_x, center_y + offset_y, 0))
    }
    oxygen((center_x, center_y, 0))
  }

  scale(0.64)
  set-origin("potential-curve.mid")
  draw-unit-cell(-4.5, 2, -0.2)
  draw-unit-cell(-0.5, 2, 0)
  draw-unit-cell(3.5, 2, 0.2)
})
