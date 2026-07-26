// Shared design tokens, so diagrams read as one collection rather than 164 one-offs.

// For anything that is not the subject of the diagram: structure, annotation, and
// reference baselines like the roc-curve diagonal, which should recede.
#let neutral = (annotation: rgb("#4A5560"), hairline: rgb("#78828C"))

// Keeps the small labels in the dense timeline and matrix diagrams in step. Sized for
// those figures, not a collection-wide minimum: legibility depends on point size
// relative to the rendered figure, which varies far too much for one number to fit.
#let annotation-size = 9pt

// Textures and deliberately faint grouping boxes go thinner and are fine there.
#let line-weight = (hairline: 0.5pt, thin: 0.8pt)

// All six clear WCAG 1.4.11 (3:1 on white), ordered by separation under simulated
// deuteranopia and protanopia: the first four stay at least 67 apart in sRGB, enough to
// tell apart by hue alone. The fifth drops to 53 and the sixth (orange against red) to
// 15, so those two add a dash. Dashes cost legibility on crossing curves, so they start
// only where hue stops carrying the load.
#let _series = (
  (rgb("#0B5FA5"), none),
  (rgb("#C2570A"), none),
  (rgb("#12793F"), none),
  (rgb("#A81E7A"), none),
  (rgb("#7A3E9D"), "dashed"),
  (rgb("#C0182B"), "densely-dotted"),
)

#let series(idx, thickness: 1.5pt) = {
  let (paint, dash) = _series.at(calc.rem(idx, _series.len()))
  (paint: paint, dash: dash, thickness: thickness)
}
