#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, line, rect, translate

// Fixed nuclei, zero temperature; insulating systems with well-defined charge gaps.
// Exact multiplicative Kohn-Sham potential: Eg = E_KS + Delta_xc.
// The optical relation refers to a bound bright exciton below its matching direct
// electron-hole continuum, not an arbitrary indirect fundamental band gap.
// Sources: Perdew & Levy, PRL 51, 1884 (1983), doi:10.1103/PhysRevLett.51.1884;
// Sham & Schlüter, PRL 51, 1888 (1983), doi:10.1103/PhysRevLett.51.1888;
// Onida, Reining & Rubio, RMP 74, 601 (2002), doi:10.1103/RevModPhys.74.601.
#set page(width: auto, height: auto, margin: 0pt, fill: none)
#set text(font: "Avenir Next", size: 18pt, fill: rgb("#19304E"))
#set par(leading: 0.55em)
#set math.equation(numbering: none)

#let ink = rgb("#19304E")
#let muted = rgb("#344257")
#let blue = rgb("#2764C3")
#let teal = rgb("#087F7C")
#let orange = rgb("#BC502D")
#let purple = rgb("#7948AD")
#let label(left, top, width, body, size: 18pt, color: ink, weight: "regular", centered: false) = {
  content(
    (left, -top),
    block(width: width * 1pt)[
      #text(size: size, fill: color, weight: weight, if centered { align(center, body) } else {
        body
      })
    ],
    anchor: "north-west",
    padding: 0pt,
  )
}
#let symbol(center_x, center_y, body, size: 22pt, color: ink) = {
  content(
    (center_x, -center_y),
    text(size: size, fill: color, top-edge: "bounds", bottom-edge: "bounds", body),
    anchor: "center",
    padding: 0pt,
  )
}
#let panel(left, top, width, height, fill) = {
  rect((left, -top), (left + width, -top - height), radius: 12, fill: fill, stroke: none)
}
#let arrow(start_x, start_y, end_x, end_y, color: ink, both: false) = {
  line((start_x, -start_y), (end_x, -end_y), stroke: 1.8pt + color, mark: (
    start: if both { "stealth" } else { none },
    end: "stealth",
    scale: 0.7,
    fill: color,
  ))
}
#let electron(center_x, center_y, color: blue, hole: false) = {
  circle(
    (center_x, -center_y),
    radius: 8,
    fill: if hole { rgb("#cdd3da") } else { color },
    stroke: 1.5pt + color,
  )
  if hole { symbol(center_x, center_y, [+], size: 16pt, color: color) }
}

