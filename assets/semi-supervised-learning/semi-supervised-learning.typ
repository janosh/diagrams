#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, line

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#canvas({
  let dot(pos, fill) = circle(pos, radius: .15, fill: fill, stroke: none)
  let gray-dot = gray.darken(10%)

  line((5.5, 2), (5.5, -2), stroke: (paint: gray.lighten(35%), dash: "dashed", thickness: 1.4pt))
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
    stroke: (paint: black, dash: "dashed", thickness: 1.4pt),
  )

  for point in (
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
  ) { dot(point, gray-dot) }

  dot((4.5, .5), red)
  dot((6.5, .5), blue)
})
