// Shared building blocks for the functional-RG diagram assets: hatched (dressed)
// vertices, regulator insertions and momentum decorations around a loop.

#import "@preview/cetz:0.5.2": draw
#import draw: circle, content, mark

// Diagonal hatching marking a vertex as dressed rather than bare.
#let hatched = tiling(size: (.1cm, .1cm))[
  #place(rect(width: 100%, height: 100%, fill: white, stroke: none))
  #place(line(start: (0%, 100%), end: (100%, 0%), stroke: 0.4pt))
]

#let momentum-arrow = (
  mark: (end: "stealth", fill: black, scale: .5),
  stroke: (thickness: 0.75pt),
)
// Hairline tying an off-diagram label to the vertex it names.
#let callout = (stroke: gray + 0.3pt)

// `rel-label: none` puts the label on top of `pos` instead of offset from it.
#let _label-at(pos, rel-label) = if rel-label == none { pos } else {
  (rel: rel-label, to: pos)
}

#let dressed-vertex(
  pos,
  label: none,
  rel-label: none,
  name: none,
  radius: 0.2,
  stroke: 0.5pt,
  ..rest,
) = {
  circle(pos, radius: radius, fill: hatched, name: name, stroke: stroke)
  if label != none { content(_label-at(pos, rel-label), $#label$, ..rest) }
}

// Regulator insertion: a circled cross knocked out of whatever it sits on.
#let cross(
  pos,
  label: none,
  rel-label: none,
  name: none,
  baseline: 0pt,
  padding: -2.5pt,
  ..rest,
) = {
  content(
    pos,
    text(size: 16pt, baseline: baseline)[$times.o$],
    stroke: none,
    fill: white,
    frame: "circle",
    padding: padding,
    name: name,
  )
  if label != none { content(_label-at(pos, rel-label), $#label$, ..rest) }
}

// Momentum labels p_i and orientation arrowheads spaced around a loop circle.
// `momenta` pairs each index with its fraction of the way around the loop, and
// `label-distance` is how far inside the rim the labels sit. Extra named arguments
// override the arrowhead style (`symbol`, `angle`, `fill`, ...).
#let loop-momenta(momenta, loop: "loop", label-distance: 0.75, span: 1deg, ..mark-style) = {
  for (idx, fraction) in momenta {
    let turn = fraction * 360deg
    // trail the label a few degrees behind its arrowhead
    let lag = turn - 3deg
    let offset = (label-distance * calc.cos(lag), label-distance * calc.sin(lag))
    content((rel: offset, to: loop), $p_#idx$, size: 8pt)
    mark(
      (name: loop, anchor: turn),
      (name: loop, anchor: turn + span),
      symbol: "stealth",
      width: .25,
      length: .15,
      stroke: .7pt,
      scale: .7,
      angle: 60deg,
      fill: black,
      ..mark-style,
    )
  }
}
