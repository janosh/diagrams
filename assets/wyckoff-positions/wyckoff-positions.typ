#import "@preview/cetz:0.4.1": canvas, draw
#import draw: circle, line, rect, rotate

#set page(width: auto, height: auto, margin: 8pt)

#canvas({
  let size = 5 // Base radius/size
  let small-square = 0.3 // Size of small squares
  let circle-radius = 0.3 // Size of circles

  // Define colors
  let colors = (
    teal: rgb("#19d4d4"),
    yellow: rgb("#f3f380"),
    red: rgb("#f36969"),
  )

  // Fill colored regions
  // Teal triangle
  line(
    (0, 0),
    (size, 0),
    (size, -size),
    fill: colors.teal,
    name: "teal-triangle",
    close: true,
    stroke: none,
  )

  // Yellow region
  line(
    (size - .5, -size),
    (0, -.5),
    (0, 0),
    (size, -size),
    fill: colors.yellow,
    name: "yellow-region",
    close: true,
    stroke: none,
  )

  // Red rectangle
  rect((0, 0), (size, 0.35), fill: colors.red, name: "red-rect", stroke: none)

  // Main square outline
  rect((-size, -size), (size, size), name: "main-square")

  // Dashed lines
  let dash-style = (stroke: (dash: "dashed"))
  line((-size, -size), (size, size), ..dash-style, name: "diag1")
  line((size, -size), (-size, size), ..dash-style, name: "diag2")
  line((-size, 0), (size, 0), ..dash-style, name: "horiz")
  line((0, -size), (0, size), ..dash-style, name: "vert")

  // Corner squares (yellow)
  for a in (-0.8 * size, 0.8 * size) {
    for b in (-0.8 * size, 0.8 * size) {
      rect(
        (a - small-square, b - small-square),
        (a + small-square, b + small-square),
        fill: colors.yellow,
        name: "corner-square-" + str(a).replace(".", "p") + "-" + str(b).replace(".", "p"),
      )
    }
  }

  // Red circles on axes
  for a in (-0.7 * size, 0.7 * size) {
    circle((a, 0), radius: circle-radius, fill: colors.red, name: "horiz-circle-" + str(a).replace(".", "p"))
    circle((0, a), radius: circle-radius, fill: colors.red, name: "vert-circle-" + str(a).replace(".", "p"))
  }

  // Rotated teal squares
  rotate(45deg)
  for i in range(8) {
    let angle = i * 360deg / 8 + 22.5deg
    let x = 2 * calc.cos(angle)
    let y = 2 * calc.sin(angle)
    rect(
      (x - small-square, y - small-square),
      (x + small-square, y + small-square),
      fill: colors.teal,
      name: "rot-square-" + str(i).replace(".", "p"),
    )
  }
})
