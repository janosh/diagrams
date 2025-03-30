#import "@preview/fractusist:0.3.0": lsystem, lsystem-use

#set page(width: auto, height: auto, margin: 0pt)
#set text(fill: white, size: 6pt)

// Sierpiński triangle with Au(100) surface background
#box({
  let triangle_size = 128pt
  let margin = 12pt
  let canvas_width = triangle_size + 2 * margin
  let canvas_height = triangle_size * calc.pow(3, 0.5) / 2 + 2 * margin

  rect(
    width: canvas_width,
    height: canvas_height,
    fill: rgb(50, 50, 50),
    {
      // Gold atoms in hexagonal close-packed arrangement
      let horizontal_spacing = 2.5pt
      let vertical_spacing = 2.2pt
      let dot_radius = 1pt
      let rows = int(canvas_height / vertical_spacing)
      let cols = int(canvas_width / horizontal_spacing)

      for y in range(-3, rows + 3) {
        let offset = if calc.odd(y) { horizontal_spacing / 2 } else { 0pt }

        for x in range(-3, cols + 3) {
          place(
            dx: x * horizontal_spacing + offset,
            dy: y * vertical_spacing,
            circle(
              radius: dot_radius,
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
      let scale_bar_width = horizontal_spacing * 8
      let (scale_bar_height, scale_bar_margin) = (2pt, 12pt)

      place(
        dx: canvas_width - scale_bar_width - scale_bar_margin,
        dy: scale_bar_margin / 5,
        rect(width: scale_bar_width, height: scale_bar_height, fill: white),
      )

      place(
        dx: canvas_width - scale_bar_width - scale_bar_margin + scale_bar_width / 2 - 7pt,
        dy: scale_bar_margin / 5 + scale_bar_height + 2pt,
        [10 nm],
      )

      // Legend
      let color_square_size = 4pt

      place(
        block(
          inset: (x: 3pt, y: 2pt),
          radius: 2pt,
          fill: rgb(30, 30, 30),
          {
            grid(
              columns: (color_square_size, auto),
              column-gutter: 2.5pt,
              row-gutter: 3pt,
              rect(width: color_square_size, height: color_square_size, fill: rgb(200, 50, 50), radius: 1pt), [Au(100)],
              rect(width: color_square_size, height: color_square_size, fill: rgb(255, 230, 100), radius: 1pt),
              [Fe/C3PC],

              rect(width: color_square_size, height: color_square_size, fill: rgb(200, 140, 0), radius: 1pt), [BPyB],
            )
          },
        ),
      )
    },
  )
})
