#import "@preview/cetz:0.4.2": canvas, draw
#import draw: circle, content, line

#set page(width: auto, height: auto, margin: 8pt)

#let range = 9
#let xy-ratio = 2 / 3

#canvas({
  let arrow-style = (mark: (end: "stealth", scale: .75), fill: black)

  // Draw axes
  line((-0.5, 0), (range, 0), ..arrow-style) // x-axis
  line((0, -0.5), (0, range * xy-ratio), ..arrow-style) // y-axis

  // Add axis labels
  content(
    (range + 0.1, .15),
    [computational complexity],
    anchor: "south-east",
  )
  content(
    (0.2, range * xy-ratio),
    [accuracy],
    anchor: "north-west",
  )

  // Add N^n labels below x-axis
  for n in std.range(1, 9) {
    content(
      (n, -0.3),
      $N^#n$,
      anchor: "north",
    )
  }

  // Add dashed diagonal line
  line((0, 0), (range, range * xy-ratio), stroke: (dash: "dashed", paint: gray, thickness: .75pt))

  // Data points with labels
  let methods = (
    (2, "semi-empirical", "SE"),
    (4, "Hartree-Fock", "HF"),
    (5, "Moller-Plesset 2nd order", "MP2"),
    (6, "Configuration Interaction", "CISD"),
    (7, "Coupled Cluster", "CCSD(T)"),
  )

  // Draw blue dots for standard methods
  for (x, name, abbr) in methods {
    circle(
      (x, x * xy-ratio),
      radius: 2pt,
      fill: rgb("#393998"),
      stroke: none,
    )
    content(
      (x + 0.2, x * xy-ratio - 0.2),
      [#name],
      anchor: "north-west",
    )
  }

  // Special point for DFT
  circle(
    (3, 5 * xy-ratio),
    radius: 2.4pt,
    fill: rgb("#de2626"),
    stroke: none,
  )
  content(
    (2.7, 5 * xy-ratio),
    [DFT],
    anchor: "east",
  )
})
