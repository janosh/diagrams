#import "@preview/cetz:0.5.3": canvas, draw
#import draw: circle, content, line, mark

// Diagonal hatching marking a vertex as dressed rather than bare.
#let hatched = tiling(size: (.1cm, .1cm))[
  #place(std.rect(width: 100%, height: 100%, fill: rgb("#cdd3da"), stroke: none))
  #place(std.line(start: (0%, 100%), end: (100%, 0%), stroke: 0.4pt))
]

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 12pt)

#let radius = 1.2
// Dressed vertices use hatching; `offset` positions the label relative to the vertex.
#let vertex(pos, label, offset) = {
  circle(pos, radius: 0.15 * radius, fill: hatched, stroke: 0.5pt)
  content((rel: offset, to: pos), label)
}

#canvas({
  circle((0, 0), radius: radius, stroke: 1pt, name: "loop")
  // Momentum labels and arrowheads around the loop; fractions set their positions.
  for (idx, fraction) in ((2, 0.125), (3, 0.375), (4, 0.625), (1, 0.875)) {
    let turn = fraction * 360deg
    // trail the label a few degrees behind its arrowhead
    let lag = turn - 3deg
    let offset = ((0.6 * radius) * calc.cos(lag), (0.6 * radius) * calc.sin(lag))
    content((rel: offset, to: "loop"), $p_#idx$)
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
    "loop.east",
    text(size: 16pt, baseline: -0.25pt)[$times.o$],
    stroke: none,
    fill: rgb("#cdd3da"),
    frame: "circle",
    padding: -2.7pt,
    name: "regulator",
  )
  content((rel: (0.3, 0), to: "loop.east"), $partial_t R_(k,i j)(p_1,p_2)$, anchor: "west")
  vertex("loop.north", $G_(k,j k)(p_2,p_3)$, (0, 0.5))
  vertex("loop.south", $G_(k,l i)(p_4,p_1)$, (0, -0.5))

  line((-2.5 * radius, 0), "loop.west", stroke: 1pt, name: "external")
  content((rel: (-0.6 * radius, 0), to: "external"), $phi_a$, anchor: "north", padding: 7pt)
  line(
    (-2.3 * radius, 0.15),
    (-1.5 * radius, 0.15),
    mark: (end: "stealth", fill: black, scale: .5),
    stroke: 0.75pt,
    name: "q-arrow",
  )
  content("q-arrow.mid", $q$, anchor: "south", padding: 5pt)

  content(
    (-2.2 * radius, 1.2 * radius),
    $Gamma_(k,a k l)^((3))(q,p_3,-p_4)$,
    name: "gamma-label",
  )
  // Gray hairline tying the off-diagram label to the external vertex.
  line("gamma-label", "loop.west", stroke: (paint: rgb("#78828C"), thickness: 0.5pt))
  circle("loop.west", radius: 0.175 * radius, fill: hatched, stroke: 0.5pt)
})
