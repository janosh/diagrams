#import "@preview/cetz:0.5.2": canvas, draw
#import draw: arc, content, line
#import "../_shared/matsubara.typ" as ms

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#let (x-range, y-range) = (4, 1)
#let radius = y-range / 4

#canvas({
  ms.zigzag-axis(-1.05 * x-range, 1.05 * x-range, amplitude: 0.2, segment-length: 0.3)
  content("x-axis.end", $"Re"(p_0)$, anchor: "west", padding: 2pt)

  line((0, -y-range), (0, y-range), ..ms.axis-arrow, name: "y-axis")
  content("y-axis.end", $"Im"(p_0)$, anchor: "north-west", padding: 4pt)

  // C_b and its point reflection: each runs in from x = ±x-range, hooks around the
  // origin on a semicircle and back out. Reflection swaps the arc's start and end.
  let leg = (start, end, ..args) => line(
    start,
    end,
    stroke: ms.contour-stroke,
    mark: ms.flow(25%, 75%),
    ..args,
  )
  for sign in (1, -1) {
    let name = "arc" + str(sign)
    arc(
      (sign * radius, 0),
      radius: radius,
      start: 90deg + sign * 180deg,
      stop: 90deg,
      anchor: "arc-center",
      stroke: ms.contour-stroke,
      name: name,
    )
    let (near, far) = if sign == 1 { ("start", "end") } else { ("end", "start") }
    leg((sign * x-range, -sign * radius), name + "." + near)
    leg(name + "." + far, (sign * x-range, sign * radius), name: "outflow" + str(sign))
  }

  content("outflow1.end", text(fill: ms.dark-blue)[$C_b$], anchor: "south-east", padding: 2pt)
})
