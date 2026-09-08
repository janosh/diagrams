#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, line, mark

// Diagonal hatching marking a vertex as dressed rather than bare.
#let hatched = tiling(size: (.1cm, .1cm))[
  #place(std.rect(width: 100%, height: 100%, fill: white, stroke: none))
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

#let radius = 1.25
#let med-rad = 0.175 * radius
// Dressed vertices use hatching; trailing options position their labels.
#let vertex(pos, label, offset, radius: 0.15 * radius, name: none, ..style) = {
  circle(pos, radius: radius, fill: hatched, name: name, stroke: 0.5pt)
  content((rel: offset, to: pos), $#label$, ..style)
}
// Momentum labels and arrowheads around the loop; fractions set their positions.
#let momenta(momenta) = {
  for (idx, fraction) in momenta {
    let turn = fraction * 360deg
    // trail the label a few degrees behind its arrowhead
    let lag = turn - 3deg
    let offset = ((0.75 * radius) * calc.cos(lag), (0.75 * radius) * calc.sin(lag))
    content((rel: offset, to: "loop"), $p_#idx$, size: 8pt)
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
}

// Momentum arrow of length 0.6*radius, drawn just above height `y`.
#let momentum(idx, x-center, y) = {
  let half = 0.3 * radius
  let name = "q" + str(idx)
  line(
    (x-center - half, y + 0.15),
    (x-center + half, y + 0.15),
    ..momentum-arrow,
    name: name,
  )
  content((rel: (0, 0.3), to: name + ".mid"), $q_#idx$)
}

// Gamma^(3) box: loop closed by two dressed propagators, one on each side
#canvas({
  circle((0, 0), radius: radius, stroke: 1pt, name: "loop")
  momenta(((1, 0.125), (2, 0.375), (3, 0.625), (4, 0.875)))

  vertex((0, radius), $G_(k,i j)(p_1,p_2)$, (0, 0.2), anchor: "south", name: "vertex-top")
  vertex((0, -radius), $G_(k,k l)(p_3,p_4)$, (0, -0.3), anchor: "north", name: "vertex-bottom")

  line((-2 * radius, 0), (-radius, 0), stroke: 1pt, name: "left-external")
  line((radius, 0), (2 * radius, 0), stroke: 1pt, name: "right-external")
  content("left-external.start", $phi_a$, anchor: "east", padding: 0.1)
  content("right-external.end", $phi_b$, anchor: "west", padding: 0.1)
  momentum(1, -1.6 * radius, 0)
  momentum(2, 1.6 * radius, 0)

  for (name, side, label) in (
    ("gamma-left", -1, $Gamma_(k,a j k)^((3))(q_1,p_2,-p_3)$),
    ("gamma-right", 1, $Gamma_(k,b l i)^((3))(-q_2,-p_1,p_4)$),
  ) {
    content((side * 2.1 * radius, radius), label, name: name)
    line(name, (side * radius, 0), stroke: leader)
    circle((side * radius, 0), radius: med-rad, fill: hatched, stroke: 0.5pt)
  }
})

#pagebreak()

// Gamma^(4) tadpole: single dressed propagator over a straight external line
#canvas({
  circle((0, 0), radius: radius, stroke: 1pt, name: "loop")
  momenta(((1, 0), (2, 0.5)))

  vertex((0, radius), $G_(k,i j)(p_1,p_2)$, (0, 0.2), anchor: "south", name: "vertex-top")

  line((-2 * radius, -radius), (2 * radius, -radius), stroke: 1pt, name: "external")
  content((rel: (-0.1, 0), to: "external.start"), $phi_a$, anchor: "east")
  content((rel: (0.1, 0), to: "external.end"), $phi_b$, anchor: "west")
  momentum(1, -1.6 * radius, -radius)
  momentum(2, 1.6 * radius, -radius)

  vertex(
    (0, -radius),
    $Gamma_(k,a b j i)^((4))(q_1,-q_2,-p_1,p_2)$,
    (0, -0.3),
    radius: med-rad,
    anchor: "north",
  )
})
