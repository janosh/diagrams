#import "@preview/cetz:0.5.2": canvas, draw
#import draw: bezier, circle, content, line, rect, set-style

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#canvas({
  set-style(
    content: (frame: "rect", stroke: none),
    mark: (offset: 0.05),
  )

  let spacing = (node: 2, layer: 2, vertical: 1.0)

  // Input nodes
  let y1 = 6
  let y-dots-1 = y1 - spacing.vertical
  let yj = y-dots-1 - spacing.vertical
  let y-dots-2 = yj - spacing.vertical
  let yn = y-dots-2 - spacing.vertical
  let arrow-style = (end: "stealth", fill: black, scale: 0.7)
  let rows = (
    (id: "1", y: y1, input: $arrow(e)_1$, alpha: $alpha_(1j)$, alpha-fill: rgb(0, 0, 0, 20%)),
    (id: "j", y: yj, input: $arrow(e)_j$, alpha: $alpha_(j j)$, alpha-fill: none),
    (id: "n", y: yn, input: $arrow(e)_n$, alpha: $alpha_(n j)$, alpha-fill: rgb(0, 0, 0, 60%)),
  )

  for row in rows { content((0, row.y), row.input, name: "arrow" + row.id, padding: 2pt) }
  for y in (y-dots-1, y-dots-2) { content((0, y), $dots$) }

  let x2 = spacing.layer
  for row in rows {
    content(
      (x2, row.y),
      $a_phi$,
      frame: "rect",
      stroke: 1pt,
      padding: (3pt, 4pt),
      name: "attn" + row.id,
    )
  }

  let x3 = x2 + spacing.layer
  for row in rows {
    let label = if row.alpha-fill == none { row.alpha } else {
      text(fill: row.alpha-fill, row.alpha)
    }
    content((x3, row.y), label, name: "alpha" + row.id + "j", padding: 3pt)
  }

  let x4 = x3 + spacing.layer
  for row in rows {
    content(
      (x4, row.y),
      $times$,
      frame: "circle",
      padding: 3pt,
      stroke: .7pt,
      name: "times" + row.id,
    )
  }

  // Fifth column (sum node)
  let x5 = x4 + spacing.layer
  content(
    (x5, yj),
    $Sigma$,
    frame: "rect",
    stroke: .7pt,
    padding: 4pt,
    name: "sum",
  )

  // Output node
  let x6 = x5 + 1
  content((x6, yj), $arrow(e)'_j$, name: "output", padding: 2pt)

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

  for (idx, row) in rows.enumerate(start: 1) {
    let start = "arrow" + row.id + ".east"
    let end = "times" + row.id + ".south-west"
    bezier(
      start,
      end,
      (
        (v1, v2) => {
          let (x1, y1, z1, ..) = v1
          let (x2, y2, z2, ..) = v2
          ((x1 + x2) / 2, (y1 + y2) / 2 - 2, (z1 + z2) / 2)
        },
        start,
        end,
      ),
      mark: arrow-style,
      stroke: 1pt,
      name: "fpsi" + str(idx),
    )
    content(
      "fpsi" + str(idx) + ".50%",
      [$f_psi$],
      frame: "rect",
      stroke: .7pt,
      padding: (3pt, 4pt),
      name: "fpsi",
      fill: white,
    )
  }
})
