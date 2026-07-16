#import "@preview/cetz:0.5.2": canvas, draw
#import draw: bezier, circle, content, line

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#canvas({
  let top = ("CAA", "AAT", "ATG", "TGG", "GGC")
  let bottom = ("GCA", "TGC", "GTG", "CGT", "GCG")
  for (row-y, row) in ((2.6, top), (0, bottom)) {
    for (idx, name) in row.enumerate() {
      circle(
        (idx * 2.4, row-y),
        radius: .42,
        fill: white,
        stroke: 1pt,
        name: name,
      )
      content(name, text(size: .8em, raw(name)))
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

  // black de Bruijn edges (diagonals)
  for (from, to) in (("ATG", "TGC"), ("GTG", "TGG"), ("GGC", "GCA")) {
    line(from, to, ..arr(black))
  }
  // curved black edge TGC → GCG (bend below); bezier doesn't clip at node
  // borders like line does, so start/end on the rim toward the control point
  let ctrl = (4.8, -1.8)
  let rim(center, toward) = {
    let (cx, cy) = center
    let (tx, ty) = toward
    let len = calc.sqrt((tx - cx) * (tx - cx) + (ty - cy) * (ty - cy))
    (cx + (tx - cx) / len * .42, cy + (ty - cy) / len * .42)
  }
  bezier(rim((2.4, 0), ctrl), rim((9.6, 0), ctrl), ctrl, ..arr(black))
})
