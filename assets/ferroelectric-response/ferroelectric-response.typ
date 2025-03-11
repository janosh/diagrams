#import "@preview/cetz:0.3.4": canvas, draw
#import draw: rect, line, circle, content, hobby, scale

#set page(width: auto, height: auto, margin: 8pt)

#canvas({
  let arrow-style = (mark: (end: "stealth", fill: black, scale: .75))
  let plot-height = 4
  let plot-width = 10
  let y-offset = 4.65 // Reduced from 6 to bring plots closer together

  // Helper to draw axes
  let draw-axes(origin, width, height) = {
    line(
      (origin.at(0) - 0.5, origin.at(1)),
      (origin.at(0) + width, origin.at(1)),
      ..arrow-style,
      name: "x-axis",
    )
    line(
      (origin.at(0), origin.at(1) - 0.5),
      (origin.at(0), origin.at(1) + height),
      ..arrow-style,
      name: "y-axis",
    )
  }

  // Top plot: Double-well potential
  let top-origin = (-5, y-offset)
  draw-axes(top-origin, plot-width, plot-height)

  // Draw double-well potential curve using hobby spline
  hobby(
    (top-origin.at(0) + .5, top-origin.at(1) + 3.5), // start high
    (top-origin.at(0) + 1.7, top-origin.at(1) + 0.4), // left minimum
    (top-origin.at(0) + 1.8, top-origin.at(1) + 0.3), // left minimum
    (top-origin.at(0) + 5, top-origin.at(1) + 1.5), // up to middle peak
    (top-origin.at(0) + 8.2, top-origin.at(1) + 0.3), // right minimum
    (top-origin.at(0) + 8.3, top-origin.at(1) + 0.4), // right minimum
    (top-origin.at(0) + 9.5, top-origin.at(1) + 3.5), // up high again
    omega: 0,
    name: "potential-curve",
  )

  // Add "Free Energy" label
  content(
    "y-axis.mid",
    [Free Energy],
    angle: 90deg,
    anchor: "south",
    padding: (0, 0, 2pt),
  )

  // Bottom plot: Polarization vs. displacement
  let bottom-origin = (-5, 0)
  draw-axes(bottom-origin, plot-width, plot-height)

  // zero lines
  line(
    (bottom-origin.at(0), bottom-origin.at(1) + plot-height / 2),
    (bottom-origin.at(0) + plot-width, bottom-origin.at(1) + plot-height / 2),
    stroke: gray + 0.5pt,
  )
  line(
    (bottom-origin.at(0) + plot-width / 2, bottom-origin.at(1)),
    (bottom-origin.at(0) + plot-width / 2, bottom-origin.at(1) + plot-height),
    stroke: gray + 0.5pt,
  )

  // Add x-axis labels
  content(
    (bottom-origin.at(0), bottom-origin.at(1)),
    [negative],
    anchor: "north-west",
    padding: (4pt, 2pt, 0),
    name: "neg-label",
  )
  content(
    (bottom-origin.at(0) + 8.5, bottom-origin.at(1)),
    [positive],
    anchor: "north-west",
    padding: (4pt, 2pt, 0),
    name: "pos-label",
  )

  // Draw linear polarization line
  line(
    (bottom-origin.at(0), bottom-origin.at(1)),
    (bottom-origin.at(0) + plot-width, bottom-origin.at(1) + plot-height),
    stroke: blue + 1.5pt,
    name: "polarization-line",
  )

  // Add "Polarization" and "Ti Displacement" labels
  content(
    "y-axis.mid",
    [Polarization],
    angle: 90deg,
    anchor: "south",
    padding: 4pt,
  )
  content(
    "x-axis.mid",
    [Ti Displacement],
    anchor: "north",
    padding: (10pt, 0, 0),
  )

  // Helper function to draw BaTiO3 unit cell
  // TODO the face-centered oxygen atom positions need fixing and the lines overlap the atoms
  let draw-unit-cell(center-x, center-y, ti-y, cell-name) = {
    let (x, y) = (center-x, center-y)
    let z-offset = 0.3 // Consistent offset for back face
    let cube-style = (stroke: 0.7pt)

    // Draw unit cell cube with consistent offsets
    rect(
      (x - 1, y - 1),
      (x + 1, y + 1),
      ..cube-style,
      name: cell-name + "-front",
    ) // Front face
    line(
      (x - 1, y - 1),
      (x - 1 + z-offset, y - 1 + z-offset),
      ..cube-style,
      name: cell-name + "-left",
    ) // Left edge
    line(
      (x + 1, y - 1),
      (x + 1 + z-offset, y - 1 + z-offset),
      ..cube-style,
      name: cell-name + "-right",
    ) // Right edge
    line(
      (x - 1 + z-offset, y - 1 + z-offset),
      (x + 1 + z-offset, y - 1 + z-offset),
      ..cube-style,
      name: cell-name + "-back",
    ) // Back edge
    line(
      (x - 1 + z-offset, y + 1 + z-offset),
      (x + 1 + z-offset, y + 1 + z-offset),
      ..cube-style,
      name: cell-name + "-top-back",
    ) // Top back edge
    line(
      (x - 1 + z-offset, y - 1 + z-offset),
      (x - 1 + z-offset, y + 1 + z-offset),
      ..cube-style,
      name: cell-name + "-left-back",
    ) // Left back edge
    line(
      (x + 1 + z-offset, y - 1 + z-offset),
      (x + 1 + z-offset, y + 1 + z-offset),
      ..cube-style,
      name: cell-name + "-right-back",
    ) // Right back edge

    // Draw Ba atoms (all 8 corners)
    let ba-style = (stroke: none, fill: rgb("#00ffff"))
    for (pos, suffix) in (
      // Front face corners
      ((x - 1, y - 1), "front-bl"),
      ((x + 1, y - 1), "front-br"),
      ((x - 1, y + 1), "front-tl"),
      ((x + 1, y + 1), "front-tr"),
      // Back face corners
      ((x - 1 + z-offset, y - 1 + z-offset), "back-bl"),
      ((x + 1 + z-offset, y - 1 + z-offset), "back-br"),
      ((x - 1 + z-offset, y + 1 + z-offset), "back-tl"),
      ((x + 1 + z-offset, y + 1 + z-offset), "back-tr"),
    ) {
      circle(
        pos,
        radius: 0.15,
        ..ba-style,
        name: cell-name + "-ba-" + suffix,
      )
    }

    // Draw O atoms (all 6 face centers)
    let o-style = (stroke: none, fill: red)
    for (pos, suffix) in (
      // Front and back face centers
      ((x, y), "front"), // Front face center
      ((x + z-offset, y + z-offset), "back"), // Back face center
      // Face centers with consistent offsets
      ((x, y + 1), "top"), // Top face center
      ((x, y - 1), "bottom"), // Bottom face center
      ((x - 1, y), "left"), // Left face center
      ((x + 1, y), "right"), // Right face center
    ) {
      circle(
        pos,
        radius: 0.12,
        ..o-style,
        name: cell-name + "-o-" + suffix,
      )
    }

    // Draw Ti atom (center, displaced)
    let ti-style = (stroke: none, fill: gray)
    circle(
      (x + z-offset / 2, y + ti-y),
      radius: 0.1,
      ..ti-style,
      name: cell-name + "-ti",
    )

    // Draw Ti-O bonds
    let bond-style = (stroke: (thickness: 0.5pt))
    for (end-pos, suffix) in (
      ((x, y), "front"), // Front face center
      ((x + z-offset, y + z-offset), "back"), // Back face center
      ((x, y + 1), "top"), // Top face center
      ((x, y - 1), "bottom"), // Bottom face center
      ((x - 1, y), "left"), // Left face center
      ((x + 1, y), "right"), // Right face center
    ) {
      line(
        (x + z-offset / 2, y + ti-y), // Ti position
        end-pos,
        ..bond-style,
        name: cell-name + "-bond-" + suffix,
      )
    }
  }

  // Draw three unit cells with different Ti displacements
  scale(0.75)
  draw-unit-cell(-4, y-offset + 5, -0.2, "cell1")
  draw-unit-cell(0, y-offset + 5, 0, "cell2")
  draw-unit-cell(4, y-offset + 5, 0.2, "cell3")
})
