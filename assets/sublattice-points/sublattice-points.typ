#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, line, on-layer

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#canvas({
  let spacing = 0.6 // half the lattice constant

  // One color per coset of the index-8 sublattice spanned by (2, 1) and (0, 4)
  let colors = (
    rgb("#4040d9"), // blue
    rgb("#90EE90"), // light green
    rgb("#006400"), // dark green
    rgb("#9ACD32"), // yellow green
    rgb("#FFA500"), // orange
    rgb("#FF0000"), // red
    rgb("#000000"), // black
    rgb("#800080"), // purple
  )

  for ii in range(5) {
    for jj in range(8) {
      // ii - 2 jj is invariant under both sublattice translations (mod 8)
      let color = colors.at(calc.rem-euclid(ii - 2 * jj, colors.len()))
      // Flat disc with a darker rim, which survives the site's dark-mode inversion
      circle(
        (2 * ii * spacing, 2 * jj * spacing),
        radius: 0.12,
        stroke: color.darken(35%) + 0.4pt,
        fill: color,
        name: str(ii) + "," + str(jj),
      )
    }
  }

  let arrow-style = (mark: (end: "stealth", fill: black, scale: .5), stroke: 1pt)
  on-layer(-1, {
    line("0,0", "2,1", ..arrow-style)
    line("0,0", "0,4", ..arrow-style)
    line("2,1", "2,5")
    line("0,4", "2,5")
  })
})
