#import "@preview/cetz:0.5.2": canvas, draw
#import draw: arc, circle, content, line

#let dark-blue = blue.darken(20%)

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

// Hairline tying a label to whatever it names: pole callouts, semi-axis leaders,
// off-diagram vertex captions.
#let leader = (paint: rgb("#78828C"), thickness: 0.5pt)

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#let y-range = 3
#let main-radius = y-range + 1.5
#let axis = (mark: (end: "stealth", scale: 0.5))

#canvas({
  line((-main-radius, 0), (main-radius, 0), ..axis, name: "x-axis")
  content("x-axis.end", $"Re"(p_0)$, anchor: "south-east", padding: 2pt)

  line((0, -main-radius), (0, main-radius), ..axis, name: "y-axis")
  content("y-axis.97%", $"Im"(p_0)$, anchor: "north-east", padding: 2pt)

  // Dots on the imaginary axis at every non-zero Matsubara frequency i omega_n.
  for n in range(-y-range, y-range + 1).filter(n => n != 0) {
    let name = "freq-" + str(n)
    circle((0, n), radius: 0.03, fill: black, name: name)
    content(name, $i omega_#text(size: 0.7em)[#n]$, anchor: "west", padding: (x: 3pt))
  }
  circle((0, 0), radius: 0.03, fill: black, name: "origin")
  content("origin", [0], anchor: "south-west", padding: (left: 3pt, bottom: 2pt))

  // Outer contour C, deformable into the four small pole contours C_1..C_4
  arc(
    (0, 0),
    radius: main-radius,
    start: 0deg,
    stop: 360deg,
    anchor: "origin",
    stroke: dark-blue,
    mark: flow(12.5%, 37.5%, 62.5%, 87.5%),
    name: "main-contour",
  )
  content(
    "main-contour.90%",
    text(fill: dark-blue)[$C$],
    anchor: "north-west",
    padding: 2pt,
  )

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

  for idx in range(1, 5) {
    let name = "c" + str(idx)
    arc(
      "p" + str(idx),
      radius: 0.5,
      start: 0deg,
      stop: 360deg,
      anchor: "origin",
      stroke: dark-blue,
      mark: flow(25%, 75%),
      name: name,
    )
    content(
      (rel: (0, 0.8), to: name),
      text(fill: dark-blue)[$C_#idx$],
      anchor: "north",
    )
  }
})
