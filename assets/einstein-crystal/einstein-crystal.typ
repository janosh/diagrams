#import "@preview/cetz:0.5.3": canvas, draw
#import draw: circle, content, group, line, rect, set-origin

// N identical atoms give M = 3N independent scalar oscillators of frequency omega_E.
// Einstein and Debye curves use equal characteristic temperatures for shape comparison.
// Debye integration: composite Simpson quadrature; the exponentially small tail above
// x = 50 is omitted. All plotted values come from the helpers tested by Typst queries.
// The free-energy path is classical, at fixed temperature, volume, particle number,
// and positional constraint. Its endpoint free energies use that same constraint.
// https://www.physics.usyd.edu.au/~sflammia/Courses/StatMech2020/normal/3/n3.html
// https://doi.org/10.1002/andp.19123441404
// https://arxiv.org/abs/1210.3956
#set page(width: auto, height: auto, margin: 0pt, fill: none)
#set text(font: "Avenir Next", size: 18pt, fill: rgb("#19304E"))
#set par(leading: 0.48em)
#set math.equation(numbering: none)

#let ink = rgb("#19304E")
#let muted = rgb("#46566C")
#let blue = rgb("#2864BB")
#let teal = rgb("#06716E")
#let orange = rgb("#A84820")
#let purple = rgb("#7750A3")
#let guide = rgb("#8799AD")
#let blue_fill = rgb("#DDE6F0")
#let teal_fill = rgb("#D8E7E3")
#let orange_fill = rgb("#EDE1D5")
#let purple_fill = rgb("#E3DEEA")

