#import "@preview/cetz:0.5.2": canvas, decorations, draw
#import draw: content, line

#set page(width: auto, height: auto, margin: 5pt, fill: none)
#set text(size: 12pt)

#canvas({
  let (xr, yr) = (5, 1)
  let arrow-style = (mark: (end: "stealth", fill: black, scale: 0.5))

  line((0, -yr), (0, yr), ..arrow-style, name: "y-axis")
  content((rel: (-0.7, -0.2), to: "y-axis.end"), $"Im"(p_0)$)

  line((-xr / 2, 0), (xr / 2, 0), name: "x-axis", mark: (
    symbol: "circle",
    fill: blue,
    scale: 0.75,
  ))
  content((rel: (0, 0.3), to: "x-axis.start"), $-sqrt(arrow(p)^2)$)
  content((rel: (0, 0.3), to: "x-axis.end"), $sqrt(arrow(p)^2)$)

  // Branch cuts out to ±∞. Zigzag drops arrow tips, but the marks still shorten its paths.
  let zigzag-style = (stroke: blue.darken(20%), amplitude: 0.2, segment-length: 0.3)
  decorations.zigzag(line((-xr - 0.5, 0), "x-axis.3%", ..arrow-style), ..zigzag-style)
  decorations.zigzag(
    line("x-axis.end", (xr, 0), ..arrow-style),
    ..zigzag-style,
    name: "right-zigzag",
  )
  content((rel: (-0.2, 0.3), to: "right-zigzag.end"), $"Re"(p_0)$)
})
