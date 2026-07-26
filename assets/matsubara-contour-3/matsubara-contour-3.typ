#import "@preview/cetz:0.5.2": canvas, draw
#import draw: content, line
#import "../_shared/matsubara.typ" as ms

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#let y-range = 3
#let main-radius = y-range + 1.5
#let y-offset = 0.25
#let axis = (mark: (end: "stealth", scale: 0.5))

#canvas({
  line(
    (-main-radius - y-offset, 0),
    (main-radius + y-offset, 0),
    ..axis,
    name: "x-axis",
  )
  content("x-axis.end", $"Re"(p_0)$, anchor: "south-east", padding: 2pt)

  line((0, -main-radius), (0, main-radius), ..axis, name: "y-axis")
  content("y-axis.97%", $"Im"(p_0)$, anchor: "north-east", padding: (right: 8pt))

  ms.frequencies(y-range, padding: (left: 10pt))
  ms.origin(padding: (left: 10pt, bottom: 3pt))
  ms.split-contour(main-radius, offset: y-offset)
  ms.poles((2.5, 1.5))
})
