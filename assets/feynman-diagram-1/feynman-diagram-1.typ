#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, line

#let momentum-arrow = (
  mark: (end: "stealth", fill: black, scale: .5),
  stroke: (thickness: 0.75pt),
)

// Diagonal hatching marking a vertex as dressed rather than bare.
#let hatched = tiling(size: (.1cm, .1cm))[
  #place(std.rect(width: 100%, height: 100%, fill: white, stroke: none))
  #place(std.line(start: (0%, 100%), end: (100%, 0%), stroke: 0.4pt))
]

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#canvas({
  line((-2.25, 0), (2.25, 0), stroke: 1pt, name: "a-to-b")
  content("a-to-b.start", $phi_a$, anchor: "east", padding: 3pt)
  content("a-to-b.end", $phi_b$, anchor: "west", padding: 3pt)

  for (idx, x-start) in ((1, -2), (2, 1)) {
    line((x-start, 0.15), (x-start + 1, 0.15), ..momentum-arrow)
    content((x-start + 0.5, 0.45), $p_#idx$)
  }

  circle((0, 0), radius: 0.25, fill: hatched, name: "vertex")
  content((rel: (0, 0.5), to: "vertex"), $G_(k,a b)(p_1,p_2)$)
})
