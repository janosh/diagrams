#import "@preview/cetz:0.5.2": canvas
#import "@preview/cetz-plot:0.1.4": plot
#import "../_shared/plot.typ": legend-box

#set page(width: auto, height: auto, margin: 8pt, fill: none)

// Constants (in SI units)
#let k-B = 1.38e-23 // Boltzmann constant
#let m-u = 1.66e-27 // unified atomic mass unit

// Maxwell-Boltzmann distribution function
#let maxwell-boltzmann(x, T) = {
  let exp = calc.exp(-m-u * calc.pow(x, 2) / (2 * k-B * T))
  let prefactor = calc.pow(m-u / (2 * calc.pi * k-B * T), 3 / 2)
  4 * calc.pi * prefactor * calc.pow(x, 2) * exp
}

#canvas({
  plot.plot(
    size: (10, 6),
    x-label: [$v$ (m/s)],
    y-label: $P(v)$,
    y-max: 0.7e-3,
    x-tick-step: 2000,
    y-tick-step: 2e-4,
    y-format: y => calc.round(10000 * y, digits: 2),
    legend: "inner-north-east",
    x-grid: true,
    y-grid: true,
    legend-style: legend-box,
    {
      for (temp, color) in ((100, red), (300, orange), (1000, blue)) {
        plot.add(
          style: (stroke: color + 1.5pt),
          domain: (0, 8000),
          samples: 150,
          x => maxwell-boltzmann(x, temp),
          label: str(temp) + " K",
        )
      }
    },
  )
})
