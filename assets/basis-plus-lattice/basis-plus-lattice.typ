#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, rect

// The flat disc underneath is fully covered by the gradient, but drawing both
// doubles up the antialiased rim so the sphere keeps a crisp edge.
#let atom(pos, fill) = {
  circle(pos, radius: 0.25, stroke: none, fill: fill)
  circle(pos, radius: 0.25, stroke: none, fill: gradient.radial(
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

#canvas({
  let (spacing, motif-x) = (4, 1)
  let (lattice-x, crystal-x) = (spacing, 2 * spacing)

  atom((motif-x, 0.8), blue)
  atom((motif-x + .5, 1.3), red)
  content((motif-x, -1))[Motif/Basis]
  content((motif-x + 0.45 * spacing, 1), text(size: 22pt)[+])

  for x in range(3) {
    for y in range(3) {
      circle((x + lattice-x, y), radius: 0.1, fill: black, stroke: none)
    }
  }
  content((lattice-x + 1, -1))[Point Lattice]
  content((lattice-x + 0.72 * spacing, 1), text(size: 22pt)[=])

  rect((crystal-x, 0), (crystal-x + 1, 1), stroke: 1pt)
  for x in range(3) {
    for y in range(3) {
      atom((x + crystal-x, y), blue)
      atom((x + crystal-x + 0.5, y + 0.5), red)
    }
  }
  content((crystal-x + 1.5, -1))[Crystal Structure]
})
