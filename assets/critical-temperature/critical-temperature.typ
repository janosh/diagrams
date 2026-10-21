#import "@preview/cetz:0.5.3": canvas, draw
#import "@preview/cetz-plot:0.1.4": plot

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 12pt)

#let tc = 1

// The two factors of the order parameter, each carrying the prefactor sqrt(3).
#let diverging-factor(x) = if x == tc { 0 } else { calc.sqrt(3) * calc.pow(tc / x - 1, 1 / 2) }
#let growing-factor(x) = calc.sqrt(3) * calc.pow(x / tc, 3 / 2)

// Mean-field order parameter from expanding m = tanh(T_c m / T) to third order in m.
#let order-parameter(x) = diverging-factor(x) * calc.pow(x / tc, 3 / 2)

#canvas({
  let axis-mark = (end: "stealth", fill: black)
  draw.set-style(axes: (
    x: (mark: axis-mark, label: (anchor: "north", offset: 0.2)),
    y: (mark: axis-mark, label: (anchor: "north-west", offset: -0.2)),
  ))

  plot.plot(
    size: (10, 8),
    x-label: $T$,
    x-min: 0,
    x-max: 1.1,
    y-min: 0,
    y-max: 2.8,
    axis-style: "left",
    x-tick-step: 0.2,
    y-tick-step: 0.5,
    legend: "inner-north-east",
    // Compact legend with a thin border.
    legend-style: (fill: rgb("#cdd3da"), item: (spacing: 0.15), padding: 0.15, stroke: 0.5pt),
    for (color, samples, domain, fn, label) in (
      ("#0B5FA5", 100, (0.01, 1), diverging-factor, $sqrt(3)(T_c \/ T - 1)^(1 \/ 2)$),
      ("#C2570A", 50, (0, 1.1), growing-factor, $sqrt(3)(T \/ T_c)^(3 \/ 2)$),
      ("#12793F", 125, (0.01, 1), order-parameter, $m_(c)(T)$),
    ) {
      plot.add(
        fn,
        style: (stroke: rgb(color) + 1.5pt),
        samples: samples,
        domain: domain,
        label: label,
      )
    },
  )
})
