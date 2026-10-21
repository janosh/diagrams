#import "@preview/cetz:0.5.3": canvas, draw
#import draw: circle, content, line

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 22pt)

// SU(3) flavor weight diagram of the spin-1/2 baryon octet. Hypercharge is scaled by
// sqrt(3)/2 relative to isospin, which makes the weight diagram a regular hexagon.
#let y-scale = calc.sqrt(3) / 2
#let pos(i3, y) = (i3, y * y-scale)

#let charge-color(q) = (rgb("#1864ab"), rgb("#5c4f8a"), rgb("#c92a2a")).at(q + 1)
#let ink = rgb("#343a40")
#let node-rad = 0.36

// (I3, Y, name, quark content); the charge follows from Gell-Mann-Nishijima Q = I3 + Y/2
#let baryons = (
  (-0.5, 1, $n$, "udd"),
  (0.5, 1, $p$, "uud"),
  (-1, 0, $Sigma^-$, "dds"),
  (1, 0, $Sigma^+$, "uus"),
  (-0.5, -1, $Xi^-$, "dss"),
  (0.5, -1, $Xi^0$, "uss"),
)

#canvas(length: 2.7cm, {
  // lines of constant charge Q = I3 + Y/2, i.e. I3 = Q - Y/2
  for q in (-1, 0, 1) {
    let col = charge-color(q)
    // run each line from just above its topmost baryon down to the label row
    let (y-lo, y-hi) = (-1.7, if q < 0 { 0.5 } else { 1.45 })
    line(pos(q - y-hi / 2, y-hi), pos(q - y-lo / 2, y-lo), stroke: (
      paint: col.transparentize(25%),
      thickness: 1.6pt,
      dash: "dashed",
    ))
    let label = if q > 0 { $Q = +1$ } else { $Q = #q$ }
    content(
      pos(q - y-lo / 2, y-lo),
      text(fill: col, size: 17pt, label),
      anchor: "north",
      padding: 0.03,
    )
  }

  // weight axes
  let axis-style = (stroke: ink + 1.1pt, mark: (end: "stealth", fill: ink, scale: 1.3))
  line(pos(-1.5, 0), pos(1.62, 0), ..axis-style)
  content(pos(1.62, 0), $I_3$, anchor: "south-east", padding: (bottom: 0.06))
  line(pos(0, -1.45), pos(0, 1.72), ..axis-style)
  content(pos(0, 1.72), $Y$, anchor: "north-west", padding: (left: 0.08))

  // hexagon through the six outer weights
  let corners = ((0.5, 1), (1, 0), (0.5, -1), (-0.5, -1), (-1, 0), (-0.5, 1)).map(((i, y)) => pos(
    i,
    y,
  ))
  line(..corners, close: true, stroke: ink + 1.6pt)

  let node(at, col, body, quarks, radii: (node-rad,)) = {
    for (k, radius) in radii.enumerate() {
      circle(at, radius: radius, fill: if k == 0 { col.lighten(68%) }, stroke: col + 2pt)
    }
    content((at.at(0), at.at(1) + 0.08), text(fill: col.darken(25%), body))
    content((at.at(0), at.at(1) - 0.19), text(fill: col.darken(15%), size: 13pt, quarks))
  }
  for (i3, y, name, quarks) in baryons {
    node(pos(i3, y), charge-color(int(i3 + y / 2)), name, quarks)
  }
  // Sigma0 and Lambda share the central weight (I3 = Y = 0): a doubly occupied site
  node(pos(0, 0), charge-color(0), $Sigma^0 #h(0.25em) Lambda$, "uds", radii: (
    node-rad + 0.04,
    node-rad + 0.12,
  ))
})
