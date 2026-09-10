#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, mark

// Diagonal hatching marking a vertex as dressed rather than bare.
#let hatched = tiling(size: (.1cm, .1cm))[
  #place(std.rect(width: 100%, height: 100%, fill: rgb("#cdd3da"), stroke: none))
  #place(std.line(start: (0%, 100%), end: (100%, 0%), stroke: 0.4pt))
]

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 12pt)

#let radius = 1.25 // \lrad in original
#let med-rad = 0.175 * radius // \mrad

#canvas({
  circle((0, 0), radius: radius, stroke: 1pt, name: "loop")
  // Momentum labels and arrowheads around the loop; fractions set their positions.
  for (idx, fraction) in ((1, 0.25), (2, 0.75)) {
    let turn = fraction * 360deg
    // trail the label a few degrees behind its arrowhead
    let lag = turn - 3deg
    let offset = ((0.75 * radius) * calc.cos(lag), (0.75 * radius) * calc.sin(lag))
    content((rel: offset, to: "loop"), text(size: 12pt)[$p_#idx$])
    mark(
      (name: "loop", anchor: turn),
      (name: "loop", anchor: turn + 1deg),
      symbol: "stealth",
      width: .25,
      length: .15,
      stroke: .7pt,
      scale: .7,
      angle: 60deg,
      fill: black,
    )
  }

  // Regulator insertion: a circled cross on an opaque gray disc.
  content(
    (-radius, 0),
    text(size: 16pt, baseline: -0.2pt)[$times.o$],
    stroke: none,
    fill: rgb("#cdd3da"),
    frame: "circle",
    padding: -2.75pt,
    name: "regulator",
  )
  content((rel: (-0.25, 0), to: (-radius, 0)), $partial_k R_(k,i j)(p_1,p_2)$, anchor: "east")

  circle((radius, 0), radius: med-rad, fill: hatched, name: "vertex", stroke: 0.5pt)
  content(
    (rel: (0.25, 0), to: (radius, 0)),
    $[Gamma_k^((2)) + R_k]_(j i)^(-1)(p_2,p_1)$,
    anchor: "west",
  )
})
