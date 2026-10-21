#import "@preview/cetz:0.5.3": canvas, decorations, draw
#import draw: circle, content, line

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 12pt)

#canvas({
  let (xrange, yrange, cut-x, q0) = (6, 4, 2, 3)
  let zigzag-style = (amplitude: 0.1, segment-length: 0.2, stroke: 0.75pt)

  // Real axis turning into a branch cut at cut-x, and a second cut shifted down by q0.
  line((-1, 0), (cut-x, 0), stroke: 0.75pt)
  decorations.zigzag(line((cut-x, 0), (xrange, 0)), ..zigzag-style, name: "x-axis-right")
  content((rel: (-0.3, 0.3), to: "x-axis-right.end"), $"Re"(p_0)$)
  decorations.zigzag(line((cut-x, -q0), (xrange, -q0)), ..zigzag-style)

  line(
    (0, -yrange - 1),
    (0, 2),
    mark: (end: "stealth", fill: black),
    stroke: 0.75pt,
    name: "y-axis",
  )
  content((rel: (0.8, -0.2), to: "y-axis.end"), $"Im"(p_0)$)

  content((cut-x, -q0 / 2), [#math.underbrace(box(width: 7.5em))], name: "q0-brace", angle: -90deg)
  content((rel: (-0.5, 0), to: "q0-brace"), $q_0$)

  // Matsubara frequencies
  for n in range(-yrange, 2).filter(n => n != 0) {
    circle((0, n), radius: 0.04, fill: black, name: "matsubara")
    content("matsubara", $i omega_#n$, anchor: "west", padding: 0.2)
  }
  circle((0, 0), radius: 0.03, fill: black)
  content((0.2, 0.1), $0$)

  // Poles one unit above and below each cut
  for (y-pos, superscript) in ((1, 1), (-1, 1), (1 - q0, 2), (-1 - q0, 2)) {
    for (x-pos, subscript) in ((cut-x + 1, 2), (cut-x + 3, 1)) {
      circle((x-pos, y-pos), radius: 0.06, fill: black)
      content((x-pos, y-pos), $alpha_#subscript^#superscript$, anchor: "south", padding: 0.1)
    }
  }

  // Region labels
  for (y-pos, label) in ((1.5, [(I)]), (-q0 / 2, [(II)]), (-q0 - 1.5, [(III)])) {
    content((cut-x + 2, y-pos), text(fill: rgb("#00008B"), label))
  }
})
