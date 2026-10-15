#import "@preview/cetz:0.5.2": canvas, draw
#import draw: arc, circle, content, line, on-layer

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 12pt)

#let green-color = rgb("#77d477")
#let blue-color = rgb("#1a1aff")

#canvas({
  let zmax = 2.5
  let angular-number = 2
  let level-spacing = 0.85
  let angular-radius = calc.sqrt(angular-number * (angular-number + 1)) * level-spacing
  // Length of L's projection onto the x-y plane for magnetic number m.
  let radial-component(magnetic-number) = calc.sqrt(
    angular-radius * angular-radius - calc.pow(magnetic-number * level-spacing, 2),
  )

  for (start, end, label, label-args) in (
    ((0, -2.7 * level-spacing), (0, zmax), $L_z$, (anchor: "west", padding: (left: 3pt))),
    ((0, 0), (zmax, 0), $L_y$, (anchor: "south", padding: (bottom: 3pt))),
    (
      (0, 0),
      (-0.62 * zmax, -0.55 * zmax),
      $L_x$,
      (anchor: "south", padding: (bottom: 6pt, left: -9pt)),
    ),
  ) {
    line(start, end, stroke: black + 1pt, mark: (end: "stealth", fill: black))
    content(end, label, ..label-args)
  }

  // Precession cone of all L sharing m = 1, seen in perspective: L_x and L_y stay undetermined.
  circle(
    (0, level-spacing),
    radius: (radial-component(1), 0.55 * level-spacing),
    stroke: (dash: "dashed", paint: blue-color, thickness: 0.6pt),
  )

  on-layer(1, content(
    (0, 0),
    text(baseline: -0.2pt)[$+$],
    frame: "circle",
    fill: rgb("#ff0000"),
    stroke: none,
  ))

  for magnetic-number in range(-angular-number, angular-number + 1) {
    let tip = (radial-component(magnetic-number), magnetic-number * level-spacing)
    line((0, tip.at(1)), tip, stroke: blue-color + 0.6pt)
    content((0, tip.at(1)), $#magnetic-number thin ħ$, anchor: "east", padding: (right: 6pt))
    line(
      (0, 0),
      tip,
      mark: (end: "stealth", fill: green-color, scale: 0.8),
      stroke: green-color + 1.1pt,
    )
  }

  // |L| = sqrt(l(l+1)) ħ is the same for every orientation.
  arc(
    (0, 0),
    start: 90deg,
    stop: -90deg,
    radius: angular-radius,
    stroke: green-color + .8pt,
    anchor: "origin",
  )

  content(
    (0.95 * angular-radius, 1.45 * level-spacing),
    text(fill: green-color, weight: "bold", size: 19pt)[L],
    anchor: "west",
  )
})
