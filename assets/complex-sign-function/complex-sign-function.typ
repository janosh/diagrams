#import "@preview/cetz:0.5.2": canvas, draw, matrix
#import draw: content, group, line, rect, scale, set-transform

#set page(width: 780pt, height: auto, margin: 22pt, fill: white)
#set text(font: "Avenir Next", size: 10.5pt, fill: rgb("#19324f"))
#set par(leading: 0.55em)

// Measure each drawing before fitting it; keep labels and geometry together.
#let fit-figure(body, height: 170pt) = layout(size => {
  let bounds = measure(body)
  let factor = calc.min(size.width / bounds.width, height / bounds.height)
  box(width: 100%, align(center + horizon, std.scale(
    x: factor * 100%,
    y: factor * 100%,
    reflow: true,
    body,
  )))
})
#let card(title, body, caption, height: 170pt) = block(
  width: 100%,
  inset: 12pt,
  radius: 8pt,
  fill: rgb("#f3f6fa"),
  breakable: false,
)[
  #text(size: 13pt, weight: "bold", title)
  #v(8pt)
  #fit-figure(body, height: height)
  #v(7pt)
  #caption
]
#let takeaway(body) = block(
  width: 100%,
  inset: 12pt,
  radius: 6pt,
  fill: rgb("#e9f5f2"),
  breakable: false,
)[#body]

// === 1  Locate the quadrant ===
#let figure-0 = [
  #let size = 8
  #let gap = 0.15 // gap between squares
  #let axes-extend = 0.3

  #canvas({
    draw.set-style(legend: (fill: white))
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
  #set text(size: 8pt)

  #canvas({
    draw.set-style(legend: (fill: white))
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

    // Draw the blue quadrants (s = -1)
    group({
      draw.on-layer(-1, {
        draw.line((-1, 0, -1), (0, 0, -1), (0, 1, -1), (-1, 1, -1), fill: rgb(
          173,
          216,
          230,
        ))
        draw.line((0, -1, -1), (1, -1, -1), (1, 0, -1), (0, 0, -1), fill: rgb(
          173,
          216,
          230,
        ))
      })
    })

    // Draw the orange quadrants (s = 1)
    group({
      draw.line((0, 0, 1), (1, 0, 1), (1, 1, 1), (0, 1, 1), fill: rgb(
        255,
        165,
        0,
      ))
      draw.line((-1, -1, 1), (0, -1, 1), (0, 0, 1), (-1, 0, 1), fill: rgb(
        255,
        165,
        0,
      ))
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

#text(size: 27pt, weight: "bold")[Complex Sign Function]
#v(5pt)
One quadrant-wise sign rule, viewed from above and as a lifted surface. This is the function used here in contour bookkeeping, not the complex phase z/|z|.
#v(14pt)
#grid(
  columns: (1fr, 1fr),
  gutter: 12pt,
  card(
    [1  Locate the quadrant],
    figure-0,
    [Equal signs of the real and imaginary parts give $+1$; opposite signs give $-1$. The sign flips on crossing either axis.],
    height: 245pt,
  ),
  card(
    [2  Lift the value to a height],
    figure-1,
    [The same two values become horizontal sheets. Height encodes the sign; the surface is discontinuous at the axes.],
    height: 245pt,
  ),
)
#v(12pt)
#takeaway[$s(z) = op("sign")(op("Re")(z) op("Im")(z))$. These panels show values *away from the axes*. At an axis, a contour calculation must specify the limiting side or its convention.]
