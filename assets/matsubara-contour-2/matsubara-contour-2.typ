#import "@preview/cetz:0.5.2": canvas, draw
#import draw: arc, content, line
#import "../_shared/matsubara.typ" as ms

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#let y-range = 3
#let main-radius = y-range + 1.5
#let axis = (mark: (end: "stealth", scale: 0.5))

#canvas({
  line((-main-radius, 0), (main-radius, 0), ..axis, name: "x-axis")
  content("x-axis.end", $"Re"(p_0)$, anchor: "south-east", padding: 2pt)

  line((0, -main-radius), (0, main-radius), ..axis, name: "y-axis")
  content("y-axis.97%", $"Im"(p_0)$, anchor: "north-east", padding: 2pt)

  ms.frequencies(y-range)
  ms.origin()

  // Outer contour C, deformable into the four small pole contours C_1..C_4
  arc(
    (0, 0),
    radius: main-radius,
    start: 0deg,
    stop: 360deg,
    anchor: "origin",
    stroke: ms.dark-blue,
    mark: ms.flow(12.5%, 37.5%, 62.5%, 87.5%),
    name: "main-contour",
  )
  content(
    "main-contour.90%",
    text(fill: ms.dark-blue)[$C$],
    anchor: "north-west",
    padding: 2pt,
  )

  ms.poles((2.5, 1.5))

  for idx in range(1, 5) {
    let name = "c" + str(idx)
    arc(
      "p" + str(idx),
      radius: 0.5,
      start: 0deg,
      stop: 360deg,
      anchor: "origin",
      stroke: ms.dark-blue,
      mark: ms.flow(25%, 75%),
      name: name,
    )
    content(
      (rel: (0, 0.8), to: name),
      text(fill: ms.dark-blue)[$C_#idx$],
      anchor: "north",
    )
  }
})
