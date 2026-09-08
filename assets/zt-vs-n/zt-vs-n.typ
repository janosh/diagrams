#import "@preview/cetz:0.5.2": canvas, draw
#import "@preview/cetz-plot:0.1.4": plot
#set page(width: 500pt, height: auto, margin: 20pt, fill: none)
#set text(font: "Avenir Next", size: 10.5pt, fill: rgb("#19324f"))
#set par(leading: 0.55em)

#let curves = (
  (
    label: $z T$,
    color: rgb("#0B5FA5"),
    points: (
      (1.174e18, 0.2317),
      (1.551e18, 0.2787),
      (2.016e18, 0.3300),
      (2.549e18, 0.3816),
      (3.171e18, 0.4332),
      (3.891e18, 0.4842),
      (4.697e18, 0.5373),
      (5.623e18, 0.5892),
      (6.714e18, 0.6404),
      (8.017e18, 0.6923),
      (9.650e18, 0.7450),
      (1.178e19, 0.7963),
      (1.461e19, 0.8486),
      (1.878e19, 0.8964),
      (2.481e19, 0.9278),
      (3.279e19, 0.9318),
      (4.334e19, 0.9057),
      (5.515e19, 0.8571),
      (6.662e19, 0.8045),
      (7.767e19, 0.7519),
      (8.859e19, 0.7000),
      (1.008e20, 0.6476),
      (1.143e20, 0.5953),
      (1.290e20, 0.5449),
      (1.447e20, 0.4906),
      (1.628e20, 0.4374),
      (1.837e20, 0.3850),
      (2.101e20, 0.3327),
      (2.436e20, 0.2799),
      (2.887e20, 0.2281),
      (3.594e20, 0.1753),
      (4.674e20, 0.1271),
      (6.178e20, 0.08917),
      (8.167e20, 0.06240),
      (1e21, 0.05),
    ),
  ),
  (
    label: $sigma$,
    color: rgb("#C2570A"),
    points: (
      (1.176e18, 0.005689),
      (1.554e18, 0.008070),
      (2.054e18, 0.009285),
      (2.714e18, 0.01216),
      (3.587e18, 0.01561),
      (4.740e18, 0.02190),
      (6.264e18, 0.02984),
      (8.277e18, 0.04013),
      (1.094e19, 0.05127),
      (1.445e19, 0.06820),
      (1.910e19, 0.09120),
      (2.511e19, 0.1191),
      (3.333e19, 0.1593),
      (4.344e19, 0.2072),
      (5.433e19, 0.2587),
      (6.613e19, 0.3123),
      (7.852e19, 0.3739),
      (8.925e19, 0.4266),
      (1.001e20, 0.4779),
      (1.110e20, 0.5310),
      (1.224e20, 0.5824),
      (1.335e20, 0.6359),
      (1.441e20, 0.6893),
      (1.551e20, 0.7425),
      (1.660e20, 0.7960),
      (1.767e20, 0.8478),
      (1.876e20, 0.9009),
      (1.986e20, 0.9532),
      (2.08e20, 1),
    ),
  ),
  (
    label: $kappa$,
    color: rgb("#286744"),
    points: (
      (1.175e18, 0.08187),
      (1.553e18, 0.08218),
      (2.053e18, 0.08379),
      (2.713e18, 0.08472),
      (3.585e18, 0.08684),
      (4.738e18, 0.08916),
      (6.261e18, 0.09142),
      (8.274e18, 0.09411),
      (1.093e19, 0.09912),
      (1.445e19, 0.1059),
      (1.909e19, 0.1145),
      (2.523e19, 0.1256),
      (3.334e19, 0.1391),
      (4.405e19, 0.1576),
      (5.821e19, 0.1830),
      (7.691e19, 0.2164),
      (1.016e20, 0.2605),
      (1.302e20, 0.3102),
      (1.589e20, 0.3629),
      (1.882e20, 0.4143),
      (2.181e20, 0.4641),
      (2.472e20, 0.5181),
      (2.764e20, 0.5714),
      (3.066e20, 0.6246),
      (3.363e20, 0.6780),
      (3.669e20, 0.7310),
      (3.981e20, 0.7826),
      (4.273e20, 0.8389),
      (4.560e20, 0.8942),
      (4.868e20, 0.9493),
      (5.2e20, 1),
    ),
  ),
  (
    label: $S$,
    color: rgb("#A81E7A"),
    points: (
      (1.65e18, 1),
      (1.931e18, 0.9729),
      (2.553e18, 0.9248),
      (3.375e18, 0.8777),
      (4.462e18, 0.8302),
      (5.899e18, 0.7816),
      (7.745e18, 0.7351),
      (1.031e19, 0.6866),
      (1.363e19, 0.6397),
      (1.802e19, 0.5897),
      (2.382e19, 0.5412),
      (3.149e19, 0.4937),
      (4.162e19, 0.4471),
      (5.503e19, 0.3977),
      (7.117e19, 0.3500),
      (9.181e19, 0.2944),
      (1.224e20, 0.2436),
      (1.618e20, 0.2019),
      (2.138e20, 0.1687),
      (2.826e20, 0.1389),
      (3.736e20, 0.1161),
      (4.938e20, 0.09646),
      (6.321e20, 0.08022),
      (8.578e20, 0.06624),
      (1e21, 0.06),
    ),
  ),
  (
    label: $S^2 sigma$,
    color: rgb("#7A3E9D"),
    points: (
      (1.159e18, 0.04006),
      (1.532e18, 0.04739),
      (2.025e18, 0.05790),
      (2.676e18, 0.06974),
      (3.386e18, 0.08033),
      (4.675e18, 0.09928),
      (6.179e18, 0.1176),
      (8.168e18, 0.1379),
      (1.080e19, 0.1608),
      (1.427e19, 0.1864),
      (1.886e19, 0.2142),
      (2.492e19, 0.2430),
      (3.294e19, 0.2713),
      (4.353e19, 0.2989),
      (5.754e19, 0.3230),
      (7.605e19, 0.3422),
      (1.005e20, 0.3528),
      (1.314e20, 0.3509),
      (1.757e20, 0.3326),
      (2.327e20, 0.3049),
      (3.071e20, 0.2777),
      (4.061e20, 0.2535),
      (5.369e20, 0.2304),
      (7.098e20, 0.2095),
      (1e21, 0.185),
    ),
  ),
)

