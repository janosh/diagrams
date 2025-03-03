#import "@preview/cetz:0.3.3": canvas, draw, decorations
#import draw: line, content, circle

#set page(width: auto, height: auto, margin: 8pt)

#canvas({
  let xrange = 6
  let yrange = 4

  // Axes styles
  let arrow-style = (mark: (end: "stealth", fill: black))
  let line-style = (stroke: 0.75pt)
  let zigzag-style = (amplitude: 0.1, segment-length: 0.2)

  // Main axes
  line((-1, 0), (2, 0), ..line-style, name: "x-axis-left")
  decorations.zigzag(
    line((2, 0), (xrange, 0)),
    ..zigzag-style,
    ..line-style,
    name: "x-axis-right",
  )
  content((rel: (-0.3, 0.3), to: "x-axis-right.end"), $"Re"(p_0)$, name: "x-label")

  decorations.zigzag(
    line((2, -3), (xrange, -3), name: "lower-zigzag"),
    ..zigzag-style,
    ..line-style,
  )

  line((0, -yrange - 1), (0, 2), ..arrow-style, ..line-style, name: "y-axis")
  content((rel: (0.8, -0.2), to: "y-axis.end"), $"Im"(p_0)$, name: "y-label")

  // Brace for q_0
  content(
    (2, -1.5),
    [#math.underbrace(box(width: 7.5em))],
    name: "q0-brace",
    angle: -90deg,
  )
  content((rel: (-0.5, 0), to: "q0-brace"), $q_0$, name: "q0-label")

  // Matsubara frequencies
  for n in range(-yrange, 2) {
    if n != 0 {
      circle((0, n), radius: 0.04, fill: black, name: "matsubara-" + str(n))
      content("matsubara-" + str(n), $i omega_#n$, anchor: "west", padding: 0.2)
    }
  }
  circle((0, 0), radius: 0.03, fill: black, name: "origin")
  content((0.2, 0.1), $0$, name: "origin-label")

  // Poles
  let pole(x, y, label) = {
    circle((x, y), radius: 0.06, fill: black, name: "pole-" + str(x) + "-" + str(y))
    content("pole-" + str(x) + "-" + str(y), label, anchor: "south", padding: 0.1)
  }

  // First row of poles
  pole(3, 1, $alpha_2^1$)
  pole(5, 1, $alpha_1^1$)

  // Second row
  pole(3, -1, $alpha_2^1$)
  pole(5, -1, $alpha_1^1$)

  // Third row
  pole(3, -2, $alpha_2^2$)
  pole(5, -2, $alpha_1^2$)

  // Fourth row
  pole(3, -4, $alpha_2^2$)
  pole(5, -4, $alpha_1^2$)

  // Region labels
  let blue = rgb("#00008B") // DarkBlue equivalent
  content((4, 1.5), text(fill: blue)[(I)], name: "region-1")
  content((4, -1.5), text(fill: blue)[(II)], name: "region-2")
  content((4, -4.5), text(fill: blue)[(III)], name: "region-3")
})
