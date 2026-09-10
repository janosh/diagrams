#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, line, mark

// Diagonal hatching marking a vertex as dressed rather than bare.
#let hatched = tiling(size: (.1cm, .1cm))[
  #place(std.rect(width: 100%, height: 100%, fill: rgb("#cdd3da"), stroke: none))
  #place(std.line(start: (0%, 100%), end: (100%, 0%), stroke: 0.4pt))
]

#let momentum-arrow = (
  mark: (end: "stealth", fill: black, scale: .5),
  stroke: (thickness: 0.75pt),
)

// Hairline tying a label to whatever it names: pole callouts, semi-axis leaders,
// off-diagram vertex captions.
#let leader = (paint: rgb("#78828C"), thickness: 0.5pt)

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 12pt)

#let radius = 1.2 // Increased for better spacing
#let med-rad = 0.175 * radius // \mrad
// Dressed vertices use hatching; trailing options position their labels.
#let vertex(pos, label, offset, radius: 0.15 * radius, name: none, ..style) = {
  circle(pos, radius: radius, fill: hatched, name: name, stroke: 0.5pt)
  content((rel: offset, to: pos), $#label$, ..style)
} // \srad

#canvas({
  circle((0, 0), radius: radius, stroke: 1pt, name: "loop")
  // Momentum labels and arrowheads around the loop; fractions set their positions.
  for (idx, fraction) in ((2, 0.125), (3, 0.375), (4, 0.625), (1, 0.875)) {
    let turn = fraction * 360deg
    // trail the label a few degrees behind its arrowhead
    let lag = turn - 3deg
    let offset = ((0.6 * radius) * calc.cos(lag), (0.6 * radius) * calc.sin(lag))
    content((rel: offset, to: "loop"), $p_#idx$, size: 12pt)
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
    (radius, 0),
    text(size: 16pt, baseline: -0.25pt)[$times.o$],
    stroke: none,
    fill: rgb("#cdd3da"),
    frame: "circle",
    padding: -2.7pt,
    name: "regulator",
  )
  content((rel: (0.3, 0), to: (radius, 0)), $partial_k R_(k,i j)(p_1,p_2)$, anchor: "west")
  vertex((0, radius), $G_(k,j k)(p_2,p_3)$, (0, 0.5), name: "vertex-top")
  vertex((0, -radius), $G_(k,l i)(p_4,p_1)$, (0, -0.5), name: "vertex-bottom")

  line((-2.5 * radius, 0), (-radius, 0), stroke: 1pt, name: "external")
  content((rel: (-0.6 * radius, -0.3), to: "external"), $phi_a$)
  line(
    (-2.3 * radius, 0.15),
    (-1.5 * radius, 0.15),
    ..momentum-arrow,
    name: "q-arrow",
  )
  content((rel: (0, 0.3), to: "q-arrow.mid"), $q$)

  content(
    (-2.2 * radius, 1.2 * radius),
    $Gamma_(k,a k l)^((3))(q,p_3,-p_4)$,
    name: "gamma-label",
  )
  line("gamma-label", (-radius, 0), stroke: leader)
  circle((-radius, 0), radius: med-rad, fill: hatched, stroke: 0.5pt, name: "vertex-external")
})
