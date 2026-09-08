#import "@preview/cetz-plot:0.1.4": plot
#import "@preview/cetz:0.5.2": canvas, draw

#let plot-height = 1.6

// `y` is the height of the panel's t-axis; the curve is shifted so that the zero of
// `y-range` lands on it, which is what lets panels with different scales line up.
#let signal-row(name, y, title, func, color, y-range, samples: 1600) = {
  let (y-min, y-max) = y-range
  let arrow = (mark: (end: "stealth", fill: black, scale: .55), stroke: .8pt)
  let (x-axis, y-axis) = (name + "-x-axis", name + "-y-axis")

  draw.line((0, y), (10.5, y), ..arrow, name: x-axis)
  draw.line((0, y - .95), (0, y + 1.15), ..arrow, name: y-axis)
  draw.content(x-axis + ".end", $t$, anchor: "west", padding: 2pt)
  draw.content(
    (rel: (.14, -.15), to: y-axis + ".end"),
    text(fill: color, title),
    anchor: "south-west",
  )

  draw.group({
    draw.translate((0, y - (0 - y-min) / (y-max - y-min) * plot-height))
    plot.plot(
      size: (10.0, plot-height),
      axis-style: none,
      y-min: y-min,
      y-max: y-max,
      plot.add(style: (stroke: color + 1.3pt), domain: (0, 1), samples: samples, func),
    )
  })
}

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#let domain-x(x) = 11 * calc.pi * x
#let msg(x) = 2.5 + 2 * calc.sin(.5 * domain-x(x))
#let carrier(x) = 2 * calc.sin(6 * domain-x(x))
#let am(x) = msg(x) * carrier(x)

#canvas({
  signal-row("msg", 4.6, $x(t)$, msg, black, (0, 7.5))
  signal-row("carrier", 2.05, [carrier wave], carrier, blue, (-2.4, 2.4))
  signal-row("am", -.6, [AM wave], am, red, (-9.5, 9.5))
})
