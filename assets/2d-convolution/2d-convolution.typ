#import "@preview/cetz:0.5.2": canvas, draw
#import draw: content, line, on-layer, rect

#set page(width: auto, height: auto, margin: 5pt, fill: none)

#canvas({
  let cell-size = 0.6
  let matrix-sep = 1.5
  let highlight = rgb(255, 200, 150) // orange!30
  let kernel-color = rgb("#9ae7e1") // teal!30
  let result-color = rgb(200, 200, 255) // blue!30

  let draw-cell(pos, value, fill: none, name: none) = {
    rect(
      pos,
      (pos.at(0) + cell-size, pos.at(1) + cell-size),
      fill: fill,
      name: name,
      stroke: .5pt,
    )
    if value != none {
      content(
        (pos.at(0) + cell-size / 2, pos.at(1) + cell-size / 2),
        $#value$,
      )
    }
  }

  let draw-matrix(origin, shape, values, highlights: (), name: none) = {
    let (rows, cols) = shape
    for ii in range(rows) {
      for jj in range(cols) {
        let pos = (origin.at(0) + jj * cell-size, origin.at(1) - ii * cell-size)
        let idx = ii * cols + jj
        let cell-name = if name != none { name + "-" + str(ii) + "-" + str(jj) }
        draw-cell(
          pos,
          if idx < values.len() { values.at(idx) },
          fill: if (ii, jj) in highlights { highlight },
          name: cell-name,
        )
      }
    }
  }

  let cell-anchor(matrix-name, ii, jj, anchor) = (
    matrix-name + "-" + str(ii) + "-" + str(jj) + "." + anchor
  )

  let input-origin = (0, 4)
  let input-values = (
    ..(0, 1, 1, 1, 0, 0, 0),
    ..(0, 0, 1, 1, 1, 0, 0),
    ..(0, 0, 0, 1, 1, 1, 0),
    ..(0, 0, 0, 1, 1, 0, 0),
    ..(0, 0, 1, 1, 0, 0, 0),
    ..(0, 1, 1, 0, 0, 0, 0),
    ..(1, 1, 0, 0, 0, 0, 0),
  )
  draw-matrix(
    input-origin,
    (7, 7),
    input-values,
    highlights: (
      (0, 3),
      (0, 4),
      (0, 5),
      (1, 3),
      (1, 4),
      (1, 5),
      (2, 3),
      (2, 4),
      (2, 5),
    ),
    name: "I",
  )
  content(
    (input-origin.at(0) + 7 * cell-size / 2, 0),
    $bold(I)$,
    name: "I-label",
  )

  content((rel: (1, 0), to: "I-3-6"), text(size: 18pt)[$*$], name: "times")

  let kernel-origin = (
    input-origin.at(0) + 7 * cell-size + matrix-sep,
    input-origin.at(1) - 2 * cell-size,
  )
  let kernel-values = (1, 0, 1, 0, 1, 0, 1, 0, 1)
  draw-matrix(
    kernel-origin,
    (3, 3),
    kernel-values,
    name: "K",
  )
  // Fill kernel matrix background
  rect(
    cell-anchor("K", 0, 0, "north-west"),
    cell-anchor("K", 2, 2, "south-east"),
    fill: kernel-color,
    stroke: none,
  )
  // Redraw matrix on top of background
  draw-matrix(kernel-origin, (3, 3), kernel-values, name: "K")
  content(
    (kernel-origin.at(0) + 3 * cell-size / 2, 0),
    $bold(K)$,
    name: "K-label",
  )

  content((rel: (1, 0), to: "K-1-2"), text(size: 18pt)[$=$], name: "equals")

  let result-origin = (
    kernel-origin.at(0) + 3 * cell-size + matrix-sep,
    input-origin.at(1) - cell-size,
  )
  let result-values = (
    ..(1, 4, 3, 4, 1),
    ..(1, 2, 4, 3, 3),
    ..(1, 2, 3, 4, 1),
    ..(1, 3, 3, 1, 1),
    ..(3, 3, 1, 1, 0),
  )
  draw-matrix(result-origin, (5, 5), result-values, name: "R")
  on-layer(-1, rect(
    cell-anchor("R", 0, 3, "north-west"),
    cell-anchor("R", 0, 3, "south-east"),
    fill: result-color,
    stroke: none,
  ))
  content(
    (result-origin.at(0) + 5 * cell-size / 2, 0),
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
        text(size: 6pt)[×#calc.rem(ii + jj, 2)],
        anchor: "south-west",
        padding: 1pt,
      )
    }
  }
})
