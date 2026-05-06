#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, line, rect

#set page(width: auto, height: auto, margin: 5pt, fill: none)

#let neuron(pos, fill: white, text: none, name: none) = {
  draw.content(pos, text, frame: "circle", fill: fill, stroke: none, padding: 4pt, name: name)
}

#let atom(pos, element, color: white, text-color: black, padding: 6pt, name: none) = {
  let radius = padding + 7pt // approximates text size + padding
  circle(pos, radius: radius, stroke: none, fill: color)
  // radial gradient overlay for 3D shading
  circle(pos, radius: radius, stroke: none, fill: gradient.radial(
    color.lighten(75%),
    color,
    color.darken(15%),
    focal-center: (30%, 25%),
    focal-radius: 5%,
    center: (35%, 30%),
  ))
  content(pos, text(fill: text-color, weight: "bold", size: 14pt)[#element], anchor: "center", name: name)
}

#canvas({
  let arrow-style = (stroke: rgb("#888") + 5pt, mark: (end: "stealth", size: 15pt))
  let vertical-center = 0

  let struct-desc-spacing = 2.5
  let model-prop-spacing = 2.5
  let component-spacing = 3.5
  let label-offset = 4
  let label-y = vertical-center - label-offset // shared y for all component labels

  let molecule-y-offset = 0.5
  let matrix-y-offset = 0.3

  let struct-x = -5.5
  let struct-y = vertical-center + molecule-y-offset
  let struct-origin = (struct-x, struct-y)

  // === Molecular structure: bonds (behind), then atoms ===
  let bonds = (
    ((1.5, -2.5), (0, -1.5)),
    ((0, -1.5), (0, 0)),
    ((0, 0), (-0.5, 1.5)),
    ((0, 0), (1.8, 0.5)),
    ((0, -3), (0, -1.5)),
    ((-1.5, -2.5), (0, -1.5)),
    ((-0.5, 1.5), (-2, 0.75)),
    ((-0.5, 1.5), (1, 2)),
  )
  for (idx, (a, b)) in bonds.enumerate() {
    line((rel: a, to: struct-origin), (rel: b, to: struct-origin), stroke: rgb("#888") + 3pt, name: "bond" + str(idx + 1))
  }

  atom(struct-origin, "C", color: rgb("#404040"), text-color: white, name: "C1", padding: 5pt)
  atom((rel: (0, -1.5), to: struct-origin), "C", color: rgb("#404040"), text-color: white, name: "C2", padding: 5pt)
  atom((rel: (-0.5, 1.5), to: struct-origin), "N", color: rgb("#4444ff"), name: "N1", padding: 6pt)
  atom((rel: (1.8, 0.5), to: struct-origin), "O", color: rgb("#ff4444"), name: "O1", padding: 7pt)
  for (idx, off) in ((1.5, -2.5), (0, -3), (-1.5, -2.5), (-2, 0.75), (1, 2)).enumerate() {
    atom((rel: off, to: struct-origin), "H", color: white, padding: 2pt, name: "H" + str(idx + 1))
  }

  content((struct-x, label-y), text(size: 14pt, weight: "bold")[Molecular Structure], anchor: "center", name: "struct-label-text")

  let struct-right-x = struct-x + 3.5

  // === Descriptor matrix ===
  let desc-x = struct-right-x + struct-desc-spacing
  let desc-y = vertical-center + matrix-y-offset

  let matrix-data = (
    (74, 25, 39, 20, 3, 3, 3, 3, 3),
    (25, 53, 31, 17, 7, 7, 2, 3, 2),
    (39, 31, 37, 24, 3, 3, 3, 3, 3),
    (20, 17, 24, 37, 2, 2, 6, 5, 5),
    (3, 7, 3, 2, 0, 1, 0, 0, 0),
    (3, 7, 3, 2, 1, 0, 0, 0, 0),
    (3, 2, 3, 6, 0, 0, 0, 1, 1),
    (3, 3, 3, 5, 0, 0, 1, 0, 1),
    (3, 2, 3, 5, 0, 0, 1, 1, 0),
  )
  let cell-size = 0.6
  let matrix-width = matrix-data.at(0).len() * cell-size
  let max-value = 74

  for (row-idx, row) in matrix-data.enumerate() {
    for (col-idx, value) in row.enumerate() {
      let x = desc-x + col-idx * cell-size
      let y = desc-y - row-idx * cell-size + 2.7 * cell-size
      rect(
        (x, y),
        (x + cell-size, y + cell-size),
        // pastel red->green ramp with value (see heatmap.typ)
        fill: rgb(90%, 50% + value / max-value * 20%, 50% - value / max-value * 20%),
        stroke: none,
        name: "cell-" + str(row-idx) + "-" + str(col-idx),
      )
      content(
        (x + cell-size / 2, y + cell-size / 2),
        text(fill: if value < 40 { white } else { black }, size: 8pt)[#value],
        anchor: "center",
        name: "value-" + str(row-idx) + "-" + str(col-idx),
      )
    }
  }

  content((desc-x + matrix-width / 2, label-y), text(size: 14pt, weight: "bold")[Descriptor], anchor: "center", name: "desc-label-text")

  let desc-right-x = desc-x + matrix-width

  // === Neural network model ===
  let model-x = desc-right-x + component-spacing
  let layer-sep = 2.5

  // (x-pos, neuron-count, fill, label-prefix)
  let layers = (
    (model-x, 3, rgb("#40d0d0"), "i"),
    (model-x + layer-sep, 4, rgb("#8080ff"), "h"),
    (model-x + 2 * layer-sep, 1, rgb("#f08040"), "o"),
  )

  // neurons first so connections render behind nodes
  for (x, count, fill, prefix) in layers {
    for i in range(count) {
      let y = vertical-center + (i - (count - 1) / 2) * 1.5
      neuron((x, y), fill: fill, text: $#prefix#(i + 1)$, name: prefix + "-" + str(i + 1))
    }
  }
  for idx in range(layers.len() - 1) {
    let (_, n1, _, prefix1) = layers.at(idx)
    let (_, n2, _, prefix2) = layers.at(idx + 1)
    for i in range(n1) {
      for j in range(n2) {
        line((prefix1 + "-" + str(i + 1)), (prefix2 + "-" + str(j + 1)), stroke: rgb("#aaa") + 0.5pt)
      }
    }
  }

  content((model-x + layer-sep, label-y), text(size: 14pt, weight: "bold")[Model], anchor: "center", name: "model-label-text")

  let model-right-x = model-x + 2 * layer-sep + 1.5

  // === Property ===
  let property-x = model-right-x + model-prop-spacing
  let property-origin = (property-x, vertical-center)
  content(property-origin, text(size: 50pt, baseline: -3pt)[$alpha$], anchor: "center", name: "property")
  content((property-x, label-y), text(size: 14pt, weight: "bold")[Property], anchor: "center", name: "property-label-text")

  // === Connecting arrows, centered between components ===
  let arrow-length = 1.75
  let midpoints = (
    (struct-right-x + (desc-x - 0.5)) / 2,
    (desc-right-x + (model-x - 0.5)) / 2,
    (model-right-x + (property-x - 1.5)) / 2,
  )
  for (idx, mid) in midpoints.enumerate() {
    line((mid - arrow-length / 2, vertical-center), (mid + arrow-length / 2, vertical-center), ..arrow-style, name: "arrow" + str(idx + 1))
  }
})
