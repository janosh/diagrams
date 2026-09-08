#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, line
#set page(width: 500pt, height: auto, margin: (x: 20pt, y: 8pt), fill: none)
#set text(font: "Avenir Next", size: 12pt)
#set par(leading: 0.55em)

#let objective(x, y) = 3 * x + 2 * y
#let feasible(x, y) = x >= 0 and y >= 0 and 2 * x + y <= 4 and x + 2 * y <= 4
// Root, x >= 2, x <= 1, then the two children of x <= 1.
#let lp_points = ((4 / 3, 4 / 3), (2, 0), (1, 3 / 2), (1, 1), (0, 2))
#align(center)[#box(inset: (x: 10pt, y: 7pt), radius: 5pt, fill: rgb("#cdd3da"))[
    #grid(
      columns: (auto, auto),
      column-gutter: 10pt,
      row-gutter: 5pt,
      align: left + horizon,
      [*Objective*], [$max z = 3x + 2y$],
      [*Constraints*], [$2x+y <= 4, quad x+2y <= 4, quad x,y in ZZ_(>=0)$],
    )
  ]
]
#v(4pt)
#align(center)[#canvas(length: 1pt, {
  let nodes = (
    (name: "p0", pos: (0, 0), label: $P_0$, fill: none),
    (name: "p1", pos: (-85, -105), label: $P_1$, fill: none),
    (name: "p2", pos: (90, -105), label: $P_2$, fill: rgb("#c6d8d2")),
    (name: "p3", pos: (-145, -220), label: $P_3$, fill: rgb("#c6d8d2")),
    (name: "p4", pos: (-25, -220), label: $P_4$, fill: rgb("#ead3c5")),
  )
  for node in nodes {
    circle(node.pos, radius: 19, fill: node.fill, stroke: 1.2pt, name: node.name)
    content(node.pos, text(size: 21pt, node.label))
  }
  for (parent, child, label, offset) in (
    ("p0", "p1", $x <= 1$, (-23, 8)),
    ("p0", "p2", $x >= 2$, (23, 8)),
    ("p1", "p3", $y <= 1$, (-24, 0)),
    ("p1", "p4", $y >= 2$, (24, 0)),
  ) {
    let edge_name = parent + "-" + child
    line(parent, child, stroke: 1pt, mark: (end: "stealth", scale: 0.7), name: edge_name)
    content((rel: offset, to: edge_name + ".mid"), label)
  }

  content((0, 44), align(center)[*LP relaxation*\ $(x,y)=(4 \/ 3,4 \/ 3), quad U=20 \/ 3$])
  content((-114, -105), align(right)[$(1,3 \/ 2)$\ $U=6$], anchor: "east")
  content((120, -105), [*3 Incumbent*\ $(2,0), quad L=6$], anchor: "west")
  content((-145, -260), align(center)[*1 Integer*\ $(1,1), quad L=5$])
  content((-15, -260), align(center)[*2 Prune*\ $(0,2), quad U=4 <= 5$])
})]
#v(12pt)
#align(center)[*Optimal:* $(x,y)=(2,0), quad z^*=6$]
