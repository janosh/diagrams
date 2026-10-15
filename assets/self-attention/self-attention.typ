#import "@preview/cetz:0.5.2": canvas, draw, vector
#import draw: bezier, content, line, set-style

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 12pt)

#canvas({
  set-style(content: (frame: "rect", stroke: none), mark: (offset: 0.05))
  let arrow-style = (end: "stealth", fill: black, scale: 0.7)
  // Columns: input, attention function, weight, product, sum, output (2 units apart)
  // Text opacity hints at each attention weight's size
  let rows = (
    (id: "1", y: 6, input: $arrow(e)_1$, alpha: text(fill: rgb(0, 0, 0, 45%), $alpha_(1j)$)),
    (id: "j", y: 4, input: $arrow(e)_j$, alpha: $alpha_(j j)$),
    (id: "n", y: 2, input: $arrow(e)_n$, alpha: text(fill: rgb(0, 0, 0, 60%), $alpha_(n j)$)),
  )
  for (above, below) in rows.windows(2) { content((0, (above.y + below.y) / 2), $dots$) }
  for row in rows {
    content((0, row.y), row.input, name: "arrow" + row.id, padding: 2pt)
    content((2, row.y), $a_phi$, stroke: 1pt, padding: (3pt, 4pt), name: "attn" + row.id)
    content((4, row.y), row.alpha, name: "alpha" + row.id + "j", padding: 3pt)
    content(
      (6, row.y),
      $times$,
      frame: "circle",
      padding: 3pt,
      stroke: .7pt,
      name: "times" + row.id,
    )
  }
  content((8, rows.at(1).y), $Sigma$, stroke: .7pt, padding: 4pt, name: "sum")
  content((rel: (1, 0), to: "sum"), $arrow(e)'_j$, name: "output", padding: 2pt)

  // every token takes the same route: input, attention score, weight, product, sum
  for row in ("1", "j", "n") {
    line("arrow" + row + ".east", "attn" + row, mark: arrow-style)
    line("attn" + row + ".east", "alpha" + row + "j", mark: arrow-style)
    line("alpha" + row + "j.east", "times" + row, mark: arrow-style)
    line("times" + row, "sum", mark: arrow-style)
  }
  // query j is the one being updated, so it also scores against the first and last tokens
  for key in ("attn1", "attnn") { line("arrowj.east", key, mark: arrow-style) }
  line("sum.east", "output.west", mark: arrow-style)

  // value branch: each input bends below its row through f_psi into the product node
  for row in rows {
    let (start, end) = ("arrow" + row.id + ".east", "times" + row.id + ".south-west")
    let control = ((from, to) => vector.add(vector.lerp(from, to, 0.5), (0, -2, 0)), start, end)
    bezier(start, end, control, mark: arrow-style, stroke: 1pt, name: "fpsi" + row.id)
    content(
      "fpsi" + row.id + ".50%",
      $f_psi$,
      stroke: .7pt,
      padding: (3pt, 4pt),
      fill: rgb("#cdd3da"),
    )
  }
})
