#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, line, rect

#set page(width: auto, height: auto, margin: 5pt, fill: none)
#set text(size: 12pt, weight: "bold")

#canvas({
  let (data-color, data-color-alt, test-data-color) = (
    rgb("#00bfbf"),
    rgb("#00a8a8"),
    rgb("#80dfdf"),
  )
  let (target-color, target-color-alt, test-target-color) = (
    rgb("#ffcc00"),
    rgb("#e6b800"),
    rgb("#ffe680"),
  )
  let (data-header, target-header) = (rgb("#008080"), rgb("#997300"))
  let arrow-style = (stroke: black + 2pt, mark: (end: "stealth", size: 10pt))
  let matrix-stroke = 0.5pt + rgb("#0099cc")

  let (feature-width, target-width, row-height) = (5, 1, 1.0)
  let dataset-rows = 7
  let (full-data-x, features-x, train-x, model-x) = (-15, -6, 6, 18)
  let target-x = features-x + feature-width + 0.5
  let (top-tables-y, test-y) = (-3.5, -8.0)

  // rows selected for the test set (0-indexed), simulating random sampling
  let test-indices = (1, 4, 6)
  let feature-headers = ("X1", "X2", "X3", "X4", "X5")

  // color a data row: test rows are highlighted, the rest alternate two shades
  let striped(base, alt, highlight) = idx => {
    if test-indices.contains(idx) { highlight } else if calc.rem(idx, 2) == 0 { base } else { alt }
  }

  // tables are vertically centered on y; the header row adds one row-height
  let tables = (
    (
      x: full-data-x,
      y: top-tables-y,
      width: feature-width + target-width,
      label: "Full Dataset",
      headers: feature-headers + ("Y",),
      fill: rgb("#cdd3da"),
      header-fill: rgb("#0099cc"),
      rows: dataset-rows,
      row-color: none,
    ),
    (
      x: features-x,
      y: top-tables-y,
      width: feature-width,
      label: "Features",
      headers: feature-headers,
      fill: data-color,
      header-fill: data-header,
      rows: dataset-rows,
      row-color: striped(data-color, data-color-alt, test-data-color),
    ),
    (
      x: target-x,
      y: top-tables-y,
      width: target-width,
      label: "Target",
      headers: ("Y",),
      fill: target-color,
      header-fill: target-header,
      rows: dataset-rows,
      row-color: striped(target-color, target-color-alt, test-target-color),
    ),
  )
  for (center-y, split, rows, feature-fill, target-fill) in (
    (0, [train], dataset-rows - test-indices.len(), data-color, target-color),
    (test-y, [test], test-indices.len(), test-data-color, test-target-color),
  ) {
    for (offset, width, label, headers, fill, header-fill) in (
      (0, feature-width, [X], feature-headers, feature-fill, data-header),
      (feature-width + 0.5, target-width, [y], ("Y",), target-fill, target-header),
    ) {
      tables.push((
        x: train-x + offset,
        y: center-y,
        width: width,
        label: [#label#sub(split)],
        headers: headers,
        fill: fill,
        header-fill: header-fill,
        rows: rows,
        row-color: idx => fill,
      ))
    }
  }

  for (x, y, width, rows, label, ..) in tables {
    content((x + width / 2, y + (rows + 1) * row-height / 2 + 0.7), text(size: 18.2pt, label))
  }

  for (x, y, width, rows, headers, fill, header-fill, row-color, ..) in tables {
    let top = y + (rows + 1) * row-height / 2
    let (header-bottom, bottom) = (top - row-height, y - (rows + 1) * row-height / 2)
    rect((x, top), (x + width, bottom), stroke: matrix-stroke, fill: fill)
    rect((x, top), (x + width, header-bottom), stroke: matrix-stroke, fill: header-fill)
    for (idx, header) in headers.enumerate() {
      content((x + 0.5 + idx, top - row-height / 2), text(fill: white, size: 13pt, header))
    }
    for idx in range(rows + 1) {
      let row-y = header-bottom - idx * row-height
      line((x, row-y), (x + width, row-y), stroke: matrix-stroke)
    }
    for idx in range(width + 1) {
      line((x + idx, header-bottom), (x + idx, bottom), stroke: matrix-stroke)
    }
    if row-color != none {
      for idx in range(rows) {
        let row-top = header-bottom - idx * row-height
        rect(
          (x, row-top),
          (x + width, row-top - row-height),
          stroke: matrix-stroke,
          fill: row-color(idx),
        )
      }
    }
  }

  // === Neural network ===
  let nn-y = -4.5
  let neuron-radius = 0.65
  let (input-x, output-x) = (model-x - 2, model-x + 2)
  content((model-x, nn-y + 4.2), text(size: 18.2pt)[ML Model])

  let neuron(x, y, name) = {
    circle((x, y), radius: neuron-radius, fill: rgb("#aaddff"), stroke: none, name: name)
    content((x, y), name)
  }
  let input-y = idx => nn-y - 2 + idx * 2
  let hidden-y = idx => nn-y - 3 + idx * 2

  for idx in range(3) { neuron(input-x, input-y(idx), "i" + str(idx + 1)) }
  for idx in range(4) { neuron(model-x, hidden-y(idx), "h" + str(idx + 1)) }
  neuron(output-x, nn-y, "o")

  for input-idx in range(1, 4) {
    for hidden-idx in range(1, 5) {
      line("i" + str(input-idx) + ".east", "h" + str(hidden-idx) + ".west", stroke: black + 0.5pt)
    }
  }
  for idx in range(1, 5) { line("h" + str(idx) + ".east", "o.west", stroke: black + 0.5pt) }

  // === Step arrows ===
  let step-text(pos, body) = content(pos, text(size: 16pt, body))
  let step-arrow(start, end, label, label-offset) = {
    line(start, end, ..arrow-style)
    step-text(((start.at(0) + end.at(0)) / 2, (start.at(1) + end.at(1)) / 2 + label-offset), label)
  }

  step-arrow(
    (full-data-x + feature-width + target-width + 0.5, top-tables-y),
    (features-x - 0.5, top-tables-y),
    [1. Arrange\ data],
    1.2,
  )

  // one arrow head fans out to both the train and the test table
  let split-from = (target-x + target-width + 0.5, top-tables-y)
  line(split-from, (train-x - 0.5, .5), ..arrow-style)
  line(split-from, (train-x - 0.5, test-y), ..arrow-style)
  step-text((rel: (2.5, 0), to: split-from), [2. Train-Test\ Split])

  let tables-right = train-x + feature-width + 0.5 + target-width + 0.5
  let model-left = input-x - neuron-radius - 0.5
  step-arrow((tables-right, 0), (model-left, nn-y + 1), [3. Use for\ training], 2)
  step-arrow((tables-right, test-y), (model-left, nn-y - 1), [4. Use for\ testing], -2.2)
})
