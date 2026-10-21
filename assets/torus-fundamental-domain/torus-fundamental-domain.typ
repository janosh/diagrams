#import "@preview/cetz:0.5.3": canvas, draw
#import draw: arc, circle, content, line, rect

#set page(width: auto, height: auto, margin: 1pt, fill: none)
#set text(size: 12pt)

#let ymax = 2.4
// Edge colors darkened from Typst red/green so the thin arcs stay visible against the gray fills.
#let (b-edge, c-edge) = (rgb("#c0281e"), rgb("#1a7f26"))

#canvas({
  draw.set-style(stroke: (thickness: 0.4pt))
  draw.set-viewport((0, 0), (20, 20), bounds: (12, 12))

  let unit-arc(..style) = arc(
    (0, 0),
    radius: 1,
    start: 0deg,
    stop: 180deg,
    anchor: "origin",
    ..style,
  )
  // F_0: strip |Re τ| <= 1/2 outside the unit circle
  draw.clip(
    circle((0, 0), radius: 1),
    rect((-0.5, 0), (0.5, ymax), fill: rgb(128, 128, 128).lighten(80%), stroke: none),
    mode: "outside",
  )
  // F'_0 = S(F_0): upper unit half-disk outside the circles |τ ± 1| = 1
  draw.clip(
    {
      circle((-1, 0), radius: 1)
      circle((1, 0), radius: 1)
    },
    unit-arc(mode: "CLOSE", fill: gray.lighten(30%), stroke: none),
    mode: "outside",
  )

  unit-arc(stroke: b-edge, name: "B-arc")
  // C and C' lie on the circles |τ ± 1| = 1, both ending at the origin
  for (start, name, arc-anchor, label-anchor, label-pos, label) in (
    (0deg, "C-arc", "start", "north-east", "C-arc.45%", $C$),
    (90deg, "C-prime-arc", "end", "north-west", "C-prime-arc.55%", $C'$),
  ) {
    arc(
      (0, 0),
      radius: 1,
      start: start,
      stop: start + 90deg,
      stroke: c-edge,
      name: name,
      anchor: arc-anchor,
    )
    content(label-pos, label, fill: green, anchor: label-anchor, padding: 2pt)
  }

  let arrow-style = (mark: (end: "stealth", fill: black, scale: 0.2), stroke: (thickness: 0.4pt))
  line((-1, 0), (1, 0), ..arrow-style)
  line((0, -0.5), (0, ymax), ..arrow-style, name: "y-axis")

  line((-0.02, 1), (0.02, 1), name: "i-tick", stroke: (thickness: 0.6pt))
  content("i-tick", $i$, anchor: "north-west", padding: 1pt)

  content("B-arc.60%", $B$, fill: red, anchor: "south", padding: (0, 0, 3pt))
  content("B-arc.40%", $B'$, fill: red, anchor: "south", padding: (0, 0, 3pt))

  // Strip edges A and A' at x = -1/2 and 1/2, each with its tick on the real axis
  for (x, tick-label, name, label, anchor, padding) in (
    (-0.5, $-1 \/ 2$, "A-line", $A$, "east", (0, 4pt, 0, 0)),
    (0.5, $1 \/ 2$, "A-prime-line", $A'$, "west", (0, 0, 0, 4pt)),
  ) {
    line((x, -0.02), (x, 0.02))
    content((x, -0.08), tick-label, anchor: "north")
    line(
      (x, 0),
      (x, ymax),
      stroke: (paint: blue),
      mark: (end: "stealth", fill: blue, scale: 0.2),
      name: name,
    )
    content(name + ".80%", label, fill: blue, anchor: anchor, padding: padding)
  }

  content("y-axis.80%", $F_0$, anchor: "west", padding: (0, 0, 0, 2pt))
  content((rel: (-0.2, -0.2), to: "B-arc.50%"), $F'_0$)
})