// Heat capacity of one mode in units of k_B, x = hbar omega / (k_B T).
// sinh avoids cancellation at small x; the zero limit is analytic.
#let mode_cv(inverse_temperature) = {
  assert(inverse_temperature >= 0)
  if inverse_temperature == 0 { return 1 }
  calc.pow(inverse_temperature / (2 * calc.sinh(inverse_temperature / 2)), 2)
}
#let einstein_cv(reduced_temperature) = {
  assert(reduced_temperature >= 0)
  if reduced_temperature == 0 { 0 } else { mode_cv(1 / reduced_temperature) }
}
#let debye_cv(reduced_temperature) = {
  assert(reduced_temperature >= 0)
  if reduced_temperature == 0 { return 0 }
  let upper = calc.min(1 / reduced_temperature, 50)
  let intervals = 400
  let step = upper / intervals
  let weighted_samples = range(intervals + 1).map(sample_idx => {
    let position = step * sample_idx
    let endpoint = sample_idx in (0, intervals)
    let weight = if endpoint { 1 } else if calc.odd(sample_idx) { 4 } else { 2 }
    weight * position * position * mode_cv(position)
  })
  let integral = weighted_samples.sum() * step / 3
  3 * calc.pow(reduced_temperature, 3) * integral
}
#let level_probability(level, reduced_temperature) = {
  assert(level >= 0 and reduced_temperature > 0)
  (1 - calc.exp(-1 / reduced_temperature)) * calc.exp(-level / reduced_temperature)
}
#let allocations = {
  let states = ()
  for first in range(3) {
    for second in range(3 - first) { states.push((first, second, 2 - first - second)) }
  }
  states
}
#let label(
  left,
  top,
  width,
  body,
  size: 18pt,
  color: muted,
  weight: "regular",
  centered: false,
) = content(
  (left, top),
  block(width: width * 1pt)[
    #text(size: size, fill: color, weight: weight, if centered { align(center, body) } else {
      body
    })
  ],
  anchor: "north-west",
  padding: 0pt,
)
#let symbol(center_x, center_y, body, size: 18pt, color: ink) = content(
  (center_x, center_y),
  text(size: size, fill: color, body),
  padding: 0pt,
)
#let equation = label.with(size: 24pt, color: ink, centered: true)
#let segment(start, end, color: guide, thickness: 1pt, dash: "solid") = line(
  start,
  end,
  stroke: (paint: color, thickness: thickness, dash: dash),
)
#let arrow(start, end, color: ink, both: false) = line(start, end, stroke: 1.5pt + color, mark: (
  start: if both { "stealth" } else { none },
  end: "stealth",
  scale: 0.65,
  fill: color,
))
#let site(center_x, center_y, size: 5) = {
  segment((center_x - size, center_y), (center_x + size, center_y), thickness: 1.3pt)
  segment((center_x, center_y - size), (center_x, center_y + size), thickness: 1.3pt)
}
#let atom(center_x, center_y, radius: 8, color: blue) = circle(
  (center_x, center_y),
  radius: radius,
  fill: color,
  stroke: none,
)
// Zigzag with 5 full oscillations between straight end points.
#let spring(start, end, color: blue, amplitude: 2.4, thickness: 1.3pt) = {
  let (delta_x, delta_y) = (end.at(0) - start.at(0), end.at(1) - start.at(1))
  let distance = calc.sqrt(delta_x * delta_x + delta_y * delta_y)
  assert(distance > 0)
  let points = range(13).map(sample_idx => {
    let wave = if sample_idx in (0, 12) { 0 } else if calc.odd(sample_idx) { amplitude } else {
      -amplitude
    }
    (
      start.at(0) + delta_x * sample_idx / 12 - delta_y * wave / distance,
      start.at(1) + delta_y * sample_idx / 12 + delta_x * wave / distance,
    )
  })
  line(..points, stroke: thickness + color)
}
// Panel background and numbered title; `body` is drawn relative to the panel's top-left corner.
#let panel(left, top, width, height, number, title, accent, fill, body) = group({
  set-origin((left, top))
  rect((0, 0), (width, height), radius: 12, fill: fill, stroke: none)
  circle((30, 32), radius: 15, fill: accent, stroke: none)
  symbol(30, 32, text(weight: "bold", fill: white, str(number)))
  content(
    (56, 34), // Optical centering against the badge.
    block(width: (width - 78) * 1pt, text(size: 23pt, fill: ink, weight: "bold", title)),
    anchor: "west",
    padding: 0pt,
  )
  body
})
#let callout(left, top, width, accent, title, body) = content(
  (left, top),
  block(width: width * 1pt, inset: 12pt, radius: 7pt, fill: rgb("#F3F5F7"), stroke: (
    left: 3pt + accent,
  ))[
    #set par(leading: 0.35em)
    #stack(
      dir: ttb,
      spacing: 7pt,
      text(size: 18pt, fill: accent, weight: "bold", title),
      text(size: 17pt, fill: muted, body),
    )
  ],
  anchor: "north-west",
  padding: 0pt,
)
// Four fixed sites and their (displaced) atoms; coupling = λ blends springs into interactions.
#let reference_cell(center_x, center_y, coupling) = {
  let positions = ((-24, -21), (24, -21), (-24, 21), (24, 21))
  let offsets = ((10, -7), (-8, 8), (9, 6), (-9, -7))
  let atoms = positions
    .zip(offsets)
    .map((((pos_x, pos_y), (off_x, off_y))) => (center_x + pos_x + off_x, center_y + pos_y + off_y))
  if coupling > 0 {
    for (first, second) in ((0, 1), (0, 2), (1, 3), (2, 3)) {
      segment(
        atoms.at(first),
        atoms.at(second),
        color: teal,
        thickness: (0.8 + 1.2 * coupling) * 1pt,
      )
    }
  }
  for (idx, (pos_x, pos_y)) in positions.enumerate() {
    let fixed = (center_x + pos_x, center_y + pos_y)
    if coupling < 1 {
      spring(fixed, atoms.at(idx), color: purple, thickness: (1.6 - coupling) * 1pt, amplitude: 2)
      site(..fixed, size: 3.5)
    }
    atom(..atoms.at(idx), radius: 7, color: if coupling == 1 { teal } else { purple })
  }
}

