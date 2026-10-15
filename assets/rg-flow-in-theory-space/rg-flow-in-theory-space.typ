#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, hobby, line

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 12pt)

#let unit = 5
#let scaled((x, y)) = (x * unit, y * unit)

#canvas({
  let arrow-style = (mark: (end: "stealth", fill: black, scale: 0.5))

  for (idx, end, anchor) in (
    (1, (0, 0.67), "south"),
    (2, (-0.5, -0.5), "north-east"),
    (3, (0.14, -0.67), "north"),
    (4, (0.83, -0.5), "north-west"),
  ) {
    let name = "lambda_" + str(idx)
    line((0, 0), scaled(end), ..arrow-style, name: name)
    content(name + ".end", $lambda_#idx$, anchor: anchor)
  }
  line((0, 0), (unit, 0), ..arrow-style)

  // dots hinting at further coupling directions
  hobby(
    ..((0.75, -0.3), (0.82, -0.2), (0.83, -0.1)).map(scaled),
    stroke: (dash: "loosely-dotted", thickness: 1.5pt),
  )

  // flows from microscopic actions S_i to the quantum effective action Γ
  let qea = scaled((-0.225, -5 / 12))
  let dark-blue = rgb("00008B")
  for (idx, action, regulator, waypoints) in (
    (1, (0.4, 0.5), (0.17, 0.25), ((0, -.8),)),
    (2, (0.6, 0.33), (0.4, 0.1), ((0, -1.7),)),
    (3, (1, 0.5), (0.5, -0.2), ()),
  ) {
    let (action, regulator) = (scaled(action), scaled(regulator))
    hobby(action, regulator, ..waypoints, qea, stroke: (dash: "dashed"))
    content(regulator, $R_#idx$, anchor: "north-west")
    circle(action, radius: 0.1, fill: dark-blue, stroke: none)
    content(
      (rel: (0, 0.2), to: action),
      text(fill: dark-blue)[$Gamma_(k=Lambda_#idx) = S_#idx$],
      anchor: "south",
    )
  }

  let dark-red = rgb("8B0000")
  circle(qea, radius: 0.1, fill: dark-red, stroke: none)
  content((rel: (0, -0.2), to: qea), text(fill: dark-red)[$Gamma_(k=0) = Gamma$], anchor: "north")
})
