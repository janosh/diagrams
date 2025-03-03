#import "@preview/cetz:0.3.3": canvas, draw
#import draw: line, content, circle, on-layer

#set page(width: auto, height: auto, margin: 8pt)

#canvas({
  // Define styles and constants
  let grid-size = 2 // number of points in each direction
  let spacing = 0.6 // spacing between points
  let dot-radius = 0.1

  // Colors in order of appearance
  let colors = (
    rgb("#4040d9"), // blue
    rgb("#90EE90"), // light green
    rgb("#006400"), // dark green
    rgb("#9ACD32"), // yellow green
    rgb("#FFA500"), // orange
    rgb("#FF0000"), // red
    rgb("#000000"), // black
    rgb("#800080"), // purple
  )

  for ii in range(0, 5) {
    for jj in range(0, 8) {
      let x = 2 * ii * spacing
      let y = 2 * jj * spacing
      // Every 2 right and 1 up is same color
      // Use modulo to cycle through colors
      let color-idx = calc.rem(ii - 2 * jj, colors.len())
      if color-idx < 0 { color-idx += colors.len() }
      circle(
        (x, y),
        radius: dot-radius * 1.2,
        fill: colors.at(color-idx),
        stroke: .5pt,
        name: str(ii) + "," + str(jj),
      )
    }
  }

  // Add arrows to show basis vectors
  let arrow-style = (
    mark: (end: "stealth", fill: black, scale: .5),
    stroke: 1pt,
  )

  on-layer(
    -1,
    {
      line("0,0", "2,1", ..arrow-style)
      line("0,0", "0,4", ..arrow-style)
      line("2,1", "2,5")
      line("0,4", "2,5")
    },
  )
})
