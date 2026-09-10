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

// === 1  A worked competition ===
#let figure-0 = canvas(length: 1.21cm, {
  draw.set-style(legend: (fill: rgb("#cdd3da")))
  plot.plot(
    size: (9, 6),
    x-min: 0,
    x-max: 600,
    y-min: -25,
    y-max: 30,
    x-label: none,
    y-label: [kJ/mol],
    axis-style: "left",
    x-tick-step: 100,
    y-tick-step: 10,
    legend-style: (fill: rgb("#cdd3da"), padding: .15, item: (spacing: .15)),
    legend: "inner-north-east",
    {
      plot.add(
        style: (stroke: rgb("#c2570a") + 1.4pt),
        domain: (0, 600),
        x => 20,
        label: [$Delta H$],
      )
      plot.add(
        style: (stroke: blue + 1.4pt),
        domain: (0, 600),
        x => -x * .05,
        label: [$-T Delta S$],
      )
      plot.add(
        style: (stroke: rgb("#008580") + 2pt),
        domain: (0, 600),
        x => 20 - x * .05,
        label: [$Delta G$],
      )
      plot.add(style: (stroke: (paint: gray, dash: "dashed")), domain: (0, 600), x => 0)
    },
  )
  draw.content((4.5, -.8), [$T$ (K)])
})

// === 2  Direction is not speed ===
#let figure-1 = canvas(length: 1.4cm, {
  draw.set-style(legend: (fill: rgb("#cdd3da")))
  let points = range(101).map(idx => {
    let coord = idx / 20
    (coord, 3 * calc.exp(-calc.pow(coord - 2.3, 2) / 0.6) - 0.35 * coord)
  })
  draw.line((-0.3, -2), (5.5, -2), mark: (end: "stealth"))
  draw.line((-.3, -2), (-.3, 3.2), mark: (end: "stealth"))
  draw.line(..points, stroke: rgb("#008580") + 1.8pt)
  draw.content((0, .35), [reactants], anchor: "south-west")
  draw.content((4.8, -1.35), [products], anchor: "south")
  draw.content((2.3, 3.4), [activation barrier], anchor: "south")
  draw.content((2.6, -2.5), [reaction coordinate])
  draw.content((-.7, 2), [$G$])
})

At fixed temperature and pressure, enthalpy and entropy compete to determine the thermodynamic direction of change. Temperature sets the weight of the entropy contribution.
#v(14pt)
#card-grid(
  (
    [1  A worked competition],
    figure-0,
    [Illustration: $Delta H=+20$ kJ/mol and $Delta S=+50$ J/(mol K), treated as constant. Their contributions balance at $T=400$ K; above it, $Delta G<0$.],
  ),
  (
    [2  Direction is not speed],
    figure-1,
    [A negative free-energy change favors the forward direction at the current composition. A large activation barrier can still make that process very slow.],
  ),
)
#v(12pt)
#takeaway[$Delta G=Delta H-T Delta S$. *Use consistent units.* For a reaction, $Delta_r G=Delta_r G^degree+R T ln Q$: composition also matters. At equilibrium $Delta_r G=0$; a catalyst changes the rate, not this equilibrium condition.]
