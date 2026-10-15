#import "@preview/cetz:0.5.2": canvas, draw, matrix
#import draw: content, scale, set-transform
#let label-size = 12pt
#let paragraph-size = 14pt
#let heading-size = 16pt

#let card_body(title, body, caption) = block(
  width: 100%,
  inset: 12pt,
  radius: 8pt,
  fill: rgb("#cdd3da"),
  breakable: false,
)[
  #text(size: heading-size, weight: "bold", title)
  #v(8pt)
  // Measure unconstrained artwork before scaling, including content wider than its card.
  #layout(size => {
    let artwork = text(size: label-size, body)
    std.scale(size.width / measure(artwork).width * 100%, reflow: true, artwork)
  })
  #v(7pt)
  #text(size: paragraph-size, caption)
]

#let card-grid(columns: 2, ..cards) = layout(size => {
  let rows = cards
    .pos()
    .chunks(columns)
    .map(row => {
      let ratios = row.map(card => {
        let bounds = measure(text(size: label-size, card.at(1)))
        bounds.width / bounds.height
      })
      let available = size.width - 12pt * (row.len() - 1) - 24pt * row.len()
      grid(
        columns: ratios.map(ratio => 24pt + available * ratio / ratios.sum()),
        gutter: 12pt,
        ..row.map(args => card_body(..args)),
      )
    })
  stack(dir: ttb, spacing: 12pt, ..rows)
})

#let takeaway(body) = block(
  width: 100%,
  inset: 12pt,
  radius: 6pt,
  fill: rgb("#c6d8d2"),
  breakable: false,
  text(size: paragraph-size, body),
)

#set page(width: 780pt, height: auto, margin: 22pt, fill: none)
#set text(font: "Avenir Next", size: paragraph-size, fill: rgb("#19324f"))
#set par(leading: 0.55em)

// === 1  Locate the quadrant ===
#let figure-0 = canvas(length: 1.2cm, {
  let (half-size, gap) = (4, 0.15) // quadrant extent, gap between squares
  for (start, tip, label, offset) in (
    ((-half-size, 0), (half-size + 0.3, 0), $"Re"(p_0)$, (.4, .2)),
    ((0, -half-size), (0, half-size + 0.3), $"Im"(p_0)$, (.7, 0)),
  ) {
    draw.line(start, tip, mark: (end: "stealth", fill: black))
    draw.content((rel: offset, to: tip), label)
  }
  for (s1, s2, color) in (
    (1, 1, rgb("#ffa500")),
    (-1, 1, rgb("#add8e6")),
    (1, -1, rgb("#add8e6")),
    (-1, -1, rgb("#ffa500")),
  ) {
    draw.rect(
      (gap * s1, gap * s2),
      (s1 * half-size, s2 * half-size),
      fill: color.lighten(80%),
      stroke: color.darken(40%),
    )
    draw.content((half-size / 2 * s1, half-size / 2 * s2), $s(p_0) = #calc.quo(s1, s2)$)
  }
})

// === 2  Lift the value to a height ===
#let figure-1 = canvas(length: 3cm, {
  draw.set-style(line: (stroke: none))
  // Oblique 3D view of the (Re, Im, s) axes
  set-transform(matrix.transform-rotate-dir((1, 1, -2), (0, 2, .3)))
  scale(x: 1.5)
  let arrow-style = (mark: (end: "stealth", fill: black, scale: 0.5))
  let guide = gray + .3pt

  // Vertical guides at the corners and the s axis through the origin
  for (x, y) in ((-1, -1), (1, -1), (-1, 1), (1, 1)) {
    draw.line((x, y, -1.2), (x, y, 1.2), stroke: guide)
  }
  draw.line((0, 0, -1.2), (0, 0, 1.2), stroke: guide, ..arrow-style)

  // Semi-transparent zero plane
  draw.rect((-1, -1, 0), (1, 1, 0), fill: rgb(128, 128, 128, 20), stroke: none)

  let face(x, y, height, color) = draw.line(
    (x, y, height),
    (x + 1, y, height),
    (x + 1, y + 1, height),
    (x, y + 1, height),
    fill: color,
  )
  // s = -1 quadrants (blue) behind the zero plane, s = +1 quadrants (orange) in front.
  draw.on-layer(-1, {
    face(-1, 0, -1, rgb(173, 216, 230))
    face(0, -1, -1, rgb(173, 216, 230))
  })
  face(0, 0, 1, rgb(255, 165, 0))
  face(-1, -1, 1, rgb(255, 165, 0))

  // Grid in the zero plane, with arrowed Re and Im axes
  for idx in range(-1, 2) {
    let style = if idx == 0 { arrow-style } else { () }
    draw.line((idx, -1, 0), (idx, 1, 0), stroke: guide, ..style)
    draw.line((-1, idx, 0), (1, idx, 0), stroke: guide, ..style)
  }

  content((1.45, .1, 0), $"Re"(p_0)$)
  content((0, 1.6, 0), $"Im"(p_0)$)
  content((0, 0, 1.5), $s(p_0)$)
  content((.5, .5, 1), $+1$)
  content((-.5, .5, -1), $-1$)
})

One quadrant-wise sign rule, viewed from above and as a lifted surface. This is the function used here in contour bookkeeping, not the complex phase $p_0 \/ abs(p_0)$.
#v(14pt)
#card-grid(
  (
    [1  Locate the quadrant],
    figure-0,
    [Equal signs of the real and imaginary parts give $+1$; opposite signs give $-1$. The sign flips on crossing either axis.],
  ),
  (
    [2  Lift the value to a height],
    figure-1,
    [The same two values become horizontal sheets. Height encodes the sign; the surface is discontinuous at the axes.],
  ),
)
#v(12pt)
#takeaway[$s(p_0) = op("sign")(op("Re")(p_0) op("Im")(p_0))$. These panels show values *away from the axes*. At an axis, a contour calculation must specify the limiting side or its convention.]