// Page coordinates: x increases rightward, y downward. Panel bodies are relative to their panel.
#canvas(length: 1pt, y: -1, {
  rect((0, 0), (1180, 1952), fill: none, stroke: none)
  label(28, 18, 1124, [Einstein crystal], size: 43pt, color: ink, weight: "bold")
  label(
    30,
    78,
    1110,
  )[One solvable model connects atomic vibrations, quantum heat capacity, entropy, and solid free energies.]

  // === Fixed-site model ===
  panel(24, 123, 610, 518, 1, [Replace the crystal by local springs], blue, blue_fill, {
    label(
      21,
      61,
      567,
      size: 19pt,
      color: blue,
      weight: "bold",
    )[N atoms × 3 directions = M = 3N independent modes]
    // displacement of each atom from its site on a 3×3 grid
    let offsets = (
      ((20, -9), (-17, -10), (16, 13)),
      ((-15, 15), (24, -11), (-14, -15)),
      ((20, 7), (-16, 10), (16, -13)),
    )
    for (row, row_offsets) in offsets.enumerate() {
      for (col, (offset_x, offset_y)) in row_offsets.enumerate() {
        let (site_x, site_y) = (63 + col * 77, 117 + row * 56)
        spring((site_x, site_y), (site_x + offset_x, site_y + offset_y))
        site(site_x, site_y)
        atom(site_x + offset_x, site_y + offset_y)
      }
    }
    label(23, 251, 276, size: 16pt)[Cross: fixed site $bold(R)_i$\ Dot: atom at $bold(r)_i$]
    let (axis_x, axis_y) = (453, 231)
    label(axis_x - 114, axis_y - 131, 240, centered: true, size: 17pt)[One displacement coordinate]
    arrow((axis_x - 112, axis_y), (axis_x + 127, axis_y), color: guide)
    arrow((axis_x, axis_y), (axis_x, axis_y - 106), color: guide)
    let parabola = range(101).map(sample_idx => {
      let position = (sample_idx - 50) / 50
      (axis_x + position * 96, axis_y - 8 - 87 * position * position)
    })
    line(..parabola, stroke: 2pt + blue)
    site(axis_x, axis_y - 8)
    circle((axis_x + 53, axis_y - 35), radius: 9, fill: blue, stroke: none, name: "displaced-atom")
    arrow("displaced-atom.west", (rel: (-30, 0)), color: orange)
    symbol(axis_x + 107, axis_y - 31, $F_u = -kappa u$, size: 17pt, color: orange)
    symbol(axis_x + 127, axis_y + 18, $u$)
    symbol(axis_x - 20, axis_y - 90, $V$)
    label(340, 256, 244, size: 17pt, centered: true)[$bold(u)_i = bold(r)_i - bold(R)_i$]
    equation(
      19,
      291,
      571,
    )[$V_"E" = kappa/2 sum_(i=1)^N |bold(u)_i|^2 quad omega_"E" = sqrt(kappa/m)$]
    label(
      19,
      332,
      566,
      size: 15pt,
      centered: true,
    )[Same stiffness $kappa$ and mass $m$; springs attach to sites, not neighboring atoms.]
    callout(20, 368, 570, blue, [Read the restoring force])[
      $bold(u)_i$ is atom $i$’s displacement from its fixed site. The force points back toward the potential minimum: $F_u = -kappa u$. Doubling $|u|$ quadruples the spring energy. Stiffer springs or lighter atoms have a higher angular frequency $omega_"E"$. This harmonic approximation describes small vibrations about stable sites.
    ]
  })

  // === Quantized energy and populations ===
  panel(652, 123, 504, 518, 2, [Heating fills a quantum ladder], orange, orange_fill, {
    equation(22, 58, 458)[$E_n = (n + 1/2) ℏ omega_"E" quad n = 0,1,2,...$]
    label(187, 103, 115, size: 16pt, color: blue, centered: true)[Cold\ $T = Theta_"E"/4$]
    label(350, 103, 117, size: 16pt, color: orange, centered: true)[Warm\ $T = 2 Theta_"E"$]
    let (ground_y, level_gap) = (274, 29)
    for level in range(5) {
      let level_y = ground_y - level * level_gap
      symbol(53, level_y, $n = #level$, size: 16pt)
      segment(
        (89, level_y),
        (161, level_y),
        color: if level == 0 { orange } else { ink },
        thickness: 1.7pt,
      )
      // bar length = probability of the level at the cold and warm temperatures
      for (left, temperature, color) in ((192, 0.25, blue), (354, 2, orange)) {
        let bar_right = left + 103 * level_probability(level, temperature)
        rect((left, level_y - 7), (bar_right, level_y + 7), radius: 1.5, fill: color, stroke: none)
      }
    }
    arrow((169, ground_y), (169, ground_y - level_gap), color: orange, both: true)
    label(
      22,
      293,
      459,
      size: 17pt,
      centered: true,
    )[$P(n) = (1-e^(-x)) e^(-n x)$; bar length = probability.]
    label(
      22,
      326,
      461,
      size: 15pt,
      centered: true,
    )[Gap $ℏ omega_"E"$; the ground state still has $E_0 = ℏ omega_"E"/2$. Higher levels omitted.]
    callout(20, 368, 464, orange, [Thermal energy competes with the gap])[
      $n$ counts excitation quanta of one mode; $P(n)$ is its level probability. $Theta_"E"$ expresses the energy gap as a temperature. Thus $x = Theta_"E" / T$ compares the gap $ℏ omega_"E"$ with thermal energy $k_"B" T$: large $x$ means few excited states.
    ]
  })

  // === Heat capacity computed from the oscillator spectrum ===
  panel(24, 659, 690, 615, 3, [Why the heat capacity falls on cooling], blue, blue_fill, {
    label(
      20,
      58,
      649,
    )[Thermal excitations store heat. The fixed zero-point energy contributes no heat capacity.]
    equation(
      20,
      106,
      648,
      color: blue,
    )[$C_V/(3 N k_"B") = (x^2 e^x)/(e^x - 1)^2 quad x = Theta_"E"/T quad Theta_"E" = (ℏ omega_"E")/k_"B"$]
    let (plot_left, plot_bottom, plot_width, plot_height) = (70, 352, 576, 170)
    let plot_top = plot_bottom - plot_height
    label(20, 148, 210, size: 16pt)[Heat capacity / $3 N k_"B"$]
    for tick in (0, 0.5, 1) {
      let tick_y = plot_bottom - plot_height * tick
      segment((plot_left, tick_y), (plot_left + plot_width, tick_y), dash: "dotted")
      symbol(plot_left - 19, tick_y, str(tick), size: 16pt)
    }
    for tick in (0, 0.5, 1, 1.5, 2) {
      let tick_x = plot_left + plot_width * tick / 2
      segment((tick_x, plot_bottom), (tick_x, plot_bottom + 5))
      symbol(tick_x, plot_bottom + 19, str(tick), size: 16pt)
    }
    segment((plot_left, plot_bottom), (plot_left + plot_width, plot_bottom))
    segment((plot_left, plot_bottom), (plot_left, plot_top))
    for (heat_capacity, color) in ((debye_cv, teal), (einstein_cv, blue)) {
      let points = range(201).map(sample_idx => {
        let temperature = sample_idx / 100
        (
          plot_left + plot_width * temperature / 2,
          plot_bottom - plot_height * heat_capacity(temperature),
        )
      })
      line(..points, stroke: 2.8pt + color)
    }
    segment(
      (plot_left, plot_top),
      (plot_left + plot_width, plot_top),
      color: muted,
      thickness: 1.5pt,
      dash: "dashed",
    )
    label(236, 148, 284, size: 16pt)[Classical Dulong–Petit limit: 1]
    for (legend_y, color, name) in (
      (257, blue, [Einstein: one frequency]),
      (300, teal, [Debye: acoustic spectrum]),
    ) {
      // centered on the lowercase letters of the 17pt label, not its baseline
      segment((406, legend_y - 6), (442, legend_y - 6), color: color, thickness: 3pt)
      label(453, legend_y - 14, 230, size: 17pt, color: color, name)
    }
    symbol(355, plot_bottom + 40, $T slash Theta$, size: 17pt)
    label(
      19,
      412,
      655,
      size: 16pt,
      centered: true,
    )[Cold Einstein: $C_V prop x^2 e^(-x)$ · Hot: $C_V -> 3 N k_"B"$\ Equal $Theta_"E" = Theta_"D" = Theta$ for shape comparison; real fitted scales differ.]
    callout(20, 465, 650, blue, [Heat capacity measures energy stored per degree])[
      $C_V = ((partial U) / (partial T))_V$ measures how much energy a small temperature rise stores at fixed volume. Classically, each mode contributes $k_"B"/2$ from motion and $k_"B"/2$ from its spring, so $3N$ modes give $3N k_"B"$. At low $T$, a mode stores little extra heat when its excitation gap greatly exceeds $k_"B" T$.
    ]
  })

  // === Local oscillators versus collective normal modes ===
  panel(732, 659, 424, 615, 4, [Real crystals have phonons], teal, teal_fill, {
    label(20, 59, 381)[Atoms move together. A phonon is one quantum of a collective vibration.]
    let wave_atoms = range(7).map(site_idx => (
      41 + 54 * site_idx,
      155 - 15 * calc.sin(site_idx * calc.pi / 3),
    ))
    for (start, end) in wave_atoms.windows(2) { spring(start, end, color: teal, amplitude: 3) }
    for position in wave_atoms { atom(..position, color: teal, radius: 7) }
    label(20, 188, 381, size: 16pt, centered: true)[Coupled atoms → many normal-mode frequencies]
    let (einstein_x, debye_x, axis_y) = (44, 259, 327)
    for left in (einstein_x, debye_x) {
      arrow((left, axis_y), (left + 136, axis_y), color: guide)
      arrow((left, axis_y), (left, axis_y - 80), color: guide)
      symbol(left - 7, axis_y - 95, $g(omega)$, size: 16pt)
      symbol(left + 139, axis_y + 16, $omega$, size: 16pt)
    }
    arrow((einstein_x + 61, axis_y), (einstein_x + 61, axis_y - 76), color: blue)
    symbol(einstein_x + 61, axis_y + 21, $omega_"E"$, size: 16pt, color: blue)
    let spectrum = range(81).map(sample_idx => {
      let fraction = sample_idx / 80
      (debye_x + 106 * fraction, axis_y - 74 * fraction * fraction)
    })
    line(..spectrum, stroke: 2.5pt + teal)
    segment((debye_x + 106, axis_y - 74), (debye_x + 106, axis_y), color: teal, dash: "dotted")
    symbol(debye_x + 106, axis_y + 21, $omega_"D"$, size: 16pt, color: teal)
    label(31, 367, 167, size: 16pt, centered: true, color: blue)[One frequency]
    label(238, 367, 170, size: 16pt, centered: true, color: teal)[Debye: $g(omega) prop omega^2$]
    label(
      19,
      393,
      383,
      size: 16pt,
      centered: true,
    )[Each spectrum contains 3N modes. In 3D, low-frequency acoustic modes give $C_V prop T^3$.]
    label(19, 436, 383, size: 14pt, centered: true)[Harmonic normal modes remain independent.]
    callout(20, 465, 384, teal, [Why soft modes matter])[
      $g(omega) dif omega$ counts modes in a frequency interval. Soft acoustic modes remain easy to excite as the solid cools, giving $C_V prop T^3$ at low $T$. $omega_"D"$ sets the cutoff, with $Theta_"D" = ℏ omega_"D" / k_"B"$.
    ]
  })

  // === Exact, enumerable microstates ===
  panel(24, 1292, 430, 555, 5, [Count states to get entropy], orange, orange_fill, {
    label(20, 62, 389)[One atom: M = 3 modes, q = 2 quanta.\ Six allocations have the same energy.]
    for (state_idx, state) in allocations.enumerate() {
      let center_x = 80 + 126 * calc.rem(state_idx, 3)
      let baseline = 172 + 84 * calc.floor(state_idx / 3)
      for (mode_idx, quanta) in state.enumerate() {
        let mode_x = center_x + (mode_idx - 1) * 27
        rect(
          (mode_x - 10, baseline - 43),
          (mode_x + 10, baseline),
          radius: 3,
          fill: rgb("#D8CFC4"),
          stroke: none,
        )
        for quantum_idx in range(quanta) {
          atom(mode_x, baseline - 9 - quantum_idx * 16, radius: 6, color: orange)
        }
      }
      symbol(center_x, baseline + 17, [#state.at(0), #state.at(1), #state.at(2)], size: 16pt)
    }
    equation(19, 298, 390)[$Omega(M, q) = binom(q+M-1, q)$]
    equation(19, 347, 390, color: orange)[$S = k_"B" ln Omega quad M = 3N$]
    callout(20, 405, 390, orange, [Same energy, different microstates])[
      Each bin is an $x$, $y$, or $z$ mode. The total excitation energy is $q ℏ omega_"E"$ above the ground state. $Omega$ counts allocations at fixed $q$: more possibilities mean larger entropy. Here $Omega = 6$ and $S = k_"B" ln 6$.
    ]
  })

  // === Classical free-energy application ===
  panel(472, 1292, 684, 555, 6, [A reference for solid free energies], purple, purple_fill, {
    label(21, 62, 641)[Classical Frenkel–Ladd integration · Helmholtz free energy $F = U - T S$]
    let cell_y = 170
    for (center_x, coupling, name) in (
      (96, 0, [Springs only]),
      (335, 0.5, [Blend]),
      (583, 1, [Real interactions]),
    ) {
      symbol(center_x, cell_y - 55, $lambda = #coupling$, size: 17pt, color: purple)
      reference_cell(center_x, cell_y, coupling)
      label(center_x - 84, cell_y + 39, 168, name, size: 17pt, centered: true)
    }
    for (start_x, end_x) in ((160, 266), (400, 511)) {
      arrow((start_x, cell_y - 2), (end_x, cell_y - 2), color: purple)
    }
    equation(20, 239, 643)[$V_lambda = (1-lambda) V_"E" + lambda V_"real"$]
    equation(
      19,
      283,
      645,
      size: 25pt,
      color: purple,
    )[$F_"real" - F_"E" = integral_0^1 chevron.l V_"real" - V_"E" chevron.r_lambda dif lambda$]
    label(
      21,
      332,
      641,
      size: 15pt,
    )[$chevron.l ... chevron.r_lambda$: equilibrium average in the blend. Keep temperature, volume, and the positional constraint fixed along a reversible crystal path. Release the fixed center of mass (or one particle: Einstein molecule) with its analytic free-energy correction.]
    callout(20, 405, 644, purple, [Use: compare candidate crystal structures])[
      $lambda in [0,1]$ controls the blend. Sampling each value gives the average in the integral, which adds up the reversible free-energy change. The result includes both energy and entropy through $F = U - T S$. At the same temperature, volume, and particle number, the candidate with lower Helmholtz free energy $F$ is favored.
    ]
  })

  label(
    30,
    1868,
    1118,
    size: 17pt,
    color: ink,
  )[*Symbols:* $T$ temperature · $k_"B"$ Boltzmann constant · $ℏ$ reduced Planck constant · $C_V$ heat capacity at fixed volume · $g(omega)$ mode density.]
  label(
    30,
    1910,
    1118,
    size: 16pt,
  )[$U$ internal energy · $V$ potential energy · $q$ excitation quanta. Heat curves include lattice vibrations only; no electronic or magnetic contribution. Thermal equilibrium is assumed.]
})
