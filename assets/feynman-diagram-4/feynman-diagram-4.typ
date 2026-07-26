#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, line
#import "../_shared/feynman.typ": hatched

#set page(width: auto, height: auto, margin: 8pt, fill: none)

// draw the four-point vertex on axes rotated 45 deg so the legs run diagonally
#let rot45(x, y) = ((x - y) / calc.sqrt(2), (x + y) / calc.sqrt(2))

#canvas({
  let arrow = (mark: (end: "stealth", fill: black, scale: .3), stroke: (thickness: 0.5pt))

  line(rot45(-2, 0), rot45(2, 0), name: "horiz")
  line(rot45(0, 2), rot45(0, -2), name: "vert")
  content("horiz.start", $phi_a$, anchor: "north-east", padding: -1pt)
  content("horiz.end", $phi_c$, anchor: "south-west", padding: 1pt)
  content("vert.start", $phi_b$, anchor: "south-east", padding: 1pt)
  content("vert.end", $phi_d$, anchor: "north-west", padding: 1pt)

  // all four momenta flow into the vertex
  for (idx, outer, inner, label-offset) in (
    (1, (-1.7, 0.15), (-0.7, 0.15), (-0.1, 0.3)),
    (3, (1.7, 0.15), (0.7, 0.15), (-0.1, 0.3)),
    (2, (0.15, 1.7), (0.15, 0.7), (0.3, 0.2)),
    (4, (0.15, -1.7), (0.15, -0.7), (0.3, 0.1)),
  ) {
    line(rot45(..outer), rot45(..inner), ..arrow, name: "p")
    content((rel: label-offset, to: "p"), $p_#idx$)
  }

  circle(rot45(0, 0), radius: 0.25, fill: hatched, name: "vertex")
  content(
    (rel: (0.35, -.05), to: "vertex"),
    $Gamma_(k,a b c d)^((4))(p_1,p_2,p_3,p_4)$,
    anchor: "west",
  )
})
