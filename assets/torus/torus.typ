#import "@preview/cetz:0.5.2": canvas, draw
#import draw: content, line, scale, set-style, set-transform

#set page(width: auto, height: auto, margin: 4pt, fill: none)
#set text(size: 17pt, fill: black)

#let major-r = 12
#let minor-r = 3
#let v-max = 300
#let axis-len = 20
#let outer-rim = major-r + minor-r
#let arrow = (end: "stealth", fill: black, scale: 0.5)
#let ax-stroke = (paint: black, thickness: 0.8pt)
#let rad-stroke = 1.6pt

#let torus-pt(u-deg, v-deg) = {
  let (u, v) = (u-deg * 1deg, v-deg * 1deg)
  let rad = major-r + minor-r * calc.cos(u)
  (rad * calc.cos(v), rad * calc.sin(v), -(minor-r * calc.sin(u)))
}

#canvas({
  // pgfplots default 3D view (azimuth 25 deg, elevation 30 deg) to match the original:
  // screen_x = -x sin(az) + y cos(az); screen_y = -(x cos(az) + y sin(az)) sin(el) + z cos(el)
  set-transform((
    (0.4226, -0.9063, 0, 0),
    (-0.4532, -0.2113, 0.8660, 0),
    (0, 0, 1, 0),
    (0, 0, 0, 1),
  ))
  scale(0.34)

  // Build depth-sorted surface quads.
  let (quads, u-step, v-step) = ((), 360.0 / 48, v-max / 44)
  let weights = (-0.785, -0.366, -0.5) // = -(camera direction) for the az=25, el=30 view
  for u-idx in range(48) {
    for v-idx in range(44) {
      let (u, v) = (u-idx * u-step, v-idx * v-step)
      let u-next = calc.rem(u-idx + 1, 48) * u-step
      let v-next = if v-idx < 43 { v + v-step } else { v-max }
      let (p1, p2, p3, p4) = (
        torus-pt(u, v),
        torus-pt(u-next, v),
        torus-pt(u-next, v-next),
        torus-pt(u, v-next),
      )
      let cx = (p1.at(0) + p2.at(0) + p3.at(0) + p4.at(0)) / 4
      let cy = (p1.at(1) + p2.at(1) + p3.at(1) + p4.at(1)) / 4
      let cz = (p1.at(2) + p2.at(2) + p3.at(2) + p4.at(2)) / 4
      quads.push((
        depth: weights.at(0) * cx + weights.at(1) * cy + weights.at(2) * cz,
        p1: p1,
        p2: p2,
        p3: p3,
        p4: p4,
      ))
    }
  }

  // x/y axes and the lower z-axis first, so the torus body occludes them.
  line((-axis-len, 0, 0), (axis-len, 0, 0), stroke: ax-stroke)
  line((0, axis-len, 0), (0, -axis-len, 0), stroke: ax-stroke)
  line((0, 0, -10), (0, 0, 0), stroke: ax-stroke)

  // Torus surface (painter's algorithm: far quads first).
  set-style(stroke: rgb("#9a9a9a") + 0.22pt, fill: rgb("#f0f0f0"))
  for quad in quads.sorted(key: q => -q.depth) {
    line(quad.p1, quad.p2, quad.p3, quad.p4, close: true)
  }

  // upper z-axis on top (its lower half is drawn earlier, behind the torus), then axis tips.
  line((0, 0, 0), (0, 0, 10), stroke: ax-stroke, mark: arrow, name: "z")
  content("z.end", $z$, anchor: "south", padding: 2pt)
  line(
    (outer-rim, 0, 0),
    (axis-len, 0, 0),
    stroke: ax-stroke,
    mark: arrow,
    name: "x",
  )
  content("x.end", $x$, anchor: "west", padding: 2pt)
  line(
    (0, -outer-rim, 0),
    (0, -axis-len, 0),
    stroke: ax-stroke,
    mark: arrow,
    name: "y",
  )
  content("y.end", $y$, anchor: "north-east", padding: 2pt)

  // R (blue): origin to tube center at far open slice.
  let v-end = v-max * 1deg
  let (rx, ry) = (major-r * calc.cos(v-end), major-r * calc.sin(v-end))
  line(
    (0, 0, 0),
    (rx, ry, 0),
    stroke: (paint: blue, thickness: rad-stroke),
    name: "R",
  )
  content("R.mid", text(fill: blue)[$R$], anchor: "south", padding: 2pt)

  // r (red): minor radius pointing diagonally upward.
  let stretch = 1 + minor-r * 0.5 / major-r
  line(
    (rx, ry, 0),
    (rx * stretch, ry * stretch, minor-r * 0.87),
    stroke: (paint: red, thickness: rad-stroke),
    name: "r",
  )
  content("r.mid", text(fill: red)[$r$], anchor: "south-east", padding: 2pt)
})
