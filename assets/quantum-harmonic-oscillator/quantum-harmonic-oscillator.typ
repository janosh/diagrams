#import "@preview/cetz:0.5.2": canvas, draw
#import "@preview/cetz-plot:0.1.4": plot

#set page(width: 780pt, height: auto, margin: 22pt, fill: white)
#set text(font: "Avenir Next", size: 10.5pt, fill: rgb("#19324f"))
#set par(leading: 0.55em)

// Measure each drawing before fitting it; keep labels and geometry together.
#let fit-figure(body, height: 170pt) = layout(size => {
  let bounds = measure(body)
  let factor = calc.min(size.width / bounds.width, height / bounds.height)
  box(width: 100%, align(center + horizon, std.scale(factor * 100%, reflow: true, body)))
})
#let card(title, body, caption, height: 210pt) = block(
  width: 100%,
  inset: 12pt,
  radius: 8pt,
  fill: rgb("#f3f6fa"),
  breakable: false,
)[
  #text(size: 13pt, weight: "bold", title)
  #v(8pt)
  #fit-figure(body, height: height)
  #v(7pt)
  #caption
]
#let takeaway(body) = block(
  width: 100%,
  inset: 12pt,
  radius: 6pt,
  fill: rgb("#e9f5f2"),
  breakable: false,
)[#body]

// Stable coth form preserves the classical limit and avoids exp overflow.
#let energy-in-quanta(x) = {
  assert(x > 0, message: "beta hbar omega must be positive")
  1 / (2 * calc.tanh(x / 2))
}
#let energy-in-thermal-units(x) = {
  assert(x >= 0, message: "beta hbar omega must be nonnegative")
  if x == 0 { 1 } else { x * energy-in-quanta(x) }
}

// === 1  Increase frequency at fixed temperature ===
#let figure-0 = [
  #canvas({
    draw.set-style(legend: (fill: white))
    plot.plot(
      size: (9, 6),
      x-min: 0,
      x-max: 8,
      y-min: 0,
      y-max: 4.2,
      x-label: none,
      y-label: $chevron.l E chevron.r \/ (k_"B" T)$,
      axis-style: "left",
      x-tick-step: 2,
      y-tick-step: 1,
      legend-style: (item: (spacing: .12), padding: .15, stroke: .4pt),
      legend: "inner-north-west",
      {
        plot.add(
          style: (stroke: (paint: rgb("#c2570a"), thickness: 1pt, dash: "dashed")),
          domain: (0.1, 8),
          x => x / 2,
          label: [zero-point contribution],
        )
        plot.add(
          style: (stroke: rgb("#008580") + 1.8pt),
          domain: (0.03, 8),
          samples: 240,
          energy-in-thermal-units,
          label: [quantum mean energy],
        )
      },
    )
    draw.content((4.5, -0.8), $x = ℏ omega \/ (k_"B" T)$)
  })
]

// === 2  Cool at fixed frequency ===
#let figure-1 = [
  #canvas({
    draw.set-style(legend: (fill: white))
    plot.plot(
      size: (9, 6),
      x-min: 0,
      x-max: 8,
      y-min: 0,
      y-max: 4.2,
      x-label: none,
      y-label: $chevron.l E chevron.r \/ (ℏ omega)$,
      axis-style: "left",
      x-tick-step: 2,
      y-tick-step: 1,
      legend-style: (item: (spacing: .12), padding: .15, stroke: .4pt),
      legend: "inner-north-east",
      {
        plot.add(
          style: (stroke: (paint: rgb("#c2570a"), thickness: 1pt, dash: "dashed")),
          domain: (0.1, 8),
          x => 0.5,
          label: [zero-point floor],
        )
        plot.add(
          style: (stroke: rgb("#008580") + 1.8pt),
          domain: (0.03, 8),
          samples: 240,
          energy-in-quanta,
          label: [quantum mean energy],
        )
      },
    )
    draw.content((4.5, -0.8), $x = beta ℏ omega$)
  })
]

#text(size: 27pt, weight: "bold")[Quantum Harmonic Oscillator]
#v(5pt)
One energy formula connects thermal motion with zero-point motion. Compare the level spacing $ℏ omega$ with the thermal energy $k_"B" T$.
#v(14pt)
#grid(
  columns: (1fr, 1fr),
  gutter: 12pt,
  card(
    [1  Increase frequency at fixed temperature],
    figure-0,
    [At small level spacing, $chevron.l E chevron.r approx k_"B" T$: classical equipartition. At large spacing the zero-point term dominates. The energy rises monotonically.],
  ),
  card(
    [2  Cool at fixed frequency],
    figure-1,
    [Move right by increasing $beta=1/(k_"B" T)$. Thermal excitations freeze out; the mean energy approaches $ℏ omega/2$, rather than zero.],
  ),
)
#v(12pt)
#takeaway[$chevron.l E chevron.r = ℏ omega (1/2 + 1/(e^(beta ℏ omega)-1))$. *The same horizontal variable, two energy units.* $omega$ is angular frequency; $ℏ$ is the reduced Planck constant.]
