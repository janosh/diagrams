#import "@preview/cetz:0.5.3": canvas, draw
#import draw: circle, content, line

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 12pt)

// Diagonal hatching marking a vertex as dressed rather than bare.
#let hatched = tiling(size: (.1cm, .1cm))[
  #place(std.rect(width: 100%, height: 100%, fill: rgb("#cdd3da"), stroke: none))
  #place(std.line(start: (0%, 100%), end: (100%, 0%), stroke: 0.4pt))
]

#let opposite = (north: "south", south: "north", east: "west", west: "east")

// Regulator insertion: a circled cross on an opaque gray disc, labeled on its given side.
#let cross(pos, side) = {
  let disc = (stroke: none, fill: rgb("#cdd3da"), frame: "circle", padding: -2.5pt)
  content(pos, text(size: 16pt)[$times.o$], ..disc, name: "x")
  content("x." + side, $partial_k R_k$, anchor: opposite.at(side), padding: 4pt)
}

// Dressed vertex labeled diagonally above it on the given side (east or west).
#let vertex(pos, label, side) = {
  circle(pos, radius: 0.2, fill: hatched, name: "v")
  content("v.north-" + side, label, anchor: "south-" + opposite.at(side), padding: 1pt)
}

#canvas({
  let ext-len = 2 // external leg half-length
  // Two Gamma^(3) loops differing only in whether the regulator sits above or below
  for (x, cross-at) in ((0, "north"), (5, "south")) {
    circle((x, 0), radius: 1, name: "loop")
    line((rel: (-ext-len, 0), to: "loop"), "loop.west")
    line("loop.east", (rel: (ext-len, 0), to: "loop"))
    cross("loop." + cross-at, opposite.at(cross-at))
    vertex("loop.west", $Gamma_k^3$, "west")
    vertex("loop.east", $Gamma_k^3$, "east")
  }

  // Gamma^(4) tadpole sitting on a single external line
  circle((10, 0), radius: 1, name: "tadpole")
  line((rel: (-ext-len, 0), to: "tadpole.south"), (rel: (2 * ext-len, 0)))
  cross("tadpole.north", "south")
  vertex("tadpole.south", $Gamma_k^4$, "east")
})
