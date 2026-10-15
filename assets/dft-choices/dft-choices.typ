#import "@preview/cetz:0.5.2": canvas, draw
#import draw: content, line, rect

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 15pt)

#canvas({
  let arrow-style = (mark: (end: "stealth", fill: black, offset: 4pt), stroke: 0.8pt)
  let node-height = 1.6
  let node-width = 1.2
  let (potential, orbital) = (rgb("#ffb3b3"), rgb("#cdd3da"))

  // Kohn-Sham equation laid out left to right. Each item sits `offset` node widths right of
  // the previous one. Items with a fill are boxed terms of relative width `width`.
  let prev-name = none
  for (name, offset, body, fill, width) in (
    ("kinetic", 0, $-frac(planck^2, 2m) arrow(nabla)_(arrow(r))^(2)$, rgb("#ffd699"), 1.3),
    ("plus-1", 1.6, $+$, none, none),
    ("ext", 1.4, $v_"ext" (arrow(r))$, potential, 1),
    ("plus-2", 1.4, $+$, none, none),
    ("hartree", 1.4, $v_H (arrow(r))$, potential, 1),
    ("plus-3", 1.4, $+$, none, none),
    ("xc", 1, $v_"xc"$, potential, .6),
    ("phi1", 2.4, $phi_i (arrow(r))$, orbital, 1),
    ("eq-1", 1.4, $=$, none, none),
    ("energy", 1, $E_i$, rgb("#b3d9ff"), .6),
    ("phi2", 1.9, $phi_i (arrow(r))$, orbital, 1),
  ) {
    let pos = if prev-name == none { (0, 0) } else {
      (rel: (offset * node-width, 0), to: prev-name)
    }
    if fill == none {
      content(pos, body, name: name)
    } else {
      let half-width = width * node-width
      rect(
        (rel: (-half-width, -node-height / 2), to: pos),
        (rel: (2 * half-width, node-height)),
        fill: fill,
        stroke: 0.4pt,
        radius: 0.2,
        name: name,
      )
      content(name, scale(140%, body))
    }
    prev-name = name
  }

  // Large parentheses around the Hamiltonian
  content((rel: (-1.6 * node-width, 0.1), to: "kinetic"), scale(350%, $($))
  content((rel: (1 * node-width, 0.1), to: "xc"), scale(350%, $)$), padding: 5pt)

  // Each comment sits at a fixed offset from the term it annotates.
  for (offset, body, target) in (
    ((1.7, 3), [non-rel. Schrödinger equation\ or relativistic Dirac equation], "kinetic"),
    ((-2, -3), [pseudopotential\ (ultrasoft/PAW/norm-conserving)\ or all-electron], "ext"),
    (
      (1.37, -3),
      [Hartree potential\ from solving Poisson eq.\ or integrating charge density],
      "hartree",
    ),
    ((-1.34, 3), [LDA or GGA\ or hybrids], "xc"),
    ((2, 3), [physical orbitals or not\ mesh density and basis set], "phi1"),
    ((0, -3), [view EVs as mere Lagrange\ multipliers or band structure approx], "energy"),
  ) {
    content((rel: offset, to: target), align(center, body), name: target + "-comment")
    line(target + "-comment", target, ..arrow-style)
  }
  line("phi1-comment", "phi2", ..arrow-style)
})
