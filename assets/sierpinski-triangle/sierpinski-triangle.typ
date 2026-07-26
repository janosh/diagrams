#import "@preview/fractusist:0.3.0": lsystem, lsystem-use

#set page(width: auto, height: auto, margin: 0pt, fill: none)
#set text(fill: white, size: 6pt)

// Sierpiński triangle with Au(100) surface background
#box({
  let triangle-size = 128pt
  let margin = 12pt
  let canvas-width = triangle-size + 2 * margin
  let canvas-height = triangle-size * calc.pow(3, 0.5) / 2 + 2 * margin

  rect(
    width: canvas-width,
    height: canvas-height,
    fill: rgb(50, 50, 50),
    {
      // Gold atoms in hexagonal close-packed arrangement
      let horizontal-spacing = 2.5pt
      let vertical-spacing = 2.2pt
      let dot-radius = 1pt
      let rows = int(canvas-height / vertical-spacing)
      let cols = int(canvas-width / horizontal-spacing)

      for y in range(-3, rows + 3) {
        let offset = if calc.odd(y) { horizontal-spacing / 2 } else { 0pt }

        for x in range(-3, cols + 3) {
          place(
            dx: x * horizontal-spacing + offset,
            dy: y * vertical-spacing,
            circle(
              radius: dot-radius,
              fill: rgb(200, 50, 50),
              stroke: none,
            ),
          )
        }
      }

      // Sierpiński triangle
      place(
        dx: margin / 2,
        dy: margin / 2,
        {
          lsystem(
            ..lsystem-use("Sierpinski Triangle"),
            order: 5,
            step-size: 4,
            start-angle: 1,
            fill: rgb(255, 230, 100),
            stroke: 0.5pt + rgb(200, 140, 0),
          )
        },
      )

      // 10nm scale bar
      let scale-bar-width = horizontal-spacing * 8
      let (scale-bar-height, scale-bar-margin) = (2pt, 12pt)

      place(
        dx: canvas-width - scale-bar-width - scale-bar-margin,
        dy: scale-bar-margin / 5,
        rect(width: scale-bar-width, height: scale-bar-height, fill: white),
      )

      place(
        dx: canvas-width - scale-bar-width - scale-bar-margin + scale-bar-width / 2 - 7pt,
        dy: scale-bar-margin / 5 + scale-bar-height + 2pt,
        [10 nm],
      )

      // Legend
      let color-square-size = 4pt

      place(
        block(
          inset: (x: 3pt, y: 2pt),
          radius: 2pt,
          fill: rgb(30, 30, 30),
          {
            grid(
              columns: (color-square-size, auto),
              column-gutter: 2.5pt,
              row-gutter: 3pt,
              rect(
                width: color-square-size,
                height: color-square-size,
                fill: rgb(200, 50, 50),
                radius: 1pt,
              ),
              [Au(100)],

              rect(
                width: color-square-size,
                height: color-square-size,
                fill: rgb(255, 230, 100),
                radius: 1pt,
              ),
              [Fe/C3PC],

              rect(
                width: color-square-size,
                height: color-square-size,
                fill: rgb(200, 140, 0),
                radius: 1pt,
              ),
              [BPyB],
            )
          },
        ),
      )
    },
  )
})