#let normalize(points) = {
  let peak = calc.max(..points.map(point => point.at(1)))
  points.map(((carrier, value)) => (carrier, value / peak))
}
#let zt_peak = curves.first().points.sorted(key: point => point.at(1)).last()
// Monotone cubic Hermite interpolation in the plotted log-carrier coordinate.
// Zero slopes at extrema preserve the sampled peak; harmonic means avoid overshoot.
#let densify(points, sample_count: 100) = {
  assert(sample_count >= points.len(), message: "Sample count must retain every original point")
  let positions = points.map(point => calc.log(point.at(0), base: 10))
  let widths = positions.windows(2).map(pair => pair.last() - pair.first())
  let secants = points
    .windows(2)
    .zip(widths)
    .map(((pair, width)) => (pair.last().at(1) - pair.first().at(1)) / width)
  let slopes = (secants.first(),)
  for idx in range(1, points.len() - 1) {
    let before = secants.at(idx - 1)
    let after = secants.at(idx)
    let weight_before = 2 * widths.at(idx) + widths.at(idx - 1)
    let weight_after = widths.at(idx) + 2 * widths.at(idx - 1)
    slopes.push(if before * after <= 0 { 0 } else {
      (weight_before + weight_after) / (weight_before / before + weight_after / after)
    })
  }
  slopes.push(secants.last())
  let dense = ()
  let intervals = points.len() - 1
  for (idx, pair) in points.windows(2).enumerate() {
    let samples = (
      calc.floor((idx + 1) * (sample_count - 1) / intervals)
        - calc.floor(idx * (sample_count - 1) / intervals)
    )
    dense.push(pair.first())
    for step in range(1, samples) {
      let phase = step / samples
      let phase_squared = phase * phase
      let phase_cubed = phase_squared * phase
      let value = (
        (2 * phase_cubed - 3 * phase_squared + 1) * pair.first().at(1)
          + (phase_cubed - 2 * phase_squared + phase) * widths.at(idx) * slopes.at(idx)
          + (-2 * phase_cubed + 3 * phase_squared) * pair.last().at(1)
          + (phase_cubed - phase_squared) * widths.at(idx) * slopes.at(idx + 1)
      )
      dense.push((calc.pow(10, positions.at(idx) + phase * widths.at(idx)), value))
    }
  }
  dense.push(points.last())
  dense
}
#let plot_points = (
  curves
    .enumerate()
    .map(((idx, curve)) => densify(if idx == 0 { curve.points } else { normalize(curve.points) }))
)
#text(size: 25pt, weight: "bold")[Thermoelectric transport]
#v(12pt)
#align(center, canvas({
  draw.set-style(axes: (
    x: (label: (anchor: "north", offset: .1)),
    y: (label: (anchor: "north-west", offset: -.2)),
  ))
  plot.plot(
    size: (14, 8.5),
    name: "plot",
    axis-style: "left",
    x-mode: "log",
    x-min: 1e18,
    x-max: 1e21,
    x-tick-step: 1,
    x-format: value => $10^#calc.round(calc.log(value, base: 10))$,
    y-min: 0,
    y-max: 1.1,
    y-tick-step: .25,
    x-grid: true,
    y-grid: true,
    x-label: none,
    y-label: none,
    legend: none,
    {
      for (idx, curve) in curves.enumerate() {
        plot.add(plot_points.at(idx), style: (
          stroke: (
            paint: curve.color,
            thickness: if idx == 0 { 2.3pt } else { 1.3pt },
            dash: if curve.label == $S^2 sigma$ { "dashed" } else { "solid" },
          ),
        ))
      }
      plot.add-anchor("peak", zt_peak)
    },
  )
  draw.circle("plot.peak", radius: 2pt, fill: curves.first().color, stroke: none)
  draw.line("plot.peak", (rel: (0, .6)), stroke: curves.first().color + .6pt, name: "peak-leader")
  draw.content(
    "peak-leader.end",
    text(size: 9pt)[sampled peak: #calc.round(zt_peak.at(1), digits: 3)],
    anchor: "south",
  )
  draw.content((rel: (0, -.4), to: "plot.south"), [$n$ ($"cm"^(-3)$)], anchor: "north")
}))
#v(10pt)
#align(center)[#for (idx, curve) in curves.enumerate() [#text(
    fill: curve.color,
  )[― #curve.label #if idx == 0 [(actual)]] #h(7pt)]]
#v(6pt)
#align(center)[Transport curves scaled individually: $f(n) \/ (max f)$.]
#v(8pt)
#align(center)[$z T = S^2 sigma T / kappa$]
