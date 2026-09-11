#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, line, rect

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
#let teal = rgb("#087F7C")
#let orange = rgb("#B95024")
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
#let label(left, top, width, body, size: 18pt, color: muted, weight: "regular", centered: false) = {
  content(
    (left, top),
    block(width: width * 1pt)[
      #text(size: size, fill: color, weight: weight, if centered { align(center, body) } else {
        body
      })
    ],
    anchor: "north-west",
    padding: 0pt,
  )
}
#let symbol(center_x, center_y, body, size: 18pt, color: ink) = content(
  (center_x, center_y),
  text(size: size, fill: color, body),
  anchor: "center",
  padding: 0pt,
)
#let equation = label.with(size: 24pt, color: ink, centered: true)
#let segment(start, end, color: guide, thickness: 1pt, dash: "solid") = line(start, end, stroke: (
  paint: color,
  thickness: thickness,
  dash: dash,
))
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
#let atom(center_x, center_y, radius: 8, color: blue) = {
  circle((center_x, center_y), radius: radius, fill: color, stroke: none)
}
#let spring(start, end, color: blue, amplitude: 2.4, thickness: 1.3pt) = {
  let (delta_x, delta_y) = (end.at(0) - start.at(0), end.at(1) - start.at(1))
  let distance = calc.sqrt(delta_x * delta_x + delta_y * delta_y)
  assert(distance > 0)
  let points = range(13).map(sample_idx => {
    let wave = if sample_idx == 0 or sample_idx == 12 { 0 } else if calc.odd(sample_idx) {
      amplitude
    } else { -amplitude }
    (
      start.at(0) + delta_x * sample_idx / 12 - delta_y * wave / distance,
      start.at(1) + delta_y * sample_idx / 12 + delta_x * wave / distance,
    )
  })
  line(..points, stroke: thickness + color)
}
#let panel(left, top, width, height, number, title, accent, fill) = {
  rect(
    (left, top),
    (left + width, top + height),
    radius: 12,
    fill: fill,
    stroke: none,
  )
  circle((left + 30, top + 32), radius: 15, fill: accent, stroke: none)
  symbol(left + 30, top + 32, text(weight: "bold", fill: white, str(number)))
  content(
    (left + 56, top + 34), // Optical centering against the badge.
    block(width: (width - 78) * 1pt)[#text(size: 23pt, fill: ink, weight: "bold", title)],
    anchor: "west",
    padding: 0pt,
  )
}
#let callout(left, top, width, accent, title, body) = content(
  (left, top),
  block(width: width * 1pt, inset: 12pt, radius: 7pt, fill: rgb("#F3F5F7"), stroke: (
    left: 3pt + accent,
  ))[
    #set par(leading: 0.35em)
    #stack(dir: ttb, spacing: 7pt, text(size: 18pt, fill: accent, weight: "bold", title), text(
      size: 17pt,
      fill: muted,
      body,
    ))
  ],
  anchor: "north-west",
  padding: 0pt,
)
#let reference_cell(center_x, center_y, coupling) = {
  let positions = ((-24, -21), (24, -21), (-24, 21), (24, 21))
  let offsets = ((10, -7), (-8, 8), (9, 6), (-9, -7))
  let atoms = positions
    .zip(offsets)
    .map(((position, offset)) => (
      center_x + position.at(0) + offset.at(0),
      center_y + position.at(1) + offset.at(1),
    ))
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
  for (idx, position) in positions.enumerate() {
    let fixed = (center_x + position.at(0), center_y + position.at(1))
    if coupling < 1 {
      spring(fixed, atoms.at(idx), color: purple, thickness: (1.6 - coupling) * 1pt, amplitude: 2)
      site(..fixed, size: 3.5)
    }
    atom(..atoms.at(idx), radius: 7, color: if coupling == 1 { teal } else { purple })
  }
}

