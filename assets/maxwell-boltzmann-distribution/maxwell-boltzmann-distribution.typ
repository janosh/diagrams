#import "@preview/cetz:0.3.3": canvas, draw
#import "@preview/cetz-plot:0.1.1": plot

#set page(width: auto, height: auto, margin: 8pt)

// Constants (in SI units)
#let k_B = 1.38e-23 // Boltzmann constant
#let m_u = 1.66e-27 // unified atomic mass unit

// Maxwell-Boltzmann distribution function
#let maxwell_boltzmann(x, T) = {
  let exp = calc.exp(-m_u * calc.pow(x, 2) / (2 * k_B * T))
  let prefactor = calc.pow(m_u / (2 * calc.pi * k_B * T), 3 / 2)
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
    legend-style: (stroke: .5pt),
    {
      // Plot distributions for different temperatures
      for (temp, color) in ((100, red), (300, orange), (1000, blue)) {
        plot.add(
          style: (stroke: color + 1.5pt),
          domain: (0, 8000),
          samples: 150,
          x => maxwell_boltzmann(x, temp),
          label: str(temp) + " K",
        )
      }
    },
  )
})
