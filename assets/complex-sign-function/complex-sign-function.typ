#import "@preview/cetz:0.5.2": canvas, draw, matrix
#import draw: content, group, line, rect, scale, set-transform
#import "../_shared/layout.typ": card-grid, label-size, paragraph-size, takeaway

#set page(width: 780pt, height: auto, margin: 22pt, fill: none)
#set text(font: "Avenir Next", size: paragraph-size, fill: rgb("#19324f"))
#set par(leading: 0.55em)

// === 1  Locate the quadrant ===
#let figure-0 = [
  #let size = 8
  #let gap = 0.15 // gap between squares
  #let axes-extend = 0.3

  #canvas(length: 1.2cm, {
    draw.line(
      (-size / 2, 0),
      (size / 2 + axes-extend, 0),
      mark: (end: "stealth", fill: black),
      name: "x-axis",
    )
    draw.line(
      (0, -size / 2),
      (0, size / 2 + axes-extend),
      mark: (end: "stealth", fill: black),
      name: "y-axis",
    )

    draw.content((rel: (.4, .2), to: "x-axis.end"), $"Re"(p_0)$)
    draw.content((rel: (.7, 0), to: "y-axis.end"), $"Im"(p_0)$)

    for (s1, s2, color) in (
      (1, 1, rgb("#ffa500")),
      (-1, 1, rgb("#add8e6")),
      (1, -1, rgb("#add8e6")),
      (-1, -1, rgb("#ffa500")),
    ) {
      draw.rect(
        (gap * s1, gap * s2),
        (s1 * size / 2, s2 * size / 2),
        fill: color.lighten(80%),
        stroke: color.darken(40%),
      )
      draw.content((size / 4 * s1, size / 4 * s2), $s(p_0) = #calc.quo(s1, s2)$)
    }
  })
]

// === 2  Lift the value to a height ===
#let figure-1 = [
  #set text(size: label-size)

  #canvas(length: 3cm, {
    draw.set-style(line: (stroke: none))
    // Set up the transformation matrix for 3D perspective
    set-transform(matrix.transform-rotate-dir((1, 1, -2), (0, 2, .3)))
    scale(x: 1.5, z: -1)

    let arrow-style = (mark: (end: "stealth", fill: black, scale: 0.5))

    // Add vertical z-lines at corners and origin
    for (x, y) in ((-1, -1), (1, -1), (-1, 1), (1, 1)) {
      draw.line((x, y, -1.2), (x, y, 1.2), stroke: gray + .3pt)
    }
    draw.line((0, 0, -1.2), (0, 0, 1.2), stroke: gray + .3pt, ..arrow-style)

    // Draw the zero plane (gray, semi-transparent)
    group({
      draw.rect(
        (-1, -1, 0),
        (1, 1, 0),
        fill: rgb(128, 128, 128, 20),
        stroke: none,
      )
    })

    let face(x, y, height, color) = draw.line(
      (x, y, height),
      (x + 1, y, height),
      (x + 1, y + 1, height),
      (x, y + 1, height),
      fill: color,
    )
    // Draw the blue quadrants (s = -1) behind the zero plane.
    group({
      draw.on-layer(-1, {
        face(-1, 0, -1, rgb(173, 216, 230))
        face(0, -1, -1, rgb(173, 216, 230))
      })
    })
    // Draw the orange quadrants (s = 1).
    group({
      face(0, 0, 1, rgb(255, 165, 0))
      face(-1, -1, 1, rgb(255, 165, 0))
    })

    for x in range(-1, 2) {
      let style = if x == 0 { arrow-style } else { () }
      draw.line((x, -1, 0), (x, 1, 0), stroke: gray + .3pt, ..style)
    }
    for y in range(-1, 2) {
      let style = if y == 0 { arrow-style } else { () }
      draw.line((-1, y, 0), (1, y, 0), stroke: gray + .3pt, ..style)
    }

    content((1.45, .1, 0), [$"Re"(p_0)$])
    content((0, 1.6, 0), [$"Im"(p_0)$])
    content((0, 0, 1.5), [$s(p_0)$])
    content((.5, .5, 1), [$+1$])
    content((-.5, .5, -1), [$-1$])
  })
]

One quadrant-wise sign rule, viewed from above and as a lifted surface. This is the function used here in contour bookkeeping, not the complex phase z/|z|.
#v(14pt)
#card-grid(
  (
    [1  Locate the quadrant],
    figure-0,
    [Equal signs of the real and imaginary parts give $+1$; opposite signs give $-1$. The sign flips on crossing either axis.],
  ),
  (
    [2  Lift the value to a height],
    figure-1,
    [The same two values become horizontal sheets. Height encodes the sign; the surface is discontinuous at the axes.],
  ),
)
#v(12pt)
#takeaway[$s(z) = op("sign")(op("Re")(z) op("Im")(z))$. These panels show values *away from the axes*. At an axis, a contour calculation must specify the limiting side or its convention.]
