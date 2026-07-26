#import "@preview/cetz:0.5.2": canvas, draw
#import draw: anchor, circle, content, group, line, rotate, set-origin

#set page(width: auto, height: auto, margin: 8pt, fill: none)

// === Circuit symbol toolkit ===
// Each symbol is a named cetz group carrying its own terminal anchors, so the schematic
// below can be wired up purely by anchor name (e.g. "M1.G" to "R1.R").

// Wire two anchors with a single right-angle bend, running horizontally first.
#let wire(from, to, ..styling) = line(from, (from, "|-", to), to, ..styling)

// Draw `body` at `position` inside a named group, register `anchors`, then place `label`.
#let symbol(
  position,
  name,
  body,
  anchors,
  label: none,
  label-pos: "center",
  label-anchor: "center",
  label-offset: (0, 0),
  label-size: 8pt,
  rotate-by: 0deg,
  ..styling,
) = {
  group(name: name, ..styling, {
    set-origin(position)
    rotate(rotate-by)
    body(..styling)
    for (anchor-name, pos) in anchors { anchor(anchor-name, pos) }
    if label != none {
      content(
        (rel: label-offset, to: label-pos),
        text(size: label-size, label),
        anchor: label-anchor,
      )
    }
  })
}

// Terminals of a horizontal two-terminal part, under both circuit (L/R/T/B) and
// compass names so labels can be positioned either way.
#let lr-anchors(left, right, half-height) = (
  L: (left, 0),
  west: (left, 0),
  R: (right, 0),
  east: (right, 0),
  T: (0, half-height),
  north: (0, half-height),
  B: (0, -half-height),
  south: (0, -half-height),
  center: (0, 0),
  default: (left, 0),
)

#let resistor(position, name, width: 0.8, height: 0.3, zigs: 3, lead: 0.3, ..opts) = {
  let (half-w, half-h) = (width / 2, height / 2)
  let (left, right) = (-half-w - lead, half-w + lead)
  let segments = zigs * 2
  let seg-w = width / segments
  let body(..styling) = {
    // one flat lead, then `segments` alternating half-height zigs, then the other lead
    let sign = 1
    line(
      (left, 0),
      (-half-w, 0),
      (rel: (seg-w / 2, half-h)),
      ..for _ in range(segments - 1) {
        sign *= -1
        ((rel: (seg-w, half-h * 2 * sign)),)
      },
      (rel: (seg-w / 2, half-h)),
      (right, 0),
      ..styling,
    )
  }
  symbol(
    position,
    name,
    body,
    lr-anchors(left, right, half-h),
    label-pos: "south",
    label-anchor: "north",
    label-offset: (0, -0.1),
    ..opts,
  )
}

#let capacitor(position, name, plate-height: 0.6, gap: 0.2, lead: 0.5, ..opts) = {
  let (half-gap, half-h) = (gap / 2, plate-height / 2)
  let (left, right) = (-half-gap - lead, half-gap + lead)
  let body(..styling) = {
    line((left, 0), (-half-gap, 0), ..styling)
    line((-half-gap, -half-h), (-half-gap, half-h), ..styling)
    line((half-gap, half-h), (half-gap, -half-h), ..styling)
    line((half-gap, 0), (right, 0), ..styling)
  }
  symbol(
    position,
    name,
    body,
    lr-anchors(left, right, half-h),
    label-pos: "south",
    label-anchor: "north",
    label-offset: (0, -0.1),
    ..opts,
  )
}

#let nmos-transistor(
  position,
  name,
  width: 0.9,
  height: 1.2,
  arrow-scale: 0.8,
  ..opts,
) = {
  let mid-y = height / 2
  let (gate-x, channel-x) = (0.3 * width, 0.4 * width)
  let reach = 0.35 * height // half-length of the vertical gate and channel bars
  let (gate, drain, source) = ((-0.3 * width, mid-y), (width, height), (width, 0))
  let bulk = (1.3 * width, mid-y)
  let body(..styling) = {
    for x in (channel-x, gate-x) {
      line((x, mid-y - reach), (x, mid-y + reach), ..styling, thickness: 1.2pt)
    }
    line(gate, (gate-x, mid-y), ..styling)
    line((channel-x, mid-y), bulk, ..styling)
    line(drain, (width, mid-y + reach), ..styling)
    line((width, mid-y + reach), (channel-x, mid-y + reach), ..styling)
    line((width, mid-y - reach), source, ..styling)
    line(
      (channel-x, mid-y - reach),
      (width, mid-y - reach),
      ..styling,
      mark: (end: "stealth", fill: black, scale: arrow-scale),
    )
  }
  symbol(
    position,
    name,
    body,
    (
      G: gate,
      D: drain,
      S: source,
      B: bulk,
      north: (width / 2, height),
      south: (width / 2, 0),
      east: (width, mid-y),
      west: (0, mid-y),
      center: (width / 2, mid-y),
      default: gate,
    ),
    label-pos: "D",
    label-anchor: "north-west",
    label-offset: (0.05, 0.05),
    ..opts,
  )
}

// Three stacked bars of shrinking width below a short lead.
#let gnd-symbol(position, name, lead: 0.3, bar-width: 0.5, spacing: 0.05, ..opts) = {
  let widths = (1.0, 0.7, 0.4).map(factor => bar-width * factor / 2)
  let body(..styling) = {
    line((0, 0), (0, -lead), ..styling)
    for (idx, half-w) in widths.enumerate() {
      line((-half-w, -lead - idx * spacing), (half-w, -lead - idx * spacing), ..styling)
    }
  }
  let bottom = -lead - 2 * spacing
  symbol(
    position,
    name,
    body,
    (
      T: (0, 0),
      north: (0, 0),
      south: (0, bottom),
      west: (-widths.first(), -lead),
      east: (widths.first(), -lead),
      center: (0, (-lead + bottom) / 2),
      default: (0, 0),
    ),
    label-pos: "north",
    label-anchor: "south",
    label-offset: (0, 0.1),
    ..opts,
  )
}

