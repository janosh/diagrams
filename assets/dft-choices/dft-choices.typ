#import "@preview/cetz:0.3.3": canvas, draw
#import draw: line, content, rect

#set page(width: auto, height: auto, margin: 8pt)
#set text(size: 15pt)

#canvas({
  // Define styles and constants
  let node-sep = 1.7 // Reduced horizontal separation
  let arrow-style = (mark: (end: "stealth", fill: black, offset: 4pt), stroke: 0.8pt)
  let node-height = 1.6 // Shorter boxes
  let node-width = 1.2 // Increased for larger text

  // Helper function to create rounded rectangle nodes
  let node(pos, text, fill: none, name: none, width: node-width, height: node-height) = {
    rect(
      (rel: (-width, -height / 2), to: pos),
      (rel: (2 * width, height)),
      fill: fill,
      stroke: 0.4pt,
      radius: 0.2,
      name: name,
    )
    content(name, scale(140%, text))
  }

  // Create main equation nodes

  node(
    (0, 0),
    $-frac(planck.reduce^2, 2m) arrow(nabla)_arrow(r)^2$,
    fill: rgb("#ffd699"),
    name: "kinetic",
    width: 1.3 * node-width,
  ) // Kinetic term

  content((rel: (-1.6 * node-width, 0.1), to: "kinetic"), scale(350%, $($), name: "lparen") // Opening parenthesis

  content((rel: (1.6 * node-width, 0), to: "kinetic"), $+$, name: "plus-1")

  node(
    (rel: (1.4 * node-width, 0), to: "plus-1"),
    $v_"ext" (arrow(r))$,
    fill: rgb("#ffb3b3"),
    name: "ext",
  ) // External potential

  content((rel: (1.4 * node-width, 0), to: "ext"), $+$, name: "plus-2")

  node(
    (rel: (1.4 * node-width, 0), to: "plus-2"),
    $v_H (arrow(r))$,
    fill: rgb("#ffb3b3"),
    name: "hartree",
  ) // Hartree potential

  content((rel: (1.4 * node-width, 0), to: "hartree"), $+$, name: "plus-3")

  node(
    (rel: (1 * node-width, 0), to: "plus-3"),
    $v_"xc"$,
    fill: rgb("#ffb3b3"),
    name: "xc",
    width: .6 * node-width,
  ) // Exchange-correlation

  content(
    (rel: (1 * node-width, 0.1), to: "xc"),
    scale(350%, $)$),
    name: "rparen",
    padding: 5pt,
  ) // Large closing parenthesis

  node(
    (rel: (2.4 * node-width, 0), to: "xc"),
    $phi_i (arrow(r))$,
    fill: rgb("#e6e6e6"),
    name: "phi1",
  ) // Wavefunction 1

  content((rel: (1.4 * node-width, 0), to: "phi1"), $=$, name: "eq-1")

  node(
    (rel: (1 * node-width, 0), to: "eq-1"),
    $E_i$,
    fill: rgb("#b3d9ff"),
    name: "energy",
    width: 0.6 * node-width,
  ) // Energy

  node(
    (rel: (1.9 * node-width, 0), to: "energy"),
    $phi_i (arrow(r))$,
    fill: rgb("#e6e6e6"),
    name: "phi2",
  ) // Wavefunction 2

  // Add comment boxes and arrows
  let comment(pos, text, target-name, name: none) = {
    content(pos, align(center, text), name: name)
    line(name, target-name, ..arrow-style)
  }

  // Add comments with arrows
  comment(
    (node-sep, 3),
    [non-rel. Schrödinger equation\
      or relativistic Dirac equation],
    "kinetic",
    name: "kinetic-comment",
  )

  comment(
    (rel: (-2, -3), to: "ext"),
    [pseudopotential\
      (ultrasoft/PAW/norm-conserving)\ or all-electron],
    "ext",
    name: "ext-comment",
  )

  comment(
    (4.9 * node-sep, -3),
    [Hartree potential\ from solving Poisson eq.\
      or integrating charge density],
    "hartree",
    name: "hartree-comment",
  )

  comment(
    (5 * node-sep, 3),
    [LDA or GGA\ or hybrids],
    "xc",
    name: "xc-comment",
  )

  comment(
    (rel: (2, 3), to: "phi1"),
    [physical orbitals or not\ mesh density and basis set],
    "phi1",
    name: "phi-comment",
  )
  line("phi-comment", "phi2", ..arrow-style)

  comment(
    (rel: (0, -3), to: "energy"),
    [view EVs as mere Lagrange\ multipliers or band structure approx],
    "energy",
    name: "energy-comment",
  )
})
