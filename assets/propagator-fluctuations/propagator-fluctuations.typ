#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, line
#import "../_shared/feynman.typ" as fey

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#let unit = 1
#let ext-len = 2 * unit
#let vertex = fey.dressed-vertex.with(
  radius: 0.2 * unit,
  stroke: auto,
  rel-label: (0.35, 0.35),
)

#canvas({
  // Two Gamma^(3) loops differing only in whether the regulator sits above or below
  for (x, cross-y, rel-label) in ((0, unit, (0, -0.5)), (5, -unit, (0, 0.5))) {
    circle((x, 0), radius: unit, stroke: 1pt)
    line((x - ext-len, 0), (x - unit, 0), stroke: 1pt)
    line((x + unit, 0), (x + ext-len, 0), stroke: 1pt)
    fey.cross((x, cross-y), label: $partial_k R_k$, rel-label: rel-label)
    vertex((x - unit, 0), label: $Gamma_k^3$, rel-label: (-0.35, 0.35))
    vertex((x + unit, 0), label: $Gamma_k^3$)
  }

  // Gamma^(4) tadpole sitting on a single external line
  circle((10, 0), radius: unit, stroke: 1pt)
  line((10 - ext-len, -unit), (10 + ext-len, -unit), stroke: 1pt)
  fey.cross((10, unit), label: $partial_k R_k$, rel-label: (0, -0.5))
  vertex((10, -unit), label: $Gamma_k^4$)
})
