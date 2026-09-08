#import "@preview/cetz:0.5.2": canvas, draw
#import draw: arc, circle, content, line, on-layer

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#let green-color = rgb("#77d477") // Adjust green to match target
#let blue-color = rgb("#1a1aff") // Lighter blue to match target
#let red-color = rgb("#ff0000")

#canvas({
  let zmax = 2.5
  let angular-number = 2
  let level-spacing = 0.85
  let angular-radius = calc.sqrt(angular-number * (angular-number + 1)) * level-spacing

  let arrow-style = (mark: (end: "stealth", fill: black))
  let vector-style = (
    mark: (end: "stealth", fill: green-color, scale: 0.8),
    stroke: green-color + 1.1pt,
  )

  let axes = (
    (
      start: (0, -2.7 * level-spacing),
      end: (0, zmax),
      name: "z-axis",
      label: $L_z$,
      label-args: (anchor: "west", padding: (left: 3pt), size: 13pt),
    ),
    (
      start: (0, 0),
      end: (zmax, 0),
      name: "y-axis",
      label: $L_y$,
      label-args: (anchor: "south", padding: (bottom: 3pt), size: 13pt),
    ),
    (
      start: (0, 0),
      end: (-0.62 * zmax, -0.55 * zmax),
      name: "x-axis",
      label: $L_x$,
      label-args: (anchor: "south", padding: (bottom: 6pt, left: -9pt), size: 13pt),
    ),
  )
  for axis in axes {
    line(axis.start, axis.end, stroke: black + 1pt, ..arrow-style, name: axis.name)
  }
  for axis in axes {
    content(axis.name + ".end", axis.label, ..axis.label-args)
  }

  // Draw blue dashed ellipse to the left of the z-axis (matching target)
  // This needs to be fully to the left of the z-axis
  let ellipse-center-x = -angular-radius
  let ellipse-center-y = level-spacing // Position at m=1 level
  let ellipse-height = 0.55 * level-spacing

  arc(
    (ellipse-center-x, ellipse-center-y),
    radius: (angular-radius * 0.955, ellipse-height),
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

  for magnetic-number in range(-angular-number, angular-number + 1) {
    // Calculate coordinates
    let y-pos = magnetic-number * level-spacing
    let radial-component = calc.sqrt(
      angular-radius * angular-radius - calc.pow(magnetic-number * level-spacing, 2),
    )

    // Draw blue horizontal line from z-axis to endpoint
    line(
      (0, y-pos),
      (radial-component, y-pos),
      stroke: blue-color + 0.6pt,
      name: "level-" + str(magnetic-number),
    )

    content(
      (0, y-pos),
      $#magnetic-number thin ħ$,
      anchor: "east",
      padding: (right: 6pt),
      size: 15pt,
    )

    line(
      (0, 0),
      (radial-component, y-pos),
      ..vector-style,
      name: "vector-" + str(magnetic-number),
    )
  }

  // Draw the green half-circle (after vectors to ensure it aligns)
  arc(
    (0, 0),
    start: 90deg,
    stop: -90deg,
    radius: angular-radius,
    stroke: green-color + .8pt,
    name: "L-circle",
    anchor: "origin",
  )

  let L_position_x = 0.95 * angular-radius
  let L_position_y = 1.45 * level-spacing // Slightly above the m=1 level

  content(
    (L_position_x, L_position_y),
    text(fill: green-color, weight: "bold", size: 19pt)[L],
    anchor: "west",
  )
})
