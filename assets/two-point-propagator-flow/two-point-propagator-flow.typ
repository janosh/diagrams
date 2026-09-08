#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, line, mark

// Diagonal hatching marking a vertex as dressed rather than bare.
#let hatched = tiling(size: (.1cm, .1cm))[
  #place(std.rect(width: 100%, height: 100%, fill: white, stroke: none))
  #place(std.line(start: (0%, 100%), end: (100%, 0%), stroke: 0.4pt))
]

// Hairline tying a label to whatever it names: pole callouts, semi-axis leaders,
// off-diagram vertex captions.
#let leader = (paint: rgb("#78828C"), thickness: 0.5pt)

// Regulator insertion: a circled cross on an opaque white disc.
#let cross(pos, label, offset, name: none) = {
  content(
    pos,
    text(size: 16pt)[$times.o$],
    stroke: none,
    fill: white,
    frame: "circle",
    padding: -2.5pt,
    name: name,
  )
  content((rel: offset, to: pos), $#label$)
}

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#let radius = 1.25 // \lrad in original
#let med-rad = 0.13 * radius
// Dressed vertices use hatching; trailing options position their labels.
#let vertex(pos, label, offset, radius: 0.1 * radius, name: none, ..style) = {
  circle(pos, radius: radius, fill: hatched, name: name, stroke: 0.5pt)
  content((rel: offset, to: pos), $#label$, ..style)
}
#let q-arrow = (
  mark: (end: "barbed", fill: black, scale: .5, width: .25, length: .2, angle: 60deg),
  stroke: .5pt,
)

#let at(pos) = (rel: pos, to: "main-loop")
// Point on the loop at `turn` around it, measured counter-clockwise from 3 o'clock.
#let on-loop(turn) = at((radius * calc.cos(turn), radius * calc.sin(turn)))

// Barbed momentum arrows around the loop, indexed clockwise from the top.
// Momentum labels and arrowheads around the loop; fractions set their positions.
#let loop-momenta(momenta) = {
  for (idx, fraction) in momenta {
    let turn = fraction * 360deg
    // trail the label a few degrees behind its arrowhead
    let lag = turn - 3deg
    let offset = ((0.75 * radius) * calc.cos(lag), (0.75 * radius) * calc.sin(lag))
    content((rel: offset, to: "main-loop"), $p_#idx$, size: 8pt)
    mark(
      (name: "main-loop", anchor: turn),
      (name: "main-loop", anchor: turn + 0.1deg),
      symbol: "barbed",
      width: .25,
      length: .15,
      stroke: .7pt,
      scale: .7,
      angle: 70deg,
      fill: none,
    )
  }
}

// Straight external legs meeting the loop at 9 and 3 o'clock, each capped by a vertex.
#let side-legs() = {
  for (name, side, turn, label) in (
    ("left-external", -1, 180deg, $phi_a$),
    ("right-external", 1, 0deg, $phi_b$),
  ) {
    line(on-loop(turn), at((side * 2 * radius, 0)), stroke: 1pt, name: name)
    content((rel: (side * 0.2, -0.3), to: name + ".mid"), label)
  }
  for (side, name) in ((-1, "left"), (1, "right")) {
    circle(
      at((side * radius, 0)),
      radius: med-rad,
      fill: hatched,
      stroke: 0.5pt,
      name: "vertex-" + name + "-external",
    )
  }
}

// Incoming q_1 and outgoing q_2, both pointing right, at height `y`.
#let external-momenta(inner, outer, y: 0.15) = {
  for (idx, x-start, x-end) in ((1, -outer, -inner), (2, inner, outer)) {
    let name = "q" + str(idx) + "-arrow"
    line(at((x-start, y)), at((x-end, y)), ..q-arrow, name: name)
    content(name + ".mid", $q_#idx$, anchor: "south", padding: (0, 0, 2pt))
  }
}

