#import "@preview/cetz:0.5.2": canvas, draw
#import "../_shared/layout.typ": card, paragraph-size, takeaway

#set page(width: 780pt, height: auto, margin: 22pt, fill: none)
#set text(font: "Avenir Next", size: paragraph-size, fill: rgb("#19324f"))
#set par(leading: 0.55em)

// === 1  What is evaluated? ===
#let figure-0 = canvas(length: 1.7cm, {
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
    let y = -idx * 1.9
    for (col, label) in ((0, input), (1, method), (2, output)) {
      draw.content(
        (col * 5.2, y),
        label,
        frame: "rect",
        padding: 10pt,
        fill: color,
        stroke: none,
        name: str(idx) + "-" + str(col),
      )
    }
    draw.content(
      (rel: (0, .45), to: str(idx) + "-0.north-west"),
      title,
      anchor: "west",
    )
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

// === 2  What must be validated? ===
#let figure-1 = [
  #set text(size: paragraph-size)
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

Choose a model for the quantities and configurations your simulation must predict. Speed, accuracy, and transferability depend on the task; they are not universal scores.
#v(14pt)
#stack(
  dir: ttb,
  spacing: 12pt,
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