#canvas(length: 1pt, {
  rect((0, -49), (1000, -1210), fill: none, stroke: none)
  rect((0, -49), (1000, -56), fill: teal, stroke: none)
  label(
    30,
    74,
    940,
    [A calculation, a charging experiment, and a light beam ask different questions.],
    size: 17pt,
    color: muted,
  )
  label(
    30,
    105,
    940,
    [Comparing the right gaps is essential when predicting conductivity, solar absorption, or a material’s color.],
    size: 18pt,
  )

  for (left, tint, heading, subtitle, accent) in (
    (
      24,
      rgb("#c7d3e1"),
      [1  READ THE ORBITALS],
      [Kohn–Sham (KS) gap: auxiliary levels],
      blue,
    ),
    (
      346,
      rgb("#c7d8d1"),
      [2  ADD / REMOVE CHARGE],
      [Fundamental gap: many-electron energies],
      teal,
    ),
    (668, rgb("#e1d2c7"), [3  SHINE LIGHT], [Optical gap: a neutral excitation], orange),
  ) {
    panel(left, 150, 308, 300, tint)
    label(left + 16, 166, 276, heading, size: 21pt, color: accent, weight: "bold")
    label(left + 16, 194, 276, subtitle, size: 18pt, color: muted)
  }

  // Kohn-Sham orbital energies: the gap is a spacing, not a total-energy change.
  line((65, -247), (186, -247), stroke: 2.8pt + blue)
  line((65, -306), (186, -306), stroke: 2.8pt + blue)
  electron(105, 306)
  electron(139, 306)
  arrow(210, 306, 210, 247, color: blue, both: true)
  label(229, 239, 80, [empty], size: 16pt, color: blue)
  label(229, 296, 80, [filled], size: 16pt, color: blue)
  symbol(177, 345, $E_"KS" = epsilon_"L" - epsilon_"H"$, size: 22pt, color: blue)
  label(
    42,
    375,
    272,
    [H: highest occupied; L: lowest unoccupied.],
    size: 18pt,
    color: muted,
    centered: true,
  )

  // N +/- 1 refer to distinct charged systems, not an orbital promotion.
  for (center_x, count, name) in ((400, 2, $N-1$), (500, 3, $N$), (600, 4, $N+1$)) {
    circle((center_x, -270), radius: 30, fill: rgb("#cdd3da"), stroke: 1.3pt + teal.lighten(50%))
    for idx in range(count) {
      let angle = 360deg * idx / count
      electron(center_x + 13 * calc.cos(angle), 270 + 13 * calc.sin(angle), color: teal)
    }
    symbol(center_x, 315, name, size: 17pt, color: teal)
  }
  arrow(467, 270, 436, 270, color: teal)
  arrow(536, 270, 567, 270, color: teal)
  symbol(500, 345, $E_"g" = I - A$, size: 24pt, color: teal)
  label(
    362,
    369,
    276,
    [I: removal cost. A: energy gained on addition.\ N: number of electrons.],
    size: 18pt,
    color: muted,
    centered: true,
  )

  // Photon creates a bound electron-hole pair; total electron number is unchanged.
  circle(
    (852, -274),
    radius: (64, 38),
    fill: orange.lighten(92%),
    stroke: 1.2pt + orange.lighten(58%),
  )
  electron(827, 274, color: orange)
  electron(875, 274, color: orange, hole: true)
  line((839, -274), (863, -274), stroke: (paint: orange, thickness: 1.2pt, dash: "dashed"))
  let wave = range(51).map(idx => (707 + idx * 1.5, -274 + 7 * calc.sin(idx / 50 * 5 * calc.pi)))
  line(..wave, stroke: 1.8pt + orange)
  arrow(781, 274, 801, 274, color: orange)
  label(700, 298, 85, [photon], size: 16pt, color: orange)
  label(790, 318, 136, [electron + hole], size: 16pt, color: orange, centered: true)
  symbol(822, 350, $E_"opt" = h nu_"onset"$, size: 23pt, color: orange)
  label(
    684,
    373,
    276,
    [$h nu$: photon energy; $nu$: frequency.\ A hole is a missing electron in a filled state.],
    size: 18pt,
    color: muted,
    centered: true,
  )

  label(
    30,
    474,
    940,
    [Two corrections, two different pieces of physics],
    size: 24pt,
    weight: "bold",
  )
  label(
    30,
    509,
    940,
    [Charging changes the electron count, so $Delta_"xc"$ converts the KS orbital gap into the fundamental gap.\ Light keeps the count fixed: electron–hole attraction lowers the excitation energy by $E_"bind"$.\ Shown: a direct gap (no momentum from lattice vibrations needed) and a bright exciton (a bound pair that light can create). Not to scale: the two corrections compete, so the optical gap can lie above or below the KS gap.],
    size: 18pt,
    color: muted,
  )

  // Keep the comparison and its explanations together below the expanded introduction.
  translate((0, -135))
  // Three energy gaps share a zero purely for visual comparison, not absolute alignment.
  line((88, -700), (910, -700), stroke: 1pt + muted.lighten(65%))
  for (center_x, upper_y, accent) in ((195, 590, blue), (500, 530, teal), (805, 564, orange)) {
    line((center_x - 80, -upper_y), (center_x + 80, -upper_y), stroke: 3pt + accent)
    arrow(center_x, 694, center_x, upper_y + 7, color: accent, both: true)
  }
  symbol(144, 646, $E_"KS"$, size: 24pt, color: blue)
  symbol(450, 633, $E_"g"$, size: 24pt, color: teal)
  symbol(856, 646, $E_"opt"$, size: 24pt, color: orange)
  arrow(282, 590, 410, 530, color: purple)
  symbol(335, 535, $+ Delta_"xc"$, size: 24pt, color: purple)
  arrow(590, 530, 715, 564, color: orange)
  symbol(656, 505, $- E_"bind"$, size: 24pt, color: orange)
  label(104, 710, 180, [orbital spacing], size: 18pt, color: blue, centered: true)
  label(405, 710, 190, [separated charges], size: 18pt, color: teal, centered: true)
  label(710, 710, 190, [bound electron–hole pair], size: 18pt, color: orange, centered: true)

  panel(24, 751, 468, 155, rgb("#d2cbdc"))
  label(42, 767, 432, [$E_"g" = E_"KS" + Delta_"xc"$], size: 23pt, color: purple, centered: true)
  label(
    42,
    806,
    432,
    [*Derivative discontinuity:* the exact exchange–correlation (XC) potential jumps at an integer electron count. Even exact KS orbital energies need this correction.],
    size: 18pt,
  )
  panel(508, 751, 468, 155, rgb("#e1d2c7"))
  label(526, 767, 432, [$E_"opt" = E_"g" - E_"bind"$], size: 23pt, color: orange, centered: true)
  label(
    526,
    806,
    432,
    [*Exciton binding:* electron–hole attraction lowers the neutral excitation below the matching free-pair threshold. An exciton is this bound pair.],
    size: 18pt,
  )

  label(
    30,
    928,
    940,
    [$E_"g" = E(N+1) + E(N-1) - 2E(N)$, where $E(N)$ is the ground-state total energy at fixed nuclei.],
    size: 18pt,
  )
  label(
    30,
    970,
    940,
    [*Read the conditions:* indirect optical transitions can need phonons for momentum; selection rules can make low excitations dark. The relation above uses a matching direct threshold.],
    size: 18pt,
    color: muted,
  )
  label(
    30,
    1030,
    940,
    [*DFT takeaway:* identify the observable before comparing gaps. The KS relation assumes a local multiplicative potential; hybrid generalized-KS gaps require their own interpretation.],
    size: 18pt,
    color: muted,
  )
})
