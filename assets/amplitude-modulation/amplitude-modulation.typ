#import "@preview/cetz:0.5.2": canvas, draw
#import "@preview/cetz-plot:0.1.4": plot
#import draw: content, group, line, translate

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#let domain-x(x) = 11 * calc.pi * x
#let msg(x) = 2.5 + 2 * calc.sin(.5 * domain-x(x))
#let carrier(x) = 2 * calc.sin(6 * domain-x(x))
#let am(x) = msg(x) * carrier(x)
#let samples = 1600
#let plot-height = 1.6

// @typstyle off
#let row(name, y, title, func, color, label-color: black, y-min: -1.55, y-max: 1.55) = {
  let arrow = (mark: (end: "stealth", fill: black, scale: .55), stroke: .8pt)
  let x-axis = name + "-x-axis"
  let y-axis = name + "-y-axis"
  let zero-y = (0 - y-min) / (y-max - y-min) * plot-height
  line((0, y), (10.5, y), ..arrow, name: x-axis)
  line((0, y - .95), (0, y + 1.15), ..arrow, name: y-axis)
  content(x-axis + ".end", $t$, anchor: "west", padding: 2pt)
  content(
    (rel: (.14, -.15), to: y-axis + ".end"),
    text(fill: label-color)[#title],
    anchor: "south-west",
  )
  group({
    translate((0, y - zero-y))
    plot.plot(
      size: (10.0, plot-height),
      axis-style: none,
      y-min: y-min,
      y-max: y-max,
      {
        plot.add(
          style: (stroke: color + 1.3pt),
          domain: (0, 1),
          samples: samples,
          func,
        )
      },
    )
  })
}

#canvas({
  row("msg", 4.6, $x(t)$, msg, black, y-min: 0, y-max: 7.5)
  row(
    "carrier",
    2.05,
    [carrier wave],
    carrier,
    blue,
    label-color: blue,
    y-min: -2.4,
    y-max: 2.4,
  )
  row("am", -.6, [AM wave], am, red, label-color: red, y-min: -9.5, y-max: 9.5)
})
