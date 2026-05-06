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
  let top_tables_y_offset = -3.5
  let nn_y_offset = -4.5

  // rows selected for the test set (0-indexed), simulating random sampling
  let test-indices = (1, 4, 6)

  let create_table(x, y, width, height, fill, header_fill, header_texts) = {
    let num_rows = int((height - header-height) / row-height)
    rect((x, y + height / 2), (x + width, y - height / 2), stroke: matrix-stroke, fill: fill)
    rect((x, y + height / 2), (x + width, y + height / 2 - header-height), stroke: matrix-stroke, fill: header_fill)
    for i in range(header_texts.len()) {
      content(
        (x + 0.5 + i, y + height / 2 - header-height / 2),
        text(..header-text-style)[#header_texts.at(i)],
        anchor: "center",
      )
    }
    for i in range(num_rows + 1) {
      let y-pos = y + height / 2 - header-height - i * row-height
      line((x, y-pos), (x + width, y-pos), stroke: matrix-stroke)
    }
    for i in range(int(width) + 1) {
      line((x + i, y + height / 2 - header-height), (x + i, y - height / 2), stroke: matrix-stroke)
    }
  }

  // fill a table's data rows with per-row colors from row_color(i)
  let fill_rows(x, y_base, width, table_height, count, row_color) = {
    for i in range(count) {
      let row-y-top = y_base + table_height / 2 - header-height - i * row-height
      rect((x, row-y-top), (x + width, row-y-top - row-height), stroke: matrix-stroke, fill: row_color(i))
    }
  }

  let add_table_label(x, y, width, height, label_text) = {
    content((x + width / 2, y + height / 2 + label-offset), text(..label-text-style)[#label_text], anchor: "center")
  }

  add_table_label(full-data-x, top_tables_y_offset, full-data-width, full-data-height, "Full Dataset")
  add_table_label(features-x, top_tables_y_offset, feature-width, full-data-height, "Features")
  add_table_label(target-x, top_tables_y_offset, target-width, full-data-height, "Target")
  add_table_label(train-x, vertical-center, feature-width, train-height, [X#sub[train]])
  add_table_label(train-x + feature-width + 0.5, vertical-center, target-width, train-height, [y#sub[train]])
  add_table_label(test-x, test-y, feature-width, test-height, [X#sub[test]])
  add_table_label(test-x + feature-width + 0.5, test-y, target-width, test-height, [y#sub[test]])

  let feature_headers = ("X1", "X2", "X3", "X4", "X5")
  let full_dataset_headers = feature_headers + ("Y",)

  // full dataset (left, white cells)
  create_table(full-data-x, top_tables_y_offset, full-data-width, full-data-height, white, rgb("#0099cc"), full_dataset_headers)

  // features + target with alternating rows; test rows highlighted
  create_table(features-x, top_tables_y_offset, feature-width, full-data-height, data-color, rgb("#008080"), feature_headers)
  fill_rows(features-x, top_tables_y_offset, feature-width, full-data-height, 7, (i) => if test-indices.contains(i) { test-data-color } else if calc.rem(i, 2) == 0 { data-color } else { data-color-alt })

  create_table(target-x, top_tables_y_offset, target-width, full-data-height, target-color, rgb("#cc9900"), ("Y",))
  fill_rows(target-x, top_tables_y_offset, target-width, full-data-height, 7, (i) => if test-indices.contains(i) { test-target-color } else if calc.rem(i, 2) == 0 { target-color } else { target-color-alt })

  // train tables (uniform color)
  create_table(train-x, vertical-center, feature-width, train-height, data-color, rgb("#008080"), feature_headers)
  fill_rows(train-x, vertical-center, feature-width, train-height, 5, (i) => data-color)

  create_table(train-x + feature-width + 0.5, vertical-center, target-width, train-height, target-color, rgb("#cc9900"), ("Y",))
  fill_rows(train-x + feature-width + 0.5, vertical-center, target-width, train-height, 5, (i) => target-color)

  // test tables (uniform lighter color)
  create_table(test-x, test-y, feature-width, test-height, test-data-color, rgb("#008080"), feature_headers)
  fill_rows(test-x, test-y, feature-width, test-height, 3, (i) => test-data-color)

  create_table(test-x + feature-width + 0.5, test-y, target-width, test-height, test-target-color, rgb("#cc9900"), ("Y",))
  fill_rows(test-x + feature-width + 0.5, test-y, target-width, test-height, 3, (i) => test-target-color)

  // === Neural network ===
  let nn-x = model-x
  let nn-y = vertical-center + nn_y_offset
  let nn-width = 6
  let nn-height = 6
  let neuron-radius = 0.65

  content((nn-x, nn-y + nn-height / 2 + 1.2), text(..label-text-style)[ML Model], anchor: "center")

  let create_neuron(x, y, name) = {
    circle((x, y), radius: neuron-radius, fill: rgb("#aaddff"), stroke: none)
    content((x, y), text(..neuron-text-style)[#name], anchor: "center")
  }

  for i in range(3) {
    create_neuron(nn-x - nn-width / 3, nn-y - 2 + i * 2, "i" + str(i + 1))
  }
  for i in range(4) {
    create_neuron(nn-x, nn-y - 3 + i * 2, "h" + str(i + 1))
  }
  create_neuron(nn-x + nn-width / 3, nn-y, "o")

  for i in range(3) {
    let input-y = nn-y - 2 + i * 2
    for j in range(4) {
      line((nn-x - nn-width / 3 + neuron-radius, input-y), (nn-x - neuron-radius, nn-y - 3 + j * 2), stroke: black + 0.5pt)
    }
  }
  for j in range(4) {
    line((nn-x + neuron-radius, nn-y - 3 + j * 2), (nn-x + nn-width / 3 - neuron-radius, nn-y), stroke: black + 0.5pt)
  }

  // === Step arrows ===
  let create_arrow(start, end, label, label_offset) = {
    line(start, end, ..arrow-style)
    if label != "" {
      content(
        ((start.at(0) + end.at(0)) / 2, (start.at(1) + end.at(1)) / 2 + label_offset),
        text(..step-text-style)[#label],
        anchor: "center",
      )
    }
  }

  // full dataset -> features/target
  create_arrow((full-data-x + full-data-width + 0.5, top_tables_y_offset), (features-x - 0.5, top_tables_y_offset), [1. Arrange\ data], 1.2)

  // features/target -> train and test
  let arrow2_common_start = (target-x + target-width + 0.5, top_tables_y_offset)
  create_arrow(arrow2_common_start, (train-x - 0.5, vertical-center + .5), "", 0)
  create_arrow(arrow2_common_start, (test-x - 0.5, test-y), "", 0)
  content((target-x + target-width + 3.0, arrow2_common_start.at(1)), text(..step-text-style)[2. Train-Test\ Split], anchor: "center")

  // train -> model
  create_arrow(
    (train-x + feature-width + 0.5 + target-width + 0.5, vertical-center),
    (nn-x - nn-width / 3 - neuron-radius - 0.5, nn-y + 1),
    [3. Use for\ training],
    2,
  )
  // test -> model
  create_arrow(
    (test-x + feature-width + 0.5 + target-width + 0.5, test-y),
    (nn-x - nn-width / 3 - neuron-radius - 0.5, nn-y - 1),
    [4. Use for\ testing],
    -2.2,
  )
})
