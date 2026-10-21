#import "@preview/cetz:0.5.3": canvas, draw
#import draw: content, line, rect

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 11pt)

// B-DNA to scale in nm: 2 nm diameter, 0.34 nm rise and 10 base pairs per 3.4 nm turn.
#let (radius, rise, pitch) = (1, 0.34, 3.4)
// The second backbone trails by 3/8 of a turn, opening a narrow minor and a wide major groove.
#let groove-offset = 0.375
#let sequence = "ATGCGATTACAGGCTTACGATCGGATCCTAG"
#let complement = (A: "T", T: "A", G: "C", C: "G")
#let base-colors = (A: rgb("#e76f51"), T: rgb("#e9c46a"), G: rgb("#2a9d8f"), C: rgb("#457b9d"))
#let strand-colors = (rgb("#264653"), rgb("#6d597a"))
// Secondary annotations: groove labels and dimension lines.
#let muted = luma(85)
#let helix-length = sequence.len() * rise

// Projected height and depth (positive = towards the viewer) of a backbone at axis position x.
#let backbone(x, strand) = {
  let angle = 2 * calc.pi * (x / pitch - strand * groove-offset)
  (radius * calc.cos(angle), radius * calc.sin(angle))
}
// Base-pair midpoints are never more than this far in front of or behind the axis.
#let max-rung-depth = radius * calc.cos(groove-offset * calc.pi)

#canvas(length: 1.3cm, {
  // Split each backbone into runs on the near and far side so base pairs can sit between them.
  let runs = (back: (), front: ())
  for strand in (0, 1) {
    let (points, side) = ((), none)
    for idx in range(401) {
      let x = helix-length * idx / 400
      let (y, depth) = backbone(x, strand)
      let now = if depth < 0 { "back" } else { "front" }
      if side != none and now != side {
        // end the old run where the new one starts so the backbone stays continuous
        runs.at(side).push((strand, points + ((x, y),)))
        points = ()
      }
      side = now
      points.push((x, y))
    }
    runs.at(side).push((strand, points))
  }
  // Far-side geometry fades towards the background as a depth cue.
  let draw-runs(side, fade) = for (strand, points) in runs.at(side) {
    let paint = strand-colors.at(strand).lighten(fade)
    line(..points, stroke: (paint: paint, thickness: 5pt, cap: "round", join: "round"))
  }

  draw-runs("back", 48%)
  // Base pairs between the far and near backbones, each half colored by its base with a
  // hydrogen-bond gap in the middle. Rungs sit at distinct x, so they never occlude each other.
  for (idx, base) in sequence.clusters().enumerate() {
    let x = (idx + 0.5) * rise
    let ((top, top-depth), (bottom, bottom-depth)) = (backbone(x, 0), backbone(x, 1))
    let (middle, depth) = ((top + bottom) / 2, (top-depth + bottom-depth) / 2)
    for (y, letter) in ((top, base), (bottom, complement.at(base))) {
      let paint = base-colors.at(letter).lighten(30% * (1 - depth / max-rung-depth))
      line((x, y), (x, y + 0.9 * (middle - y)), stroke: paint + 3.5pt)
    }
  }
  draw-runs("front", 0%)

  // With the sugars on the minor-groove side, each strand's partner leads it by 3/8 turn about
  // its own 5′→3′ direction. Strand 0 leads strand 1 about +x, so strand 1 runs 5′→3′ rightwards.
  for (strand, (start, end)) in ((0, ([3′], [5′])), (1, ([5′], [3′]))) {
    for (x, label, anchor, shift) in ((0, start, "east", -0.2), (helix-length, end, "west", 0.2)) {
      let (y, _) = backbone(x, strand)
      content(
        (x + shift, y),
        text(fill: strand-colors.at(strand), weight: "bold", label),
        anchor: anchor,
      )
    }
  }

  // Strand peaks sit at x/pitch = k (first) and k + 3/8 (second); the backbones cross halfway
  // between, at the bottom of the narrow and wide notches the grooves cut into the silhouette.
  for (label, turn-fraction) in (([minor groove], 1.1875), ([major groove], 2.6875)) {
    let x = turn-fraction * pitch
    line((x, 0.75 * radius), (x, radius + 0.45), stroke: gray + 0.6pt, name: "tick")
    content((rel: (0, 0.05), to: "tick.end"), text(fill: muted, label), anchor: "south")
  }

  let dimension = (stroke: muted + 0.8pt, mark: (start: "|", end: "|", scale: 0.8))
  let dimension-y = -radius - 0.45
  line((pitch, dimension-y), (2 * pitch, dimension-y), ..dimension, name: "turn")
  let turn-label = [one turn: #pitch nm, #calc.round(pitch / rise) base pairs]
  content((rel: (0, -0.12), to: "turn.mid"), turn-label, anchor: "north")
  let dimension-x = helix-length + 1
  line((dimension-x, -radius), (dimension-x, radius), ..dimension, name: "diameter")
  content((rel: (0.15, 0), to: "diameter.mid"), [#(2 * radius) nm], anchor: "west")

  // Key: the two Watson-Crick pairs.
  let key-y = dimension-y - 0.95
  let names = (A: "adenine", T: "thymine", G: "guanine", C: "cytosine")
  for (idx, (left, right)) in (("A", "T"), ("G", "C")).enumerate() {
    let x = helix-length / 2 - 4.2 + idx * 4.6
    // A darker outline keeps pale swatches (T) visible on both page themes.
    for (offset, base) in ((0, left), (0.32, right)) {
      let fill = base-colors.at(base)
      rect(
        (x + offset, key-y - 0.1),
        (rel: (0.3, 0.2)),
        fill: fill,
        stroke: fill.darken(35%) + 0.6pt,
      )
    }
    content(
      (x + 0.75, key-y),
      [*#left*–*#right* #h(2pt) #names.at(left)–#names.at(right)],
      anchor: "west",
    )
  }
})
