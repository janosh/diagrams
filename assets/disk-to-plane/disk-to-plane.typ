#import "@preview/cetz:0.5.2": canvas, draw
#import draw: arc, circle, content, line, rect

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 12pt)

#let radius = 1
#let axis-length = 2.5
#let arrow-sep = 3.5
#let x-shift = 8.5

#let region-fill = rgb(220, 220, 220).transparentize(60%)
#let arrow-style = (mark: (end: "stealth", fill: black, scale: 0.7), stroke: 0.8pt)
#let direction-marks(paint) = (
  end: (25%, 75%).map(pos => (
    pos: pos,
    symbol: "barbed",
    fill: paint,
    scale: 0.7,
    shorten-to: none,
  )),
)
#canvas({
  let axes(x, x-label, y-label, padding) = {
    line((x - axis-length, 0), (x + axis-length, 0), ..arrow-style, name: "x-axis")
    content("x-axis.end", x-label, anchor: "west", padding: padding)
    line((x, -axis-length), (x, axis-length), ..arrow-style, name: "y-axis")
    content("y-axis.end", y-label, anchor: "south", padding: padding)
  }

  axes(0, $x$, $y$, (0, 3pt, 2pt))

  // Transformation arrow and label
  line((arrow-sep, 0), (arrow-sep + 1.5, 0), ..arrow-style, name: "transform-arrow")
  content("transform-arrow.mid", $z &= S(w)\ &= (w + i) / (i w + 1)$, anchor: "south", padding: 4pt)

  circle((0, 0), radius: radius, stroke: 0.8pt, fill: region-fill)
  content((-0.4, 0.5), $DD^2$)

  // Boundary semicircles from w_4 = i down to w_2 = -i through w_3 = -1 (blue) and w_1 = 1 (red)
  for (pos, start, paint, thickness) in (
    ((-radius, 0), 270deg, blue, 1.2pt),
    ((radius, 0), -90deg, red, 0.8pt),
  ) {
    arc(
      pos,
      radius: radius,
      start: start,
      stop: 90deg,
      stroke: paint + thickness,
      anchor: "arc-center",
      mark: direction-marks(paint),
    )
  }

  axes(x-shift, $u$, $v$, 2pt)

  // Images of the semicircles: S maps w_3 = -1 to -1 and w_1 = 1 to 1, with w_4 to infinity and w_2 to 0
  for (direction, paint) in ((1, red), (-1, blue)) {
    line(
      (x-shift, 0),
      (x-shift + direction * axis-length, 0),
      stroke: paint + 1.2pt,
      mark: direction-marks(paint),
    )
  }

  // Upper half-plane with gray fill
  rect(
    (x-shift - axis-length, 0),
    (x-shift + axis-length, axis-length),
    stroke: none,
    fill: region-fill,
    name: "plane",
  )
  content("plane.north-west", $HH$, anchor: "north-west", padding: 4pt)

  // Leader lines connect w_0 and z_2 to their offset labels
  for (name, pos, offset, label, anchor) in (
    ("w0", (0, 0), (2, 0.75), $w_0 = 0$, "center"),
    ("w1", (radius, 0), (0.08, -0.08), $w_1 = 1$, "north-west"),
    ("w2", (0, -radius), (0.08, -0.08), $w_2 = -i$, "north-west"),
    ("w3", (-radius, 0), (-0.08, -0.08), $w_3 = -1$, "north-east"),
    ("w4", (0, radius), (0.2, 0.3), $w_4 = i$, "west"),
    ("z0", (x-shift, radius), (0.2, 0), $z_0 = i$, "west"),
    ("z1", (x-shift + radius, 0), (0, -0.4), $z_1 = 1$, "center"),
    ("z2", (x-shift, 0), (-1, 0.8), $z_2 = 0$, "center"),
    ("z3", (x-shift - radius, 0), (0, -0.4), $z_3 = -1$, "center"),
  ) {
    circle(pos, fill: gray, radius: 0.08, stroke: none, name: name)
    content((rel: offset, to: pos), label, anchor: anchor, name: name + "-label")
  }
  content((rel: (0.2, -0.2), to: "y-axis.end"), $z_4 = +i infinity$, anchor: "west")
  line("w0-label", "w0", stroke: gray + 0.5pt)
  line("z2-label", "z2", stroke: gray + 0.5pt)
})
