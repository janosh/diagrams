#import "@preview/cetz:0.5.3": canvas, draw
#import draw: bezier, circle, content, line

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 12pt)

#canvas({
  let top = ("CAA", "AAT", "ATG", "TGG", "GGC")
  let bottom = ("GCA", "TGC", "GTG", "CGT", "GCG")
  let (spacing, radius) = (2.4, .42)
  for (row-y, row) in ((2.6, top), (0, bottom)) {
    for (idx, name) in row.enumerate() {
      circle((idx * spacing, row-y), radius: radius, fill: rgb("#cdd3da"), stroke: 1pt, name: name)
      content(name, raw(name))
    }
  }

  let arr(color) = (
    stroke: color + 1.4pt,
    mark: (end: "stealth", fill: color, scale: .65),
  )

  // red Hamiltonian cycle: along the top row, down, back along the bottom row
  for (from, to) in (top + bottom.rev() + (top.first(),)).windows(2) {
    line(from, to, ..arr(rgb(255, 0, 0)))
  }

  // remaining black overlap edges (2-letter suffix of one 3-mer = prefix of the next)
  for (from, to) in (("ATG", "TGC"), ("GTG", "TGG"), ("GGC", "GCA")) {
    line(from, to, ..arr(black))
  }
  // curved black edge TGC → GCG (bend below); bezier doesn't clip at node
  // borders like line does, so start/end on the rim toward the control point
  let ctrl = (2 * spacing, -1.8)
  bezier(("TGC", radius, ctrl), ("GCG", radius, ctrl), ctrl, ..arr(black))
})
