#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, line

#set page(width: auto, height: auto, margin: 14pt, fill: none)
#set text(font: "Avenir Next", size: 12pt)

// Exponents describe conventional dense algorithms, not measured runtime.
// Vertical coordinates are schematic, not benchmark accuracies or error estimates.
#let methods = (
  (name: "Semilocal DFT", exponent: 3, height: 3.4, color: rgb("#d24636")),
  (name: "Hartree–Fock", exponent: 4, height: 1.7, color: rgb("#385da8")),
  (name: "MP2", exponent: 5, height: 3.5, color: rgb("#385da8")),
  (name: "CCSD", exponent: 6, height: 4.7, color: rgb("#385da8")),
  (name: "CCSD(T)", exponent: 7, height: 5.7, color: rgb("#385da8")),
)
#let scope = "Single-reference molecular energies near equilibrium"
#let qualification = "Schematic positions; accuracy depends on system, observable, and basis."

#canvas({
  let plot_x(exponent) = (exponent - 2) * 2.3
  content((0, 6.95), text(size: 14pt, scope), anchor: "west")

  let arrow = (mark: (end: "stealth", scale: 0.7), stroke: 0.9pt)
  line((0, 0), (13.2, 0), ..arrow)
  line((0, 0), (0, 6.4), ..arrow)
  content((0.15, 6.25), [higher accuracy], anchor: "west")
  content((0.15, 5.75), [qualitative], anchor: "west")
  content((6.6, -1.0), text(size: 14pt)[Conventional scaling · $N$ = basis functions])

  // One method per scaling exponent: axis tick, label and schematic point
  for (name, exponent, height, color) in methods {
    let axis_x = plot_x(exponent)
    line((axis_x, -0.08), (axis_x, 0.08), stroke: 0.7pt)
    content((axis_x, -0.4), $O(N^#exponent)$)
    circle((axis_x, height), radius: 0.085, fill: color, stroke: none)
    content((axis_x, height + 0.36), text(weight: "bold", name))
  }
  content((plot_x(3), 2.95), [functional-dependent])
  content((6.6, -1.8), text(size: 14pt, qualification))
})
