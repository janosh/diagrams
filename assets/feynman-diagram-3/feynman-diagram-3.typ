#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, line
#import "../_shared/feynman.typ": hatched

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#canvas({
  let arrow = (mark: (end: "stealth", fill: black, scale: .3), stroke: (thickness: 0.5pt))

  line((-2, 0), (0, 0), name: "in")
  line((0, 0), (1.5, 1.5), name: "up")
  line((0, 0), (1.5, -1.5), name: "down")
  content("in.start", $phi_a$, anchor: "east", padding: 1pt)
  content("up.end", $phi_b$, anchor: "south-west", padding: 1pt)
  content("down.end", $phi_c$, anchor: "north-west", padding: 1pt)

  // momentum arrows point inward along each leg
  for (idx, start, end, label-offset) in (
    (1, (-1.7, 0.15), (-0.7, 0.15), (0, 0.3)),
    (2, (1.0, 1.2), (0.3, 0.5), (-0.3, 0.3)),
    (3, (1.4, -1.2), (0.6, -0.4), (0.3, 0.3)),
  ) {
    line(start, end, ..arrow, name: "p" + str(idx))
    content((rel: label-offset, to: "p" + str(idx)), $p_#idx$)
  }

  circle((0, 0), radius: 0.25, fill: hatched, name: "vertex")
  content(
    (rel: (0.35, -.05), to: "vertex"),
    $Gamma_(k,a b c)^((3))(p_1,p_2,p_3)$,
    anchor: "west",
  )
})
