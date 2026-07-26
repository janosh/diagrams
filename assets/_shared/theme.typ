// Shared design tokens so diagrams look like one collection rather than 164 one-offs.
//
// The series hues clear WCAG 1.4.11 (3:1 against white for graphical objects). Hue alone
// stops separating reliably past about four series under red-green color vision
// deficiency, so `series()` pairs each hue with a dash pattern; that also survives
// grayscale printing.

// Neutrals carry structure and annotation, never a data series.
#let neutral = (annotation: rgb("#4A5560"), hairline: rgb("#78828C"))

// Type scale in pt, for keeping tiers consistent across diagrams. It is not a
// legibility guarantee: what a reader can actually make out depends on point size
// relative to the figure, since the gallery scales every figure to the same card
// width. periodic-table's 13pt shrinks to ~1.1pt in a card while multilayer-perceptron's
// 7pt survives at ~2.6pt, so a flat floor would flag the wrong diagrams. Dense
// annotation layers may legitimately sit below `caption`; raising them can collide.
#let size = (caption: 9pt, label: 11pt, heading: 14pt, title: 18pt)

// Stroke weights. `hairline` is the floor for anything meant to be seen.
#let line-weight = (hairline: 0.5pt, thin: 0.8pt, normal: 1.2pt, heavy: 2pt)

// Ordered so the leading hues stay far apart under simulated deuteranopia and
// protanopia: the first four are separated by at least 67 in sRGB, which is enough to
// tell them apart by hue alone. The fifth drops to 53 and the sixth (orange against
// red) to 15, so those two take a dash pattern as a second cue. Dashes cost real
// legibility on crossing curves, so they start only where hue stops carrying the load.
#let _series = (
  (rgb("#0B5FA5"), none),
  (rgb("#C2570A"), none),
  (rgb("#12793F"), none),
  (rgb("#A81E7A"), none),
  (rgb("#7A3E9D"), "dashed"),
  (rgb("#C0182B"), "densely-dotted"),
)

// Stroke for the `idx`-th curve of a multi-series plot.
#let series(idx, thickness: 1.5pt) = {
  let (paint, dash) = _series.at(calc.rem(idx, _series.len()))
  (paint: paint, dash: dash, thickness: thickness)
}
