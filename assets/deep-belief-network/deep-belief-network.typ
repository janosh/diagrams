#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, line, rect
#set page(width: 540pt, height: auto, margin: 20pt, fill: none)
#set text(font: "Avenir Next", size: 14pt, fill: rgb("#19324f"))
#set par(leading: 0.55em)
#show math.equation: set text(size: 14pt)

// Hinton et al. (2006): https://www.cs.toronto.edu/~hinton/absps/fastnc.pdf
#align(center)[#canvas(length: 1pt, {
  rect((-26, 28), (166, -108), radius: 8pt, fill: rgb("#cdd3da"), stroke: none)
  // Nine undirected edges in the top RBM, nine downward generative edges below it.
  for upper in range(3) {
    for lower in range(3) {
      line((upper * 70, -13), (lower * 70, -67), stroke: rgb("#60768c") + 0.8pt)
      line((upper * 70, -93), (lower * 70, -167), stroke: rgb("#0b5fa5") + 0.8pt, mark: (
        end: "stealth",
        scale: 0.55,
      ))
    }
  }
  for (height, label, fill) in (
    (0, $h_2$, rgb("#b9c7d9")),
    (-80, $h_1$, rgb("#b9c7d9")),
    (-180, $x$, rgb("#c6d8d2")),
  ) {
    content((-44, height), label)
    for idx in range(3) {
      circle((idx * 70, height), radius: 13, fill: fill, stroke: rgb("#19324f") + 0.9pt)
    }
  }
  for (height, title, body) in (
    (-35, [Undirected top pair], [RBM prior: $p(h_1,h_2)$]),
    (-155, [Downward generation], [Conditional model: $p(x | h_1)$]),
  ) {
    content(
      (205, height),
      block(width: 225pt)[#text(size: 16pt, weight: "bold", title) #v(6pt) #body],
      anchor: "west",
      padding: 0pt,
    )
  }
})]
#v(12pt)
#align(center, block(
  inset: (x: 12pt, y: 8pt),
  radius: 5pt,
  fill: rgb("#cdd3da").transparentize(65%),
  breakable: false,
)[
  $p(x,h_1,h_2) = p(h_1,h_2) p(x | h_1)$
])
