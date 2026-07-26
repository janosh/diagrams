// Right-hand side of a one-loop functional-RG flow equation: a loop closed by two
// three-point vertices plus a regulator insertion, added to a tadpole carrying a
// four-point vertex. Shared by the gravitons and feynman-diagram-loops assets, which
// differ only in the left-hand side, the momentum letter and their external leg style.

#import "@preview/cetz:0.5.2": decorations, draw
#import draw: arc, circle, content, line, mark
#import "feynman.typ" as fey

#let wavy = (amplitude: .1, segment-length: .18, stroke: .9pt)
#let radius = 1.15

#let _vertex(pos) = circle(pos, radius: .075, fill: black, stroke: none)

// Point on a loop of the given radius, `turn` measured counter-clockwise from 3 o'clock.
#let _on(center, turn, r: radius) = (
  center.at(0) + r * calc.cos(turn),
  center.at(1) + r * calc.sin(turn),
)

// A wavy quarter/half arc of the loop, optionally carrying a clockwise arrowhead and
// momentum label at its midpoint.
#let _propagator(center, from, to, loop, label: none) = {
  decorations.wave(
    arc(center, radius: radius, start: from, stop: to, anchor: "origin"),
    ..wavy,
  )
  if label == none { return }
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
  content(_on(center, mid, r: radius + 0.33), label)
}

// `momentum` is the loop-momentum symbol; `leg` draws an external line between two points.
#let flow-diagrams(momentum, leg) = {
  // three-point vertices at 9 and 3 o'clock, regulator insertion at 6 o'clock
  let hub = (0, 0)
  circle(hub, radius: radius, stroke: none, name: "loop")
  for (from, to, labeled) in (
    (180deg, 90deg, true),
    (90deg, 0deg, false),
    (0deg, -90deg, true),
    (-90deg, -180deg, true),
  ) {
    _propagator(hub, from, to, "loop", label: if labeled { momentum })
  }
  leg(_on(hub, 180deg), (-radius - 1.25, 0))
  leg(_on(hub, 0deg), (radius + 1.25, 0))
  _vertex(_on(hub, 180deg))
  _vertex(_on(hub, 0deg))
  fey.cross(_on(hub, -90deg), padding: -3pt)

  content((radius + 1.8, 0), $+$)

  // tadpole: both external legs meet one four-point vertex, regulator opposite it
  let bubble = (2 * radius + 3.7, 0)
  circle(bubble, radius: radius, stroke: none, name: "bubble")
  for (from, to) in ((180deg, 0deg), (0deg, -180deg)) {
    _propagator(bubble, from, to, "bubble", label: momentum)
  }
  for dy in (0.85, -0.85) {
    leg(_on(bubble, 180deg), (bubble.at(0) - radius - 1.25, dy))
  }
  _vertex(_on(bubble, 180deg))
  fey.cross(_on(bubble, 0deg), padding: -3pt)
}
