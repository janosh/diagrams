// adapted from https://github.com/cetz-package/cetz/blob/a082e02a/gallery/waves.typ
#import "@preview/cetz:0.5.2": canvas, draw, matrix
#import draw: content, grid, group, line, rotate, scale, set-transform

#set page(width: auto, height: auto, margin: .5cm, fill: none)
#set text(size: 12pt)

#canvas({
  set-transform(matrix.transform-rotate-dir((1, 1, -1.3), (0, 1, .4)))
  scale(x: 1.5, z: -1)
  let arrow-style = (mark: (end: "stealth", fill: black, scale: 0.5))
  line((0, -2, 0), (0, 2.5, 0), ..arrow-style)
  line((-0.5, 0, 0), (8.5, 0, 0), ..arrow-style)
  line((0, 0, -1.5), (0, 0, 2), ..arrow-style)
  content((0, 0, 2.3), [$arrow(E)$])
  content((0, 3, 0), [$arrow(B)$])
  content((8.7, 0, 0), [$arrow(v)$])

  grid(
    (0, -2),
    (8, 2),
    stroke: gray + .5pt,
  )

  // filled sine wave of two periods along x with 8 vertical stems per period
  let wave(amplitude, fill, phases: 2, length: 8, samples: 100, subdivs: 8) = {
    line(
      ..range(samples + 1).map(idx => {
        let x = idx / samples
        (x * length, calc.sin(2 * phases * calc.pi * x) * amplitude)
      }),
      fill: fill,
    )
    for phase in range(phases) {
      for div in range(1, subdivs + 1) {
        let x = phase / phases * length + div / subdivs * length / phases
        let y = calc.sin(2 * calc.pi * (div / subdivs)) * amplitude
        line((x, 0), (x, y), stroke: rgb(0, 0, 0, 150) + .5pt)
      }
    }
  }

  group({
    rotate(x: 90deg)
    wave(1.6, rgb(0, 0, 255, 50))
  })
  wave(1, rgb(255, 0, 0, 50))
})
