#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, line

// Diagonal hatching marking a vertex as dressed rather than bare.
#let hatched = tiling(size: (.1cm, .1cm))[
  #place(std.rect(width: 100%, height: 100%, fill: rgb("#cdd3da"), stroke: none))
  #place(std.line(start: (0%, 100%), end: (100%, 0%), stroke: 0.4pt))
]

// Regulator insertion: a circled cross on an opaque gray disc.
#let cross(pos, label, offset, name: none) = {
  content(
    pos,
    text(size: 16pt)[$times.o$],
    stroke: none,
    fill: rgb("#cdd3da"),
    frame: "circle",
    padding: -2.5pt,
    name: name,
  )
  content((rel: offset, to: pos), $#label$)
}

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#let unit = 1
#let ext-len = 2 * unit
// Dressed vertices use hatching; trailing options position their labels.
#let vertex(pos, label, offset, radius: 0.2 * unit, name: none, ..style) = {
  circle(pos, radius: radius, fill: hatched, name: name, stroke: auto)
  content((rel: offset, to: pos), $#label$, ..style)
}

#canvas({
  // Two Gamma^(3) loops differing only in whether the regulator sits above or below
  for (x, cross-y, rel-label) in ((0, unit, (0, -0.5)), (5, -unit, (0, 0.5))) {
    circle((x, 0), radius: unit, stroke: 1pt)
    line((x - ext-len, 0), (x - unit, 0), stroke: 1pt)
    line((x + unit, 0), (x + ext-len, 0), stroke: 1pt)
    cross((x, cross-y), $partial_k R_k$, rel-label)
    vertex((x - unit, 0), $Gamma_k^3$, (-0.35, 0.35))
    vertex((x + unit, 0), $Gamma_k^3$, (0.35, 0.35))
  }

  // Gamma^(4) tadpole sitting on a single external line
  circle((10, 0), radius: unit, stroke: 1pt)
  line((10 - ext-len, -unit), (10 + ext-len, -unit), stroke: 1pt)
  cross((10, unit), $partial_k R_k$, (0, -0.5))
  vertex((10, -unit), $Gamma_k^4$, (0.35, 0.35))
})
