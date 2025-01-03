#import "@preview/cetz:0.3.1": canvas, draw
#import draw: line, content, circle, bezier

#set page(width: auto, height: auto, margin: 3pt)

#let (V, p) = (9, 6)

#canvas({
  // Draw axes
  line((0, 0), (0, p), mark: (end: "stealth", fill: black))
  content((0.2, p), $p$)
  line((0, 0), (V, 0), mark: (end: "stealth", fill: black))
  content((V + 0.2, 0), $V$)

  // Draw dashed lines for min/max values
  let p-max = 0.9 * p
  let p-min = 0.2 * p
  let V-min = 0.2 * V
  let V-max = 0.9 * V

  // Vertical dashed line for V-min
  line((0, p-max), (V-min, p-max), stroke: (dash: "dotted", thickness: 0.8pt))
  line((V-min, 0), (V-min, p-max), stroke: (dash: "dotted", thickness: 0.8pt))
  content((-0.5, p-max), $p_"max"$)
  content((V-min, -0.5), $V_"min"$)

  // Vertical dashed line for V-max
  line((0, p-min), (V-max, p-min), stroke: (dash: "dotted", thickness: 0.8pt))
  line((V-max, 0), (V-max, p-min), stroke: (dash: "dotted", thickness: 0.8pt))
  content((-0.5, p-min), $p_"min"$)
  content((V-max, -0.5), $V_"max"$)

  // Define points
  let a = (V-min, p-max)
  let b = (V-max, 0.5 * p)
  let c = (V-max, p-min)
  let d = (V-min, 0.45 * p)

  // Draw points
  for pt in (a, b, c, d) {
    circle(pt, radius: 3pt, fill: black)
  }

  // Add point labels
  content((a.at(0), a.at(1) + 0.3), [1])
  content((b.at(0) + 0.3, b.at(1)), [2])
  content((c.at(0) + 0.3, c.at(1)), [3])
  content((d.at(0) - 0.3, d.at(1)), [4])

  // Draw cycle paths with arrows and labels
  // a -> b (adiabatic expansion)
  let arrow_style = (end: "stealth", fill: black)
  let stroke_style = (paint: rgb("#00008b"), thickness: 1.5pt)
  bezier(a, b, (b.at(0) - 5, b.at(1) + 1), stroke: stroke_style, mark: arrow_style)
  content(((a.at(0) + b.at(0)) / 2, (a.at(1) + b.at(1)) / 2 + 0.1), $Delta Q = 0$)

  // b -> c (heat rejection)
  line(b, c, mark: arrow_style, stroke: stroke_style)
  content((b.at(0) + 0.7, (b.at(1) + c.at(1)) / 2), text(fill: blue.darken(5%))[$arrow.r Q_"out"$])

  // c -> d (adiabatic compression)
  bezier(c, d, (d.at(0) + 2.4, d.at(1) - 1.3), stroke: stroke_style, mark: arrow_style)
  content(((c.at(0) + d.at(0)) / 2, (c.at(1) + d.at(1)) / 2 + 0.15), $Delta Q = 0$)

  // d -> a (heat addition)
  line(d, a, mark: arrow_style, stroke: stroke_style)
  content((d.at(0) - 0.6, (d.at(1) + a.at(1)) / 2), text(fill: red)[$Q_"in" arrow.r$])
})
