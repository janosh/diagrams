// Shared wiring for the neural-network diagrams.

#import "@preview/cetz:0.5.2": draw

// Edge from every node of one layer to every node of the next, addressing nodes by the
// `<prefix><index>` names their layer gave them. `start` is that numbering's first index.
#let fully-connect(from-prefix, to-prefix, from-count, to-count, start: 1, ..style) = {
  for from-idx in range(start, from-count + start) {
    for to-idx in range(start, to-count + start) {
      draw.line(from-prefix + str(from-idx), to-prefix + str(to-idx), ..style)
    }
  }
}
