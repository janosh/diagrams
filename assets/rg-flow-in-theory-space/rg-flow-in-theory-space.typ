#import "@preview/cetz:0.3.4": canvas, draw
#import draw: line, content, circle, hobby

#set page(width: auto, height: auto, margin: 8pt)

#let unit = 5

#canvas({
  let arrow-style = (mark: (end: "stealth", fill: black, scale: 0.5))

  // Define coordinates
  let qea = (-0.225 * unit, -5 / 12 * unit) // quantum effective action
  let ma1 = (0.4 * unit, 0.5 * unit) // microscopic action 1
  let ma2 = (0.6 * unit, 0.33 * unit) // microscopic action 2
  let ma3 = (unit, 0.5 * unit) // microscopic action 3
  let r1 = (0.17 * unit, 0.25 * unit) // regulator 1
  let r2 = (0.4 * unit, 0.1 * unit) // regulator 2
  let r3 = (0.5 * unit, -0.2 * unit) // regulator 3

  // Draw coordinate system
  line((0, 0), (0, 0.67 * unit), ..arrow-style, name: "lambda_1")
  content("lambda_1.end", $lambda_1$, anchor: "south")

  line((0, 0), (-0.5 * unit, -0.5 * unit), ..arrow-style, name: "lambda_2")
  content("lambda_2.end", $lambda_2$, anchor: "north-east")

  line((0, 0), (0.14 * unit, -0.67 * unit), ..arrow-style, name: "lambda_3")
  content("lambda_3.end", $lambda_3$, anchor: "north")

  line((0, 0), (0.83 * unit, -0.5 * unit), ..arrow-style, name: "lambda_4")
  content("lambda_4.end", $lambda_4$, anchor: "north-west")

  line((0, 0), (unit, 0), ..arrow-style)

  // Draw dotted line segment
  hobby(
    (0.75 * unit, -0.3 * unit),
    (0.82 * unit, -0.2 * unit),
    (0.83 * unit, -0.1 * unit),
    stroke: (dash: "loosely-dotted", thickness: 1.5pt),
  )

  // Draw flow trajectories using hobby curves
  hobby(
    ma1,
    r1,
    (0, -.8),
    qea,
    stroke: (dash: "dashed"),
  )
  content(r1, $R_1$, anchor: "north-west")

  hobby(
    ma2,
    r2,
    (0, -1.7),
    qea,
    stroke: (dash: "dashed"),
  )
  content(r2, $R_2$, anchor: "north-west")

  hobby(
    ma3,
    r3,
    qea,
    stroke: (dash: "dashed"),
  )
  content(r3, $R_3$, anchor: "north-west")

  // Draw points and labels
  let dark-red = rgb("8B0000")
  circle(qea, radius: 0.1, fill: dark-red, stroke: none)
  content((rel: (0, -0.2), to: qea), text(fill: dark-red)[$Gamma_(k=0) = Gamma$], anchor: "north")

  let dark-blue = rgb("00008B")
  circle(ma1, radius: 0.1, fill: dark-blue, stroke: none)
  content((rel: (0, 0.2), to: ma1), text(fill: dark-blue)[$Gamma_(k=Lambda_1) = S_1$], anchor: "south")

  circle(ma2, radius: 0.1, fill: dark-blue, stroke: none)
  content((rel: (0, 0.2), to: ma2), text(fill: dark-blue)[$Gamma_(k=Lambda_2) = S_2$], anchor: "south")

  circle(ma3, radius: 0.1, fill: dark-blue, stroke: none)
  content((rel: (0, 0.2), to: ma3), text(fill: dark-blue)[$Gamma_(k=Lambda_3) = S_3$], anchor: "south")
})
