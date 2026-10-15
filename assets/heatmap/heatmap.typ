#import "@preview/cetz:0.5.2": canvas, draw
#import draw: content, rect

#set page(width: auto, height: auto, margin: 3pt, fill: none)
#set text(size: 12pt)

#canvas({
  let cell-size = .7
  let cell-data = (
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
  for col in range(9) {
    content(((col + 1) * cell-size, 0), str(col + 1))
  }
  for (row, label) in "abcdefghi".clusters().enumerate() {
    content((0, -(row + 1) * cell-size), label)
  }

  for (row, values) in cell-data.enumerate() {
    for (col, value) in values.enumerate() {
      let (x, y) = ((col + 1) * cell-size, -(row + 1) * cell-size)
      rect(
        (x - cell-size / 2, y - cell-size / 2),
        (x + cell-size / 2, y + cell-size / 2),
        // Salmon (90%, 50%, 50%) for 0 to gold (90%, 70%, 30%) for the maximum 78.
        fill: rgb(90%, 50% + value / 78 * 20%, 50% - value / 78 * 20%),
      )
      content((x, y), text(fill: if value < 40 { white } else { black }, str(value)))
    }
  }
})
