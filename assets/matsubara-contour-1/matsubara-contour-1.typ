#import "@preview/cetz:0.5.2": canvas, draw
#import draw: arc, content, line
#import "../_shared/matsubara.typ" as ms

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#let range-xy = 3
#let axis = (..ms.axis-arrow, stroke: 0.5pt)
#let contour = (stroke: ms.dark-blue, mark: (end: "stealth", scale: 0.5))

#canvas({
  line((-range-xy - 1, 0), (range-xy + 1, 0), ..axis, name: "x-axis")
  content("x-axis.end", $"Re"(p_0)$, anchor: "south-east", padding: 2pt)

  line((0, -range-xy - 0.7), (0, range-xy + 0.7), ..axis, name: "y-axis")
  content(
    (rel: (-1, 0), to: "y-axis.95%"),
    $"Im"(p_0)$,
    name: "y-label",
    anchor: "south-east",
    padding: 2pt,
  )
  line("y-axis.98%", "y-label", stroke: ms.leader)

  ms.frequencies(range-xy)
  ms.origin()

  // Contour C hugs the imaginary axis, closed by semicircles beyond the last frequency
  line((1, -range-xy - 0.3), (1, range-xy + 0.3), ..contour, name: "right-line")
  line((-1, range-xy + 0.3), (-1, -range-xy - 0.3), ..contour)
  arc((0, range-xy + 0.6), radius: 1, start: 0deg, stop: 180deg, anchor: "center", ..contour)
  arc((0, -range-xy - 0.5), radius: 1, start: 180deg, stop: 360deg, anchor: "center", ..contour)
  content("right-line.end", text(fill: ms.dark-blue)[$C$], anchor: "south-west", padding: 2pt)

  ms.poles((2.75, 1.5))
})
