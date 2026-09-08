#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, hobby, line

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#let unit = 5

#canvas({
  let arrow-style = (mark: (end: "stealth", fill: black, scale: 0.5))

  let qea = (-0.225 * unit, -5 / 12 * unit) // quantum effective action
  let ma1 = (0.4 * unit, 0.5 * unit) // microscopic action 1
  let ma2 = (0.6 * unit, 0.33 * unit) // microscopic action 2
  let ma3 = (unit, 0.5 * unit) // microscopic action 3
  let r1 = (0.17 * unit, 0.25 * unit) // regulator 1
  let r2 = (0.4 * unit, 0.1 * unit) // regulator 2
  let r3 = (0.5 * unit, -0.2 * unit) // regulator 3

  for (idx, end, anchor) in (
    (1, (0, 0.67 * unit), "south"),
    (2, (-0.5 * unit, -0.5 * unit), "north-east"),
    (3, (0.14 * unit, -0.67 * unit), "north"),
    (4, (0.83 * unit, -0.5 * unit), "north-west"),
  ) {
    let name = "lambda_" + str(idx)
    line((0, 0), end, ..arrow-style, name: name)
    content(name + ".end", $lambda_#idx$, anchor: anchor)
  }

  line((0, 0), (unit, 0), ..arrow-style)

  hobby(
    (0.75 * unit, -0.3 * unit),
    (0.82 * unit, -0.2 * unit),
    (0.83 * unit, -0.1 * unit),
    stroke: (
      dash: "loosely-dotted",
      thickness: 1.5pt,
    ),
  )

  for (idx, points, regulator) in (
    (1, (ma1, r1, (0, -.8), qea), r1),
    (2, (ma2, r2, (0, -1.7), qea), r2),
    (3, (ma3, r3, qea), r3),
  ) {
    hobby(..points, stroke: (dash: "dashed"))
    content(regulator, $R_#idx$, anchor: "north-west")
  }

  let dark-red = rgb("8B0000")
  circle(qea, radius: 0.1, fill: dark-red, stroke: none)
  content(
    (rel: (0, -0.2), to: qea),
    text(fill: dark-red)[$Gamma_(k=0) = Gamma$],
    anchor: "north",
  )

  let dark-blue = rgb("00008B")
  for (idx, pos) in ((1, ma1), (2, ma2), (3, ma3)) {
    circle(pos, radius: 0.1, fill: dark-blue, stroke: none)
    content(
      (rel: (0, 0.2), to: pos),
      text(fill: dark-blue)[$Gamma_(k=Lambda_#idx) = S_#idx$],
      anchor: "south",
    )
  }
})
