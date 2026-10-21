// Ref. https://normaldeviate.wordpress.com/2012/07/01/topological-data-analysis/
#import "@preview/cetz:0.5.3": canvas, draw
#import draw: bezier, circle, content, line

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 12pt)

#let dr = 0.1

// Nested chain, cycle and boundary groups of one degree, sitting on the zero element.
#let stack(x, degree) = {
  let padding = 0.2
  for (name, radius, fill, label) in (
    ("C", 1.5, luma(192), $C_degree$),
    ("Z", 1, luma(160), $Z_degree$),
    ("B", 0.5, luma(128), $B_degree$),
  ) {
    circle((x, 0), anchor: "south", radius: (radius, radius), fill: fill, name: name)
    content(name + ".north", label, anchor: "north", padding: padding)
  }

  circle((x, 0), anchor: "center", radius: dr, fill: rgb("#cdd3da"), name: "zero")
  content("zero.south", $0$, anchor: "north", padding: padding)
}

#canvas({
  let x = 4

  for (idx, degree) in ($r+1$, $r$, $r-1$).enumerate() { stack(idx * x, degree.body) }

  let boundary-labels = ($partial_(r+1)$, $partial_(r)$)
  for span in range(2) {
    let offset = span * x
    let midpoint = offset + 0.5 * x
    line((offset + dr, 0), (offset + x - dr, 0), stroke: (dash: "dashed"))
    // Z_(r+1) maps to 0 and C_(r+1) onto B_r.
    for (start-y, end, end-y) in ((2, x - dr, 0), (3, x, 1)) {
      bezier(
        (offset, start-y),
        (offset + end, end-y),
        (midpoint, start-y),
        (midpoint, end-y),
        stroke: (dash: "dashed"),
      )
    }
    let name = "arrow" + str(1 - span)
    line(
      (offset + 1, -0.5),
      (offset + x - 1, -0.5),
      mark: (end: "straight"),
      name: name,
    )
    content(name, boundary-labels.at(span), anchor: "north", padding: 0.1)
  }
})
