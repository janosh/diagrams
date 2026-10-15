#import "@preview/cetz:0.5.2": canvas, draw
#import draw: content, line, on-layer, rect

#set page(width: auto, height: auto, margin: 5pt, fill: none)
#set text(size: 12pt)

#canvas({
  let matrix-sep = 1.5

  // Unit cells named "<name>-<row>-<col>"; the input's top-right 3x3 patch is highlighted.
  let draw-matrix(origin, values, name, highlighted: false) = {
    for (row_idx, row) in values.enumerate() {
      for (col_idx, value) in row.enumerate() {
        let (coord_x, coord_y) = (origin.at(0) + col_idx, origin.at(1) - row_idx)
        rect(
          (coord_x, coord_y),
          (coord_x + 1, coord_y + 1),
          fill: if highlighted and row_idx < 3 and 3 <= col_idx and col_idx <= 5 {
            rgb(255, 200, 150)
          },
          name: name + "-" + str(row_idx) + "-" + str(col_idx),
          stroke: .5pt,
        )
        content((coord_x + 1 / 2, coord_y + 1 / 2), $#value$)
      }
    }
  }

  let cell-anchor(matrix-name, ii, jj, anchor) = (
    matrix-name + "-" + str(ii) + "-" + str(jj) + "." + anchor
  )

  let input-origin = (0, 4)
  let matrix-label-y = input-origin.at(1) - 6 - 0.55
  draw-matrix(
    input-origin,
    (
      (0, 1, 1, 1, 0, 0, 0),
      (0, 0, 1, 1, 1, 0, 0),
      (0, 0, 0, 1, 1, 1, 0),
      (0, 0, 0, 1, 1, 0, 0),
      (0, 0, 1, 1, 0, 0, 0),
      (0, 1, 1, 0, 0, 0, 0),
      (1, 1, 0, 0, 0, 0, 0),
    ),
    "I",
    highlighted: true,
  )
  content((input-origin.at(0) + 7 / 2, matrix-label-y), $bold(I)$)
  content((rel: (1, 0), to: "I-3-6"), text(size: 18pt)[$*$])

  let kernel-origin = (input-origin.at(0) + 7 + matrix-sep, input-origin.at(1) - 2)
  draw-matrix(kernel-origin, ((1, 0, 1), (0, 1, 0), (1, 0, 1)), "K")
  on-layer(-1, rect(
    cell-anchor("K", 0, 0, "north-west"),
    cell-anchor("K", 2, 2, "south-east"),
    fill: rgb("#9ae7e1"),
    stroke: none,
  ))
  content((kernel-origin.at(0) + 3 / 2, matrix-label-y), $bold(K)$)
  content((rel: (1, 0), to: "K-1-2"), text(size: 18pt)[$=$])

  let result-origin = (kernel-origin.at(0) + 3 + matrix-sep, input-origin.at(1) - 1)
  draw-matrix(
    result-origin,
    ((1, 4, 3, 4, 1), (1, 2, 4, 3, 3), (1, 2, 3, 4, 1), (1, 3, 3, 1, 1), (3, 3, 1, 1, 0)),
    "R",
  )
  on-layer(-1, rect(
    cell-anchor("R", 0, 3, "north-west"),
    cell-anchor("R", 0, 3, "south-east"),
    fill: rgb(200, 200, 255),
    stroke: none,
  ))
  content((result-origin.at(0) + 5 / 2, matrix-label-y), $bold(I * K)$)

  // dashed guides tie the input patch to the kernel, then the kernel to the cell it produces
  for (paint, ends) in (
    (
      rgb(150, 220, 200),
      (
        (("I", 0, 5, "north-east"), ("K", 0, 0, "north-west")),
        (("I", 2, 5, "south-east"), ("K", 2, 0, "south-west")),
      ),
    ),
    (
      rgb(150, 150, 220),
      (
        (("K", 0, 2, "north-east"), ("R", 0, 3, "north-west")),
        (("K", 2, 2, "south-east"), ("R", 0, 3, "south-west")),
      ),
    ),
  ) {
    for (from, to) in ends {
      line(cell-anchor(..from), cell-anchor(..to), stroke: (dash: "dashed", paint: paint))
    }
  }

  // Kernel weight multiplying each highlighted input cell.
  for ii in range(3) {
    for jj in (3, 4, 5) {
      content(
        cell-anchor("I", ii, jj, "south-west"),
        [×#calc.rem(ii + jj, 2)],
        anchor: "south-west",
        padding: 1pt,
      )
    }
  }
})
