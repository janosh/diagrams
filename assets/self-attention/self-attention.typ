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

  // First column (input vectors)
  content((0, y1), $arrow(e)_1$, name: "arrow1", padding: 2pt)
  content((0, y-dots-1), $dots$)
  content((0, yj), $arrow(e)_j$, name: "arrowj", padding: 2pt)
  content((0, y-dots-2), $dots$)
  content((0, yn), $arrow(e)_n$, name: "arrown", padding: 2pt)

  // Second column (attention nodes)
  let x2 = spacing.layer
  content(
    (x2, y1),
    $a_phi$,
    frame: "rect",
    stroke: 1pt,
    padding: (3pt, 4pt),
    name: "attn1",
  )
  content(
    (x2, yj),
    $a_phi$,
    frame: "rect",
    stroke: 1pt,
    padding: (3pt, 4pt),
    name: "attnj",
  )
  content(
    (x2, yn),
    $a_phi$,
    frame: "rect",
    stroke: 1pt,
    padding: (3pt, 4pt),
    name: "attnn",
  )

  // Third column (alpha values)
  let x3 = x2 + spacing.layer
  content(
    (x3, y1),
    text(fill: rgb(0, 0, 0, 20%))[$alpha_(1j)$],
    name: "alpha1j",
    padding: 3pt,
  )
  content((x3, yj), $alpha_(j j)$, name: "alphajj", padding: 3pt)
  content(
    (x3, yn),
    text(fill: rgb(0, 0, 0, 60%))[$alpha_(n j)$],
    name: "alphanj",
    padding: 3pt,
  )

  // Fourth column (multiplication nodes)
  let x4 = x3 + spacing.layer
  content(
    (x4, y1),
    name: "times1",
    $times$,
    frame: "circle",
    padding: 3pt,
    stroke: .7pt,
  )
  content(
    (x4, yj),
    name: "timesj",
    $times$,
    frame: "circle",
    padding: 3pt,
    stroke: .7pt,
  )
  content(
    (x4, yn),
    name: "timesn",
    $times$,
    frame: "circle",
    padding: 3pt,
    stroke: .7pt,
  )

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

  for (idx, (start, end)) in (
    ("arrow1.east", "times1.south-west"),
    ("arrowj.east", "timesj.south-west"),
    ("arrown.east", "timesn.south-west"),
  ).enumerate(start: 1) {
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
