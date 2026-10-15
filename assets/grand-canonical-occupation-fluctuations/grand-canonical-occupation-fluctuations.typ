#import "@preview/cetz:0.5.2": canvas, draw
#import "@preview/cetz-plot:0.1.4": plot

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 12pt)

#let size = (8, 5)

#canvas({
  let axis-mark = (end: "stealth", fill: black)
  draw.set-style(axes: (
    x: (mark: axis-mark, label: (anchor: "north", offset: 0.1)),
    y: (mark: axis-mark, label: (anchor: "north-west", offset: -0.2)),
  ))

  // Occupation-number variance of a mode with ε_k - μ = 1 at temperature T = 1 / beta.
  let fluctuation-plot(variance, y-label, y-tick-step, y-max: auto) = plot.plot(
    size: size,
    x-min: 0,
    x-max: 4.2,
    y-min: 0,
    y-max: y-max,
    x-label: $T$,
    y-label: y-label,
    x-tick-step: 1,
    y-tick-step: y-tick-step,
    axis-style: "left",
    plot.add(
      style: (stroke: blue + 1.5pt),
      domain: (0.01, 4.2), // avoid T = 0
      samples: 200,
      temp => variance(1 / temp),
    ),
  )

  // Bose: ⟨n⟩(1 + ⟨n⟩) = 1 / (4 sinh²(β/2)), Fermi: ⟨n⟩(1 - ⟨n⟩) = 1 / (4 cosh²(β/2)).
  fluctuation-plot(beta => 1 / calc.pow(2 * calc.sinh(beta / 2), 2), $Delta n_k^+$, 5)
  draw.translate((size.at(0) + 2.5, 0))
  fluctuation-plot(beta => 1 / (2 + 2 * calc.cosh(beta)), $Delta n_k^-$, 0.05, y-max: 0.28)
})
