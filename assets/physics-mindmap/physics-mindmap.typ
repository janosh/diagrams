#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, line, on-layer

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(weight: "bold")

// Circle size and label size for each of the three levels of the map. Labels grow
// steeply towards the center. Each level sits just inside what its widest label
// allows: "Physics" overflows past 23pt, "High-Energy" past 11.5pt and "Quantum
// Field Theory" past 8pt.
#let (hub-style, branch-style, leaf-style) = (
  (radius: 1.5, font-size: 21pt),
  (radius: 1.2, font-size: 11pt),
  (radius: 0.8, font-size: 7.5pt),
)
#let (branch-dist, leaf-dist) = (3.75, 3.0)
// connector half-widths as fractions of the radius of the node at either end
#let (taper-wide, taper-narrow) = (0.14, 0.08)

// Black label on light fills, white on dark ones, from sRGB relative luminance.
// Lowering the cutoff towards the 0.179 equal-contrast point flips more fills to
// black text; 0.5 keeps white on everything but gold.
#let label-color(fill-color, cutoff: 0.5) = {
  let to-linear(channel) = {
    let val = channel / 100%
    if val <= 0.04045 { val / 12.92 } else { calc.pow((val + 0.055) / 1.055, 2.4) }
  }
  let (red, green, blue) = fill-color.rgb().components(alpha: false).map(to-linear)
  if 0.2126 * red + 0.7152 * green + 0.0722 * blue > cutoff { black } else { white }
}

#let node(pos, txt, style, color: orange) = {
  circle(pos, radius: style.radius, fill: color, stroke: none)
  content(pos, text(
    fill: label-color(color),
    size: style.font-size,
    align(center, txt),
  ))
}

// Link drawn as a trapezoid that narrows from parent to child and whose ends scale
// with the radii of the nodes it joins, so links thicken towards the map center.
#let connect(from, from-style, to, to-style, color) = {
  let ((from-x, from-y), (to-x, to-y)) = (from, to)
  let (delta-x, delta-y) = (to-x - from-x, to-y - from-y)
  let length = calc.sqrt(delta-x * delta-x + delta-y * delta-y)
  // unit normal to the link direction, offsets the trapezoid corners sideways
  let (normal-x, normal-y) = (-delta-y / length, delta-x / length)
  let (half-from, half-to) = (
    taper-wide * from-style.radius,
    taper-narrow * to-style.radius,
  )
  on-layer(-1, line(
    (from-x + normal-x * half-from, from-y + normal-y * half-from),
    (to-x + normal-x * half-to, to-y + normal-y * half-to),
    (to-x - normal-x * half-to, to-y - normal-y * half-to),
    (from-x - normal-x * half-from, from-y - normal-y * half-from),
    close: true,
    fill: color,
    stroke: none,
  ))
}

// Branches are placed every 60deg around the hub, leaf angles are absolute.
// The page is transparent, so fills have to stay legible on both the site's light
// (#F8F9FA) and dark (#534C5E) diagram backdrops. Those straddle mid grey, so no
// opaque fill clears 3:1 on both; the best any color can do is 2.79:1 either way.
// Cosmology and Quantum Mechanics were near-invisible in dark mode as #006400
// (1.10:1) and #00008B (1.87:1), and now sit at 2.63:1 and 2.62:1.
#let branches = (
  (
    title: [Classical\ Mechanics],
    color: rgb("#FFD700"),
    leaves: (
      ([Lagrange\ Hamilton], -54deg),
      ([Chaos\ Theory], -18deg),
      ([Gases\ & Fluids], 18deg),
      ([Electro\ dynamics], 54deg),
    ),
  ),
  (
    title: [High-Energy],
    color: purple,
    leaves: (
      ([Particle\ Physics], 30deg),
      ([Quantum\ Field\ Theory], 70deg),
      ([Nuclear\ Physics], 110deg),
    ),
  ),
  (
    title: [Cosmology],
    color: rgb("#00A855"),
    leaves: (([Astronomy], 140deg), ([Early\ Universe], 100deg)),
  ),
  (
    title: [Statistical\ Mechanics],
    color: red,
    leaves: (
      ([Thermo\ dynamics], 140deg),
      ([Kinetic\ Gas\ Theory], 180deg),
      ([Condensed\ Matter], 220deg),
    ),
  ),
  (
    title: [Relativity],
    color: teal,
    leaves: (([Special], 270deg), ([General], 210deg)),
  ),
  (
    title: [Quantum\ Mechanics],
    color: rgb("#2196F3"),
    leaves: (
      ([Atomic\ Physics], 250deg),
      ([Molecular\ Physics], 290deg),
      ([Chemistry], 330deg),
    ),
  ),
)

#canvas({
  let hub-pos = (0, 0)

  for (idx, branch) in branches.enumerate() {
    let branch-angle = idx * 60deg
    let branch-pos = (
      calc.cos(branch-angle) * branch-dist,
      calc.sin(branch-angle) * branch-dist,
    )
    connect(hub-pos, hub-style, branch-pos, branch-style, branch.color)

    for (leaf-title, leaf-angle) in branch.leaves {
      let leaf-pos = (
        branch-pos.at(0) + calc.cos(leaf-angle) * leaf-dist,
        branch-pos.at(1) + calc.sin(leaf-angle) * leaf-dist,
      )
      connect(branch-pos, branch-style, leaf-pos, leaf-style, branch.color)
      node(leaf-pos, leaf-title, leaf-style, color: branch.color)
    }
    node(branch-pos, branch.title, branch-style, color: branch.color)
  }

  node(hub-pos, [Physics], hub-style)
})
