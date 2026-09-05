#import "@preview/cetz:0.5.2": canvas, draw
#import draw: bezier, circle, content, line, rect, translate

// Ground-state, nonrelativistic Coulomb DFT, atomic units, integer KS occupations.
// At a fixed density: Exc = T - Ts + Vee - EH; Ex = <Phi_s|Vee|Phi_s> - EH.
// Ec = Tc + Uc, with Tc = T - Ts and Uc = Vee - EH - Ex.
// A physical XC hole gives the interaction correction only; its coupling-strength
// average at fixed density also incorporates Tc in the Coulomb energy integral.
// The schematic profiles below are illustrations, not calculated electron densities.
// Sources: https://dft.uci.edu/teaching/lausanne/ABCDFT.pdf (chapters 7, 11-13),
// https://dft.uci.edu/pubs/B97.pdf (XC holes),
// https://www.bristol.ac.uk/physics/media/theory-theses/archer-aj-thesis.pdf (chapter 2).
#set page(width: auto, height: auto, margin: 0pt, fill: white)
#set text(font: "Avenir Next", size: 14pt, fill: rgb("#22334B"))
#set par(leading: 0.5em)
#set math.equation(numbering: none)

#let ink = rgb("#19304E")
#let muted = rgb("#617087")
#let blue = rgb("#2764C3")
#let orange = rgb("#B94F2C")
#let purple = rgb("#7948AD")
#let teal = rgb("#087F7C")
#let pale_blue = rgb("#F0F5FE")
#let pale_orange = rgb("#FFF5EF")

#let label(left, top, width, body, size: 14pt, color: ink, weight: "regular", centered: false) = {
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
// Use the rendered glyph bounds rather than a top-aligned paragraph for symbols.
#let centered_symbol(center_x, center_y, body, size: 24pt, color: ink) = {
  content(
    (center_x, -center_y),
    text(size: size, fill: color, top-edge: "bounds", bottom-edge: "bounds", body),
    anchor: "center",
    padding: 0pt,
  )
}
#let panel(left, top, width, height, fill) = {
  rect((left, -top), (left + width, -top - height), radius: 17, fill: fill, stroke: none)
}
#let connect(start, end, color: muted, dashed: false) = {
  line(
    start,
    end,
    stroke: (paint: color, thickness: 1.8pt, dash: if dashed { "dashed" } else { "solid" }),
    mark: (end: "stealth", scale: 0.7, fill: color),
  )
}
#let curve(start, end, control_a, control_b, color: muted, arrowhead: false) = {
  bezier(start, end, control_a, control_b, stroke: 1.8pt + color, mark: if arrowhead {
    (end: "stealth", scale: 0.7, fill: color)
  } else { none })
}
#let electron(center_x, center_y, spin: none, color: blue, radius: 10) = {
  circle((center_x, -center_y), radius: radius, fill: color, stroke: none)
  if spin != none {
    let direction = if spin == "up" { 1 } else { -1 }
    line(
      (center_x, -center_y - direction * 5),
      (center_x, -center_y + direction * 5),
      stroke: 1.3pt + white,
      mark: (end: "stealth", scale: 0.45, fill: white),
    )
  }
}
#let nucleus(center_x, center_y, radius: 9) = {
  circle((center_x, -center_y), radius: radius, fill: ink, stroke: none)
  line((center_x - 4, -center_y), (center_x + 4, -center_y), stroke: 1.3pt + white)
  line((center_x, -center_y - 4), (center_x, -center_y + 4), stroke: 1.3pt + white)
}

