#import "@preview/cetz-plot:0.1.4": plot
#import "@preview/cetz:0.5.2": canvas, draw

#set page(width: 780pt, height: auto, margin: 22pt, fill: white)
#set text(font: "Avenir Next", size: 10.5pt, fill: rgb("#19324f"))
#set par(leading: 0.55em)

// Measure each drawing before fitting it; keep labels and geometry together.
#let fit-figure(body, height: 170pt) = layout(size => {
  let bounds = measure(body)
  let factor = calc.min(size.width / bounds.width, height / bounds.height)
  box(width: 100%, align(center + horizon, std.scale(factor * 100%, reflow: true, body)))
})
#let card(title, body, caption, height: 240pt) = block(
  width: 100%,
  inset: 12pt,
  radius: 8pt,
  fill: rgb("#f3f6fa"),
  breakable: false,
)[
  #text(size: 13pt, weight: "bold", title)
  #v(8pt)
  #fit-figure(body, height: height)
  #v(7pt)
  #caption
]
#let takeaway(body) = block(
  width: 100%,
  inset: 12pt,
  radius: 6pt,
  fill: rgb("#e9f5f2"),
  breakable: false,
)[#body]

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


// === AM: change the envelope ===
#let figure-0 = [
  #let domain-x(x) = 11 * calc.pi * x
  #let msg(x) = 2 * calc.sin(.5 * domain-x(x))
  #let carrier(x) = 2 * calc.sin(6 * domain-x(x))
  #let am(x) = (2.5 + msg(x)) * carrier(x)

  #canvas({
    draw.set-style(legend: (fill: white))
    signal-row("msg", 4.6, $x(t)$, msg, black, (-2.4, 2.4))
    signal-row("carrier", 2.05, [carrier wave], carrier, blue, (-2.4, 2.4))
    signal-row("am", -.6, [AM wave], am, red, (-9.5, 9.5))
  })
]

// === FM: change the spacing ===
#let figure-1 = [
  #let domain-x(x) = 11 * x
  #let msg(x) = 2 * calc.sin(2 * calc.pi * .25 * domain-x(x))
  #let carrier(x) = 2 * calc.sin(6 * calc.pi * domain-x(x))
  // Frequency modulation: integrate the message into the carrier phase.
  #let fm(x) = (
    2
      * calc.sin(
        2 * calc.pi * 3 * domain-x(x) - 8 * calc.cos(2 * calc.pi * .25 * domain-x(x)),
      )
  )

  #canvas({
    draw.set-style(legend: (fill: white))
    let green = green.darken(15%)
    signal-row("msg", 4.6, $x(t)$, msg, black, (-2.4, 2.4))
    signal-row("carrier", 2.05, [carrier wave], carrier, blue, (-2.4, 2.4))
    signal-row("fm", -.6, [FM wave], fm, green, (-2.4, 2.4))
  })
]

#text(size: 27pt, weight: "bold")[Amplitude vs Frequency Modulation]
#v(5pt)
Transmit the same message by changing one property of a fast carrier. Read each column from the message at the top to the transmitted signal at the bottom.
#v(14pt)
#grid(
  columns: (1fr, 1fr),
  gutter: 12pt,
  card(
    [AM: change the envelope],
    figure-0,
    [The carrier’s amplitude follows the message; its rapid oscillation rate stays fixed. The envelope is easiest to see in the peaks.],
  ),
  card(
    [FM: change the spacing],
    figure-1,
    [The instantaneous frequency follows the message; the amplitude stays fixed. Closely spaced peaks mean a higher frequency.],
  ),
)
#v(12pt)
#takeaway[*Memory aid: AM changes height; FM changes spacing.* The carrier is the fast oscillation. The message is the slower signal we want to convey.]
