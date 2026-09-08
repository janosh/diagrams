#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, line, rect
#set page(width: 660pt, height: auto, margin: 20pt, fill: none)
#set text(font: "Avenir Next", size: 10.5pt, fill: rgb("#19324f"))
#set par(leading: 0.55em)
#let panel = block.with(
  width: 100%,
  inset: 12pt,
  radius: 7pt,
  fill: rgb("#cdd3da"),
  breakable: false,
)

#let samples = (
  (4.7, 0.1),
  (5.2, 0.1),
  (5.1, -.3),
  (5.6, -.33),
  (5.4, -.7),
  (5.8, -.9),
  (5.9, -1.3),
  (6.4, -1.2),
  (6.9, -1.1),
  (7.4, -1.3),
  (7.45, -1.7),
  (7.8, -1.5),
  (8.2, -1.4),
  (8.3, -1.0),
  (8.6, -1.3),
  (6.1, .8),
  (5.7, .9),
  (5.8, 1.3),
  (5.4, 1.15),
  (5, 1.2),
  (4.8, 1.5),
  (4.3, 1.6),
  (4.2, 1.2),
  (3.8, 1.3),
  (3.4, 1.3),
  (3.4, .8),
  (3.1, 1.1),
  (2.75, .7),
  (2.45, .1),
  (2.35, .45),
  (1.9, -.04),
  (1.85, -.5),
)

#let labeled_samples = (((4.5, .5), red), ((6.5, .5), blue))
#let example(use_unlabeled: false) = canvas(length: 30pt, {
  // Shared bounds keep the same samples aligned in both panels.
  rect((1.2, -2.2), (9.2, 2.2), stroke: none)
  let gray_dot = rgb("#7c858e")
  if use_unlabeled {
    line(
      (1.5, -1),
      (2, -.866),
      (2.5, -.5),
      (3, 0),
      (3.5, .5),
      (4, .866),
      (4.5, 1),
      (5, .866),
      (5.5, .5),
      (6, 0),
      (6.5, -.5),
      (7, -.866),
      (7.5, -1),
      (8, -.866),
      (8.5, -.5),
      (9, 0),
      stroke: (paint: rgb("#19324f"), dash: "dashed", thickness: 1.4pt),
    )
  } else {
    line((5.5, 2), (5.5, -2), stroke: (paint: rgb("#19324f"), dash: "dashed", thickness: 1.4pt))
  }
  for point in samples { circle(point, radius: .15, fill: gray_dot, stroke: none) }
  for (point, color) in labeled_samples { circle(point, radius: .16, fill: color, stroke: none) }
})
#grid(
  columns: (1fr, 1fr),
  gutter: 12pt,
  ..(
    ([1  Labeled data only], false, [Gray samples ignored.]),
    ([2  Include unlabeled data], true, [Boundary follows the low-density gap.]),
  ).map(((title, use_unlabeled, caption)) => panel[
    #text(size: 14pt, weight: "bold", title)
    #v(10pt)
    #align(center, example(use_unlabeled: use_unlabeled))
    #v(8pt)
    #align(center, caption)
  ]),
)
#v(12pt)
#block(
  width: 100%,
  inset: 10pt,
  radius: 5pt,
  fill: rgb("#c6d8d2"),
  breakable: false,
)[Red / blue: labeled · Gray: unlabeled · Dashed: boundary\ Assumption: connected clusters tend to share a class.]