// A shaded probability map: the central dot is conditioned on, not a moving particle.
#let density_map(center_x, center_y, radius: 68, kind: "exchange", color: blue) = {
  if kind == "exchange" {
    circle((center_x, -center_y), radius: radius, fill: color.lighten(65%), stroke: none)
    for idx in range(32) {
      let ring_radius = radius * (1 - idx / 34)
      let lightness = 65% + idx / 31 * 33%
      circle(
        (center_x, -center_y),
        radius: ring_radius,
        fill: color.lighten(lightness),
        stroke: none,
      )
    }
  } else if kind == "correlation" {
    circle((center_x, -center_y), radius: radius, fill: teal.lighten(63%), stroke: none)
    for idx in range(28) {
      circle(
        (center_x, -center_y),
        radius: radius * (0.82 - idx / 38),
        fill: orange.lighten(94% - idx / 27 * 27%),
        stroke: none,
      )
    }
  } else {
    circle((center_x, -center_y), radius: radius, fill: color.lighten(72%), stroke: none)
  }
  electron(center_x, center_y, spin: "up", color: ink, radius: 10)
}
#let hole_plot(left, top, kind, color) = {
  let baseline = top + 30
  let plot_width = 212
  line((left, -baseline), (left + plot_width, -baseline), stroke: (
    paint: muted,
    thickness: 0.7pt,
    dash: "dashed",
  ))
  let points = range(151).map(idx => {
    let distance = idx / 150 * 4.5
    let value = if kind == "exchange" {
      -calc.exp(-distance * distance)
    } else {
      let scaled_distance = distance / 1.6
      (4 / 3 * calc.pow(scaled_distance, 4) - 1) * calc.exp(-calc.pow(scaled_distance, 4))
    }
    (left + idx / 150 * plot_width, -baseline + 60 * value)
  })
  line(
    (left, -baseline),
    ..points,
    (left + plot_width, -baseline),
    close: true,
    fill: color.lighten(82%),
    stroke: none,
  )
  line(..points, stroke: 2.8pt + color)
  label(
    left + 2,
    top - 12,
    70,
    if kind == "exchange" { [$h_x$] } else { [$h_c$] },
    size: 18pt,
    color: color,
  )
  label(left - 15, baseline - 8, 13, [0], size: 11pt, color: muted)
  label(left + 130, top + 94, 90, [separation →], size: 11pt, color: muted)
  label(left + 76, top + 65, 75, [deficit], size: 11pt, color: color)
  if kind == "correlation" { label(left + 99, top + 2, 90, [excess], size: 11pt, color: teal) }
}

