#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, line, rect

#set page(width: auto, height: auto, margin: 5pt, fill: none)

#canvas({
  let data-color = rgb("#00bfbf")
  let data-color-alt = rgb("#00a8a8")
  let test-data-color = rgb("#80dfdf")
  let target-color = rgb("#ffcc00")
  let target-color-alt = rgb("#e6b800")
  let test-target-color = rgb("#ffe680")
  let (data-header, target-header) = (rgb("#008080"), rgb("#cc9900"))
  let arrow-style = (stroke: black + 2pt, mark: (end: "stealth", size: 10pt))
  let step-text-style = (fill: black, weight: "bold", size: 14.3pt)
  let label-text-style = (fill: black, weight: "bold", size: 18.2pt)
  let header-text-style = (fill: white, weight: "bold", size: 13pt)
  let neuron-text-style = (fill: black, weight: "bold", size: 11.7pt)
  let matrix-stroke = 0.5pt + rgb("#0099cc")

  let vertical-center = 0
  let label-offset = 0.7

  let full-data-width = 6
  let full-data-height = 8
  let feature-width = 5
  let target-width = 1
  let train-height = 5.0
  let test-height = 3.0
  let header-height = 1.0
  let row-height = 1.0

  let full-data-x = -15
  let features-x = -6
  let target-x = features-x + feature-width + 0.5
  let train-x = 6
  let test-x = train-x
  let test-y = -8.0
  let model-x = 18
  let top-tables-y-offset = -3.5
  let nn-y-offset = -4.5

  // rows selected for the test set (0-indexed), simulating random sampling
  let test-indices = (1, 4, 6)
  let feature-headers = ("X1", "X2", "X3", "X4", "X5")

  // color a data row: test rows are highlighted, the rest alternate two shades
  let striped(base, alt, highlight) = idx => {
    if test-indices.contains(idx) { highlight } else if calc.rem(idx, 2) == 0 {
      base
    } else { alt }
  }

  let tables = (
    (
      x: full-data-x,
      y: top-tables-y-offset,
      width: full-data-width,
      height: full-data-height,
      label: "Full Dataset",
      headers: feature-headers + ("Y",),
      fill: white,
      header-fill: rgb("#0099cc"),
    ),
    (
      x: features-x,
      y: top-tables-y-offset,
      width: feature-width,
      height: full-data-height,
      label: "Features",
      headers: feature-headers,
      fill: data-color,
      header-fill: data-header,
      rows: 7,
      row-color: striped(data-color, data-color-alt, test-data-color),
    ),
    (
      x: target-x,
      y: top-tables-y-offset,
      width: target-width,
      height: full-data-height,
      label: "Target",
      headers: ("Y",),
      fill: target-color,
      header-fill: target-header,
      rows: 7,
      row-color: striped(target-color, target-color-alt, test-target-color),
    ),
    (
      x: train-x,
      y: vertical-center,
      width: feature-width,
      height: train-height,
      label: [X#sub[train]],
      headers: feature-headers,
      fill: data-color,
      header-fill: data-header,
      rows: 5,
      row-color: idx => data-color,
    ),
    (
      x: train-x + feature-width + 0.5,
      y: vertical-center,
      width: target-width,
      height: train-height,
      label: [y#sub[train]],
      headers: ("Y",),
      fill: target-color,
      header-fill: target-header,
      rows: 5,
      row-color: idx => target-color,
    ),
    (
      x: test-x,
      y: test-y,
      width: feature-width,
      height: test-height,
      label: [X#sub[test]],
      headers: feature-headers,
      fill: test-data-color,
      header-fill: data-header,
      rows: 3,
      row-color: idx => test-data-color,
    ),
    (
      x: test-x + feature-width + 0.5,
      y: test-y,
      width: target-width,
      height: test-height,
      label: [y#sub[test]],
      headers: ("Y",),
      fill: test-target-color,
      header-fill: target-header,
      rows: 3,
      row-color: idx => test-target-color,
    ),
  )

  for (x, y, width, height, label, ..) in tables {
    content(
      (x + width / 2, y + height / 2 + label-offset),
      text(..label-text-style)[#label],
      anchor: "center",
    )
  }

  for spec in tables {
    let (x, y, width, height, headers) = spec
    let top = y + height / 2
    rect((x, top), (x + width, y - height / 2), stroke: matrix-stroke, fill: spec.fill)
    rect(
      (x, top),
      (x + width, top - header-height),
      stroke: matrix-stroke,
      fill: spec.header-fill,
    )
    for (idx, header) in headers.enumerate() {
      content(
        (x + 0.5 + idx, top - header-height / 2),
        text(..header-text-style)[#header],
        anchor: "center",
      )
    }
    for idx in range(int((height - header-height) / row-height) + 1) {
      let row-y = top - header-height - idx * row-height
      line((x, row-y), (x + width, row-y), stroke: matrix-stroke)
    }
    for idx in range(int(width) + 1) {
      line((x + idx, top - header-height), (x + idx, y - height / 2), stroke: matrix-stroke)
    }
    for idx in range(spec.at("rows", default: 0)) {
      let row-top = top - header-height - idx * row-height
      rect(
        (x, row-top),
        (x + width, row-top - row-height),
        stroke: matrix-stroke,
        fill: (spec.row-color)(idx),
      )
    }
  }

  // === Neural network ===
  let nn-x = model-x
  let nn-y = vertical-center + nn-y-offset
  let (nn-width, nn-height) = (6, 6)
  let neuron-radius = 0.65
  let input-x = nn-x - nn-width / 3
  let output-x = nn-x + nn-width / 3

  content(
    (nn-x, nn-y + nn-height / 2 + 1.2),
    text(..label-text-style)[ML Model],
    anchor: "center",
  )

  let neuron(x, y, name) = {
    circle((x, y), radius: neuron-radius, fill: rgb("#aaddff"), stroke: none)
    content((x, y), text(..neuron-text-style)[#name], anchor: "center")
  }
  let input-y = idx => nn-y - 2 + idx * 2
  let hidden-y = idx => nn-y - 3 + idx * 2

  for idx in range(3) { neuron(input-x, input-y(idx), "i" + str(idx + 1)) }
  for idx in range(4) { neuron(nn-x, hidden-y(idx), "h" + str(idx + 1)) }
  neuron(output-x, nn-y, "o")

  for idx in range(3) {
    for jdx in range(4) {
      line(
        (input-x + neuron-radius, input-y(idx)),
        (nn-x - neuron-radius, hidden-y(jdx)),
        stroke: black + 0.5pt,
      )
    }
  }
  for jdx in range(4) {
    line(
      (nn-x + neuron-radius, hidden-y(jdx)),
      (output-x - neuron-radius, nn-y),
      stroke: black + 0.5pt,
    )
  }

  // === Step arrows ===
  let step-arrow(start, end, label, label-offset) = {
    line(start, end, ..arrow-style)
    if label != "" {
      content(
        ((start.at(0) + end.at(0)) / 2, (start.at(1) + end.at(1)) / 2 + label-offset),
        text(..step-text-style)[#label],
        anchor: "center",
      )
    }
  }

  step-arrow(
    (full-data-x + full-data-width + 0.5, top-tables-y-offset),
    (features-x - 0.5, top-tables-y-offset),
    [1. Arrange\ data],
    1.2,
  )

  // one arrow head fans out to both the train and the test table
  let split-from = (target-x + target-width + 0.5, top-tables-y-offset)
  step-arrow(split-from, (train-x - 0.5, vertical-center + .5), "", 0)
  step-arrow(split-from, (test-x - 0.5, test-y), "", 0)
  content(
    (target-x + target-width + 3.0, split-from.at(1)),
    text(..step-text-style)[2. Train-Test\ Split],
    anchor: "center",
  )

  let tables-right = feature-width + 0.5 + target-width + 0.5
  let model-left = input-x - neuron-radius - 0.5
  step-arrow(
    (train-x + tables-right, vertical-center),
    (model-left, nn-y + 1),
    [3. Use for\ training],
    2,
  )
  step-arrow(
    (test-x + tables-right, test-y),
    (model-left, nn-y - 1),
    [4. Use for\ testing],
    -2.2,
  )
})
