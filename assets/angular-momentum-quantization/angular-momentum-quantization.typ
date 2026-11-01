#import "@preview/cetz:0.5.3": canvas, draw
#import draw: arc, circle, content, line, on-layer

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 12pt)

// L and its fixed magnitude in blue, the quantized z-components m ħ in purple
#let (ink, l-color, m-color, nucleus-color) = ("#19304E", "#2864BB", "#7750A3", "#5A6A80").map(rgb)
#set text(fill: ink)

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
      (-0.75 * zmax, -0.35 * zmax),
      $L_x$,
      (anchor: "north-east", padding: (top: 2pt)),
    ),
  ) {
    line(start, end, stroke: ink + 1pt, mark: (end: "stealth", fill: ink))
    content(end, label, ..label-args)
  }

  // Precession cone of all L sharing m = 1, seen in perspective: L_x and L_y stay undetermined.
  circle(
    (0, level-spacing),
    radius: (radial-component(1), 0.55 * level-spacing),
    stroke: (dash: "dashed", paint: m-color, thickness: 0.8pt),
  )

  // Positively charged nucleus at the origin, around which the electron's L is drawn
  let nucleus(pos) = content(
    pos,
    text(fill: white, baseline: -0.2pt)[$+$],
    frame: "circle",
    fill: nucleus-color,
    stroke: none,
  )
  on-layer(1, nucleus((0, 0)))

  for magnetic-number in range(-angular-number, angular-number + 1) {
    let tip = (radial-component(magnetic-number), magnetic-number * level-spacing)
    line((0, tip.at(1)), tip, stroke: m-color + 0.8pt)
    content(
      (0, tip.at(1)),
      text(fill: m-color)[$#magnetic-number thin ħ$],
      anchor: "east",
      padding: (right: 9pt),
    )
    line(
      (0, 0),
      tip,
      mark: (end: "stealth", fill: l-color, scale: 0.8),
      stroke: l-color + 1.3pt,
    )
  }

  // |L| = sqrt(l(l+1)) ħ is the same for every orientation.
  arc(
    (0, 0),
    start: 90deg,
    stop: -90deg,
    radius: angular-radius,
    stroke: l-color + .8pt,
    anchor: "origin",
  )

  content(
    (1.05 * angular-radius, 0.75 * level-spacing),
    text(fill: l-color)[
      #text(weight: "bold", size: 19pt)[L] angular momentum \
      $|bold(L)| = sqrt(l(l+1)) thin ħ$ \
      $= sqrt(6) thin ħ$ for $l = 2$
    ],
    anchor: "south-west",
  )
  content(
    (-radial-component(1), level-spacing),
    text(fill: m-color)[cone of $bold(L)$ \ with $m = 1$],
    anchor: "east",
    padding: (right: 4pt),
  )
  content(
    (-0.15, angular-number * level-spacing + 0.45),
    text(fill: m-color)[quantized $L_z = m thin ħ$],
    anchor: "south-east",
  )
  let legend-y = -2.7 * level-spacing - 0.55
  nucleus((-1.6, legend-y))
  content((-1.6, legend-y), [nucleus (positive charge)], anchor: "west", padding: (left: 0.3))
})
