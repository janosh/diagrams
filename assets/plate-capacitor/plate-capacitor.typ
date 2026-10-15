#import "@preview/cetz:0.5.2": canvas, draw
#import draw: anchor, content, group, line, rect

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 12pt)

#let height = 5
#let width = 4
#let plate-width = 0.5
#let diel-width = 0.16 * width
#let n-field-lines = 7
#let n-charges = 7

#let e-color = rgb("#b35900")
#let plus-color = rgb("#b81e00").transparentize(20%)
#let minus-color = rgb("#0044cc").transparentize(20%)

#let plate(x, is-anode: true) = {
  let color = if is-anode { plus-color } else { minus-color }
  let fill-base = if is-anode { rgb("#f29797") } else { rgb("#9fc2f6") }
  let sign = if is-anode { $+$ } else { $-$ }

  rect(
    (x, 0),
    (x + plate-width, height),
    stroke: (paint: color, thickness: .7pt),
    fill: gradient.linear(fill-base.lighten(50%), fill-base, angle: 90deg),
  )
  content((x + plate-width / 2, height + 0.1), text(fill: color)[$sign Q_"C"$], anchor: "south")
  for idx in range(n-charges) {
    content((x + plate-width / 2, idx * height / n-charges + 0.325), text(fill: color)[$sign$])
  }
}

// capsule from corner `x` to corner `y`: negative (blue) left half, positive (red) right half
#let dipole(x, y, ..style) = group({
  let shade(color) = gradient.linear(angle: 90deg, color.lighten(30%), color.darken(30%))
  rect(
    x,
    ((x, "|-", y), 50%, y),
    fill: shade(minus-color),
    radius: (west: .5),
    name: "minus",
    ..style,
  )
  rect(
    y,
    ((x, "-|", y), 50%, x),
    fill: shade(plus-color),
    radius: (east: .5),
    name: "plus",
    ..style,
  )
  // cetz centers the text line box rather than the glyph, which leaves both symbols
  // sitting ~10% of the capsule height low; -0.07em measures out within 0.1% of center
  let symbol(sign) = text(baseline: -0.07em, sign)
  content("plus", symbol[+])
  content("minus", symbol[--])
})

#canvas({
  // Dielectric slab
  rect(
    (diel-width, -0.03 * height),
    (width - diel-width, 1.08 * height),
    stroke: e-color,
    fill: rgb("#e1d8cb"), // muted orange
  )
  content((width / 2, 1.15 * height), text(fill: e-color)[$arrow(E)$])
  // bound surface charges, opposite in sign to the free charge on the adjacent plate
  for (x, label, color) in (
    (width * 0.8, $+Q_"surf"$, plus-color),
    (1.3 * diel-width, $-Q_"surf"$, minus-color),
  ) { content((x, 1.09 * height), text(fill: color, label), anchor: "south") }

  // Electric field lines
  for idx in range(n-field-lines) {
    let y = (idx + 0.42) * height / n-field-lines
    line(
      (-plate-width, y),
      (width + plate-width, y),
      stroke: (paint: e-color, thickness: 1.2pt),
      mark: (pos: 0.5, end: "stealth", fill: e-color),
    )
  }

  plate(width, is-anode: false) // right plate (cathode)
  plate(-plate-width, is-anode: true) // left plate (anode)

  // Dipoles between the field lines
  for x in (0.3, 0.5, 0.7) {
    for idx in range(n-field-lines) {
      let y = (idx + 0.94) * height / n-field-lines
      dipole((x * width - 0.3, y - 0.12), (x * width + 0.3, y + 0.12), stroke: 0.5pt)
    }
  }
})
