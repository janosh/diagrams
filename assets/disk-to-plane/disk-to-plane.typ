#import "@preview/cetz:0.5.2": canvas, draw
#import draw: arc, circle, content, line, rect

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#let radius = 1
#let axis-length = 2.5
#let arrow-sep = 3.5
#let arrow-width = 1.5
#let x-shift = 8.5

#let dot-style = (fill: gray, radius: 0.08, stroke: none)
#let arrow-style = (
  mark: (end: "stealth", fill: black, scale: 0.7),
  stroke: 0.8pt,
)
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
  let axes(origin, x-name, x-label, y-name, y-label, padding) = {
    let (x, y) = origin
    line((x - axis-length, y), (x + axis-length, y), ..arrow-style, name: x-name)
    content(x-name + ".end", x-label, anchor: "west", padding: padding)
    line((x, y - axis-length), (x, y + axis-length), ..arrow-style, name: y-name)
    content(y-name + ".end", y-label, anchor: "south", padding: padding)
  }

  axes((0, 0), "x-axis", $x$, "y-axis", $y$, (0, 3pt, 2pt))

  // Transformation arrow and label
  line(
    (arrow-sep, 0),
    (arrow-sep + arrow-width, 0),
    ..arrow-style,
    name: "transform-arrow",
  )
  content(
    (rel: (0, 0), to: "transform-arrow.mid"),
    $z &= S(w)\ &= (w + i) / (i w + 1)$,
    anchor: "south",
    padding: 4pt,
  )

  // Unit disk with gray fill
  circle(
    (0, 0),
    radius: radius,
    stroke: 0.8pt,
    fill: rgb(220, 220, 220).transparentize(60%),
    name: "disk",
  )
  content((rel: (-0.4, 0.5), to: "disk.center"), $DD^2$)

  let disk-points = (
    (name: "w0", pos: (0, 0), rel: (2, 1), label: $w_0 = 0$, args: (name: "w0-label")),
    (name: "w1", pos: (radius, 0), rel: (0.3, -0.3), label: $w_1 = 1$),
    (name: "w2", pos: (0, -radius), rel: (.8, -0.2), label: $w_2 = -i$),
    (name: "w3", pos: (-radius, 0), rel: (-0.2, -0.3), label: $w_3 = -1$),
    (name: "w4", pos: (0, radius), rel: (0.2, 0.3), label: $w_4 = i$, args: (anchor: "west")),
  )
  for point in disk-points { circle(point.pos, ..dot-style, name: point.name) }
  for point in disk-points {
    content((rel: point.rel, to: point.name), point.label, ..point.at("args", default: (:)))
  }
  line("w0-label", "w0", stroke: gray + 0.5pt)

  for (pos, start, paint, thickness, name) in (
    ((-radius, 0), 270deg, blue, 1.2pt, "blue-arc"),
    ((radius, 0), -90deg, red, 0.8pt, "red-arc"),
  ) {
    arc(
      pos,
      radius: radius,
      start: start,
      stop: 90deg,
      stroke: paint + thickness,
      anchor: "arc-center",
      mark: direction-marks(paint),
      name: name,
    )
  }

  axes((x-shift, 0), "u-axis", $u$, "v-axis", $v$, 2pt)

  for (direction, paint, name) in ((1, blue, "pos-real-line"), (-1, red, "neg-real-line")) {
    line(
      (x-shift, 0),
      (x-shift + direction * axis-length, 0),
      stroke: paint + 1.2pt,
      mark: direction-marks(paint),
      name: name,
    )
  }

  // Upper half-plane with gray fill
  rect(
    (x-shift - axis-length, 0),
    (x-shift + axis-length, axis-length),
    stroke: none,
    fill: rgb(220, 220, 220).transparentize(60%),
    name: "plane",
  )
  content("plane.north-west", $HH$, anchor: "north-west", padding: 4pt)

  let plane-points = (
    (name: "z0", pos: (x-shift, radius), rel: (0.2, 0), label: $z_0 = i$, args: (anchor: "west")),
    (name: "z1", pos: (x-shift + radius, 0), rel: (0, -0.4), label: $z_1 = 1$),
    (name: "z2", pos: (x-shift, 0), rel: (-1, 0.8), label: $z_2 = 0$, args: (name: "z2-label")),
    (name: "z3", pos: (x-shift - radius, 0), rel: (0, -0.4), label: $z_3 = -1$),
  )
  for point in plane-points { circle(point.pos, ..dot-style, name: point.name) }
  for point in plane-points {
    content((rel: point.rel, to: point.name), point.label, ..point.at("args", default: (:)))
  }
  content(
    (rel: (0.2, -0.2), to: "v-axis.end"),
    $z_4 = +i infinity$,
    anchor: "west",
  )
  line("z2-label", "z2", stroke: gray + 0.5pt)
})
