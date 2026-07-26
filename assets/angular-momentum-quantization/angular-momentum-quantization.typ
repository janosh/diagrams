#import "@preview/cetz:0.5.2": canvas, draw
#import draw: arc, circle, content, line, on-layer

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#let green-color = rgb("#77d477") // Adjust green to match target
#let blue-color = rgb("#1a1aff") // Lighter blue to match target
#let red-color = rgb("#ff0000")

#canvas({
  let zmax = 2.5
  let l = 2
  let h = 0.85 // Spacing between quantized levels
  let R = calc.sqrt(l * (l + 1)) * h // total angular momentum radius

  let arrow-style = (mark: (end: "stealth", fill: black))
  let vector-style = (
    mark: (end: "stealth", fill: green-color, scale: 0.8),
    stroke: green-color + 1.1pt,
  )

  // Draw axes - z-axis first (to position things relative to it)
  line(
    (0, -2.7 * h),
    (0, zmax),
    stroke: black + 1pt,
    ..arrow-style,
    name: "z-axis",
  )
  line((0, 0), (zmax, 0), stroke: black + 1pt, ..arrow-style, name: "y-axis")
  line(
    (0, 0),
    (-0.62 * zmax, -0.55 * zmax),
    stroke: black + 1pt,
    ..arrow-style,
    name: "x-axis",
  )

  content("z-axis.end", $L_z$, anchor: "west", padding: (left: 3pt), size: 13pt)
  content(
    "y-axis.end",
    $L_y$,
    anchor: "south",
    padding: (bottom: 3pt),
    size: 13pt,
  )
  content(
    "x-axis.end",
    $L_x$,
    anchor: "south",
    padding: (bottom: 6pt, left: -9pt),
    size: 13pt,
  )

  // Draw blue dashed ellipse to the left of the z-axis (matching target)
  // This needs to be fully to the left of the z-axis
  let ellipse-center-x = -R
  let ellipse-center-y = h // Position at m=1 level
  let ellipse-height = 0.55 * h

  arc(
    (ellipse-center-x, ellipse-center-y),
    radius: (R * 0.955, ellipse-height),
    start: 0deg,
    stop: 360deg,
    stroke: (dash: "dashed", paint: blue-color, thickness: 0.6pt),
    name: "ellipse-m1",
    anchor: "arc-center",
  )

  on-layer(1, content(
    (0, 0),
    text(baseline: -0.2pt)[$+$],
    size: 13pt,
    frame: "circle",
    fill: red-color,
    stroke: none,
    name: "origin",
  ))

  for m in range(-l, l + 1) {
    // Calculate coordinates
    let y = m * h
    let rx = calc.sqrt(R * R - (m * h) * (m * h))

    // Draw blue horizontal line from z-axis to endpoint
    line((0, y), (rx, y), stroke: blue-color + 0.6pt, name: "level-" + str(m))

    content(
      (0, y),
      $#m thin ħ$,
      anchor: "east",
      padding: (right: 6pt),
      size: 15pt,
    )

    line((0, 0), (rx, y), ..vector-style, name: "vector-" + str(m))
  }

  // Draw the green half-circle (after vectors to ensure it aligns)
  arc(
    (0, 0),
    start: 90deg,
    stop: -90deg,
    radius: R,
    stroke: green-color + .8pt,
    name: "L-circle",
    anchor: "origin",
  )

  let L_position_x = 0.95 * R
  let L_position_y = 1.45 * h // Slightly above the m=1 level

  content(
    (L_position_x, L_position_y),
    text(fill: green-color, weight: "bold", size: 19pt)[L],
    anchor: "west",
  )
})
