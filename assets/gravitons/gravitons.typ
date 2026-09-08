#import "@preview/cetz:0.5.2": canvas, decorations, draw
#import draw: arc, circle, content, line, mark

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#let wavy = (amplitude: .1, segment-length: .18, stroke: .9pt)
#let radius = 1.15

#let graviton(from, to) = decorations.wave(line(from, to), ..wavy)
#let vertex(pos) = circle(pos, radius: .075, fill: black, stroke: none)
#let regulator(pos) = {
  let radius = .18
  let arm = radius / calc.sqrt(2)
  circle(pos, radius: radius, fill: white, stroke: .8pt)
  for direction in (-1, 1) {
    line(
      (rel: (-arm, direction * arm), to: pos),
      (rel: (arm, -direction * arm), to: pos),
      stroke: .8pt,
    )
  }
}

// Point at `turn` around `center`, measured counter-clockwise from 3 o'clock. `out`
// pushes past the loop rim, which is where the momentum labels sit.
#let on-loop(center, turn, out: 0) = (
  center.at(0) + (radius + out) * calc.cos(turn),
  center.at(1) + (radius + out) * calc.sin(turn),
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
  content(on-loop(center, mid, out: 0.33), $p$)
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
  regulator(on-loop(hub, -90deg))

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
  regulator(on-loop(bubble, 0deg))
})
