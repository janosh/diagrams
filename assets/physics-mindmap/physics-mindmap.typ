#import "@preview/cetz:0.5.3": canvas, draw
#import draw: circle, content, line, on-layer

#set page(width: auto, height: auto, margin: 8pt, fill: none)

// Circle radii and branch spacing accommodate 16pt headings and 12pt leaf labels.
#let (hub-style, branch-style, leaf-style) = (
  (radius: 1.5, font-size: 21pt),
  (radius: 1.75, font-size: 16pt),
  (radius: 1.3, font-size: 12pt),
)
#let (branch-dist, leaf-dist) = (5.2, 4.4)
// connector half-widths as fractions of the radius of the node at either end
#let (taper-wide, taper-narrow) = (0.14, 0.08)

// Solid hub and branches carry white bold labels; leaves are light tints of their branch
// color, ringed in that color, with dark regular-weight labels so the hierarchy reads at a glance.
#let node(pos, body, style, color, leaf: false) = {
  let (fill, stroke, label) = if leaf {
    (color.lighten(78%), color + 2pt, text(fill: color.darken(45%), body))
  } else { (color, none, text(fill: white, weight: "bold", body)) }
  circle(pos, radius: style.radius, fill: fill, stroke: stroke)
  content(pos, text(size: style.font-size, align(center, label)))
}

// Link drawn as a trapezoid that narrows from parent to child and whose ends scale
// with the radii of the nodes it joins, so links thicken towards the map center.
#let connect(from, from-style, to, to-style, color) = {
  let ((from-x, from-y), (to-x, to-y)) = (from, to)
  let length = calc.sqrt(calc.pow(to-x - from-x, 2) + calc.pow(to-y - from-y, 2))
  // unit normal to the link direction, offsets the trapezoid corners sideways
  let (normal-x, normal-y) = (-(to-y - from-y) / length, (to-x - from-x) / length)
  let (half-from, half-to) = (taper-wide * from-style.radius, taper-narrow * to-style.radius)
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

// Branches are placed every 60deg around the hub, leaf angles are absolute. Muted mid-tone
// fills keep white labels legible and stay distinct on both light and dark backdrops.
#let branches = (
  (
    title: [Classical\ Physics],
    color: rgb("#d9731a"),
    leaves: (
      ([Analytical\ Mechanics], -60deg),
      ([Chaos\ Theory], -20deg),
      ([Fluid\ Dynamics], 20deg),
      ([Electro-\ dynamics], 60deg),
    ),
  ),
  (
    title: [High-Energy\ Physics],
    color: rgb("#9c5b8f"),
    leaves: (
      ([Particle\ Physics], 30deg),
      ([Quantum\ Field\ Theory], 70deg),
      ([Nuclear\ Physics], 110deg),
    ),
  ),
  (
    title: [Cosmology],
    color: rgb("#3b6ba5"),
    leaves: (([Astro-\ physics], 140deg), ([Early\ Universe], 100deg)),
  ),
  (
    title: [Statistical\ Mechanics],
    color: rgb("#c8443f"),
    leaves: (
      ([Thermo-\ dynamics], 140deg),
      ([Kinetic\ Theory], 180deg),
      ([Condensed\ Matter], 220deg),
    ),
  ),
  (
    title: [Relativity],
    color: rgb("#3e9a93"),
    leaves: (([Special], 270deg), ([General], 210deg)),
  ),
  (
    title: [Quantum\ Mechanics],
    color: rgb("#4a8a3f"),
    leaves: (
      ([Atomic &\ Molecular], 250deg),
      ([Quantum\ Optics], 290deg),
      ([Quantum\ Information], 330deg),
    ),
  ),
)

#let polar(center, angle, dist) = (
  center.at(0) + calc.cos(angle) * dist,
  center.at(1) + calc.sin(angle) * dist,
)

#canvas({
  let hub-pos = (0, 0)
  for (idx, (title, color, leaves)) in branches.enumerate() {
    let branch-pos = polar(hub-pos, idx * 60deg, branch-dist)
    connect(hub-pos, hub-style, branch-pos, branch-style, color)
    for (leaf-title, leaf-angle) in leaves {
      let leaf-pos = polar(branch-pos, leaf-angle, leaf-dist)
      connect(branch-pos, branch-style, leaf-pos, leaf-style, color.lighten(35%))
      node(leaf-pos, leaf-title, leaf-style, color, leaf: true)
    }
    node(branch-pos, title, branch-style, color)
  }
  node(hub-pos, [Physics], hub-style, rgb("#2f3e4e"))
})
