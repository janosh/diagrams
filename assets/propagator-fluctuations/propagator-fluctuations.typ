#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, line

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 12pt)

// Diagonal hatching marking a vertex as dressed rather than bare.
#let hatched = tiling(size: (.1cm, .1cm))[
  #place(std.rect(width: 100%, height: 100%, fill: rgb("#cdd3da"), stroke: none))
  #place(std.line(start: (0%, 100%), end: (100%, 0%), stroke: 0.4pt))
]

// Regulator insertion: a circled cross on an opaque gray disc.
#let cross(pos, offset) = {
  let symbol = text(size: 16pt)[$times.o$]
  content(pos, symbol, stroke: none, fill: rgb("#cdd3da"), frame: "circle", padding: -2.5pt)
  content((rel: offset, to: pos), $partial_k R_k$)
}

// Dressed vertex with its label shifted by offset.
#let vertex(pos, label, offset) = {
  circle(pos, radius: 0.2, fill: hatched)
  content((rel: offset, to: pos), label)
}

#canvas({
  let ext-len = 2 // external leg half-length
  // Two Gamma^(3) loops differing only in whether the regulator sits above or below
  for (x, cross-y, label-offset) in ((0, 1, (0, -0.5)), (5, -1, (0, 0.5))) {
    circle((x, 0), radius: 1)
    line((x - ext-len, 0), (x - 1, 0))
    line((x + 1, 0), (x + ext-len, 0))
    cross((x, cross-y), label-offset)
    vertex((x - 1, 0), $Gamma_k^3$, (-0.35, 0.35))
    vertex((x + 1, 0), $Gamma_k^3$, (0.35, 0.35))
  }

  // Gamma^(4) tadpole sitting on a single external line
  circle((10, 0), radius: 1)
  line((10 - ext-len, -1), (10 + ext-len, -1))
  cross((10, 1), (0, -0.5))
  vertex((10, -1), $Gamma_k^4$, (0.35, 0.35))
})
