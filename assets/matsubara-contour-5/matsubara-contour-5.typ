#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, line
#import "../_shared/matsubara.typ" as ms

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#let (x-range, y-range) = (3.5, 3)
#let main-radius = y-range + 0.75
#let y-offset = 0.25

#canvas({
  // Right zigzag stops where the x-axis meets the right arc
  ms.zigzag-axis(-x-range - 0.4, y-offset + main-radius)
  content("x-axis.end", $"Re"(p_0)$, anchor: "south-east", padding: 2pt)

  line((0, -y-range - 0.7), (0, y-range + 0.7), ..ms.axis-arrow, name: "y-axis")
  content("y-axis.97%", $"Im"(p_0)$, anchor: "north-east", padding: (right: 8pt))

  ms.frequencies(y-range, padding: (left: 10pt))
  ms.origin(padding: 2pt, anchor: "north-east")
  ms.split-contour(main-radius, offset: y-offset)

  for (pos, label, anchor) in (
    ((x-range / 2, y-range / 4), $E$, "west"),
    ((-x-range / 2, -y-range / 4), $-E$, "east"),
  ) {
    circle(pos, radius: 0.05, fill: black, name: "pole")
    content("pole", label, anchor: anchor, padding: 2pt)
  }
})
