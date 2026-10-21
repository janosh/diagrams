#import "@preview/cetz:0.5.3": canvas, draw, vector
#import draw: circle, content, line, on-layer

#set page(width: auto, height: auto, margin: 5pt, fill: none)
#set text(size: 12pt)

// Atom with 3D shading effect: base circle with a radial gradient overlay
#let atom(pos, color, element, radius, name) = {
  circle(pos, radius: radius, stroke: none, fill: color, name: name)
  circle(pos, radius: radius, stroke: none, fill: gradient.radial(
    color.lighten(85%),
    color,
    color.darken(25%),
    focal-center: (25%, 20%),
    focal-radius: 10%,
    center: (30%, 25%),
  ))
  let text-color = if element in ("C", "N") { white } else { black }
  content(pos, text(
    fill: text-color,
    weight: "bold",
    size: if radius < 0.4 { 12pt } else { 14pt },
    element,
  ))
}

#canvas({
  let colors = (C: rgb("#333"), N: rgb("#3333cc"), O: red.darken(10%), H: rgb("#eee"))

  // Heavy atom positions from the LaTeX source
  let positions = (
    C1: (-3.19, 0.68),
    C2: (-0.78, 0.67),
    C3: (0.47, -0.18),
    C4: (1.73, 0.67),
    N1: (-2.00, -0.15),
    N2: (0.51, -1.32),
    O1: (1.80, 1.88),
    O2: (2.86, -0.07),
  )

  // Hydrogens: LaTeX position, bonded heavy atom, and a nudge separating overlapping
  // hydrogens at the top left and beside the lower N atom
  let hydrogens = (
    H1: ((-2.9, 1.39), "C1", (-0.2, 0.2)),
    H2: ((-3.5, 1.23), "C1", (-0.2, -0.2)),
    H3: ((-3.8, 0.15), "C1", (0, 0)),
    H4: ((-1.7, -0.6), "N1", (0, 0)),
    H5: ((-0.3, 1.4), "C2", (0, 0)),
    H6: ((-1, 1.15), "C2", (0, 0)),
    H7: ((0, -0.7), "C3", (0, 0)),
    H8: ((1, -1.82), "N2", (0.3, -0.2)),
    H9: ((0.2, -1.8), "N2", (-0.3, -0.2)),
    H10: ((3.5, 0.5), "O2", (0, 0)),
  )
  // Push each hydrogen 1.5x further from its bonded atom than in the LaTeX source
  for (name, ((h-x, h-y), bonded, (nudge-x, nudge-y))) in hydrogens {
    let (bonded-x, bonded-y) = positions.at(bonded)
    positions.insert(name, (
      bonded-x + (h-x - bonded-x) * 1.5 + nudge-x,
      bonded-y + (h-y - bonded-y) * 1.5 + nudge-y,
    ))
  }

  for (name, pos) in positions {
    let element = name.first()
    atom(pos, colors.at(element), element, if element == "H" { 0.35 } else { 0.5 }, name)
  }

  // Bonds on a background layer behind the atoms
  let backbone = ("C1", "N1", "C2", "C3", "C4")
  let side-bonds = (
    (("C3", "N2"), ("C4", "O2")) + hydrogens.pairs().map(((name, (_, bonded, _))) => (bonded, name))
  )
  on-layer(-1, {
    for (start, end) in backbone.windows(2) + side-bonds {
      line(positions.at(start), positions.at(end), stroke: (paint: gray, thickness: 3.5pt))
    }
    // Carbonyl C=O double bond: two thinner sticks offset perpendicular to the bond
    let (carbon, oxygen) = (positions.C4, positions.O1)
    let (delta-x, delta-y) = vector.sub(oxygen, carbon)
    let offset = vector.scale(vector.norm((-delta-y, delta-x)), 0.12)
    for sign in (-1, 1) {
      let shift = vector.scale(offset, sign)
      line(vector.add(carbon, shift), vector.add(oxygen, shift), stroke: (
        paint: gray,
        thickness: 2.2pt,
      ))
    }
  })
})
