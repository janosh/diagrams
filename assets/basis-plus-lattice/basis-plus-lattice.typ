#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, group, rect

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
#set text(size: 14pt)

#let atom(pos, color) = sphere(pos, fill: color)

#canvas({
  // Constants for layout
  let (spacing, motif-x) = (4, 1)
  let (lattice-x, crystal-x) = (spacing, 2 * spacing)

  group({
    atom((motif-x, 0.8), blue)
    atom((motif-x + .5, 1.3), red)
  })
  content((motif-x, -1), text(size: 14pt)[Motif/Basis])

  // Plus sign
  content((motif-x + 0.45 * spacing, 1), text(size: 22pt)[+])

  group({
    for x in range(3) {
      for y in range(3) {
        circle(
          (x + lattice-x, y),
          radius: 0.1,
          fill: black,
          stroke: none,
        )
      }
    }
  })
  content((lattice-x + 1, -1), text(size: 14pt)[Point Lattice])

  // Equals sign
  content((lattice-x + 0.72 * spacing, 1), text(size: 22pt)[=])

  group({
    rect((crystal-x, 0), (crystal-x + 1, 1), stroke: 1pt)

    for x in range(3) {
      for y in range(3) {
        atom((x + crystal-x, y), blue)
        atom((x + crystal-x + 0.5, y + 0.5), red)
      }
    }
  })
  content((crystal-x + 1.5, -1), text(size: 14pt)[Crystal Structure])
})
