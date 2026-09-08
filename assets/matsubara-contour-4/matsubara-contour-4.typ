#import "@preview/cetz:0.5.2": canvas, decorations, draw
#import draw: arc, content, line

#let axis-arrow = (mark: (end: "stealth", fill: black, scale: 0.5))

#let dark-blue = blue.darken(20%)

#let contour-stroke = (paint: dark-blue, thickness: 0.8pt)

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#let (x-range, y-range) = (4, 1)
#let radius = y-range / 4

#canvas({
  // Real axis drawn as a branch cut: zigzag either side of the origin, straight arrow tip.
  let contour-left-end = -1.05 * x-range
  let contour-right-end = 1.05 * x-range
  let (gap, tip) = (0.5, 0.4)
  let zigzag = (amplitude: 0.2, segment-length: 0.3, stroke: 0.8pt)
  line((-gap, 0), (gap, 0), stroke: 0.8pt)
  decorations.zigzag(line((contour-left-end, 0), (-gap, 0)), ..zigzag)
  decorations.zigzag(line((gap, 0), (contour-right-end - tip, 0)), ..zigzag)
  line(
    (contour-right-end - tip, 0),
    (contour-right-end, 0),
    stroke: 0.8pt,
    ..axis-arrow,
    name: "x-axis",
  )
  content("x-axis.end", $"Re"(p_0)$, anchor: "west", padding: 2pt)

  line((0, -y-range), (0, y-range), ..axis-arrow, name: "y-axis")
  content("y-axis.end", $"Im"(p_0)$, anchor: "north-west", padding: 4pt)

  // C_b and its point reflection: each runs in from x = ±x-range, hooks around the
  // origin on a semicircle and back out. Reflection swaps the arc's start and end.
  let leg = (start, end, ..args) => line(
    start,
    end,
    stroke: contour-stroke,
    mark: (
      end: (25%, 75%).map(pos => (
        pos: pos,
        symbol: "stealth",
        fill: dark-blue,
        scale: 0.5,
        shorten-to: none,
      )),
    ),
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
      stroke: contour-stroke,
      name: name,
    )
    let (near, far) = if sign == 1 { ("start", "end") } else { ("end", "start") }
    leg((sign * x-range, -sign * radius), name + "." + near)
    leg(name + "." + far, (sign * x-range, sign * radius), name: "outflow" + str(sign))
  }

  content("outflow1.end", text(fill: dark-blue)[$C_b$], anchor: "south-east", padding: 2pt)
})
