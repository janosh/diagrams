#import "@preview/cetz:0.5.2": canvas, draw
#import "@preview/cetz-plot:0.1.4": plot
#let label-size = 12pt
#let paragraph-size = 14pt
#let heading-size = 16pt

#let card_body(title, body, caption) = block(
  width: 100%,
  inset: 12pt,
  radius: 8pt,
  fill: rgb("#cdd3da"),
  breakable: false,
)[
  #text(size: heading-size, weight: "bold", title)
  #v(8pt)
  // Measure unconstrained artwork before scaling, including content wider than its card.
  #layout(size => {
    let artwork = text(size: label-size, body)
    std.scale(size.width / measure(artwork).width * 100%, reflow: true, artwork)
  })
  #v(7pt)
  #text(size: paragraph-size, caption)
]

#let card-grid(columns: 2, ..cards) = layout(size => {
  let rows = cards
    .pos()
    .chunks(columns)
    .map(row => {
      let ratios = row.map(card => {
        let bounds = measure(text(size: label-size, card.at(1)))
        bounds.width / bounds.height
      })
      let available = size.width - 12pt * (row.len() - 1) - 24pt * row.len()
      grid(
        columns: ratios.map(ratio => 24pt + available * ratio / ratios.sum()),
        gutter: 12pt,
        ..row.map(args => card_body(..args)),
      )
    })
  stack(dir: ttb, spacing: 12pt, ..rows)
})

#let takeaway(body) = block(
  width: 100%,
  inset: 12pt,
  radius: 6pt,
  fill: rgb("#c6d8d2"),
  breakable: false,
  text(size: paragraph-size, body),
)

#set page(width: 780pt, height: auto, margin: 22pt, fill: none)
#set text(font: "Avenir Next", size: paragraph-size, fill: rgb("#19324f"))
#set par(leading: 0.55em)

// Stable coth form preserves the classical limit and avoids exp overflow.
#let energy-in-quanta(x) = {
  assert(x > 0, message: "beta hbar omega must be positive")
  1 / (2 * calc.tanh(x / 2))
}
#let energy-in-thermal-units(x) = {
  assert(x >= 0, message: "beta hbar omega must be nonnegative")
  if x == 0 { 1 } else { x * energy-in-quanta(x) }
}

// Both views use the same horizontal variable and plot geometry, but different energy units.
#let energy-plot(thermal-units: false) = canvas(length: 1cm, {
  draw.set-style(legend: (fill: rgb("#cdd3da")))
  plot.plot(
    size: (9, 6),
    x-min: 0,
    x-max: 8,
    y-min: 0,
    y-max: 4.2,
    x-label: none,
    y-label: if thermal-units { $chevron.l E chevron.r \/ (k_"B" T)$ } else {
      $chevron.l E chevron.r \/ (ℏ omega)$
    },
    axis-style: "left",
    x-tick-step: 2,
    y-tick-step: 1,
    legend-style: (item: (spacing: .12), padding: .15, stroke: .4pt),
    legend: if thermal-units { "inner-north-west" } else { "inner-north-east" },
    {
      plot.add(
        style: (stroke: (paint: rgb("#c2570a"), thickness: 1pt, dash: "dashed")),
        domain: (0.1, 8),
        x => if thermal-units { x / 2 } else { 0.5 },
        label: if thermal-units { [zero-point contribution] } else { [zero-point floor] },
      )
      plot.add(
        style: (stroke: rgb("#008580") + 1.8pt),
        domain: (0.03, 8),
        samples: 240,
        if thermal-units { energy-in-thermal-units } else { energy-in-quanta },
        label: [quantum mean energy],
      )
    },
  )
  draw.content((4.5, -0.8), if thermal-units { $x = ℏ omega \/ (k_"B" T)$ } else {
    $x = beta ℏ omega$
  })
})

One energy formula connects thermal motion with zero-point motion. Compare the level spacing $ℏ omega$ with the thermal energy $k_"B" T$.
#v(14pt)
#card-grid(
  (
    [1  Increase frequency at fixed temperature],
    energy-plot(thermal-units: true),
    [At small level spacing, $chevron.l E chevron.r approx k_"B" T$: classical equipartition. At large spacing the zero-point term dominates. The energy rises monotonically.],
  ),
  (
    [2  Cool at fixed frequency],
    energy-plot(),
    [Move right by increasing $beta=1 \/ (k_"B" T)$. Thermal excitations freeze out; the mean energy approaches $ℏ omega \/ 2$, rather than zero.],
  ),
)
#v(12pt)
#takeaway[$chevron.l E chevron.r = ℏ omega (1/2 + 1/(e^(beta ℏ omega)-1))$. *The same horizontal variable, two energy units.* $omega$ is angular frequency; $ℏ$ is the reduced Planck constant.]
