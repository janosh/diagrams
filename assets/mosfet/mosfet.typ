#import "@preview/cetz:0.4.0": canvas, draw
#import draw: line, rect, content, set-style

#set page(width: auto, height: auto, margin: 8pt)

#canvas({
  // Circuit board (base)
  rect((0, 0), (11, -0.25), fill: rgb("#008080"), name: "board")
  content("board.south", [circuit board], anchor: "north", padding: (top: 3pt))

  // Dielectric layer with brick pattern
  let brick-width = 0.4
  let brick-height = 0.2
  let start-x = 3.8
  let end-x = 7.2
  let start-y = 2
  let end-y = 3

  // Draw brick pattern background
  rect((start-x, start-y), (end-x, end-y), fill: white, stroke: rgb("#f00"), name: "dielectric-box")

  // Draw horizontal brick lines
  for y in range(int((end-y - start-y) / brick-height + 1)) {
    let y-pos = start-y + y * brick-height
    if y-pos < end-y {
      line((start-x, y-pos), (end-x, y-pos), stroke: rgb("#f00"))
    }
  }

  // Draw vertical brick lines with offset for alternating rows
  for x in range(int((end-x - start-x) / brick-width + 1)) {
    for y in range(int((end-y - start-y) / brick-height)) {
      let x-offset = if calc.rem(y, 2) == 0 { 0 } else { brick-width / 2 }
      let x-pos = start-x + x * brick-width + x-offset
      if x-pos < end-x {
        let y-start = start-y + y * brick-height
        let y-end = calc.min(y-start + brick-height, end-y)
        line((x-pos, y-start), (x-pos, y-end), stroke: rgb("#f00"))
      }
    }
  }

  // P-type semiconductor substrate
  rect((0, 0), (11, 2), fill: rgb("#ffa500").lighten(50%), name: "substrate")
  content("substrate", align(center)[$p$-type\ semiconductor])

  // N-type semiconductor regions
  rect((1, 1), (4, 2), fill: rgb("#90ee90"), name: "source-n")
  content("source-n", align(center)[$n$-type\ semiconductor])
  rect((7, 1), (10, 2), fill: rgb("#90ee90"), name: "drain-n")
  content("drain-n", align(center)[$n$-type\ semiconductor])

  content(
    "dielectric-box",
    [dielectric],
    frame: "rect",
    padding: 2pt,
    fill: white,
    stroke: (thickness: .5pt),
  )

  // Metal contacts
  rect((4, 3), (7, 3.5), fill: rgb("#e6e6ff"), name: "gate-metal")
  content("gate-metal", [gate])

  rect((1.25, 2), (3, 2.5), fill: rgb("#e6e6ff"), name: "source-metal")
  content("source-metal", [source])

  rect((8, 2), (9.75, 2.5), fill: rgb("#e6e6ff"), name: "drain-metal")
  content("drain-metal", [drain])

  // Title
  content("gate-metal.north", [$n$-type MOSFET], anchor: "south", padding: (bottom: 2mm))
})
