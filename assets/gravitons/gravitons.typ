#import "@preview/cetz:0.5.2": canvas, decorations, draw
#import draw: arc, circle, content, line, mark
#import "../_shared/feynman.typ" as fey

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#let wavy = (amplitude: .1, segment-length: .18, stroke: .9pt)
#let radius = 1.15

#let graviton(from, to) = decorations.wave(line(from, to), ..wavy)
#let vertex(pos) = circle(pos, radius: .075, fill: black, stroke: none)

// Point on a loop of the given radius, `turn` measured counter-clockwise from 3 o'clock.
#let on-loop(center, turn) = (
  center.at(0) + radius * calc.cos(turn),
  center.at(1) + radius * calc.sin(turn),
)

// A wavy arc of the loop, optionally carrying a clockwise arrowhead and momentum
// label at its midpoint.
#let propagator(center, loop, from, to, labeled: true) = {
  decorations.wave(arc(center, radius: radius, start: from, stop: to, anchor: "origin"), ..wavy)
  if not labeled { return }
  let mid = (from + to) / 2
  mark(
    (name: loop, anchor: mid + 2deg),
    (name: loop, anchor: mid),
    symbol: "stealth",
    width: .22,
    length: .16,
    scale: .8,
    fill: black,
    stroke: .7pt,
  )
  // sit the label just outside the rim
  let out = radius + 0.33
  content((center.at(0) + out * calc.cos(mid), center.at(1) + out * calc.sin(mid)), $p$)
}

// One-loop flow of the graviton effective potential. Every line is a graviton, so the
// external legs are drawn wavy like the propagators inside the loops.
#canvas({
  content((-2.55, 0), $partial_t V_g space =$, anchor: "east")

  // three-point vertices at 9 and 3 o'clock, regulator insertion at 6 o'clock
  let hub = (0, 0)
  circle(hub, radius: radius, stroke: none, name: "loop")
  for (from, to, labeled) in (
    (180deg, 90deg, true),
    (90deg, 0deg, false),
    (0deg, -90deg, true),
    (-90deg, -180deg, true),
  ) {
    propagator(hub, "loop", from, to, labeled: labeled)
  }
  graviton(on-loop(hub, 180deg), (-radius - 1.25, 0))
  graviton(on-loop(hub, 0deg), (radius + 1.25, 0))
  vertex(on-loop(hub, 180deg))
  vertex(on-loop(hub, 0deg))
  fey.cross(on-loop(hub, -90deg), padding: -3pt)

  content((radius + 1.8, 0), $+$)

  // tadpole: both external legs meet one four-point vertex, regulator opposite it
  let bubble = (2 * radius + 3.7, 0)
  circle(bubble, radius: radius, stroke: none, name: "bubble")
  for (from, to) in ((180deg, 0deg), (0deg, -180deg)) {
    propagator(bubble, "bubble", from, to)
  }
  for dy in (0.85, -0.85) {
    graviton(on-loop(bubble, 180deg), (bubble.at(0) - radius - 1.25, dy))
  }
  vertex(on-loop(bubble, 180deg))
  fey.cross(on-loop(bubble, 0deg), padding: -3pt)
})
