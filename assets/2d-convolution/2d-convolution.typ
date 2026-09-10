#import "@preview/cetz:0.5.2": canvas, draw
#import draw: content, line, on-layer, rect

#set page(width: auto, height: auto, margin: 5pt, fill: none)
#set text(size: 12pt)

#canvas({
  let cell-size = 1.0
  let matrix-sep = 1.5
  let highlight = rgb(255, 200, 150) // orange!30
  let kernel-color = rgb("#9ae7e1") // teal!30
  let result-color = rgb(200, 200, 255) // blue!30

  let draw-matrix(origin, values, name, highlighted: false) = {
    for (row_idx, row) in values.enumerate() {
      for (col_idx, value) in row.enumerate() {
        let (coord_x, coord_y) = (
          origin.at(0) + col_idx * cell-size,
          origin.at(1) - row_idx * cell-size,
        )
        rect(
          (coord_x, coord_y),
          (coord_x + cell-size, coord_y + cell-size),
          fill: if highlighted and row_idx < 3 and 3 <= col_idx and col_idx <= 5 { highlight },
          name: name + "-" + str(row_idx) + "-" + str(col_idx),
          stroke: .5pt,
        )
        content((coord_x + cell-size / 2, coord_y + cell-size / 2), $#value$)
      }
    }
  }

  let cell-anchor(matrix-name, ii, jj, anchor) = (
    matrix-name + "-" + str(ii) + "-" + str(jj) + "." + anchor
  )

  let input-origin = (0, 4)
  let matrix-label-y = input-origin.at(1) - 6 * cell-size - 0.55
  let input-values = (
    (0, 1, 1, 1, 0, 0, 0),
    (0, 0, 1, 1, 1, 0, 0),
    (0, 0, 0, 1, 1, 1, 0),
    (0, 0, 0, 1, 1, 0, 0),
    (0, 0, 1, 1, 0, 0, 0),
    (0, 1, 1, 0, 0, 0, 0),
    (1, 1, 0, 0, 0, 0, 0),
  )
  draw-matrix(input-origin, input-values, "I", highlighted: true)
  content(
    (input-origin.at(0) + 7 * cell-size / 2, matrix-label-y),
    $bold(I)$,
    name: "I-label",
  )

  content((rel: (1, 0), to: "I-3-6"), text(size: 18pt)[$*$], name: "times")

  let kernel-origin = (
    input-origin.at(0) + 7 * cell-size + matrix-sep,
    input-origin.at(1) - 2 * cell-size,
  )
  let kernel-values = ((1, 0, 1), (0, 1, 0), (1, 0, 1))
  draw-matrix(kernel-origin, kernel-values, "K")
  // Fill kernel matrix background
  rect(
    cell-anchor("K", 0, 0, "north-west"),
    cell-anchor("K", 2, 2, "south-east"),
    fill: kernel-color,
    stroke: none,
  )
  // Redraw matrix on top of background
  draw-matrix(kernel-origin, kernel-values, "K")
  content(
    (kernel-origin.at(0) + 3 * cell-size / 2, matrix-label-y),
    $bold(K)$,
    name: "K-label",
  )

  content((rel: (1, 0), to: "K-1-2"), text(size: 18pt)[$=$], name: "equals")

  let result-origin = (
    kernel-origin.at(0) + 3 * cell-size + matrix-sep,
    input-origin.at(1) - cell-size,
  )
  let result-values = (
    (1, 4, 3, 4, 1),
    (1, 2, 4, 3, 3),
    (1, 2, 3, 4, 1),
    (1, 3, 3, 1, 1),
    (3, 3, 1, 1, 0),
  )
  draw-matrix(result-origin, result-values, "R")
  on-layer(-1, rect(
    cell-anchor("R", 0, 3, "north-west"),
    cell-anchor("R", 0, 3, "south-east"),
    fill: result-color,
    stroke: none,
  ))
  content(
    (result-origin.at(0) + 5 * cell-size / 2, matrix-label-y),
    $bold(I * K)$,
    name: "R-label",
  )

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

  for ii in range(3) {
    for jj in (3, 4, 5) {
      content(
        cell-anchor("I", ii, jj, "south-west"),
        text(size: 12pt)[×#calc.rem(ii + jj, 2)],
        anchor: "south-west",
        padding: 1pt,
      )
    }
  }
})
