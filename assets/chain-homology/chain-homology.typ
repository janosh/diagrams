// Ref. https://normaldeviate.wordpress.com/2012/07/01/topological-data-analysis/
#import "@preview/cetz:0.4.2": canvas, draw
#import draw: circle, content, line, bezier

#set page(width: auto, height: auto, margin: 8pt)

#let dr = 0.1

#let stack(x, Cr, Zr, Br) = {
  let padding = 0.2

  // Chains
  circle((x, 0), anchor: "south", radius: (1.5, 1.5), fill: luma(192), name: "C")
  content("C.north", Cr, anchor: "north", padding: padding)

  // Cycles
  circle((x, 0), anchor: "south", radius: (1, 1), fill: luma(160), name: "Z")
  content("Z.north", Zr, anchor: "north", padding: padding)

  // Boundaries
  circle((x, 0), anchor: "south", radius: (0.5, 0.5), fill: luma(128), name: "B")
  content("B.north", Br, anchor: "north", padding: padding)

  circle((x, 0), anchor: "center", radius: dr, fill: white, name: "zero")
  content("zero.south", $0$, anchor: "north", padding: padding)
}

#canvas({
  let x = 4

  stack(0, $C_(r+1)$, $Z_(r+1)$, $B_(r+1)$)
  stack(x, $C_(r)$, $Z_(r)$, $B_(r)$)
  stack(2 * x, $C_(r-1)$, $Z_(r-1)$, $B_(r-1)$)

  line((dr, 0), (x - dr, 0), stroke: (dash: "dashed"))
  line((x + dr, 0), (2 * x - dr, 0), stroke: (dash: "dashed"))

  // Kernel
  bezier((0, 2), (x - dr, 0), (0.5 * x, 2), (0.5 * x, 0), stroke: (dash: "dashed"))
  bezier((x, 2), (2 * x - dr, 0), (1.5 * x, 2), (1.5 * x, 0), stroke: (dash: "dashed"))

  // Image
  bezier((0, 3), (x, 1), (0.5 * x, 3), (0.5 * x, 1), stroke: (dash: "dashed"))
  bezier((x, 3), (2* x, 1), (1.5 * x, 3), (1.5 * x, 1), stroke: (dash: "dashed"))

  // Boundary operators
  line((1, -0.5), (x - 1, -0.5), mark: (end: "straight"), name: "arrow1")
  content("arrow1", $partial_(r+1)$, anchor: "north", padding: 0.1)

  line((x + 1, -0.5), (2 * x - 1, -0.5), mark: (end: "straight"), name: "arrow0")
  content("arrow0", $partial_(r)$, anchor: "north", padding: 0.1)
})
