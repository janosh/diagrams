#import "@preview/cetz:0.5.3": canvas, draw
#import draw: circle, content, line

#set page(width: auto, height: auto, margin: 8pt, fill: none)

// Lattice constants (Å) and twist angle
#let a-gr = 2.46 // graphene
#let a-bn = 2.504 // hexagonal boron nitride (1.8 % larger)
#let twist = 8deg
#let delta = a-bn / a-gr - 1
// moiré period for twist θ and mismatch δ
#let period = (
  (1 + delta) * a-gr / calc.sqrt(delta * delta + 2 * (1 + delta) * (1 - calc.cos(twist)))
)
#let radius = 2.7 * period / 2 // circular cut-out spans this many moiré periods

// drawing scale: the cut-out circle is 8.4 cm wide; strokes below are given in Å
#let unit = 4.2cm / radius

#let ink = rgb("#2b2f36")
#let col-b = rgb("#d12f80")
#let col-n = rgb("#2f6fd6")
#let col-glow = rgb("#f59f00")
#let w-bond = 0.45 // bond line width (Å)

#let rot(p, ang) = (
  p.at(0) * calc.cos(ang) - p.at(1) * calc.sin(ang),
  p.at(0) * calc.sin(ang) + p.at(1) * calc.cos(ang),
)
#let add(p, q) = (p.at(0) + q.at(0), p.at(1) + q.at(1))
#let norm2(p) = p.at(0) * p.at(0) + p.at(1) * p.at(1)
#let lattice(n, v1, m, v2) = (n * v1.at(0) + m * v2.at(0), n * v1.at(1) + m * v2.at(1))

// Honeycomb with hexagon centers on the triangular lattice n a1 + m a2 (so both layers have a
// hexagon center at the origin = AA stacking there). Returns its bonds as (A site, B site).
#let honeycomb(a, ang) = {
  let a1 = rot((a, 0), ang)
  let a2 = rot((a / 2, a * calc.sqrt(3) / 2), ang)
  let d-a = rot((a / 2, a / (2 * calc.sqrt(3))), ang)
  let d-b = rot((0, a / calc.sqrt(3)), ang)
  let n-max = calc.ceil(1.2 * radius / a) + 2
  let cell(n, m) = lattice(n, a1, m, a2)
  let bonds = ()
  for n in range(-n-max, n-max + 1) {
    for m in range(-n-max, n-max + 1) {
      let c = cell(n, m)
      if norm2(c) > calc.pow(radius + 2 * a, 2) { continue }
      for nb in (c, cell(n + 1, m), cell(n + 1, m - 1)) {
        bonds.push((add(c, d-a), add(nb, d-b)))
      }
    }
  }
  bonds
}

// Clip segment p→q to the disk of the given radius; none if outside.
#let clip(p, q) = {
  let d = (q.at(0) - p.at(0), q.at(1) - p.at(1))
  let aa = norm2(d)
  let bb = 2 * (p.at(0) * d.at(0) + p.at(1) * d.at(1))
  let cc = norm2(p) - radius * radius
  let disc = bb * bb - 4 * aa * cc
  if disc <= 0 { return none }
  let t0 = calc.max(0, (-bb - calc.sqrt(disc)) / (2 * aa))
  let t1 = calc.min(1, (-bb + calc.sqrt(disc)) / (2 * aa))
  if t0 >= t1 { return none }
  (
    (p.at(0) + t0 * d.at(0), p.at(1) + t0 * d.at(1)),
    (p.at(0) + t1 * d.at(0), p.at(1) + t1 * d.at(1)),
  )
}

