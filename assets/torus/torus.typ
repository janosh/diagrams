#import "@preview/cetz:0.4.2": canvas, draw, matrix
#import draw: content, line, rotate, scale, set-style, set-transform

#set page(width: auto, height: auto, margin: 4pt, fill: none)
#set text(size: 17pt, fill: black)

#let major_r = 12
#let minor_r = 3
#let v_max = 300
#let axis_len = 20
#let outer_rim = major_r + minor_r
#let arrow = (end: "stealth", fill: black, scale: 0.5)
#let ax_stroke = (paint: black, thickness: 0.8pt)
#let rad_stroke = 1.6pt

#let torus_pt(u_deg, v_deg) = {
  let (u, v) = (u_deg * 1deg, v_deg * 1deg)
  let rad = major_r + minor_r * calc.cos(u)
  (rad * calc.cos(v), rad * calc.sin(v), minor_r * calc.sin(u))
}

#canvas({
  set-transform(matrix.transform-rotate-dir((2.7, 1, -2), (0, 1, 0.5)))
  scale(x: 0.34, y: 0.30, z: 0.34)
  rotate(z: 146deg)

  // Build depth-sorted surface quads.
  let (quads, u_step, v_step) = ((), 360.0 / 48, v_max / 44)
  let weights = (-1.2, -0.2, -1)
  for u_idx in range(48) {
    for v_idx in range(44) {
      let (u, v) = (u_idx * u_step, v_idx * v_step)
      let u_next = calc.rem(u_idx + 1, 48) * u_step
      let v_next = if v_idx < 43 { v + v_step } else { v_max }
      let (p1, p2, p3, p4) = (torus_pt(u, v), torus_pt(u_next, v), torus_pt(u_next, v_next), torus_pt(u, v_next))
      let cx = (p1.at(0) + p2.at(0) + p3.at(0) + p4.at(0)) / 4
      let cy = (p1.at(1) + p2.at(1) + p3.at(1) + p4.at(1)) / 4
      let cz = (p1.at(2) + p2.at(2) + p3.at(2) + p4.at(2)) / 4
      quads.push((depth: weights.at(0) * cx + weights.at(1) * cy + weights.at(2) * cz, p1: p1, p2: p2, p3: p3, p4: p4))
    }
  }

  // x/y axes first (torus body occludes them).
  line((-axis_len, 0, 0), (axis_len, 0, 0), stroke: ax_stroke)
  line((0, axis_len, 0), (0, -axis_len, 0), stroke: ax_stroke)

  // Torus surface (painter's algorithm: far quads first).
  set-style(stroke: rgb("#9a9a9a") + 0.22pt, fill: rgb("#f0f0f0"))
  for quad in quads.sorted(key: q => -q.depth) {
    line(quad.p1, quad.p2, quad.p3, quad.p4, close: true)
  }

  // z-axis on top, then front-facing axis tips with arrowheads.
  line((0, 0, 10), (0, 0, -10), stroke: ax_stroke, mark: arrow, name: "z")
  content("z.end", $z$, anchor: "south", padding: 2pt)
  line((outer_rim, 0, 0), (axis_len, 0, 0), stroke: ax_stroke, mark: arrow, name: "x")
  content("x.end", $x$, anchor: "west", padding: 2pt)
  line((0, -outer_rim, 0), (0, -axis_len, 0), stroke: ax_stroke, mark: arrow, name: "y")
  content("y.end", $y$, anchor: "north-east", padding: 2pt)

  // R (blue): origin to tube center at far open slice.
  let v_end = v_max * 1deg
  let (rx, ry) = (major_r * calc.cos(v_end), major_r * calc.sin(v_end))
  line((0, 0, 0), (rx, ry, 0), stroke: (paint: blue, thickness: rad_stroke), name: "R")
  content("R.mid", text(fill: blue)[$R$], anchor: "south", padding: 2pt)

  // r (red): minor radius pointing diagonally upward.
  let stretch = 1 + minor_r * 0.5 / major_r
  line((rx, ry, 0), (rx * stretch, ry * stretch, -minor_r * 0.87), stroke: (paint: red, thickness: rad_stroke), name: "r")
  content("r.mid", text(fill: red)[$r$], anchor: "south-east", padding: 2pt)
})
