#import "@preview/cetz:0.3.4": canvas, draw
#import draw: rect, content

#set page(width: auto, height: auto, margin: 3pt)

#canvas({
  let cell-size = .7 // Size of each heatmap cell
  let data = (
    (74, 25, 39, 20, 3, 3, 3, 3, 3),
    (25, 53, 31, 17, 7, 7, 2, 3, 2),
    (39, 31, 37, 24, 3, 3, 3, 3, 3),
    (20, 17, 24, 37, 2, 2, 6, 5, 5),
    (3, 7, 3, 2, 12, 1, 0, 0, 0),
    (3, 7, 3, 2, 1, 36, 0, 0, 0),
    (3, 2, 3, 6, 0, 0, 45, 1, 1),
    (3, 3, 3, 5, 0, 0, 1, 23, 1),
    (3, 2, 3, 5, 0, 0, 1, 1, 78),
  )
  let row-labels = ("a", "b", "c", "d", "e", "f", "g", "h", "i")

  // Draw column labels (1-9)
  for col in range(9) {
    content(
      ((col + 1) * cell-size, 0),
      str(col + 1),
      name: "col-label-" + str(col + 1),
    )
  }

  // Draw row labels (a-i)
  for row in range(9) {
    content(
      (0, -(row + 1) * cell-size),
      row-labels.at(row),
      name: "row-label-" + row-labels.at(row),
    )
  }

  // Draw heatmap cells
  for row in range(9) {
    for col in range(9) {
      let value = data.at(row).at(col)
      rect(
        ((col + 1) * cell-size - cell-size / 2, -(row + 1) * cell-size - cell-size / 2),
        ((col + 1) * cell-size + cell-size / 2, -(row + 1) * cell-size + cell-size / 2),
        fill: rgb(
          // Purple (90%, 70%, 90%) to Yellow (90%, 90%, 70%)
          90%, // Red stays constant at 90% for pastel effect
          50% + value / 78 * 20%, // Green increases with value
          50% - value / 78 * 20%, // Blue decreases with value
        ),
        name: "cell-" + str(row) + "-" + str(col),
      )
      content(
        ((col + 1) * cell-size, -(row + 1) * cell-size),
        text(fill: if value < 40 { white } else { black }, str(value)),
        name: "value-" + str(row) + "-" + str(col),
      )
    }
  }
})