// Supply rail: a short stem capped by a horizontal bar.
#let vdd-symbol(position, name, stem: 0.3, bar-width: 0.5, ..opts) = {
  let half-w = bar-width / 2
  let body(..styling) = {
    line((0, 0), (0, stem), ..styling)
    line((-half-w, stem), (half-w, stem), ..styling)
  }
  symbol(
    position,
    name,
    body,
    (
      B: (0, 0),
      south: (0, 0),
      T: (0, stem),
      north: (0, stem),
      west: (-half-w, stem),
      east: (half-w, stem),
      center: (0, stem / 2),
      default: (0, 0),
    ),
    label-pos: "north",
    label-anchor: "south",
    label-offset: (0, 0.1),
    ..opts,
  )
}

// Circle with leads top and bottom, annotated by a voltage arrow to its left.
#let voltage-source(
  position,
  name,
  label: none,
  radius: 0.3,
  lead: 0.3,
  arrow-offset: 0.7,
  label-size: 8pt,
  ..opts,
) = {
  let arrow-x = -radius * (1 + arrow-offset)
  let half-arrow = radius // half of the arrow's length, which spans 2 * radius
  let body(..styling) = {
    circle((0, 0), radius: radius, ..styling)
    line((0, radius), (0, radius + lead), ..styling)
    line((0, -radius), (0, -radius - lead), ..styling)
    line(
      (arrow-x, half-arrow),
      (arrow-x, -half-arrow),
      ..styling,
      mark: (end: "stealth", scale: 0.4, fill: black, stroke: (paint: black, thickness: 0.6pt)),
    )
    if label != none {
      content(
        (rel: (-0.1, 0), to: (arrow-x, 0)),
        text(size: label-size, label),
        anchor: "east",
        offset: (-0.05, 0),
      )
    }
  }
  let (top, bottom) = (radius + lead, -radius - lead)
  symbol(
    position,
    name,
    body,
    (
      T: (0, top),
      north: (0, top),
      B: (0, bottom),
      south: (0, bottom),
      east: (radius, 0),
      west: (-radius, 0),
      center: (0, 0),
      default: (0, top),
    ),
    ..opts,
  )
}

#let node(position, name, radius: 0.05, fill: white, ..opts) = {
  let diag = radius * calc.cos(45deg)
  symbol(
    position,
    name,
    (..styling) => circle((0, 0), radius: radius, ..styling, fill: fill),
    (
      center: (0, 0),
      default: (0, 0),
      north: (0, radius),
      south: (0, -radius),
      east: (radius, 0),
      west: (-radius, 0),
      north-east: (diag, diag),
      north-west: (-diag, diag),
      south-east: (diag, -diag),
      south-west: (-diag, -diag),
    ),
    ..opts,
  )
}

// === Common-source amplifier schematic ===
#canvas({
  let thin = (stroke: (thickness: .6pt))
  let x-vin = 0
  let x-r1 = 1.0
  let x-m1 = 1.9
  let x-out = x-m1 + 0.9
  let x-cl = x-out + 2.0
  let y-gate = 1.6
  let y-source = 1.0
  let y-drain = y-source + 1.2
  let y-bulk = y-source + 0.6
  let y-gnd = -1.0

  voltage-source(
    (x-vin, y-gate - 1),
    "Vin",
    label: $V_"in"$,
    radius: 0.4,
    lead: 0.2,
    ..thin,
  )
  resistor(
    (x-r1, y-gate),
    "R1",
    label: $R_1$,
    label-pos: "north",
    label-offset: (0, 0.4),
    width: 1.0,
    ..thin,
  )
  nmos-transistor(
    (x-m1, y-source),
    "M1",
    label: $M_1$,
    label-pos: "east",
    label-anchor: "west",
    label-offset: (0.3, 0.3),
    ..thin,
  )
  vdd-symbol((x-out, y-drain + 1.5), "Vdd", label: $V_"DD"$, ..thin)
  resistor(
    (x-out, y-source - 1),
    "R2",
    rotate-by: 90deg,
    label: $R_2$,
    label-pos: "west",
    label-offset: (0.5, 0.5),
    ..thin,
  )
  capacitor(
    (x-cl, y-source - 0.95),
    "CL",
    rotate-by: 90deg,
    label: $C_L$,
    label-pos: "east",
    label-offset: (-0.2, -0.5),
    ..thin,
  )
  node(
    (x-cl + 1.0, y-bulk),
    "VoutNode",
    label: $V_"out"$,
    label-offset: (0.15, 0),
    label-anchor: "west",
    ..thin,
  )

  for (name, pos) in (
    ("GND_Vin", (x-vin, y-gnd)),
    ("GND_M1B", (x-m1 + 1.27, y-bulk)),
    ("GND_R2", (x-out, y-gnd)),
    ("GND_CL", (x-cl, y-gnd)),
  ) {
    gnd-symbol(pos, name, ..thin)
  }

  for (from, to) in (
    ("Vin.T", "R1.L"),
    ("Vin.B", "GND_Vin.T"),
    ("R1.R", "M1.G"),
    ("M1.D", "Vdd.B"),
    ("M1.B", "GND_M1B.T"),
    ("M1.S", "R2.R"),
    ("GND_R2.T", "R2.L"),
    ("GND_CL.T", "CL.L"),
    ("CL.R", "M1.S"),
    ("VoutNode", "M1.S"),
  ) {
    wire(from, to, ..thin)
  }
})
