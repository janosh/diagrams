#import "@preview/cetz:0.5.2": canvas, decorations, draw
#import draw: circle, content, line

#set page(width: auto, height: auto, margin: 5pt, fill: none)

#let re-range = 5
#let im-range = 4
#let arrow-style = (end: "stealth", fill: black, scale: 0.5)

#canvas({
  // cetz decorations can't carry a mark (cetz-package/cetz#446), so the zigzag stops
  // short of the end and a straight stub carries the arrowhead
  let tip = 0.4
  decorations.zigzag(
    line((-re-range, 0), (re-range - tip, 0)),
    amplitude: 0.1,
    segment-length: 0.2,
  )
  line((re-range - tip, 0), (re-range, 0), mark: arrow-style, name: "x-axis")
  content("x-axis.end", $"Re"(omega)$, anchor: "north-east", padding: (top: 5pt))

  // Imaginary axis
  line(
    (0, -im-range + 1),
    (0, im-range - 1),
    mark: arrow-style,
    name: "y-axis",
  )
  content("y-axis.end", $"Im"(omega)$, anchor: "north-west", padding: (
    left: 5pt,
  ))

  // Matsubara frequencies
  for n in range(-im-range, im-range + 1) {
    circle(
      (0, 2 / 3 * n),
      radius: 0.05,
      fill: black,
      name: "omega" + str(n),
    )
  }
  content((-1.1, 2), align(right)[Matsubara\ frequencies])

  for spec in (
    (
      name: "advanced",
      start: (-re-range, -1),
      end: (re-range, -1),
      paint: red,
      label: [advanced],
      label-pos: (rel: (0, -0.4), to: "advanced.start"),
      label-args: (anchor: "south-west", padding: (left: 5pt)),
    ),
    (
      name: "retarded",
      start: (-re-range, 1),
      end: (re-range, 1),
      paint: blue,
      label: [retarded],
      label-pos: "retarded.start",
      label-args: (anchor: "south-west", padding: 2pt),
    ),
    (
      name: "feynman",
      start: (-re-range, -1),
      end: (re-range, 1),
      paint: orange,
      label: [Feynman],
      label-pos: (rel: (-0.7, -0.55), to: "feynman.end"),
      label-args: (padding: 2pt),
    ),
  ) {
    line(spec.start, spec.end, stroke: (paint: spec.paint, dash: "dashed"), name: spec.name)
    content(spec.label-pos, text(spec.paint, spec.label), ..spec.label-args)
  }
})
