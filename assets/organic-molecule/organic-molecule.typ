#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, line, on-layer

#set page(width: auto, height: auto, margin: 5pt, fill: none)

// Atom with 3D shading effect
#let atom(pos, color, element, radius: 0.3, name: none) = {
  // Base circle with main color
  circle(pos, radius: radius, stroke: none, fill: color, name: name)

  // Gradient overlay for 3D effect
  circle(pos, radius: radius, stroke: none, fill: gradient.radial(
    color.lighten(85%),
    color,
    color.darken(25%),
    focal-center: (25%, 20%),
    focal-radius: 10%,
    center: (30%, 25%),
  ))

  let text-color = if color == rgb("#333333") { white } else { black }

  // Calculate text size based on radius
  let text-size = if radius < 0.4 { 10pt } else { 14pt }

  content(
    pos,
    text(fill: text-color, weight: "bold", size: text-size)[#element],
    anchor: "center",
  )
}

#canvas({
  let hydrogen-color = rgb("#eee")
  let carbon-color = rgb("#333")
  let nitrogen-color = rgb("#3333cc")
  let oxygen-color = red.darken(10%)

  // Define atom sizes - increased to match target image
  let h-radius = 0.35
  let heavy-radius = 0.5

  // Adjust hydrogen positions to be further from connected atoms
  // Original positions from LaTeX
  let orig-h-positions = (
    ("H1", (-2.9, 1.39)),
    ("H2", (-3.5, 1.23)),
    ("H3", (-3.8, 0.15)),
    ("H4", (-1.7, -0.6)),
    ("H5", (-0.3, 1.4)),
    ("H6", (-1, 1.15)),
    ("H7", (0, -0.7)),
    ("H8", (1, -1.82)),
    ("H9", (0.2, -1.8)),
    ("H10", (3.5, 0.5)),
  )

  // Heavy atom positions
  let c-positions = (
    ("C1", (-3.19, 0.68)),
    ("C2", (-0.78, 0.67)),
    ("C3", (0.47, -0.18)),
    ("C4", (1.73, 0.67)),
  )

  let n-positions = (
    ("N1", (-2.00, -0.15)),
    ("N2", (0.51, -1.32)),
  )

  let o-positions = (
    ("O1", (1.80, 1.88)),
    ("O2", (2.86, -0.07)),
  )

  // Function to move hydrogen atoms further from their connected atoms
  let adjust-h-position(h-pos, connected-pos, factor: 1.5) = {
    let (hx, hy) = h-pos
    let (cx, cy) = connected-pos
    let dx = hx - cx
    let dy = hy - cy
    let dist = calc.sqrt(dx * dx + dy * dy)
    let new-dist = dist * factor
    let scale = new-dist / dist
    (cx + dx * scale, cy + dy * scale)
  }

  // Connection map: which hydrogen connects to which heavy atom
  let h-connections = (
    "H1": "C1",
    "H2": "C1",
    "H3": "C1",
    "H4": "N1",
    "H5": "C2",
    "H6": "C2",
    "H7": "C3",
    "H8": "N2",
    "H9": "N2",
    "H10": "O2",
  )

  // Combine all heavy atom positions for lookup
  let heavy-atoms = (:)
  for (name, pos) in c-positions + n-positions + o-positions { heavy-atoms.insert(name, pos) }

  // Adjust hydrogen positions
  let h-positions = (:)
  for (name, pos) in orig-h-positions {
    let connected-atom = h-connections.at(name)
    let connected-pos = heavy-atoms.at(connected-atom)
    h-positions.insert(name, adjust-h-position(pos, connected-pos))
  }

  // Separate overlapping hydrogens at the top left and beside the right N atom.
  for (name, shift_x, shift_y) in (
    ("H1", -0.2, 0.2),
    ("H2", -0.2, -0.2),
    ("H8", 0.3, -0.2),
    ("H9", -0.3, -0.2),
  ) {
    let (coord_x, coord_y) = h-positions.at(name)
    h-positions.insert(name, (coord_x + shift_x, coord_y + shift_y))
  }

  for (positions, color, element, radius) in (
    (c-positions, carbon-color, "C", heavy-radius),
    (n-positions, nitrogen-color, "N", heavy-radius),
    (o-positions, oxygen-color, "O", heavy-radius),
    (h-positions.pairs(), hydrogen-color, "H", h-radius),
  ) {
    for (name, pos) in positions { atom(pos, color, element, radius: radius, name: name) }
  }

  // bonds on a background layer (behind atoms); resolve H vs heavy-atom lookups
  let pos-of(name) = if name.starts-with("H") { h-positions.at(name) } else {
    heavy-atoms.at(name)
  }
  let chain = ("H1", "C1", "N1", "C2", "C3", "C4", "O1")
  let bonds = (
    chain.windows(2)
      + (
        ("H2", "C1"),
        ("H3", "C1"),
        ("N1", "H4"),
        ("C2", "H5"),
        ("C2", "H6"),
        ("C3", "H7"),
        ("C3", "N2"),
        ("N2", "H8"),
        ("N2", "H9"),
        ("C4", "O2"),
        ("O2", "H10"),
      )
  )
  on-layer(-1, {
    for (from, to) in bonds {
      line(pos-of(from), pos-of(to), stroke: (paint: gray, thickness: 3.5pt))
    }
  })
})
