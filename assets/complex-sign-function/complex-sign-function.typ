#import "@preview/cetz:0.4.0": canvas, draw, vector, matrix
#import draw: set-transform, scale, content, line, rect, group

#set page(width: auto, height: auto, margin: 8pt)
#set text(size: 8pt)

#canvas({
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
    draw.rect((-1, -1, 0), (1, 1, 0), fill: rgb(128, 128, 128, 20), stroke: none)
  })

  // Draw the blue quadrants (s = -1)
  group({
    draw.on-layer(
      -1,
      {
        draw.line(
          (-1, 0, -1),
          (0, 0, -1),
          (0, 1, -1),
          (-1, 1, -1),
          fill: rgb(173, 216, 230),
        )
        draw.line(
          (0, -1, -1),
          (1, -1, -1),
          (1, 0, -1),
          (0, 0, -1),
          fill: rgb(173, 216, 230),
        )
      },
    )
  })

  // Draw the orange quadrants (s = 1)
  group({
    draw.line(
      (0, 0, 1),
      (1, 0, 1),
      (1, 1, 1),
      (0, 1, 1),
      fill: rgb(255, 165, 0),
    )
    draw.line(
      (-1, -1, 1),
      (0, -1, 1),
      (0, 0, 1),
      (-1, 0, 1),
      fill: rgb(255, 165, 0),
    )
  })

  // Draw grid lines
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
})
