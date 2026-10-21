#import "@preview/cetz:0.5.3": canvas, draw
#import draw: circle, content, line, rect

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 16pt)

// One-loop SM running: α_i⁻¹(μ) = α_i⁻¹(M_Z) − b_i/(2π) ln(μ/M_Z)
// α⁻¹(M_Z) from PDG: α̂⁻¹(M_Z) = 127.95, ŝ²_Z = 0.2312, α_s(M_Z) = 0.1180
#let alpha-inv = (59.0, 29.6, 8.47) // U(1)_Y (GUT normalized), SU(2)_L, SU(3)_c
#let b = (41 / 10, -19 / 6, -7)
#let colors = (rgb("#1f6fb4"), rgb("#2a9d48"), rgb("#d0342c"))
#let log-mz = calc.log(91.19, base: 10)

#let (x-min, x-max) = (1.5, 19)
#let (y-min, y-max) = (0, 62)
#let (width, height) = (8, 7.6)
#let px(x) = (x - x-min) / (x-max - x-min) * width
#let py(y) = (y - y-min) / (y-max - y-min) * height
#let coupling(i, log-mu) = (
  alpha-inv.at(i) - b.at(i) / (2 * calc.pi) * (log-mu - log-mz) * calc.ln(10)
)

// pairwise crossings in log10(μ/GeV)
#let crossing(i, j) = {
  let log-mu = (
    log-mz + (alpha-inv.at(i) - alpha-inv.at(j)) * 2 * calc.pi / ((b.at(i) - b.at(j)) * calc.ln(10))
  )
  (log-mu, coupling(i, log-mu))
}
#let crossings = ((0, 1), (0, 2), (1, 2)).map(((i, j)) => crossing(i, j))

#canvas({
  let axis-stroke = 1.2pt + black
  let guide = (paint: rgb("#7a8591"), thickness: 1pt, dash: "dashed")

  // near-miss of unification: soft ellipse around the three pairwise crossings
  let (xs, ys) = (crossings.map(c => px(c.at(0))), crossings.map(c => py(c.at(1))))
  let (x0, x1, y0, y1) = (calc.min(..xs), calc.max(..xs), calc.min(..ys), calc.max(..ys))
  circle(
    ((x0 + x1) / 2, (y0 + y1) / 2),
    radius: ((x1 - x0) / 2 + 0.45, (y1 - y0) / 2 + 0.45),
    fill: rgb("#cdd3da"),
    stroke: guide,
  )

  // M_Z marker
  line((px(log-mz), 0), (px(log-mz), height), stroke: guide)
  content((px(log-mz), -0.12), $M_Z$, anchor: "north")

  // coupling lines
  for i in range(3) {
    line(
      (px(log-mz), py(coupling(i, log-mz))),
      (px(x-max), py(coupling(i, x-max))),
      stroke: (paint: colors.at(i), thickness: 3pt, cap: "round"),
    )
  }
  for (x, y) in crossings {
    circle((px(x), py(y)), radius: 0.09, fill: black, stroke: none)
  }

  // line labels
  for (i, label-x, anchor) in ((0, 6, "north-east"), (1, 6, "south"), (2, 5.5, "south-east")) {
    content(
      (px(label-x), py(coupling(i, label-x))),
      text(fill: colors.at(i), size: 20pt, $alpha_#(i + 1)^(-1)$),
      anchor: anchor,
      padding: 0.2,
    )
  }

  // axes
  rect((0, 0), (width, height), stroke: axis-stroke)
  for x in (5, 10, 15) {
    line((px(x), 0), (px(x), 0.15), stroke: axis-stroke)
    content((px(x), -0.12), $10^#x$, anchor: "north")
  }
  for y in (0, 20, 40, 60) {
    line((0, py(y)), (0.15, py(y)), stroke: axis-stroke)
    content((-0.12, py(y)), str(y), anchor: "east")
  }
  content((width / 2, -0.85), [$mu$ (GeV)], anchor: "north")
  content((-1.0, height / 2), $alpha^(-1)$, anchor: "south", angle: 90deg)
})
