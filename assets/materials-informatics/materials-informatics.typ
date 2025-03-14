#import "@preview/cetz:0.3.4": canvas, draw
#import draw: line, content, rect, circle

#set page(width: auto, height: auto, margin: 5pt)

#let neuron(pos, fill: white, text: none, name: none) = {
  draw.content(
    pos,
    text,
    frame: "circle",
    fill: fill,
    stroke: none,
    padding: 4pt,
    name: name,
  )
}

#let atom(pos, element, color: white, text-color: black, padding: 6pt, name: none) = {
  // Calculate the radius based on padding to match the original size
  let radius = padding + 7pt // Approximation of text size + padding

  // Draw base circle with the main color
  circle(
    pos,
    radius: radius,
    stroke: none,
    fill: color,
  )

  // Draw gradient overlay for 3D shading effect
  circle(
    pos,
    radius: radius,
    stroke: none,
    fill: gradient.radial(
      color.lighten(75%),
      color,
      color.darken(15%),
      focal-center: (30%, 25%),
      focal-radius: 5%,
      center: (35%, 30%),
    ),
  )

  // Draw the element text on top
  content(
    pos,
    text(fill: text-color, weight: "bold", size: 14pt)[#element],
    anchor: "center",
    name: name,
  )
}

#canvas({
  // Define styles
  let arrow-style = (
    stroke: rgb("#888") + 5pt,
    mark: (end: "stealth", size: 15pt),
  )

  // Set vertical center point for all elements
  let vertical-center = 0

  // Define spacing constants
  let struct-desc-spacing = 2.5 // Closer spacing between structure and descriptor
  let model-prop-spacing = 2.5 // Closer spacing between model and property
  let component-spacing = 3.5 // Spacing between other components
  let label-offset = 4 // Vertical distance from components to labels
  let label-y = vertical-center - label-offset // Fixed y-position for all labels

  // Define vertical offsets
  let molecule-y-offset = 0.5 // Move molecule up
  let matrix-y-offset = 0.3 // Move matrix up

  // Define component positions
  let struct-x = -5.5
  let struct-y = vertical-center + molecule-y-offset
  let struct-origin = (struct-x, struct-y)

  // Draw molecular structure
  // Bonds first (so atoms appear on top)
  line(
    (rel: (1.5, -2.5), to: struct-origin),
    (rel: (0, -1.5), to: struct-origin),
    stroke: rgb("#888") + 3pt,
    name: "bond1",
  )
  line(
    (rel: (0, -1.5), to: struct-origin),
    struct-origin,
    stroke: rgb("#888") + 3pt,
    name: "bond2",
  )
  line(
    struct-origin,
    (rel: (-0.5, 1.5), to: struct-origin),
    stroke: rgb("#888") + 3pt,
    name: "bond3",
  )
  line(
    struct-origin,
    (rel: (1.8, 0.5), to: struct-origin),
    stroke: rgb("#888") + 3pt,
    name: "bond4",
  )
  line(
    (rel: (0, -3), to: struct-origin),
    (rel: (0, -1.5), to: struct-origin),
    stroke: rgb("#888") + 3pt,
    name: "bond5",
  )
  line(
    (rel: (-1.5, -2.5), to: struct-origin),
    (rel: (0, -1.5), to: struct-origin),
    stroke: rgb("#888") + 3pt,
    name: "bond6",
  )
  line(
    (rel: (-0.5, 1.5), to: struct-origin),
    (rel: (-2, 0.75), to: struct-origin),
    stroke: rgb("#888") + 3pt,
    name: "bond7",
  )
  line(
    (rel: (-0.5, 1.5), to: struct-origin),
    (rel: (1, 2), to: struct-origin),
    stroke: rgb("#888") + 3pt,
    name: "bond8",
  )

  // Now draw atoms on top of bonds - with increased size
  // Carbon atoms
  atom(struct-origin, "C", color: rgb("#404040"), text-color: white, name: "C1", padding: 5pt)
  atom((rel: (0, -1.5), to: struct-origin), "C", color: rgb("#404040"), text-color: white, name: "C2", padding: 5pt)

  // Nitrogen atom
  atom((rel: (-0.5, 1.5), to: struct-origin), "N", color: rgb("#4444ff"), name: "N1", padding: 6pt)

  // Oxygen atom
  atom((rel: (1.8, 0.5), to: struct-origin), "O", color: rgb("#ff4444"), name: "O1", padding: 7pt)

  // Hydrogen atoms
  atom((rel: (1.5, -2.5), to: struct-origin), "H", color: white, padding: 2pt, name: "H1")
  atom((rel: (0, -3), to: struct-origin), "H", color: white, padding: 2pt, name: "H2")
  atom((rel: (-1.5, -2.5), to: struct-origin), "H", color: white, padding: 2pt, name: "H3")
  atom((rel: (-2, 0.75), to: struct-origin), "H", color: white, padding: 2pt, name: "H4")
  atom((rel: (1, 2), to: struct-origin), "H", color: white, padding: 2pt, name: "H5")

  // Add structure label - using fixed label-y
  content(
    (struct-x, label-y),
    text(size: 14pt, weight: "bold")[Molecular Structure],
    anchor: "center",
    name: "struct-label-text",
  )

  // Calculate right edge of structure for arrow positioning
  let struct-right-x = struct-x + 3.5
  let struct-right = (struct-right-x, struct-y)

  // Descriptor matrix - position relative to structure with closer spacing
  let desc-x = struct-right-x + struct-desc-spacing
  let desc-y = vertical-center + matrix-y-offset
  let desc-origin = (desc-x, desc-y)

  // Matrix data
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
  let matrix-height = matrix-data.len() * cell-size

  // Draw matrix cells
  for (row-idx, row) in matrix-data.enumerate() {
    for (col-idx, value) in row.enumerate() {
      let x = desc-x + col-idx * cell-size
      let y = desc-y - row-idx * cell-size + 2.7 * cell-size

      // Calculate color using the approach from heatmap.typ
      let max-value = 74
      rect(
        (x, y),
        (x + cell-size, y + cell-size),
        fill: rgb(
          90%, // Red stays constant at 90% for pastel effect
          50% + value / max-value * 20%, // Green increases with value
          50% - value / max-value * 20%, // Blue decreases with value
        ),
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

  // Add descriptor label - using fixed label-y
  content(
    (desc-x + matrix-width / 2, label-y),
    text(size: 14pt, weight: "bold")[Descriptor],
    anchor: "center",
    name: "desc-label-text",
  )

  // Calculate right edge of descriptor for arrow positioning
  let desc-right-x = desc-x + matrix-width
  let desc-right = (desc-right-x, desc-y)

  // Neural network model - position relative to descriptor
  let model-x = desc-right-x + component-spacing
  let model-y = vertical-center
  let model-origin = (model-x, model-y)
  let layer-sep = 2.5

  // Define neural network layers
  let layers = (
    // (x-pos, neuron-count, fill-color, label-prefix)
    (model-x, 3, rgb("#40d0d0"), "i"), // Input layer - teal
    (model-x + layer-sep, 4, rgb("#8080ff"), "h"), // Hidden layer - light blue
    (model-x + 2 * layer-sep, 1, rgb("#f08040"), "o"), // Output layer - orange
  )

  // Draw all neurons FIRST (so connections appear behind nodes)
  for (idx, (x, count, fill, prefix)) in layers.enumerate() {
    for i in range(count) {
      let y = vertical-center + (i - (count - 1) / 2) * 1.5

      if idx == 2 {
        y = vertical-center // Adjust output node position
      }

      neuron(
        (x, y),
        fill: fill,
        text: $#prefix#(i+1)$,
        name: prefix + "-" + str(i + 1),
      )
    }
  }

  // THEN draw connections using node names
  for idx in range(layers.len() - 1) {
    let (_, n1, _, prefix1) = layers.at(idx)
    let (_, n2, _, prefix2) = layers.at(idx + 1)

    // Connect every node in this layer to every node in the next layer
    for i in range(n1) {
      for j in range(n2) {
        let node1-name = prefix1 + "-" + str(i + 1)
        let node2-name = prefix2 + "-" + str(j + 1)

        line(
          (node1-name),
          (node2-name),
          stroke: rgb("#aaa") + 0.5pt,
        )
      }
    }
  }

  // Add model label - using fixed label-y
  content(
    (model-x + layer-sep, label-y),
    text(size: 14pt, weight: "bold")[Model],
    anchor: "center",
    name: "model-label-text",
  )

  // Calculate right edge of model for arrow positioning
  let model-right-x = model-x + 2 * layer-sep + 1.5
  let model-right = (model-right-x, model-y)

  // Property - position relative to model with closer spacing
  let property-x = model-right-x + model-prop-spacing
  let property-y = vertical-center
  let property-origin = (property-x, property-y)

  // Draw property (alpha)
  content(
    property-origin,
    text(size: 50pt, baseline: -3pt)[$alpha$],
    anchor: "center",
    name: "property",
  )

  // Add property label - using fixed label-y
  content(
    (property-x, label-y),
    text(size: 14pt, weight: "bold")[Property],
    anchor: "center",
    name: "property-label-text",
  )

  // Define exact arrow length and positions for consistency
  let arrow-length = 1.75

  // Calculate midpoints between components for centered arrows
  let desc-left-x = desc-x - 0.5
  let model-left-x = model-x - 0.5
  let property-left-x = property-x - 1.5

  // Calculate midpoints for arrows
  let midpoint1-x = (struct-right-x + desc-left-x) / 2
  let midpoint2-x = (desc-right-x + model-left-x) / 2
  let midpoint3-x = (model-right-x + property-left-x) / 2

  // Draw arrows connecting the components
  // First arrow: Molecular Structure to Descriptor
  line(
    (midpoint1-x - arrow-length / 2, vertical-center),
    (midpoint1-x + arrow-length / 2, vertical-center),
    ..arrow-style,
    name: "arrow1",
  )

  // Second arrow: Descriptor to Model
  line(
    (midpoint2-x - arrow-length / 2, vertical-center),
    (midpoint2-x + arrow-length / 2, vertical-center),
    ..arrow-style,
    name: "arrow2",
  )

  // Third arrow: Model to Property
  line(
    (midpoint3-x - arrow-length / 2, vertical-center),
    (midpoint3-x + arrow-length / 2, vertical-center),
    ..arrow-style,
    name: "arrow3",
  )
})
