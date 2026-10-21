#import "@preview/cetz:0.5.3": canvas, draw
#import draw: circle, content, line, rect

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 12pt)

// Close-packed layers sit on one of three lateral positions A, B, C.
#let site-names = ("A", "B", "C")
#let site-colors = (rgb("#4c72b0"), rgb("#dd8452"), rgb("#55a868"))
#let hcp-fill = rgb("#d9d0ec")
// Secondary text stays dark enough that the site's dark-mode inversion turns it light gray.
#let muted = rgb("#404040")

// Each stacking step either advances A→B→C→A (△) or reverses it (▽), Frank's notation.
// Perfect fcc is all Δ; an intrinsic fault (a removed layer) flips one step, an extrinsic
// fault (an inserted layer) flips two in a row, and a twin boundary flips every step above it.
#let stackings = (
  ([perfect fcc], [ABC repeats], (1, 1, 1, 1, 1, 1, 1, 1)),
  ([intrinsic fault], [one layer removed], (1, 1, 1, -1, 1, 1, 1, 1)),
  ([extrinsic fault], [one layer inserted], (1, 1, 1, -1, -1, 1, 1, 1)),
  ([twin boundary], [mirror plane], (1, 1, 1, 1, -1, -1, -1, -1)),
)
#let (advance, reverse) = (sym.triangle.stroked.t, sym.triangle.stroked.b)
// Lateral shift of every layer in thirds of the atom spacing, bottom to top; its remainder
// mod 3 is the layer's site A, B or C.
#let layer-shifts(steps) = steps.fold((0,), (shifts, step) => shifts + (shifts.last() + step,))
// A layer whose neighbors above and below share a site (ABA) is locally hcp.
#let hcp-like(sites) = range(1, sites.len() - 1).filter(idx => (
  sites.at(idx - 1) == sites.at(idx + 1)
))

// Flat discs with a darker rim: a lit-sphere highlight would invert into a dark pit under the
// site's dark-mode filter.
#let atom(pos, radius, fill) = circle(
  pos,
  radius: radius,
  fill: fill,
  stroke: fill.darken(35%) + 0.8pt,
)

#canvas({
  // === Top view: one close-packed A layer and the two kinds of hollow above it ===
  let polar(angle, dist) = (dist * calc.cos(angle), dist * calc.sin(angle))
  for pos in ((0, 0),) + range(6).map(idx => polar(idx * 60deg, 1)) {
    atom(pos, 0.5, site-colors.at(0))
  }
  // Hollows alternate between B and C around every atom; the next layer fills one kind.
  for idx in range(6) {
    let site = 1 + calc.rem(idx, 2)
    let pos = polar(30deg + idx * 60deg, 1 / calc.sqrt(3))
    circle(pos, radius: 0.19, fill: site-colors.at(site).darken(30%), stroke: white + 0.8pt)
    content(pos, text(fill: white, weight: "bold", size: 7pt, site-names.at(site)))
  }
  content((0, 0), text(fill: white, weight: "bold", [A]))
  content((0, -1.75), align(center)[close-packed layer A \ with B and C hollows], anchor: "north")

  // === Side views: each stacking seen edge-on, layers shifted by their site ===
  let (layer-gap, atom-gap, column-gap, radius) = (0.62, 0.78, 4.3, 0.21)
  let atoms-per-layer = 4
  let width = (atoms-per-layer - 1 + 2 / 3) * atom-gap
  // hcp bands span from the row letters to past the step marks
  let (origin, band-left, band-right) = (3.2, -0.7, width + 0.4)
  let layer-y(idx) = idx * layer-gap - 2.2
  for (column-idx, (title, subtitle, steps)) in stackings.enumerate() {
    let shifts = layer-shifts(steps)
    let sites = shifts.map(shift => calc.rem-euclid(shift, 3))
    let left = origin + column-idx * column-gap

    for idx in hcp-like(sites) {
      let y = layer-y(idx)
      rect(
        (left + band-left, y - layer-gap / 2),
        (left + band-right, y + layer-gap / 2),
        fill: hcp-fill,
        stroke: none,
      )
    }
    // Following one atom up the stack: fcc climbs a straight slope, each fault kinks it.
    line(
      ..shifts.enumerate().map(((idx, shift)) => (left + shift / 3 * atom-gap, layer-y(idx))),
      stroke: (paint: rgb("#6b6b6b"), thickness: 2.5pt, cap: "round", join: "round"),
    )
    for (idx, site) in sites.enumerate() {
      let y = layer-y(idx)
      for atom-idx in range(atoms-per-layer) {
        atom((left + (atom-idx + site / 3) * atom-gap, y), radius, site-colors.at(site))
      }
      content((left - 0.5, y), text(
        fill: site-colors.at(site).darken(45%),
        weight: "bold",
        site-names.at(site),
      ))
    }
    for (idx, step) in steps.enumerate() {
      let symbol = if step > 0 { advance } else { reverse }
      content((left + width + 0.22, layer-y(idx + 0.5)), text(fill: muted, symbol))
    }
    let title-y = layer-y(sites.len() - 1) + 0.4
    content(
      (left + width / 2, title-y),
      align(center)[*#title* \ #text(size: 10pt, fill: muted, subtitle)],
      anchor: "south",
    )
  }

  // === Legend ===
  let legend-y = layer-y(0) - 0.65
  // An inline swatch sits on the text baseline, so it lines up with the label like a glyph.
  let swatch = box(width: 1.4em, height: 0.75em, fill: hcp-fill)
  content(
    (origin + band-left, legend-y),
    [#swatch #h(0.3em) locally hcp layer (same site above and below)],
    anchor: "west",
  )
  let frank = [#advance step A→B→C→A #h(0.8em) #reverse reversed step]
  content((origin + 3 * column-gap + band-right, legend-y), frank, anchor: "east")
})
