#import "@preview/cetz:0.3.4": canvas, draw
#import draw: content, circle, group, rect

#set page(width: auto, height: auto, margin: 8pt)

#let atom(pos, color) = {
  // First draw the base circle with the main color
  circle(
    pos,
    radius: 0.25,
    stroke: none,
    fill: color,
  )
  // Then draw the gradient overlay for 3D shading effect
  circle(
    (),
    radius: 0.25,
    stroke: none,
    fill: gradient.radial(
      color.lighten(75%),
      color,
      color.darken(15%),
      focal-center: (30%, 25%),
      focal-radius: 5%,
      center: (35%, 30%),
    ),
  )
}

#canvas({
  // Constants for layout
  let (spacing, motif-x) = (4, 1)
  let (lattice-x, crystal-x) = (spacing, 2 * spacing)

  // Draw motif/basis
  group({
    atom((motif-x, 0.8), blue)
    atom((motif-x + .5, 1.3), red)
  })
  content((motif-x, -1), text(size: 10pt)[Motif/Basis])

  // Plus sign
  content((motif-x + 0.45 * spacing, 1), text(size: 22pt)[+])

  // Draw point lattice
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
  content((lattice-x + 1, -1), text(size: 10pt)[Point Lattice])

  // Equals sign
  content((lattice-x + 0.72 * spacing, 1), text(size: 22pt)[=])

  // Draw crystal structure
  group({
    // Draw unit cell outline
    rect((crystal-x, 0), (crystal-x + 1, 1), stroke: 1pt)

    // Draw atoms
    for x in range(3) {
      for y in range(3) {
        atom((x + crystal-x, y), blue)
        atom((x + crystal-x + 0.5, y + 0.5), red)
      }
    }
  })
  content((crystal-x + 1.5, -1), text(size: 10pt)[Crystal Structure])
})
