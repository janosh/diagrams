#import "@preview/cetz:0.5.2": canvas, draw
#import draw: arc, circle, content, line

#let dark-blue = blue.darken(20%)

#let contour-stroke = (paint: dark-blue, thickness: 0.8pt)

// Hairline tying a label to whatever it names: pole callouts, semi-axis leaders,
// off-diagram vertex captions.
#let leader = (paint: rgb("#78828C"), thickness: 0.5pt)

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

  // Dots on the imaginary axis at every non-zero Matsubara frequency i omega_n.
  for n in range(-y-range, y-range + 1).filter(n => n != 0) {
    let name = "freq-" + str(n)
    circle((0, n), radius: 0.03, fill: black, name: name)
    content(name, $i omega_#text(size: 0.7em)[#n]$, anchor: "west", padding: (left: 10pt))
  }
  circle((0, 0), radius: 0.03, fill: black, name: "origin")
  content("origin", [0], anchor: "south-west", padding: (left: 10pt, bottom: 3pt))
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
  // Poles of h(p_0), each tied to a shared callout label by a hairline.
  content((2.5, 1.5), [poles of $h(p_0)$], name: "poles-label")
  let sites = (
    ((1.5, 3), "west"),
    ((2, -2), "north"),
    ((-3, 1), "south"),
    ((-2, -1.5), "north"),
  )
  for (idx, (pos, anchor)) in sites.enumerate(start: 1) {
    let name = "p" + str(idx)
    circle(pos, radius: 0.05, fill: black, name: name)
    content(name, $p_#idx$, anchor: anchor, padding: 2pt)
    // p3 sits far to the left, so aim its hairline at the label's west edge
    let target = if idx == 3 { "poles-label.west" } else { "poles-label" }
    line(target, name, stroke: leader)
  }
})
