#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, line, rect
#set page(width: 660pt, height: auto, margin: 20pt, fill: none)
#set text(font: "Avenir Next", size: 10.5pt, fill: rgb("#19324f"))
#set par(leading: 0.55em)
#let panel = block.with(
  width: 100%,
  inset: 12pt,
  radius: 7pt,
  fill: rgb("#cdd3da"),
  breakable: false,
)

// A one-degree-of-freedom oscillator uses canonical coordinates (q,p), not two positions.
#let oscillator_energy(q, p, mass: 1, stiffness: 1) = p * p / (2 * mass) + stiffness * q * q / 2
#let shell_energy = 1
#let shell_width = .25
#let shell_axes(energy, mass: 1, stiffness: 1) = (
  calc.sqrt(2 * energy / stiffness),
  calc.sqrt(2 * mass * energy),
)
#let angle_point(time, ratio) = (calc.rem(time, 1), calc.rem(time * ratio, 1))
#let orbit(ratio, turns: 1) = canvas(length: 1pt, {
  rect((0, 0), (210, 125), fill: rgb("#cdd3da"), stroke: rgb("#78828c") + .6pt)
  let previous = angle_point(0, ratio)
  for step in range(1, turns * 120 + 1) {
    let point = angle_point(step / 120, ratio)
    // Break at identified edges: never draw a spurious chord across a wrap.
    if calc.abs(point.at(0) - previous.at(0)) < .1 and calc.abs(point.at(1) - previous.at(1)) < .1 {
      line(
        (210 * previous.at(0), 125 * previous.at(1)),
        (210 * point.at(0), 125 * point.at(1)),
        stroke: rgb("#0b5fa5") + .65pt,
      )
    }
    previous = point
  }
  content((105, -15), $theta_1: 0 arrow.r 2pi$)
  content((-12, 62), rotate(-90deg, reflow: true)[$theta_2: 0 arrow.r 2pi$])
})
#panel[
  #text(size: 14pt, weight: "bold")[1  One oscillator: volume, contour, shell]
  #v(9pt)
  #grid(
    columns: (280pt, 1fr),
    gutter: 14pt,
    align: horizon,
    align(center, canvas(length: 1pt, {
      let inner = shell_axes(shell_energy)
      let outer = shell_axes(shell_energy + shell_width)
      let scale_q = 70
      let scale_p = 45
      circle(
        (0, 0),
        radius: (scale_q * outer.at(0), scale_p * outer.at(1)),
        fill: rgb("#c6d8d2"),
        stroke: rgb("#286744") + 1pt,
      )
      circle(
        (0, 0),
        radius: (scale_q * inner.at(0), scale_p * inner.at(1)),
        fill: rgb("#cdd3da"),
        stroke: rgb("#0b5fa5") + 1.5pt,
      )
      line((-125, 0), (125, 0), stroke: rgb("#19324f") + .7pt, mark: (end: "stealth"))
      line((0, -83), (0, 83), stroke: rgb("#19324f") + .7pt, mark: (end: "stealth"))
      content((130, 0), $q$)
      content((0, 90), $p$)
      content((52, 20), $H < E$)
      content((45, -84), text(fill: rgb("#0b5fa5"))[$H=E$])
      line((45, -75), (55, -53), stroke: rgb("#0b5fa5") + .7pt)
      content((-60, 90), text(fill: rgb("#286744"))[$E < H < E+Delta E$])
    })),
    [
      $H(q,p) = p^2/(2m) + k q^2/2$
      #v(6pt)
      $q_(max)=sqrt(2E/k), quad p_(max)=sqrt(2 m E)$
      #v(6pt)
      Interior: $H < E$\ Blue contour: $H=E$\ Green shell: $E < H < E+Delta E$
      #v(6pt)
      Axes scaled independently; shell exaggerated.
    ],
  )
]
#v(12pt)
#grid(
  columns: (1fr, 1fr),
  gutter: 12pt,
  panel[
    #text(size: 14pt, weight: "bold")[2  Rational: closed orbit]
    #v(8pt)
    #align(center, orbit(2))
    #v(8pt)
    #align(center)[$omega_2 \/ omega_1=2$ · Opposite edges identified.]
  ],
  panel[
    #text(size: 14pt, weight: "bold")[3  Irrational: dense orbit]
    #v(8pt)
    #align(center, orbit(calc.sqrt(2), turns: 24))
    #v(8pt)
    #align(center)[$omega_2 \/ omega_1=sqrt(2)$ · Finite segment shown.]
  ],
)
#v(12pt)
#block(
  width: 100%,
  inset: 10pt,
  radius: 5pt,
  fill: rgb("#c6d8d2"),
  breakable: false,
)[Irrational flow is ergodic on its *fixed-action torus* with uniform angle measure, not generally on the full energy surface.]
