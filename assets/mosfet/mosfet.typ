#import "@preview/cetz:0.5.2": canvas, draw
#import draw: content, line, rect

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 12pt)

#canvas({
  // Board/substrate width, dielectric x-span and the substrate surface height
  let (width, start-x, end-x, start-y) = (11, 3.8, 7.2, 2)

  // Circuit board (base)
  rect((0, 0), (width, -0.25), fill: rgb("#008080"), name: "board")
  content("board.south", [circuit board], anchor: "north", padding: (top: 3pt))

  // Dielectric layer with brick pattern (5 rows of 0.4 x 0.2 bricks, odd rows offset by half a brick)
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
  rect((0, 0), (width, start-y), fill: rgb("#ffa500").lighten(50%), name: "substrate")
  content("substrate", align(center)[$p$-type\ semiconductor])

  // n-type wells, each topped by its metal contact
  for (well-x, inset, name) in ((1, 0.25, "source"), (7, 1, "drain")) {
    rect((well-x, 1), (rel: (3, start-y - 1)), fill: rgb("#90ee90"), name: name + "-n")
    content(name + "-n", align(center)[$n$-type\ semiconductor])
    rect((well-x + inset, start-y), (rel: (1.75, 0.5)), fill: rgb("#c8c8e1"), name: name + "-metal")
    content(name + "-metal", name)
  }

  content(
    "dielectric-box",
    [dielectric],
    frame: "rect",
    padding: 2pt,
    fill: rgb("#cdd3da"),
    stroke: .5pt,
  )

  // Gate contact on top of the dielectric
  rect((start-x + 0.2, start-y + 1), (rel: (3, 0.5)), fill: rgb("#c8c8e1"), name: "gate-metal")
  content("gate-metal", [gate])

  // Title
  content("gate-metal.north", [$n$-type channel], anchor: "south", padding: (bottom: 2mm))
})
