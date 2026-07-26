// Shared design tokens so diagrams look like one collection rather than 164 one-offs.
//
// The series hues clear WCAG 1.4.11 (3:1 against white for graphical objects). Hue alone
// stops separating reliably past about four series under red-green color vision
// deficiency, so `series()` pairs each hue with a dash pattern; that also survives
// grayscale printing.

// Neutrals carry structure and annotation, never a data series.
#let neutral = (annotation: rgb("#4A5560"), hairline: rgb("#78828C"))

// Type scale in pt. Nothing below `caption` should reach the page: at the sizes these
// diagrams render, smaller than this is unreadable in the gallery grid.
#let size = (caption: 9pt, label: 11pt, heading: 14pt, title: 18pt)

// Stroke weights. `hairline` is the floor for anything meant to be seen.
#let line-weight = (hairline: 0.5pt, thin: 0.8pt, normal: 1.2pt, heavy: 2pt)

// Ordered so the two closest hues under CVD (orange and red) sit far apart, and so the
// first four are separable by hue alone before the dashes have to do the work.
#let _series = (
  (rgb("#0B5FA5"), none),
  (rgb("#C2570A"), "dashed"),
  (rgb("#12793F"), "dotted"),
  (rgb("#7A3E9D"), "dash-dotted"),
  (rgb("#A81E7A"), "loosely-dashed"),
  (rgb("#C0182B"), "densely-dotted"),
)

// Stroke for the `idx`-th curve of a multi-series plot.
#let series(idx, thickness: 1.5pt) = {
  let (paint, dash) = _series.at(calc.rem(idx, _series.len()))
  (paint: paint, dash: dash, thickness: thickness)
}
