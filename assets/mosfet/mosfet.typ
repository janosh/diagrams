#import "@preview/cetz:0.5.2": canvas, draw
#import draw: content, line, rect

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 12pt)

#canvas({
  // Circuit board (base)
  rect((0, 0), (11, -0.25), fill: rgb("#008080"), name: "board")
  content("board.south", [circuit board], anchor: "north", padding: (top: 3pt))

  // Dielectric layer with brick pattern (5 rows of 0.4 x 0.2 bricks, odd rows offset by half a brick)
  let (start-x, end-x, start-y) = (3.8, 7.2, 2)
  let (brick-width, brick-height) = (0.4, 0.2)
  let brick-red = rgb("#f00")
  rect(
    (start-x, start-y),
    (end-x, start-y + 1),
    fill: rgb("#cdd3da"),
    stroke: brick-red,
    name: "dielectric-box",
  )
  for row in range(5) {
    let y-start = start-y + row * brick-height
    line((start-x, y-start), (end-x, y-start), stroke: brick-red)
    for col in range(9) {
      let x-pos = start-x + col * brick-width + calc.rem(row, 2) * brick-width / 2
      if x-pos < end-x {
        line((x-pos, y-start), (x-pos, y-start + brick-height), stroke: brick-red)
      }
    }
  }

  // P-type semiconductor substrate
  rect((0, 0), (11, 2), fill: rgb("#ffa500").lighten(50%), name: "substrate")
  content("substrate", align(center)[$p$-type\ semiconductor])

  for (start, end, name) in (((1, 1), (4, 2), "source-n"), ((7, 1), (10, 2), "drain-n")) {
    rect(start, end, fill: rgb("#90ee90"), name: name)
    content(name, align(center)[$n$-type\ semiconductor])
  }

  content(
    "dielectric-box",
    [dielectric],
    frame: "rect",
    padding: 2pt,
    fill: rgb("#cdd3da"),
    stroke: .5pt,
  )

  for (start, end, name, label) in (
    ((4, 3), (7, 3.5), "gate-metal", [gate]),
    ((1.25, 2), (3, 2.5), "source-metal", [source]),
    ((8, 2), (9.75, 2.5), "drain-metal", [drain]),
  ) {
    rect(start, end, fill: rgb("#c8c8e1"), name: name)
    content(name, label)
  }

  // Title
  content("gate-metal.north", [$n$-type channel], anchor: "south", padding: (bottom: 2mm))
})
