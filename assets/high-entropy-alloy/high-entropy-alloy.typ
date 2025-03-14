#import "@preview/cetz:0.3.4": canvas, draw
#import draw: circle, content

#set page(width: auto, height: auto, margin: 5pt)

// Define the atom function with nice 3D shading
#let atom(pos, color, radius: 0.3, element: none, name: none) = {
  // Draw base circle with the main color
  circle(pos, radius: radius, stroke: none, fill: color)

  // Draw gradient overlay for 3D shading effect
  circle(
    pos,
    radius: radius,
    stroke: none,
    fill: gradient.radial(
      color.lighten(75%),
      color,
      color.darken(15%),
      focal-center: (30%, 25%),
      focal-radius: 5%,
      center: (35%, 30%),
    ),
  )

  // Add element label if provided
  if element != none {
    content(
      pos,
      text(fill: white, weight: "bold", size: 10pt)[#element],
      anchor: "center",
      name: name,
    )
  }
}

#canvas({
  // Define colors for the high-entropy alloy (equivalent to the LaTeX colors but toned down)
  let colors = (
    rgb("#cc3333"),
    rgb("#006666"),
    rgb("#3333cc"),
    rgb("#cc8000"),
    rgb("#aaaaee"),
  )

  // Function to get a "random" color from the colors array
  // Since Typst doesn't have a random function, we'll use a deterministic pattern
  // based on position to create a random-looking distribution
  let pseudo-random-color(i, j, k) = {
    let index = calc.rem(i * 3 + j * 5 + k * 7, colors.len())
    colors.at(index)
  }

  // viewing angle parameters
  let x-factor = 0.3
  let y-factor = -0.18
  let z-spacing = 1.1

  // Draw the alloy structure
  // This is equivalent to the nested foreach loops in the LaTeX code
  for i in range(12) {
    for j in range(4) {
      // First set of atoms (equivalent to the first nested loop in LaTeX)
      for k in range(4) {
        atom(
          (-i + x-factor * j, y-factor * j + z-spacing * k),
          pseudo-random-color(i, j, k),
        )
      }

      // Second set of atoms (equivalent to the second nested loop in LaTeX)
      for k in range(3) {
        atom(
          (-i + 0.5 + x-factor * j, y-factor * j + z-spacing * k + 0.65),
          pseudo-random-color(i, j, k + 10),
        )
      }
    }
  }

  // Draw the legend (moved further down)
  let elements = (
    ("Al", rgb("#cc3333")), // red!80 (toned down)
    ("Co", rgb("#3333cc")), // blue!80 (toned down)
    ("Cr", rgb("#006666")), // teal (toned down)
    ("Fe", rgb("#cc8000")), // orange (toned down)
    ("Ni", rgb("#aaaaee")), // blue!20 (toned down)
  )

  // Position the legend further down
  let legend-y-start = 3
  let legend-spacing = 0.8

  for (idx, (element, color)) in elements.enumerate() {
    // Draw atom with element symbol
    atom(
      (2.5, legend-y-start - idx * legend-spacing),
      color,
      element: element,
    )
  }
})
