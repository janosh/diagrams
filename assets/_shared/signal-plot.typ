// Stacked time-domain signal panels shared by the amplitude- and frequency-modulation
// diagrams: an arrowed t-axis, a titled y-axis, and one curve threaded through them.

#import "@preview/cetz:0.5.2": draw
#import "@preview/cetz-plot:0.1.4": plot
#import draw: content, group, line, translate

#let plot-height = 1.6

// `y` is the height of the panel's t-axis; the curve is shifted so that the zero of
// `y-range` lands on it, which is what lets panels with different scales line up.
#let signal-row(name, y, title, func, color, y-range, samples: 1600) = {
  let (y-min, y-max) = y-range
  let arrow = (mark: (end: "stealth", fill: black, scale: .55), stroke: .8pt)
  let (x-axis, y-axis) = (name + "-x-axis", name + "-y-axis")

  line((0, y), (10.5, y), ..arrow, name: x-axis)
  line((0, y - .95), (0, y + 1.15), ..arrow, name: y-axis)
  content(x-axis + ".end", $t$, anchor: "west", padding: 2pt)
  content(
    (rel: (.14, -.15), to: y-axis + ".end"),
    text(fill: color, title),
    anchor: "south-west",
  )

  group({
    translate((0, y - (0 - y-min) / (y-max - y-min) * plot-height))
    plot.plot(
      size: (10.0, plot-height),
      axis-style: none,
      y-min: y-min,
      y-max: y-max,
      plot.add(style: (stroke: color + 1.3pt), domain: (0, 1), samples: samples, func),
    )
  })
}
