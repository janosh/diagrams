#import "@preview/cetz:0.5.2": canvas, draw

#set page(width: 780pt, height: auto, margin: 22pt, fill: white)
#set text(font: "Avenir Next", size: 10.5pt, fill: rgb("#19324f"))
#set par(leading: 0.55em)

// Measure each drawing before fitting it; keep labels and geometry together.
#let fit-figure(body, height: 170pt) = layout(size => {
  let bounds = measure(body)
  let factor = calc.min(size.width / bounds.width, height / bounds.height)
  box(width: 100%, align(center + horizon, std.scale(factor * 100%, reflow: true, body)))
})
#let card(title, body, caption, height: 260pt) = block(
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

// === 1  What is evaluated? ===
#let figure-0 = [
  #canvas({
    draw.set-style(legend: (fill: white))
    let rows = (
      (
        [Classical force field],
        [positions],
        [fitted energy formula],
        [energy + forces],
        rgb("#d6e9f8"),
      ),
      (
        [ML potential],
        [local environments],
        [trained neural model],
        [energy + forces],
        rgb("#d3ede5"),
      ),
      (
        [Density functional theory],
        [nuclei + electrons],
        [self-consistent electrons],
        [energy + forces],
        rgb("#fbe4d4"),
      ),
    )
    for (idx, (title, input, method, output, color)) in rows.enumerate() {
      let y = -idx * 2.7
      draw.content((0, y + .9), title, anchor: "west")
      for (col, label) in ((0, input), (1, method), (2, output)) {
        draw.content(
          (col * 4, y),
          label,
          frame: "rect",
          padding: 10pt,
          fill: color,
          stroke: none,
          name: str(idx) + "-" + str(col),
        )
      }
      for col in range(2) {
        draw.line(
          str(idx) + "-" + str(col) + ".east",
          str(idx) + "-" + str(col + 1) + ".west",
          mark: (end: "stealth"),
          stroke: gray + 1pt,
        )
      }
    }
  })
]

// === 2  What must be validated? ===
#let figure-1 = [
  #box(width: 680pt)[#table(
    columns: (1fr, 2fr),
    inset: 9pt,
    stroke: rgb("#cad4df") + .5pt,
    table.header([*Method*], [*Checks for the intended application*]),
    [Classical force field],
    [Functional form and parameter coverage; bonding changes, charges, and long-range interactions.],

    [ML potential],
    [Training-domain coverage; errors on representative structures, forces, defects, and trajectories.],

    [DFT],
    [Functional, basis and sampling convergence; relevant charge, spin, and electronic states.],
  )]
]

#text(size: 27pt, weight: "bold")[Atomistic Simulation Methods]
#v(5pt)
Choose a model for the quantities and configurations your simulation must predict. Speed, accuracy, and transferability depend on the task; they are not universal scores.
#v(14pt)
#grid(
  columns: (1fr,),
  gutter: 12pt,
  card(
    [1  What is evaluated?],
    figure-0,
    [All three can supply energies and forces for atomistic simulation. They differ in how that mapping is built and what electronic physics is represented.],
  ),
  card(
    [2  What must be validated?],
    figure-1,
    [Benchmark the same observable, structures, and accuracy target on the intended hardware. Report throughput and errors with units; test transfer on configurations excluded from fitting.],
  ),
)
#v(12pt)
#takeaway[*Ask “good enough for this task?” before “which is best?”* Classical and ML models amortize a fitted approximation over many evaluations. DFT solves an approximate electronic problem for each configuration. None guarantees accuracy outside its validated setting.]
