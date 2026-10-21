#import "@preview/cetz:0.5.3": canvas, draw
#import draw: circle, line, rect, rotate

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#canvas({
  let size = 5 // half the unit cell's side length
  let marker-size = 0.3 // half side of square markers, radius of circular ones
  let colors = (teal: rgb("#19d4d4"), yellow: rgb("#f3f380"), red: rgb("#f36969"))
  let square((x, y), fill) = rect(
    (x - marker-size, y - marker-size),
    (x + marker-size, y + marker-size),
    fill: fill,
  )

  // asymmetric unit (teal) and strips marking the mirror lines that constrain
  // the yellow (diagonal mirror) and red (axial mirror) Wyckoff positions
  line((0, 0), (size, 0), (size, -size), fill: colors.teal, close: true, stroke: none)
  let yellow-strip = ((size - .5, -size), (0, -.5), (0, 0), (size, -size))
  line(..yellow-strip, fill: colors.yellow, close: true, stroke: none)
  rect((0, 0), (size, 0.35), fill: colors.red, stroke: none)

  rect((-size, -size), (size, size))
  // mirror lines
  for (start, end) in (
    ((-size, -size), (size, size)),
    ((size, -size), (-size, size)),
    ((-size, 0), (size, 0)),
    ((0, -size), (0, size)),
  ) { line(start, end, stroke: (dash: "dashed")) }

  // 4 sites on the diagonal mirrors
  for x in (-0.8 * size, 0.8 * size) {
    for y in (-0.8 * size, 0.8 * size) { square((x, y), colors.yellow) }
  }
  // 4 sites on the axial mirrors
  for offset in (-0.7 * size, 0.7 * size) {
    circle((offset, 0), radius: marker-size, fill: colors.red)
    circle((0, offset), radius: marker-size, fill: colors.red)
  }
  // 8 sites in the general position
  rotate(45deg)
  for idx in range(8) {
    let (angle, ring-radius) = (idx * 360deg / 8 + 22.5deg, 0.4 * size)
    square((ring-radius * calc.cos(angle), ring-radius * calc.sin(angle)), colors.teal)
  }
})