#canvas(length: 1pt, {
  rect((0, 0), (1100, -1225), fill: white, stroke: none)
  rect((0, 0), (1100, -8), fill: teal, stroke: none)
  label(30, 26, 1040, [Exchange & correlation], size: 37pt, weight: "bold")
  label(
    32,
    77,
    1040,
    [DFT’s missing energy: same density, different electron-pair probabilities.],
    size: 18pt,
    color: muted,
  )

  label(
    32,
    110,
    1036,
    [A *functional* maps the whole density to an energy. Kohn-Sham uses *noninteracting electrons at the same density*.],
    size: 13.5pt,
  )
  translate((0, -40))

  // === The four terms, drawn as physical ingredients ===
  for (center_x, title, caption, color) in (
    (170, [$T_s$], [KS kinetic energy], teal),
    (425, [$V_"ext"$], [nuclear attraction], ink),
    (680, [$E_H$], [smooth-charge repulsion], muted),
    (935, [$E_"xc"$], [the missing correction], purple),
  ) {
    label(center_x - 100, 200, 200, title, size: 29pt, color: color, centered: true)
    label(center_x - 115, 234, 230, caption, size: 13pt, color: color, centered: true)
  }
  // Orbital wave: Ts is already quantum.
  line((103, -178), (237, -178), stroke: 0.7pt + teal.lighten(65%))
  let wave_points = range(101).map(idx => (
    105 + idx * 1.3,
    -159 + 18 * calc.sin(idx / 100 * 4 * calc.pi),
  ))
  line(..wave_points, stroke: 2.8pt + teal)
  label(107, 117, 130, [already quantum], size: 11pt, color: teal, centered: true)
  // Electron-nucleus attraction.
  nucleus(390, 156, radius: 15)
  electron(468, 156, radius: 11)
  connect((451, -156), (413, -156), color: blue)
  // Hartree: two smooth patches of the same density, no conditional hole.
  circle((650, -157), radius: 29, fill: blue.lighten(78%), stroke: none)
  circle((710, -157), radius: 29, fill: blue.lighten(78%), stroke: none)
  connect((634, -157), (612, -157), color: muted)
  connect((726, -157), (748, -157), color: muted)
  // XC split, indicated with the same colors used below.
  circle((914, -155), radius: 25, fill: blue.lighten(70%), stroke: none)
  circle((955, -155), radius: 25, fill: orange.lighten(70%), stroke: none)
  centered_symbol(914, 155, [$x$], color: blue)
  centered_symbol(955, 155, [$c$], color: orange)
  label(20, 203, 89, [$E[n] =$], size: 23pt)
  for center_x in (297, 552, 807) { label(center_x - 10, 202, 28, [$+$], size: 25pt, color: muted) }
  label(
    30,
    270,
    1040,
    [$E_"xc" = underbrace(T - T_s, "kinetic correction") + underbrace(V_(e e) - E_H, "interaction correction") = E_x + E_c$],
    size: 23pt,
    color: purple,
    centered: true,
  )

  // === Exchange: swapping amplitudes and the same-spin hole ===
  panel(28, 323, 514, 466, pale_blue)
  panel(558, 323, 514, 466, pale_orange)
  label(49, 339, 468, [EXCHANGE], size: 25pt, color: blue, weight: "bold")
  label(
    49,
    377,
    468,
    [Antisymmetry: swapping fermions changes the sign.],
    size: 13.5pt,
    color: blue,
  )

  electron(123, 441, spin: "up", radius: 17)
  electron(264, 441, spin: "up", radius: 17)
  curve((130, -419), (255, -419), (159, -390), (226, -390), color: blue, arrowhead: true)
  curve((256, -463), (133, -463), (227, -490), (164, -490), color: blue, arrowhead: true)
  centered_symbol(193.5, 441, [swap], size: 15pt, color: blue)
  label(100, 474, 51, [$bold(r)_1$], size: 13pt, centered: true)
  label(240, 474, 51, [$bold(r)_2$], size: 13pt, centered: true)
  centered_symbol(418.5, 441, [$Psi -> -Psi$], size: 27pt, color: blue)
  label(328, 460, 181, [same position → $Psi = 0$], size: 13pt, centered: true)
  label(
    56,
    510,
    457,
    [Pauli exclusion • same spin only • present in one determinant],
    size: 12.5pt,
    color: blue,
    centered: true,
  )

  label(
    63,
    532,
    443,
    [Opposite-spin pairs have no exchange hole.],
    size: 11.5pt,
    color: blue,
    centered: true,
  )

  density_map(142, 621)
  label(59, 702, 166, [same-spin probability], size: 11pt, color: blue, centered: true)
  hole_plot(282, 563, "exchange", blue)
  label(
    270,
    678,
    247,
    [$integral h_x dif^3 bold(r)' = -1$],
    size: 23pt,
    color: blue,
    centered: true,
  )
  label(
    63,
    735,
    443,
    [One missing electron. No extra force.],
    size: 16pt,
    weight: "bold",
    color: blue,
    centered: true,
  )
  label(
    63,
    763,
    443,
    [The hole persists without Coulomb repulsion.],
    size: 12pt,
    color: muted,
    centered: true,
  )

  // === Correlation: three recognizable physical mechanisms ===
  label(579, 339, 468, [CORRELATION], size: 25pt, color: orange, weight: "bold")
  label(
    579,
    377,
    468,
    [Joint probabilities beyond the KS determinant.],
    size: 13.5pt,
    color: orange,
  )
  // Dynamic correlation: spatial avoidance.
  circle((630, -447), radius: 32, fill: orange.lighten(91%), stroke: 0.8pt + orange.lighten(60%))
  electron(614, 447, spin: "up", color: orange)
  electron(646, 447, spin: "down", color: orange)
  connect((603, -447), (582, -447), color: orange)
  connect((657, -447), (678, -447), color: orange)
  label(573, 492, 140, [DYNAMIC], size: 12.5pt, weight: "bold", color: orange, centered: true)
  label(573, 514, 140, [short-range avoidance\ and screening], size: 11.5pt, centered: true)

  // Static correlation: the two separated-atom spin configurations of a singlet.
  for (row_y, first_spin, second_spin) in ((424, "up", "down"), (469, "down", "up")) {
    circle((759, -row_y), radius: 17, fill: white, stroke: 0.8pt + orange.lighten(65%))
    circle((829, -row_y), radius: 17, fill: white, stroke: 0.8pt + orange.lighten(65%))
    line((779, -row_y), (809, -row_y), stroke: (paint: muted, thickness: 0.8pt, dash: "dashed"))
    electron(759, row_y, spin: first_spin, color: orange, radius: 10)
    electron(829, row_y, spin: second_spin, color: orange, radius: 10)
  }
  centered_symbol(794, 447, [$-$], size: 19pt)
  label(724, 492, 140, [STATIC], size: 12.5pt, weight: "bold", color: orange, centered: true)
  label(
    718,
    514,
    151,
    [several configurations\ stretched-bond singlet],
    size: 11.5pt,
    centered: true,
  )

  // Dispersion: correlated instantaneous dipoles, not permanent ones.
  for center_x in (931, 1004) {
    circle((center_x + 8, -445), radius: 24, fill: orange.lighten(76%), stroke: none)
    nucleus(center_x - 8, 445, radius: 8)
    centered_symbol(center_x + 14, 445, [$-$], size: 18pt, color: orange)
    connect((center_x - 17, -478), (center_x + 23, -478), color: orange)
  }
  line((956, -445), (978, -445), stroke: (paint: orange, thickness: 1.4pt, dash: "dashed"))
  label(890, 492, 155, [DISPERSION], size: 12.5pt, weight: "bold", color: orange, centered: true)
  label(
    883,
    514,
    170,
    [coupled fluctuations\ even at zero temperature],
    size: 11.5pt,
    centered: true,
  )

  density_map(672, 621, kind: "correlation", color: orange)
  label(589, 702, 166, [change in probability], size: 11pt, color: orange, centered: true)
  hole_plot(812, 563, "correlation", orange)
  label(
    800,
    678,
    247,
    [$integral h_c dif^3 bold(r)' = 0$],
    size: 23pt,
    color: orange,
    centered: true,
  )
  label(
    593,
    735,
    443,
    [Same-spin and opposite-spin pairs.],
    size: 16pt,
    weight: "bold",
    color: orange,
    centered: true,
  )
  label(
    593,
    763,
    443,
    [A near deficit is balanced by an excess farther away.],
    size: 12pt,
    color: muted,
    centered: true,
  )

  // === Compact energy ledger: preserve the kinetic correction ===
  label(
    47,
    807,
    484,
    [$E_x = chevron.l Phi_s bar.v hat(V)_(e e) bar.v Phi_s chevron.r - E_H <= 0$],
    size: 21pt,
    color: blue,
    centered: true,
  )
  label(
    577,
    802,
    477,
    [$E_c = underbrace(T - T_s, T_c >= 0) + underbrace(V_(e e) - E_H - E_x, U_c) <= 0$],
    size: 22pt,
    color: orange,
    centered: true,
  )
  label(
    45,
    846,
    485,
    [$Phi_s$: antisymmetric KS orbital state. $T$, $V_(e e)$: exact interacting values at the same density.],
    size: 11.5pt,
    color: muted,
    centered: true,
  )
  label(
    580,
    861,
    475,
    [Correlation balances reduced repulsion against a kinetic cost.],
    size: 12pt,
    color: orange,
    centered: true,
  )

  // === The sum rule: the picture to remember ===
  panel(28, 900, 1044, 69, rgb("#F4F0FA"))
  label(45, 914, 275, [ONE REFERENCE ELECTRON], size: 13pt, color: purple, weight: "bold")
  label(45, 941, 275, [Only $N - 1$ others remain.], size: 12pt, color: purple)
  label(336, 916, 397, [$n_"cond" = n + h_x + h_c$], size: 26pt, color: purple, centered: true)
  label(758, 914, 285, [net hole: $-1 + 0 = -1$], size: 23pt, color: purple, centered: true)
  label(
    758,
    948,
    285,
    [probability deficit, not an empty cavity],
    size: 10.5pt,
    color: muted,
    centered: true,
  )

  // === Classical contrast, exact one-electron check, and the KS feedback loop ===
  label(34, 991, 310, [CLASSICAL CHARGES], size: 13pt, color: teal, weight: "bold")
  electron(70, 1038, color: teal, radius: 12)
  electron(132, 1038, color: teal, radius: 12)
  connect((50, -1038), (30, -1038), color: teal)
  connect((151, -1038), (165, -1038), color: teal)
  label(36, 1061, 152, [correlated positions], size: 11pt, color: teal, centered: true)
  label(179, 1016, 172, [Correlation: *yes*\ Pauli exchange: *no*], size: 13pt, color: teal)

  label(
    383,
    991,
    258,
    [ONE ELECTRON: NO SELF-REPULSION],
    size: 11.5pt,
    color: purple,
    weight: "bold",
    centered: true,
  )
  electron(410, 1038, color: purple, radius: 12)
  label(
    385,
    1074,
    260,
    [Approximate XC can violate this cancellation.],
    size: 10.5pt,
    color: muted,
    centered: true,
  )
  label(435, 1020, 204, [$E_H + E_x = 0$\ $E_c = 0$], size: 19pt, color: purple, centered: true)

  label(
    700,
    991,
    350,
    [XC FEEDS BACK INTO THE DENSITY],
    size: 12pt,
    color: purple,
    weight: "bold",
    centered: true,
  )
  centered_symbol(765.5, 1040, [$v_"xc" = (delta E_"xc") / (delta n)$], size: 19pt, color: purple)
  connect((840, -1040), (873, -1040), color: purple)
  centered_symbol(919, 1040, [orbitals], size: 14pt, color: purple)
  connect((964, -1040), (994, -1040), color: purple)
  centered_symbol(1018, 1040, [$n$], size: 22pt, color: purple)
  curve((1018, -1058), (756, -1060), (1018, -1094), (756, -1094), color: purple, arrowhead: true)

  label(
    30,
    1100,
    1040,
    [*Why approximate?* Exact XC is formally defined, but no practical general expression is known.],
    size: 12pt,
    color: muted,
    centered: true,
  )
  label(
    30,
    1124,
    1040,
    [LDA: local electron gas · GGA: density gradients · hybrids: orbital exchange. Ordinary LDA/GGA miss long-range dispersion.],
    size: 11.5pt,
    color: muted,
    centered: true,
  )
  label(
    30,
    1150,
    1040,
    [Schematic maps / curves; map center = reference electron. Hole sums are 3D integrals. Fixed nuclei; spin labels suppressed; atomic units; nuclear repulsion added separately.],
    size: 9.5pt,
    color: muted,
    centered: true,
  )
  label(
    30,
    1169,
    1040,
    [#link("https://dft.uci.edu/teaching/lausanne/ABCDFT.pdf")[Burke: The ABC of DFT, §§7, 11–13] · #link("https://dft.uci.edu/pubs/B97.pdf")[The exchange-correlation hole] · #link("https://www.bristol.ac.uk/physics/media/theory-theses/archer-aj-thesis.pdf")[Archer: Classical fluids, ch. 2]],
    size: 9pt,
    color: muted,
    centered: true,
  )
})
