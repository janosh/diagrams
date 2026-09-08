#import "@preview/cetz:0.5.2": canvas, draw
#import "@preview/cetz-plot:0.1.4": plot

#set page(width: 780pt, height: auto, margin: 22pt, fill: white)
#set text(font: "Avenir Next", size: 10.5pt, fill: rgb("#19324f"))
#set par(leading: 0.55em)

// Measure each drawing before fitting it; keep labels and geometry together.
#let fit-figure(body, height: 170pt) = layout(size => {
  let bounds = measure(body)
  let factor = calc.min(size.width / bounds.width, height / bounds.height)
  box(width: 100%, align(center + horizon, std.scale(
    x: factor * 100%,
    y: factor * 100%,
    reflow: true,
    body,
  )))
})
#let card(title, body, caption, height: 170pt) = block(
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

// === 1  A worked competition ===
#let figure-0 = [
  #canvas({
    draw.set-style(legend: (fill: white))
    plot.plot(
      size: (9, 6),
      x-min: 0,
      x-max: 600,
      y-min: -25,
      y-max: 30,
      x-label: [$T$ (K)],
      y-label: [kJ/mol],
      axis-style: "left",
      x-tick-step: 100,
      y-tick-step: 10,
      legend-style: (fill: white, padding: .15, item: (spacing: .15)),
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
  })
]

// === 2  Direction is not speed ===
#let figure-1 = [
  #canvas({
    draw.set-style(legend: (fill: white))
    let points = range(101).map(idx => {
      let coord = idx / 20
      (coord, 3 * calc.exp(-calc.pow(coord - 2.3, 2) / 0.6) - 0.35 * coord)
    })
    draw.line((-0.3, -2), (5.5, -2), mark: (end: "stealth"))
    draw.line((-.3, -2), (-.3, 3.2), mark: (end: "stealth"))
    draw.line(..points, stroke: rgb("#008580") + 1.8pt)
    draw.content((0, .35), [reactants], anchor: "south")
    draw.content((4.8, -1.35), [products], anchor: "south")
    draw.content((2.3, 3.4), [activation barrier], anchor: "south")
    draw.content((2.6, -2.5), [reaction coordinate])
    draw.content((-.7, 2), [$G$])
  })
]

#text(size: 27pt, weight: "bold")[Gibbs Free Energy]
#v(5pt)
At fixed temperature and pressure, enthalpy and entropy compete to determine the thermodynamic direction of change. Temperature sets the weight of the entropy contribution.
#v(14pt)
#grid(
  columns: (1fr, 1fr),
  gutter: 12pt,
  card(
    [1  A worked competition],
    figure-0,
    [Illustration: $Delta H=+20$ kJ/mol and $Delta S=+50$ J/(mol K), treated as constant. Their contributions balance at $T=400$ K; above it, $Delta G<0$.],
    height: 215pt,
  ),
  card(
    [2  Direction is not speed],
    figure-1,
    [A negative free-energy change favors the forward direction at the current composition. A large activation barrier can still make that process very slow.],
    height: 215pt,
  ),
)
#v(12pt)
#takeaway[$Delta G=Delta H-T Delta S$. *Use consistent units.* For a reaction, $Delta_r G=Delta_r G^degree+R T ln Q$: composition also matters. At equilibrium $Delta_r G=0$; a catalyst changes the rate, not this equilibrium condition.]
