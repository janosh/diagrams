// Shared vocabulary for the neural-network diagrams, so a reader moving between them
// can assume a styling difference means something.

#import "@preview/cetz:0.5.2": draw
#import "theme.typ": line-weight

// One outline weight for every unit in every network diagram. Radius still varies,
// because the diagrams are drawn at different scales and show different amounts.
#let node-stroke = line-weight.thin

// Edge from every node of one layer to every node of the next, addressing nodes by the
// `<prefix><index>` names their layer gave them. `start` is that numbering's first index.
#let fully-connect(from-prefix, to-prefix, from-count, to-count, start: 1, ..style) = {
  for from-idx in range(start, from-count + start) {
    for to-idx in range(start, to-count + start) {
      draw.line(from-prefix + str(from-idx), to-prefix + str(to-idx), ..style)
    }
  }
}
