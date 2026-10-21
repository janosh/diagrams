#import "@preview/cetz:0.5.3": canvas, decorations, draw
#import draw: circle, content, line

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 22pt)

#let lepton = rgb("#1c62b0")
#let photon = rgb("#d9480f")
#let quark = rgb("#2b8a3e")
#let gluon = rgb("#8e3fae")
#let ink = rgb("#222831")

#let weight = 2.6pt

// Straight fermion line with an arrowhead at its midpoint. `reverse` flips the arrow
// against the drawing direction (antiparticle lines run backwards in time).
#let fermion(from, to, color, reverse: false) = {
  line(from, to, stroke: color + weight)
  let (a, b) = if reverse { (to, from) } else { (from, to) }
  line(
    (a, 50%, b),
    ((a, 50%, b), 0.24, b),
    stroke: color + weight,
    mark: (end: "stealth", fill: color, scale: 1.3, stroke: (join: "miter")),
  )
}

#let vertex(pos) = circle(pos, radius: .11, fill: ink, stroke: none)

#canvas(length: 1cm, {
  let (a, b) = ((-1.15, 0), (1.05, 0)) // annihilation and pair-creation vertices
  let (e-minus, e-plus) = ((-2.6, 2.2), (-2.6, -2.2))
  let (q-end, qbar-end) = ((2.45, 2.25), (2.45, -2.2))
  let g-vtx = (b, 50%, q-end) // gluon emission vertex halfway along the outgoing quark
  let g-end = (3.4, 0.7)

  // incoming leptons: e- flows into the vertex, e+ arrow points back out of it
  fermion(e-minus, a, lepton)
  fermion(e-plus, a, lepton, reverse: true)

  // virtual photon
  decorations.wave(line(a, b), amplitude: .22, segments: 4, stroke: photon + weight)

  // outgoing quark (arrow away from vertex) and antiquark (arrow back toward it)
  fermion(b, g-vtx, quark)
  fermion(g-vtx, q-end, quark)
  fermion(b, qbar-end, quark, reverse: true)

  // radiated gluon
  decorations.coil(
    line(g-vtx, g-end),
    amplitude: .34,
    segments: 7,
    factor: 160%,
    stroke: gluon + weight,
  )

  for pos in (a, b, g-vtx) { vertex(pos) }

  // particle labels
  content((rel: (-0.05, 0.38), to: e-minus), text(fill: lepton, $e^-$), anchor: "south")
  content((rel: (-0.05, -0.38), to: e-plus), text(fill: lepton, $e^+$), anchor: "north")
  content((0, 0.42), text(fill: photon, $gamma^*$), anchor: "south")
  content((rel: (0.1, 0.38), to: q-end), text(fill: quark, $q$), anchor: "south")
  content((rel: (0.1, -0.38), to: qbar-end), text(fill: quark, $overline(q)$), anchor: "north")
  content((rel: (0.3, 0), to: g-end), text(fill: gluon, $g$), anchor: "west")

  // time arrow
  let y-time = -3.55
  line(
    (-1.4, y-time),
    (1.4, y-time),
    stroke: ink + 1.6pt,
    mark: (end: "stealth", fill: ink, scale: 0.9),
  )
  content((1.6, y-time), text(size: 18pt, fill: ink, $t$), anchor: "west")
})
