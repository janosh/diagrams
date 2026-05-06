#import "@preview/cetz:0.5.2": canvas, draw
#import draw: bezier, circle, content, line

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#canvas({
  let arrow = (mark: (end: "stealth", fill: black, scale: .55), stroke: .8pt)
  let perceptron-radius = .48
  let small(name, pos, label: none, radius: .18) = {
    circle(pos, radius: radius, fill: white, stroke: .65pt, name: name)
    if label != none { content(name, label) }
  }
  let right-rim(pos, radius: .18) = (pos.at(0) + radius, pos.at(1))
  let rim-from(pos) = {
    let length = calc.sqrt(pos.at(0) * pos.at(0) + pos.at(1) * pos.at(1))
    (pos.at(0) / length * perceptron-radius, pos.at(1) / length * perceptron-radius)
  }

  circle((0, 0), radius: perceptron-radius, fill: white, stroke: .8pt, name: "perceptron")
  content("perceptron", $Sigma sigma$)
  for (name, y, label, weight, ctrl-y) in (
    ("x0", 1.5, $+1$, $w_0$, 1.05),
    ("x1", .75, $x_1$, $w_1$, .72),
    ("x2", 0, $x_2$, $w_2$, 0),
    ("x3", -.75, $x_3$, $w_3$, -.72),
    ("xn", -1.75, $x_n$, $w_n$, -1.05),
  ) {
    let pos = (-2, y)
    small(name, pos, label: text(size: 7pt)[#label])
    bezier(right-rim(pos), rim-from((-.85, ctrl-y)), (-1.45, y), (-.85, ctrl-y), ..arrow)
    content((-1.25, (y + ctrl-y) / 2 + .12), text(size: 8pt)[#weight], anchor: "south")
  }
  content((rel: (0, .53), to: "xn"), $dots.v$)
  line(
    (rel: (0, -.43), to: "perceptron"),
    (rel: (0, .43), to: "perceptron"),
    stroke: (dash: "dashed", paint: black, thickness: .5pt),
  )
  line("perceptron.east", (rel: (3.5, 0), to: "perceptron.east"), ..arrow, name: "perceptron-out")
  content((rel: (0, .42), to: "perceptron-out.mid"), $sigma(w_0 + sum_(i=1)^n w_i x_i)$, fill: white, padding: 1pt)

  let inputs = (("i1", (6, .75), $I_1$), ("i2", (6, 0), $I_2$), ("i3", (6, -.75), $I_3$))
  let hidden = (("h1", (8, 1.5)), ("h2", (8, .75)), ("h3", (8, 0)), ("h4", (8, -.75)), ("h5", (8, -1.5)))
  let outputs = (("o1", (10, .75), $O_1$), ("o2", (10, -.75), $O_2$))
  for (name, pos, label) in inputs {
    small(name, pos, radius: .16)
    let west = name + ".west"
    let edge = name + "-in"
    line((rel: (-.85, 0), to: west), west, ..arrow, name: edge)
    content((rel: (0, .28), to: edge + ".mid"), label)
  }
  for (name, pos) in hidden { small(name, pos, radius: .16) }
  for (name, pos, label) in outputs { small(name, pos, radius: .16) }
  for (input-name, ..) in inputs {
    for (hidden-name, ..) in hidden { line(input-name, hidden-name, ..arrow) }
  }
  for (hidden-name, ..) in hidden {
    for (output-name, ..) in outputs { line(hidden-name, output-name, ..arrow) }
  }
  for (name, pos, label) in outputs {
    let east = name + ".east"
    let edge = name + "-out"
    line(east, (rel: (.85, 0), to: east), ..arrow, name: edge)
    content((rel: (0, .28), to: edge + ".mid"), label)
  }
  content((rel: (0, 1.55), to: "i1.north"), align(center)[Input\ layer])
  content((rel: (0, .8), to: "h1.north"), align(center)[Hidden\ layer])
  content((rel: (0, 1.55), to: "o1.north"), align(center)[Output\ layer])
  line(
    (rel: (.12, .43), to: "perceptron"),
    (rel: (0, .16), to: "h5"),
    stroke: (paint: luma(45%), dash: "dashed", thickness: 1pt),
  )
  line(
    (rel: (.12, -.43), to: "perceptron"),
    (rel: (0, -.16), to: "h5"),
    stroke: (paint: luma(45%), dash: "dashed", thickness: 1pt),
  )
})