// Off-diagram Gamma^(3) label tied to the vertex it names by a hairline.
#let gamma-callout(name, pos, label, target) = {
  content(at(pos), label, name: name)
  line(name, target, stroke: leader)
}

// Regulator at the top, dressed propagators at 3, 9 and 6 o'clock
#canvas({
  circle((0, 0), radius: radius, stroke: 1pt, name: "main-loop")
  loop-momenta(((6, 0.0625), (1, 0.1875), (2, 0.3125), (3, 0.4375), (4, 0.625), (5, 0.875)))

  cross(at((0, radius)), $partial_k R_(k,i j) (p_1,p_2)$, (0, 0.5), name: "regulator")
  vertex(on-loop(135deg), $G_(k,j k)(p_2,p_3)$, (-1.2, 0.3))
  vertex(on-loop(45deg), $G_(k,n i)(p_6,p_1)$, (1.2, 0.3))
  vertex(at((0, -radius)), $G_(k,l m) (p_4,p_5)$, (0, -.8))

  side-legs()
  external-momenta(1.4, 2.3)
  gamma-callout("gamma-left", (-2, -1.5), $Gamma_(k,a k l)^((3))(q_1,p_3,-p_4)$, at((-radius, 0)))
  gamma-callout("gamma-right", (2, -1.5), $Gamma_(k,b m n)^((3))(-q_2,p_5,-p_6)$, at((radius, 0)))
})

#pagebreak()

// Regulator moved to the bottom, propagators at 4, 8 and 12 o'clock
#canvas({
  circle((0, 0), radius: radius, stroke: 1pt, name: "main-loop")
  loop-momenta(((6, 0.125), (3, 0.375), (4, 0.5625), (1, 0.6875), (2, 0.8125), (5, 0.9375)))

  cross(at((0, -radius)), $partial_k R_(k,i j)(p_1,p_2)$, (0, -0.5))
  vertex(on-loop(-45deg), $G_(k,j m)(p_2,p_5)$, (1.2, -0.3))
  vertex(on-loop(225deg), $G_(k,l i)(p_4,p_1)$, (-1.2, -0.3))
  vertex(at((0, radius)), $G_(k,n k)(p_6,p_3)$, (0, 0.3))

  side-legs()
  external-momenta(1.6, 2.4)
  // pushed further out than in the first diagram to clear the propagator labels
  gamma-callout(
    "gamma-left",
    (-2.4, 1.1),
    $Gamma_(k,a k l)^((3))(q_1,p_3,-p_4)$,
    "vertex-left-external",
  )
  gamma-callout(
    "gamma-right",
    (2.5, 1.1),
    $Gamma_(k,b m n)^((3))(-q_2,p_5,-p_6)$,
    "vertex-right-external",
  )
})

#pagebreak()

// Gamma^(4) tadpole: the loop rides on a single external line
#canvas({
  circle((0, 0), radius: radius, stroke: 1pt, name: "main-loop")
  loop-momenta(((1, 0.125), (2, 0.375), (3, 0.625), (4, 0.875)))

  cross(at((0, radius)), $partial_k R_(k,i j)(p_1,p_2)$, (0, 0.4))
  vertex(at((-radius, 0)), $G_(k,j k)(p_2,p_3)$, (-1.2, 0))
  vertex(at((radius, 0)), $G_(k,l i)(p_4,p_1)$, (1.2, 0))

  line(
    at((-2.2 * radius, -radius)),
    at((2.2 * radius, -radius)),
    stroke: 1pt,
    name: "external-line",
  )
  circle(at((0, -radius)), radius: med-rad, fill: hatched, stroke: 0.5pt)
  content(at((0, -2)), $Gamma_(k,a b k l)^((4))(q_1,-q_2,p_3,-p_4)$)
  content(at((-2, -1.5)), $phi_a$)
  content(at((2, -1.5)), $phi_b$)

  external-momenta(1.3, 2.3, y: -radius + 0.15)
})
