#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, line

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 12pt)

#canvas({
  let arrow-style = (mark: (start: "stealth", fill: black, scale: 0.5), stroke: (thickness: 1.1pt))

  content((0, 0), text(size: 24pt)[=])

  // The process p, k -> p', k' (left) balances its reverse p', k' -> p, k (right).
  for (x, in-labels, out-labels) in (
    (-3, ($p$, $k$), ($p'$, $k'$)),
    (3, ($p'$, $k'$), ($p$, $k$)),
  ) {
    circle((x, 0), radius: 0.3, fill: gray.lighten(50%), stroke: gray, name: "vertex")
    // Arrowheads sit at each line's start: on the vertex for incoming legs, at the far end
    // for outgoing ones.
    for (dy, in-label, out-label) in (1, -1).zip(in-labels, out-labels) {
      line((rel: (2, dy), to: "vertex"), "vertex", ..arrow-style, name: "out")
      content("out.start", out-label, anchor: "west")
      line("vertex", (rel: (-2, dy), to: "vertex"), ..arrow-style, name: "in")
      content("in.end", in-label, anchor: "east")
    }
  }
})
