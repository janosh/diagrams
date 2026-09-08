#import "@preview/cetz:0.5.2": canvas, draw
#import draw: arc, circle, content, line

#let axis-arrow = (mark: (end: "stealth", fill: black, scale: 0.5))

#let dark-blue = blue.darken(20%)

// Hairline tying a label to whatever it names: pole callouts, semi-axis leaders,
// off-diagram vertex captions.
#let leader = (paint: rgb("#78828C"), thickness: 0.5pt)

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#let range-xy = 3
#let axis = (..axis-arrow, stroke: 0.5pt)
#let contour = (stroke: dark-blue, mark: (end: "stealth", scale: 0.5))

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
  line("y-axis.98%", "y-label", stroke: leader)

  // Dots on the imaginary axis at every non-zero Matsubara frequency i omega_n.
  for n in range(-range-xy, range-xy + 1).filter(n => n != 0) {
    let name = "freq-" + str(n)
    circle((0, n), radius: 0.03, fill: black, name: name)
    content(name, $i omega_#text(size: 0.7em)[#n]$, anchor: "west", padding: (x: 3pt))
  }
  circle((0, 0), radius: 0.03, fill: black, name: "origin")
  content("origin", [0], anchor: "south-west", padding: (left: 3pt, bottom: 2pt))

  // Contour C hugs the imaginary axis, closed by semicircles beyond the last frequency
  line((1, -range-xy - 0.3), (1, range-xy + 0.3), ..contour, name: "right-line")
  line((-1, range-xy + 0.3), (-1, -range-xy - 0.3), ..contour)
  arc((0, range-xy + 0.6), radius: 1, start: 0deg, stop: 180deg, anchor: "center", ..contour)
  arc((0, -range-xy - 0.5), radius: 1, start: 180deg, stop: 360deg, anchor: "center", ..contour)
  content("right-line.end", text(fill: dark-blue)[$C$], anchor: "south-west", padding: 2pt)

  // Poles of h(p_0), each tied to a shared callout label by a hairline.
  content((2.75, 1.5), [poles of $h(p_0)$], name: "poles-label")
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
