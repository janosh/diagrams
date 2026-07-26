// Shared cetz-plot axis styling: arrow-tipped axes with the y-label tucked above the
// tip and the x-label just inside the right end.

#import "@preview/cetz:0.5.2": draw

#let stealth = (end: "stealth", fill: black)

// One legend look for every plot: hairline box, consistent padding and item spacing.
// Pair it with a named `legend:` anchor rather than hardcoded coordinates, which drift
// as soon as the data range changes.
#let legend-box = (item: (spacing: 0.15), padding: 0.15, stroke: 0.5pt)

// Pass `none` for a label or the mark to fall back to cetz-plot's own default.
#let style-axes(
  x-label: (anchor: "south-east", offset: -0.2),
  y-label: (anchor: "north-west", offset: -0.2),
  mark: stealth,
) = {
  let axis(label) = {
    let style = (:)
    if label != none { style.label = label }
    if mark != none { style.mark = mark }
    style
  }
  draw.set-style(axes: (x: axis(x-label), y: axis(y-label)))
}
