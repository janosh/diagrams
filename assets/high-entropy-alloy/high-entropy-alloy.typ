#import "@preview/cetz:0.5.3": canvas, draw
#import draw: circle, content

#set page(width: auto, height: auto, margin: 5pt, fill: none)
#set text(size: 12pt)

// The flat disc underneath is fully covered by the gradient, but drawing both
// doubles up the antialiased rim so the sphere keeps a crisp edge.
#let atom(pos, fill, element: none, label-fill: white) = {
  circle(pos, radius: 0.3, stroke: none, fill: fill)
  circle(pos, radius: 0.3, stroke: none, fill: gradient.radial(
    (fill.lighten(40%), 0%),
    (fill, 75%),
    (fill.darken(15%), 100%),
    // A broad, subdued highlight gives soft lighting without a white hotspot.
    focal-center: (30%, 25%),
    focal-radius: 0%,
    center: (50%, 50%),
  ))
  if element != none { content(pos, text(fill: label-fill, weight: "bold", element)) }
}

#canvas({
  let colors = (
    Al: rgb("#cc3333"),
    Co: rgb("#3333cc"),
    Cr: rgb("#006666"),
    Fe: rgb("#cc8000"),
    Ni: rgb("#aaaaee"),
  )
  // Deterministic position hash scatters the five elements across lattice sites.
  let hash-order = ("Al", "Cr", "Co", "Fe", "Ni")
  let site-color(i, j, k) = colors.at(hash-order.at(calc.rem(i * 3 + j * 5 + k * 7, 5)))

  // Oblique projection: deeper layers j shift down and to the right.
  let (x-factor, y-factor, z-spacing) = (0.3, -0.18, 1.1)
  for i in range(12) {
    for j in range(4) {
      // Corner sites, then body-center sites offset by half a cell.
      for k in range(4) {
        atom((-i + x-factor * j, y-factor * j + z-spacing * k), site-color(i, j, k))
      }
      for k in range(3) {
        atom((-i + 0.5 + x-factor * j, y-factor * j + z-spacing * k + 0.65), site-color(
          i,
          j,
          k + 10,
        ))
      }
    }
  }

  for (idx, (element, color)) in colors.pairs().enumerate() {
    // White on the light Fe and Ni spheres is only 3.2:1 and 2.2:1, so they get black labels.
    let label-fill = if element in ("Fe", "Ni") { black } else { white }
    atom((2.5, 3 - idx * 0.8), color, element: element, label-fill: label-fill)
  }
})