// Use page coordinates throughout: x increases rightward, y downward.
#canvas(length: 1pt, y: -1, {
  rect((0, 0), (1180, 1952), fill: none, stroke: none)
  label(28, 18, 1124, [Einstein crystal], size: 43pt, color: ink, weight: "bold")
  label(
    30,
    78,
    1110,
  )[One solvable model connects atomic vibrations, quantum heat capacity, entropy, and solid free energies.]

  // === Fixed-site model ===
  panel(24, 123, 610, 518, 1, [Replace the crystal by local springs], blue, blue_fill)
  label(
    45,
    184,
    567,
    size: 19pt,
    color: blue,
    weight: "bold",
  )[N atoms × 3 directions = M = 3N independent modes]
  let offsets = (
    (20, -9),
    (-17, -10),
    (16, 13),
    (-15, 15),
    (24, -11),
    (-14, -15),
    (20, 7),
    (-16, 10),
    (16, -13),
  )
  for (idx, offset) in offsets.enumerate() {
    let site_x = 87 + calc.rem(idx, 3) * 77
    let site_y = 240 + calc.floor(idx / 3) * 56
    spring((site_x, site_y), (site_x + offset.at(0), site_y + offset.at(1)))
    site(site_x, site_y)
    atom(site_x + offset.at(0), site_y + offset.at(1))
  }
  label(47, 374, 276, size: 16pt)[Cross: fixed site $bold(R)_i$\ Dot: atom at $bold(r)_i$]
  label(363, 223, 240, centered: true, size: 17pt)[One displacement coordinate]
  arrow((365, 354), (604, 354), color: guide)
  arrow((477, 354), (477, 248), color: guide)
  let parabola = range(101).map(sample_idx => {
    let position = (sample_idx - 50) / 50
    (477 + position * 96, 346 - 87 * position * position)
  })
  line(..parabola, stroke: 2pt + blue)
  site(477, 346)
  circle((530, 319), radius: 9, fill: blue, stroke: none, name: "displaced-atom")
  arrow("displaced-atom.west", (rel: (-30, 0)), color: orange)
  symbol(584, 323, $F_u = -kappa u$, size: 17pt, color: orange)
  symbol(604, 372, $u$)
  symbol(457, 264, $V$)
  label(364, 379, 244, size: 17pt, centered: true)[$bold(u)_i = bold(r)_i - bold(R)_i$]
  equation(
    43,
    414,
    571,
  )[$V_"E" = kappa/2 sum_(i=1)^N |bold(u)_i|^2 quad omega_"E" = sqrt(kappa/m)$]
  label(
    43,
    455,
    566,
    size: 15pt,
    centered: true,
  )[Same stiffness $kappa$ and mass $m$; springs attach to sites, not neighboring atoms.]
  callout(44, 491, 570, blue, [Read the restoring force])[
    $bold(u)_i$ is atom $i$’s displacement from its fixed site. The force points back toward the potential minimum: $F_u = -kappa u$. Doubling $|u|$ quadruples the spring energy. Stiffer springs or lighter atoms have a higher angular frequency $omega_"E"$. This harmonic approximation describes small vibrations about stable sites.
  ]

  // === Quantized energy and populations ===
  panel(652, 123, 504, 518, 2, [Heating fills a quantum ladder], orange, orange_fill)
  equation(674, 181, 458)[$E_n = (n + 1/2) ℏ omega_"E" quad n = 0,1,2,...$]
  label(839, 226, 115, size: 16pt, color: blue, centered: true)[Cold\ $T = Theta_"E"/4$]
  label(1002, 226, 117, size: 16pt, color: orange, centered: true)[Warm\ $T = 2 Theta_"E"$]
  for level in range(5) {
    let level_y = 397 - level * 29
    symbol(705, level_y, $n = #level$, size: 16pt)
    segment(
      (741, level_y),
      (813, level_y),
      color: if level == 0 { orange } else { ink },
      thickness: 1.7pt,
    )
    for (left, temperature, color) in ((844, 0.25, blue), (1006, 2, orange)) {
      let probability = level_probability(level, temperature)
      rect(
        (left, level_y - 7),
        (left + 103 * probability, level_y + 7),
        radius: 1.5,
        fill: color,
        stroke: none,
      )
    }
  }
  arrow((821, 397), (821, 368), color: orange, both: true)
  label(
    674,
    416,
    459,
    size: 17pt,
    centered: true,
  )[$P(n) = (1-e^(-x)) e^(-n x)$; bar length = probability.]
  label(
    674,
    449,
    461,
    size: 15pt,
    centered: true,
  )[Gap $ℏ omega_"E"$; the ground state still has $E_0 = ℏ omega_"E"/2$. Higher levels omitted.]
  callout(672, 491, 464, orange, [Thermal energy competes with the gap])[
    $n$ counts excitation quanta of one mode; $P(n)$ is its level probability. $Theta_"E"$ expresses the energy gap as a temperature. Thus $x = Theta_"E" / T$ compares the gap $ℏ omega_"E"$ with thermal energy $k_"B" T$: large $x$ means few excited states.
  ]

  // === Heat capacity computed from the oscillator spectrum ===
  panel(24, 659, 690, 615, 3, [Why the heat capacity falls on cooling], blue, blue_fill)
  label(
    44,
    717,
    649,
  )[Thermal excitations store heat. The fixed zero-point energy contributes no heat capacity.]
  equation(
    44,
    765,
    648,
    color: blue,
  )[$C_V/(3 N k_"B") = (x^2 e^x)/(e^x - 1)^2 quad x = Theta_"E"/T quad Theta_"E" = (ℏ omega_"E")/k_"B"$]
  let plot_left = 94
  let plot_bottom = 1011
  let plot_width = 576
  let plot_height = 170
  label(44, 807, 210, size: 16pt)[Heat capacity / $3 N k_"B"$]
  for tick in (0, 0.5, 1) {
    let tick_y = plot_bottom - plot_height * tick
    segment((plot_left, tick_y), (plot_left + plot_width, tick_y), dash: "dotted")
    symbol(75, tick_y, str(tick), size: 16pt)
  }
  for tick in (0, 0.5, 1, 1.5, 2) {
    let tick_x = plot_left + plot_width * tick / 2
    segment((tick_x, plot_bottom), (tick_x, plot_bottom + 5))
    symbol(tick_x, plot_bottom + 19, str(tick), size: 16pt)
  }
  segment((plot_left, plot_bottom), (plot_left + plot_width, plot_bottom))
  segment((plot_left, plot_bottom), (plot_left, plot_bottom - plot_height))
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
    (plot_left, plot_bottom - plot_height),
    (plot_left + plot_width, plot_bottom - plot_height),
    color: muted,
    thickness: 1.5pt,
    dash: "dashed",
  )
  label(260, 807, 284, size: 16pt)[Classical Dulong–Petit limit: 1]
  segment((430, 916), (466, 916), color: blue, thickness: 3pt)
  label(477, 902, 170, size: 17pt, color: blue)[Einstein: one frequency]
  segment((430, 959), (466, 959), color: teal, thickness: 3pt)
  label(477, 945, 180, size: 17pt, color: teal)[Debye: acoustic spectrum]
  symbol(379, 1051, $T slash Theta$, size: 17pt)
  label(
    43,
    1071,
    655,
    size: 16pt,
    centered: true,
  )[Cold Einstein: $C_V prop x^2 e^(-x)$ · Hot: $C_V -> 3 N k_"B"$\ Equal $Theta_"E" = Theta_"D" = Theta$ for shape comparison; real fitted scales differ.]
  callout(44, 1124, 650, blue, [Heat capacity measures energy stored per degree])[
    $C_V = ((partial U) / (partial T))_V$ measures how much energy a small temperature rise stores at fixed volume. Classically, each mode contributes $k_"B"/2$ from motion and $k_"B"/2$ from its spring, so $3N$ modes give $3N k_"B"$. At low $T$, a mode stores little extra heat when its excitation gap greatly exceeds $k_"B" T$.
  ]

  // === Local oscillators versus collective normal modes ===
  panel(732, 659, 424, 615, 4, [Real crystals have phonons], teal, teal_fill)
  label(752, 718, 381)[Atoms move together. A phonon is one quantum of a collective vibration.]
  let wave_atoms = range(7).map(site_idx => (
    773 + 54 * site_idx,
    814 - 15 * calc.sin(site_idx * calc.pi / 3),
  ))
  for (start, end) in wave_atoms.windows(2) { spring(start, end, color: teal, amplitude: 3) }
  for position in wave_atoms { atom(..position, color: teal, radius: 7) }
  label(752, 847, 381, size: 16pt, centered: true)[Coupled atoms → many normal-mode frequencies]
  for left in (776, 991) {
    arrow((left, 986), (left + 136, 986), color: guide)
    arrow((left, 986), (left, 906), color: guide)
    symbol(left - 7, 891, $g(omega)$, size: 16pt)
    symbol(left + 139, 1002, $omega$, size: 16pt)
  }
  arrow((837, 986), (837, 910), color: blue)
  symbol(837, 1007, $omega_"E"$, size: 16pt, color: blue)
  let spectrum = range(81).map(sample_idx => {
    let fraction = sample_idx / 80
    (991 + 106 * fraction, 986 - 74 * fraction * fraction)
  })
  line(..spectrum, stroke: 2.5pt + teal)
  segment((1097, 912), (1097, 986), color: teal, dash: "dotted")
  symbol(1097, 1007, $omega_"D"$, size: 16pt, color: teal)
  label(763, 1026, 167, size: 16pt, centered: true, color: blue)[One frequency]
  label(970, 1026, 170, size: 16pt, centered: true, color: teal)[Debye: $g(omega) prop omega^2$]
  label(
    751,
    1052,
    383,
    size: 16pt,
    centered: true,
  )[Each spectrum contains 3N modes. In 3D, low-frequency acoustic modes give $C_V prop T^3$.]
  label(751, 1095, 383, size: 14pt, centered: true)[Harmonic normal modes remain independent.]
  callout(752, 1124, 384, teal, [Why soft modes matter])[
    $g(omega) dif omega$ counts modes in a frequency interval. Soft acoustic modes remain easy to excite as the solid cools, giving $C_V prop T^3$ at low $T$. $omega_"D"$ sets the cutoff, with $Theta_"D" = ℏ omega_"D" / k_"B"$.
  ]

  // === Exact, enumerable microstates ===
  panel(24, 1292, 430, 555, 5, [Count states to get entropy], orange, orange_fill)
  label(
    44,
    1354,
    389,
  )[One atom: M = 3 modes, q = 2 quanta.\ Six allocations have the same energy.]
  for (state_idx, state) in allocations.enumerate() {
    let center_x = 104 + 126 * calc.rem(state_idx, 3)
    let baseline = 1464 + 84 * calc.floor(state_idx / 3)
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
  equation(43, 1590, 390)[$Omega(M, q) = binom(q+M-1, q)$]
  equation(43, 1639, 390, color: orange)[$S = k_"B" ln Omega quad M = 3N$]
  callout(44, 1697, 390, orange, [Same energy, different microstates])[
    Each bin is an $x$, $y$, or $z$ mode. The total excitation energy is $q ℏ omega_"E"$ above the ground state. $Omega$ counts allocations at fixed $q$: more possibilities mean larger entropy. Here $Omega = 6$ and $S = k_"B" ln 6$.
  ]

  // === Classical free-energy application ===
  panel(472, 1292, 684, 555, 6, [A reference for solid free energies], purple, purple_fill)
  label(
    493,
    1354,
    641,
  )[Classical Frenkel–Ladd integration · Helmholtz free energy $F = U - T S$]
  for (center_x, coupling, name) in (
    (568, 0, [Springs only]),
    (807, 0.5, [Blend]),
    (1055, 1, [Real interactions]),
  ) {
    symbol(center_x, 1407, $lambda = #coupling$, size: 17pt, color: purple)
    reference_cell(center_x, 1462, coupling)
    label(center_x - 84, 1501, 168, name, size: 17pt, centered: true)
  }
  arrow((632, 1460), (738, 1460), color: purple)
  arrow((872, 1460), (983, 1460), color: purple)
  equation(492, 1531, 643)[$V_lambda = (1-lambda) V_"E" + lambda V_"real"$]
  equation(
    491,
    1575,
    645,
    size: 25pt,
    color: purple,
  )[$F_"real" - F_"E" = integral_0^1 chevron.l V_"real" - V_"E" chevron.r_lambda dif lambda$]
  label(
    493,
    1624,
    641,
    size: 15pt,
  )[$chevron.l ... chevron.r_lambda$: equilibrium average in the blend. Keep temperature, volume, and the positional constraint fixed along a reversible crystal path. Release the fixed center of mass (or one particle: Einstein molecule) with its analytic free-energy correction.]
  callout(492, 1697, 644, purple, [Use: compare candidate crystal structures])[
    $lambda in [0,1]$ controls the blend. Sampling each value gives the average in the integral, which adds up the reversible free-energy change. The result includes both energy and entropy through $F = U - T S$. At the same temperature, volume, and particle number, the candidate with lower Helmholtz free energy $F$ is favored.
  ]

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
