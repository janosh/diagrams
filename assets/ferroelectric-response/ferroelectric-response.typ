#import "@preview/cetz:0.3.4": canvas, draw
#import draw: rect, line, circle, content, hobby, scale, set-origin

#set page(width: auto, height: auto, margin: 8pt)

#canvas({
  let arrow-style = (mark: (end: "stealth", fill: black, scale: .75))
  let plot-height = 4
  let plot-width = 10
  let y-offset = 4.5

  // Helper to draw axes
  let draw-axes(origin, width, height) = {
    line(
      (origin.at(0) - 0.3, origin.at(1)),
      (origin.at(0) + width, origin.at(1)),
      ..arrow-style,
      name: "x-axis",
    )
    line(
      (origin.at(0), origin.at(1) - 0.3),
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
    (top-origin.at(0) + .5, top-origin.at(1) + 4), // start high
    (top-origin.at(0) + 1.7, top-origin.at(1) + 0.4), // left minimum
    (top-origin.at(0) + 1.8, top-origin.at(1) + 0.3), // left minimum
    (top-origin.at(0) + 5, top-origin.at(1) + 1.5), // up to middle peak
    (top-origin.at(0) + 8.2, top-origin.at(1) + 0.3), // right minimum
    (top-origin.at(0) + 8.3, top-origin.at(1) + 0.4), // right minimum
    (top-origin.at(0) + 9.5, top-origin.at(1) + 4), // up high again
    omega: 0,
    name: "potential-curve",
    stroke: 1.5pt,
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
  let atom(pos, radius: 0.20, fill: luma(50), ..args) = {
    circle(
      pos, 
      radius: radius,
      stroke: none,
      fill: fill,
      ..args
    )
    circle(
      (),
      radius: radius,
      stroke: none,
      fill: gradient.radial(
        fill.lighten(75%), fill, fill.darken(15%),
        focal-center: (30%, 25%),
        focal-radius: 5%,
        center: (35%, 30%),
      ),
    )
  }
  let draw-unit-cell(center-x, center-y, ti-y, cell-name) = {
    let (x, y) = (center-x, center-y)
    let z-offset = -1.0 // Consistent offset for back face
    let cube-style = (stroke: 0.7pt)


    // Draw unit cell cube with consistent offsets
    rect(
      (x - 1, y - 1, 0),
      (x + 1, y + 1, 0),
      ..cube-style,
      name: cell-name + "-front",
    ) // Front face
    line(
      (x - 1, y - 1, 0),
      (x - 1, y - 1, z-offset),
      ..cube-style,
      name: cell-name + "-left",
    ) // Left edge
    line(
      (x + 1, y - 1, 0),
      (x + 1, y - 1, z-offset),
      ..cube-style,
      name: cell-name + "-right",
    ) // Right edge
    line(
      (x - 1, y - 1, z-offset),
      (x + 1, y - 1, z-offset),
      ..cube-style,
      name: cell-name + "-back",
    ) // Back edge
    line(
      (x - 1, y + 1, z-offset),
      (x + 1, y + 1, z-offset),
      ..cube-style,
      name: cell-name + "-top-back",
    ) // Top back edge
    line(
      (x - 1, y - 1, z-offset),
      (x - 1, y + 1, z-offset),
      ..cube-style,
      name: cell-name + "-left-back",
    ) // Left back edge
    line(
      (x + 1, y - 1, z-offset),
      (x + 1, y + 1, z-offset),
      ..cube-style,
      name: cell-name + "-right-back",
    ) // Right back edge
    line(
      (x + 1, y - -1),
      (x + 1, y - -1, z-offset),
      ..cube-style,
      name: cell-name + "top-right",
    ) // top right edge
    line(
      (x + -1, y - -1),
      (x + -1, y - -1, z-offset),
      ..cube-style,
      name: cell-name + "top-left",
    ) // top right edge

    // Define helper functions for each atom style
    let Ba-atom(pos, name) = atom(pos, fill: rgb("#00ffff"), name: cell-name + "-ba-" + name)
    let O-atom(pos, name) = atom( pos, fill: red, name: cell-name + "-o-" + name)
    let Ti-atom(pos) = atom( pos, fill: gray, name: cell-name + "-ti")
    let Ti-O-bond(end-pos, name) = line(
      ((x, y + ti-y, z-offset/2), 15%, end-pos),
      ((x, y + ti-y, z-offset/2), 85%, end-pos),
      stroke: 1pt,
      name: cell-name + "-bond-" + name,
    )
    
    // --- Back Plane (z = z-offset) ---
    Ba-atom((x - 1, y - 1, z-offset), "back-bl")
    Ba-atom((x + 1, y - 1, z-offset), "back-br")
    Ba-atom((x - 1, y + 1, z-offset), "back-tl")
    Ba-atom((x + 1, y + 1, z-offset), "back-tr")
    O-atom((x, y, z-offset), "back")
    Ti-O-bond((x, y, z-offset), "back")
    
    // --- Middle Plane (z = z-offset/2) ---
    if ti-y >= 0 {
      Ti-O-bond((x, y + 1, z-offset/2), "top")
    }
    if ti-y <= 0 {
      Ti-O-bond((x, y - 1, z-offset/2), "bottom")
    }
    Ti-O-bond((x - 1, y, z-offset/2), "left")
    Ti-O-bond((x + 1, y, z-offset/2), "right")
    O-atom((x, y + 1, z-offset/2), "top")
    O-atom((x, y - 1, z-offset/2), "bottom")
    O-atom((x - 1, y, z-offset/2), "left")
    O-atom((x + 1, y, z-offset/2), "right")
    Ti-atom((x, y + ti-y, z-offset/2))
    
    // --- Front Plane (z = 0) ---
    Ti-O-bond((x, y, 0), "front")
    Ba-atom((x - 1, y - 1, 0), "front-bl")
    Ba-atom((x + 1, y - 1, 0), "front-br")
    Ba-atom((x - 1, y + 1, 0), "front-tl")
    Ba-atom((x + 1, y + 1, 0), "front-tr")
    O-atom((x, y, 0), "front")
  }

  // Draw three unit cells with different Ti displacements
  scale(0.64)
  set-origin("potential-curve.mid")
  draw-unit-cell(-4.5, 2, -0.2, "cell1")
  draw-unit-cell(-0.5, 2, 0, "cell2")
  draw-unit-cell(3.5, 2, 0.2, "cell3")
})
