#import "@preview/cetz:0.5.2": canvas, decorations, draw
#import draw: arc, circle, content, line

#let axis-arrow = (mark: (end: "stealth", fill: black, scale: 0.5))

#let dark-blue = blue.darken(20%)

#let contour-stroke = (paint: dark-blue, thickness: 0.8pt)

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#let (x-range, y-range) = (3.5, 3)
#let main-radius = y-range + 0.75
#let y-offset = 0.25

#canvas({
  // Right zigzag stops where the x-axis meets the right arc
  // Real axis drawn as a branch cut: zigzag either side of the origin, straight arrow tip.
  let contour-left-end = -x-range - 0.4
  let contour-right-end = y-offset + main-radius
  let (gap, tip) = (0.5, 0.4)
  let zigzag = (amplitude: 0.15, segment-length: 0.25, stroke: 0.8pt)
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
  content("x-axis.end", $"Re"(p_0)$, anchor: "south-east", padding: 2pt)

  line((0, -y-range - 0.7), (0, y-range + 0.7), ..axis-arrow, name: "y-axis")
  content("y-axis.97%", $"Im"(p_0)$, anchor: "north-east", padding: (right: 8pt))

  // Dots on the imaginary axis at every non-zero Matsubara frequency i omega_n.
  for n in range(-y-range, y-range + 1).filter(n => n != 0) {
    let name = "freq-" + str(n)
    circle((0, n), radius: 0.03, fill: black, name: name)
    content(name, $i omega_#text(size: 0.7em)[#n]$, anchor: "west", padding: (left: 10pt))
  }
  circle((0, 0), radius: 0.03, fill: black, name: "origin")
  content("origin", [0], anchor: "north-east", padding: 2pt)
  // Contour split into a right half C_1 and a left half C_2, each a vertical line
  // running past the poles and closed by a semicircle at infinity.
  let style = (
    stroke: contour-stroke,
    mark: (
      end: (25%, 50%, 75%).map(pos => (
        pos: pos,
        symbol: "stealth",
        fill: dark-blue,
        scale: 0.5,
        shorten-to: none,
      )),
    ),
  )
  // C_1 runs down the right of the imaginary axis and back up its semicircle; C_2 mirrors it
  for (sign, start, label, anchor) in (
    (1, -90deg, $C_1$, "south-west"),
    (-1, 90deg, $C_2$, "south-east"),
  ) {
    let x = sign * y-offset
    line((x, sign * main-radius), (x, -sign * main-radius), ..style)
    arc(
      (x, 0),
      radius: main-radius,
      start: start,
      stop: start + 180deg,
      anchor: "origin",
      ..style,
    )
    content((x, -main-radius), text(fill: dark-blue, label), anchor: anchor, padding: 4pt)
  }

  for (name, pos, label, anchor) in (
    ("pole-e", (x-range / 2, y-range / 4), $E$, "west"),
    ("pole-minus-e", (-x-range / 2, -y-range / 4), $-E$, "east"),
  ) {
    circle(pos, radius: 0.05, fill: black, name: name)
    content(name, label, anchor: anchor, padding: 2pt)
  }
})
