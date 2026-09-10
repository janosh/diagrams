#import "@preview/cetz:0.5.2": canvas, draw
#import "@preview/cetz-plot:0.1.4": plot
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

// === 1  Convex: above a tangent ===
#let figure-0 = canvas(length: 1.2cm, {
  draw.set-style(legend: (fill: rgb("#cdd3da")))
  let axis-mark = (end: "stealth", fill: black)
  draw.set-style(axes: (
    x: (mark: axis-mark, label: (anchor: "north", offset: 0.1)),
    y: (mark: axis-mark, label: (anchor: "north-west", offset: -0.2)),
  ))
  plot.plot(
    size: (8, 5),
    x-label: $x$,
    y-tick-step: 1,
    x-tick-step: 1,
    x-grid: true,
    y-grid: true,
    legend: "inner-north-west",
    // Compact legend with a thin border.
    legend-style: (item: (spacing: 0.15), padding: 0.15, stroke: 0.5pt),
    axis-style: "left",
    {
      // x ln(x) function
      plot.add(
        style: (stroke: blue + 1.5pt),
        domain: (0.01, 2.7), // avoid x=0 since ln(0) is undefined
        samples: 100,
        label: $x ln(x)$,
        x => x * calc.ln(x),
      )

      // x-1 function
      plot.add(
        style: (stroke: red + 1.5pt),
        domain: (0, 2.7),
        label: $x-1$,
        x => x - 1,
      )
    },
  )
})

// === 2  Concave: reverse the inequality ===
#let figure-1 = canvas(length: 1.2cm, {
  draw.set-style(legend: (fill: rgb("#cdd3da")))
  let axis-mark = (end: "stealth", fill: black)
  draw.set-style(axes: (
    x: (mark: axis-mark),
    y: (mark: axis-mark, label: (anchor: "north-west", offset: -0.2)),
  ))
  plot.plot(
    size: (8, 5),
    x-min: 0,
    x-max: 1,
    x-label: $x$,
    y-tick-step: 0.2,
    x-tick-step: 0.2,
    x-grid: true,
    y-grid: true,
    legend: "inner-north-west",
    // Compact legend with a thin border.
    legend-style: (item: (spacing: 0.15), padding: 0.15, stroke: 0.5pt),
    axis-style: "left",
    {
      // x function
      plot.add(style: (stroke: blue + 1.5pt), domain: (0, 1), label: $x$, x => { x })
      // -x ln(x) function
      plot.add(
        style: (stroke: red + 1.5pt),
        domain: (0.01, 1), // avoid x=0 since ln(0) is undefined
        samples: 100,
        label: $-x ln(x)$,
        x => -x * calc.ln(x),
      )
    },
  )
})

// === 3  The local picture for log ===
#let figure-2 = canvas(length: 1.6cm, {
  draw.set-style(legend: (fill: rgb("#cdd3da")))
  let axis-mark = (end: "stealth", fill: black, scale: 0.7)
  draw.set-style(axes: (
    x: (mark: axis-mark, label: (anchor: "south-east", offset: -0.25)),
    y: (mark: axis-mark, label: (anchor: "north-west", offset: -0.2)),
  ))

  plot.plot(
    size: (8, 6),
    x-label: $x$,
    y-label: $log x$,
    y-min: -1,
    x-tick-step: none,
    y-tick-step: none,
    axis-style: "school-book",
    {
      // Main logarithmic curve
      plot.add(
        style: (stroke: rgb(0%, 0%, 80%) + 1.5pt),
        domain: (11, 150),
        samples: 150,
        x => calc.ln(x - 10) - 2,
      )

      // Dashed line
      plot.add(
        style: (
          stroke: (paint: orange, thickness: 1.5pt, dash: "dashed"),
        ),
        domain: (8, 120),
        x => 0.2 + (3 - 0.2) * (x - 8) / (120 - 8),
      )
    },
  )
})

// === 4  Average first, or apply f first? ===
#let figure-3 = canvas(length: 1.85cm, {
  draw.set-style(legend: (fill: rgb("#cdd3da")))
  let curve(x) = 0.3 * x * x
  draw.line((0, 0), (4.5, 0), mark: (end: "stealth"))
  draw.line((0, 0), (0, 5.3), mark: (end: "stealth"))
  draw.line(
    ..range(0, 81).map(idx => {
      let x = idx / 20
      (x, curve(x))
    }),
    stroke: blue + 1.5pt,
  )
  draw.line((1, curve(1)), (4, curve(4)), stroke: rgb("#c45a31") + 1.3pt)
  draw.line((2.5, 0), (2.5, 2.55), stroke: (dash: "dashed", paint: gray))
  draw.circle((2.5, curve(2.5)), radius: 0.07, fill: blue)
  draw.circle((2.5, 2.55), radius: 0.07, fill: rgb("#c45a31"))
  draw.content((2.5, -0.25), $bar(x)$, anchor: "north")
  draw.content((2.35, curve(2.5)), $f(bar(x))$, anchor: "east", padding: 4pt)
  draw.content((1.6, 3.15), [average of $f$], anchor: "south")
})

Curvature tells us how a function compares with its tangents, chords, and averages. Convex bends upward; concave bends downward.
#v(14pt)
#card-grid(
  (
    [1  Convex: above a tangent],
    figure-0,
    [For $f(x)=x ln x$ ($x>0$), the tangent at $x=1$ is $x-1$. Thus $x ln x >= x-1$, with equality at the contact point.],
  ),
  (
    [2  Concave: reverse the inequality],
    figure-1,
    [Negating $x ln x$ reverses its curvature. A straight line is both convex and concave. Curvature statements apply on the specified domain.],
  ),

  (
    [3  The local picture for log],
    figure-2,
    [The concave logarithm lies below its tangent. To understand Jensen’s inequality, compare a point on the curve with the chord between two sampled values.],
  ),
  (
    [4  Average first, or apply f first?],
    figure-3,
    [For convex $f$, $f(sum_i w_i x_i) <= sum_i w_i f(x_i)$ when $w_i >= 0$ and $sum_i w_i=1$. For concave $f$, reverse the sign.],
  ),
)
#v(12pt)
#takeaway[*Tangent = local slope; chord = interpolation between two points.* Jensen compares the function of an average with the average of the function.]