// Moiré superlattice: AA points satisfy (A_bn^-1 - A_gr^-1) r ∈ Z², so the moiré lattice
// vectors are K e_i with K = (1/a_bn - R(-θ)/a_gr)^-1. Their length is
// λ = (1 + δ) a_gr / sqrt(δ² + 2 (1 + δ)(1 - cos θ)) with δ = a_bn / a_gr - 1 .
#let moire-vec(e) = {
  let (c, s) = (calc.cos(twist), calc.sin(twist))
  // M = 1/a_bn I - R(-θ)/a_gr, with R(-θ) = ((c, s), (-s, c))
  let (m11, m12, m21, m22) = (1 / a-bn - c / a-gr, -s / a-gr, s / a-gr, 1 / a-bn - c / a-gr)
  let det = m11 * m22 - m12 * m21
  ((m22 * e.at(0) - m12 * e.at(1)) / det, (-m21 * e.at(0) + m11 * e.at(1)) / det)
}

// rotate the whole figure (both layers) so that one moiré lattice vector points along +x
#let frame = -calc.atan2(..moire-vec((1, 0)))
#let m1 = rot(moire-vec((1, 0)), frame)
#let m2 = rot(moire-vec((0.5, calc.sqrt(3) / 2)), frame)
#assert(calc.abs(calc.norm(..m1) - period) < 1e-9 and calc.abs(m1.at(1)) < 1e-9)

#canvas(length: unit, {
  // bond segment clipped to the cut-out disk
  let bond(p, q, col) = {
    let s = clip(p, q)
    if s != none { line(..s, stroke: (paint: col, thickness: w-bond * unit, cap: "round")) }
  }

  // soft highlight on the AA-stacked moiré spots (lattice n m1 + m m2)
  let r-glow = 0.34 * period
  let glows = range(-3, 4).map(n => range(-3, 4).map(m => lattice(n, m1, m, m2))).join()
  let glows = glows.filter(c => calc.norm(..c) + r-glow < radius)
  assert(glows.len() == 7, message: "cut-out should frame the central AA spot and its 6 neighbors")
  for c in glows {
    circle(c, radius: r-glow, stroke: none, fill: gradient.radial(
      (col-glow.transparentize(25%), 0%),
      (col-glow.transparentize(70%), 55%),
      (col-glow.transparentize(100%), 100%),
    ))
  }
  // hBN layer: each bond split into a B half (pink) and an N half (blue)
  for (p-b, p-n) in honeycomb(a-bn, frame) {
    let mid = ((p-b.at(0) + p-n.at(0)) / 2, (p-b.at(1) + p-n.at(1)) / 2)
    bond(p-b, mid, col-b)
    bond(mid, p-n, col-n)
  }
  // graphene layer on top: dark bonds
  for (p, q) in honeycomb(a-gr, twist + frame) { bond(p, q, ink) }
  circle((0, 0), radius: radius, stroke: ink + 1.6pt)

  // dimension line for the moiré period: extension lines from the two lower AA spot centers
  // down to a dimension line just below the circle
  let (xl, xr, y-aa) = (-m1.at(0) / 2, m1.at(0) / 2, -m2.at(1))
  let y-dim = -radius - 0.09 * radius
  for x in (xl, xr) {
    circle((x, y-aa), radius: 0.025 * radius, fill: ink, stroke: none)
    line((x, y-aa), (x, y-dim - 0.05 * radius), stroke: (
      paint: ink,
      thickness: 1pt,
      dash: (2pt, 1.5pt),
    ))
  }
  line((xl, y-dim), (xr, y-dim), stroke: ink + 1.4pt, mark: (
    start: "stealth",
    end: "stealth",
    fill: ink,
    scale: 0.8,
  ))
  content((xr + 0.05 * radius, y-dim), anchor: "west", text(20pt, fill: ink)[$lambda$])

  // legend: single column right of the circle, level with its lower edge
  for (k, (name, col)) in (("C", ink), ("B", col-b), ("N", col-n)).enumerate() {
    let p = (radius * 1.02, -radius * (0.62 + 0.17 * k))
    circle(p, radius: 0.045 * radius, fill: col, stroke: none)
    content((p.at(0) + 0.075 * radius, p.at(1)), anchor: "west", text(17pt, fill: ink, name))
  }
})
