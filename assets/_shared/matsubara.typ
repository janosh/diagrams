// Shared complex-plane scaffolding for the matsubara-contour-* diagrams:
// axis/contour styling, Matsubara frequencies on the imaginary axis, poles of h(p_0).

#import "@preview/cetz:0.5.2": decorations, draw
#import draw: arc, circle, content, line
#import "theme.typ": leader

#let dark-blue = blue.darken(20%)
#let axis-arrow = (mark: (end: "stealth", fill: black, scale: 0.5))
#let contour-stroke = (paint: dark-blue, thickness: 0.8pt)

// Arrowheads at the given fractions along a contour, marking its orientation.
#let flow(..fractions) = (
  end: fractions
    .pos()
    .map(pos => (
      pos: pos,
      symbol: "stealth",
      fill: dark-blue,
      scale: 0.5,
      shorten-to: none,
    )),
)

// Dots on the imaginary axis at every non-zero Matsubara frequency i omega_n.
#let frequencies(y-range, padding: (x: 3pt)) = {
  for n in range(-y-range, y-range + 1).filter(n => n != 0) {
    let name = "freq-" + str(n)
    circle((0, n), radius: 0.03, fill: black, name: name)
    content(name, $i omega_#text(size: 0.7em)[#n]$, anchor: "west", padding: padding)
  }
}

#let origin(padding: (left: 3pt, bottom: 2pt), anchor: "south-west") = {
  circle((0, 0), radius: 0.03, fill: black, name: "origin")
  content("origin", [0], anchor: anchor, padding: padding)
}

// Poles of h(p_0), each tied to a shared callout label by a hairline.
#let poles(label-pos) = {
  content(label-pos, [poles of $h(p_0)$], name: "poles-label")
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
}

// Contour split into a right half C_1 and a left half C_2, each a vertical line
// running past the poles and closed by a semicircle at infinity.
#let split-contour(radius, offset: 0.25) = {
  let style = (stroke: contour-stroke, mark: flow(25%, 50%, 75%))
  // C_1 runs down the right of the imaginary axis and back up its semicircle; C_2 mirrors it
  for (sign, start, label, anchor) in (
    (1, -90deg, $C_1$, "south-west"),
    (-1, 90deg, $C_2$, "south-east"),
  ) {
    let x = sign * offset
    line((x, sign * radius), (x, -sign * radius), ..style)
    arc((x, 0), radius: radius, start: start, stop: start + 180deg, anchor: "origin", ..style)
    content((x, -radius), text(fill: dark-blue, label), anchor: anchor, padding: 4pt)
  }
}

// Real axis drawn as a branch cut: zigzag either side of the origin, straight arrow tip.
#let zigzag-axis(left-end, right-end, amplitude: 0.15, segment-length: 0.25) = {
  let (gap, tip) = (0.5, 0.4)
  let zigzag = (amplitude: amplitude, segment-length: segment-length, stroke: 0.8pt)
  line((-gap, 0), (gap, 0), stroke: 0.8pt)
  decorations.zigzag(line((left-end, 0), (-gap, 0)), ..zigzag)
  decorations.zigzag(line((gap, 0), (right-end - tip, 0)), ..zigzag)
  line((right-end - tip, 0), (right-end, 0), stroke: 0.8pt, ..axis-arrow, name: "x-axis")
}
