#import "@preview/cetz:0.5.2": canvas, draw
#import "@preview/cetz-plot:0.1.4": plot

#set page(width: 780pt, height: auto, margin: 22pt, fill: white)
#set text(font: "Avenir Next", size: 10.5pt, fill: rgb("#19324f"))
#set par(leading: 0.55em)

// Measure each drawing before fitting it; keep labels and geometry together.
#let fit-figure(body, height: 170pt) = layout(size => {
  let bounds = measure(body)
  let factor = calc.min(size.width / bounds.width, height / bounds.height)
  box(width: 100%, align(center + horizon, std.scale(factor * 100%, reflow: true, body)))
})
#let card(title, body, caption, height: 180pt) = block(
  width: 100%,
  inset: 12pt,
  radius: 8pt,
  fill: rgb("#f3f6fa"),
  breakable: false,
)[
  #text(size: 13pt, weight: "bold", title)
  #v(8pt)
  #fit-figure(body, height: height)
  #v(7pt)
  #caption
]
#let takeaway(body) = block(
  width: 100%,
  inset: 12pt,
  radius: 6pt,
  fill: rgb("#e9f5f2"),
  breakable: false,
)[#body]

// === 1  Convex: above a tangent ===
#let figure-0 = [
  #canvas({
    draw.set-style(legend: (fill: white))
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
]

// === 2  Concave: reverse the inequality ===
#let figure-1 = [
  #canvas({
    draw.set-style(legend: (fill: white))
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
]

// === 3  The local picture for log ===
#let figure-2 = [
  #canvas({
    draw.set-style(legend: (fill: white))
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
]

// === 4  Average first, or apply f first? ===
#let figure-3 = [
  #canvas({
    draw.set-style(legend: (fill: white))
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
]

#text(size: 27pt, weight: "bold")[Convexity and Jensen’s Inequality]
#v(5pt)
Curvature tells us how a function compares with its tangents, chords, and averages. Convex bends upward; concave bends downward.
#v(14pt)
#grid(
  columns: (1fr, 1fr),
  gutter: 12pt,
  card(
    [1  Convex: above a tangent],
    figure-0,
    [For $f(x)=x ln x$ ($x>0$), the tangent at $x=1$ is $x-1$. Thus $x ln x >= x-1$, with equality at the contact point.],
  ),
  card(
    [2  Concave: reverse the inequality],
    figure-1,
    [Negating $x ln x$ reverses its curvature. A straight line is both convex and concave. Curvature statements apply on the specified domain.],
  ),

  card(
    [3  The local picture for log],
    figure-2,
    [The concave logarithm lies below its tangent. To understand Jensen’s inequality, compare a point on the curve with the chord between two sampled values.],
  ),
  card(
    [4  Average first, or apply f first?],
    figure-3,
    [For convex $f$, $f(sum_i w_i x_i) <= sum_i w_i f(x_i)$ when $w_i >= 0$ and $sum_i w_i=1$. For concave $f$, reverse the sign.],
  ),
)
#v(12pt)
#takeaway[*Tangent = local slope; chord = interpolation between two points.* Jensen compares the function of an average with the average of the function.]
