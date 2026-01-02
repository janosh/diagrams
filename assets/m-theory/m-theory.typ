#import "@preview/cetz:0.4.2": canvas, draw
#import draw: arc, bezier, content, merge-path, on-layer, set-style

#set page(width: auto, height: auto, margin: 10pt, fill: none)
#set text(size: 14pt)

#canvas(length: 1cm, {
  draw.scale(1.2)

  // Vertices: (position, arc_start, arc_stop)
  let vertices = (
    ((-4.5, -1.2), -34deg, 45deg),
    ((-2.8, 3.5), -90deg, -11deg),
    ((4.5, 3), 180deg, 256deg),
    ((5, -2.3), 124deg, 194deg),
    ((0, -5.2), 56deg, 124deg),
  )
  // Pentagon edge controls
  let edge_ctrls = (
    ((-3.2, 0.2), (-2.8, 1.8)),
    ((0.2, 2.8), (2.2, 2.8)),
    ((4, 0.8), (4, -0.2)),
    ((3, -2.8), (1.2, -3.5)),
    ((-1.2, -3.5), (-2.8, -2.3)),
  )
  // Arrow data: (from_off, to_off, ctrl1, ctrl2, label, lbl_pos, anchor)
  // Control points for moderate curvature
  let arrows = (
    ((-0.3, 0.3), (-0.3, -0.3), (-5.4, 0.5), (-4.5, 2.4), align(center)[compac-\ tification], (-4.5, 2.1), "east"),
    ((0.3, 0.2), (-0.2, 0.3), (-0.1, 4.8), (2.2, 4.5), [M-theory], (0.6, 4.4), "south"),
    ((0.3, -0.2), (0.3, 0.3), (5.8, 1.6), (5.9, 0.0), [T-duality], (5.8, 0.6), "west"),
    (
      (-0.2, -0.3),
      (0.3, -0.2),
      (3.8, -4.3),
      (1.6, -5.5),
      align(center)[orientifold\ action $Omega$],
      (3.9, -4.5),
      "north",
    ),
    ((-0.3, -0.2), (-0.2, -0.3), (-1.6, -5.5), (-4.5, -3.2), [S-duality], (-4.0, -4.2), "north"),
  )
  // Node labels: (offset, label, anchor) - positioned close to cusp tips
  let labels = (
    ((-0.6, -0.3), align(center)[heterotic\ $S O(32)$], "east"),
    ((-0.3, 0.6), align(center)[heterotic\ $E(8) times E(8)$], "south"),
    ((0.5, 0.3), [Type II A], "west"),
    ((0.5, 0), [Type II B], "west"),
    ((0, -0.5), [Type I], "north"),
  )

  let off(pt, delta) = (pt.at(0) + delta.at(0), pt.at(1) + delta.at(1))

  // Build pentagon path
  let pentagon = {
    for idx in range(5) {
      let (pt, ..) = vertices.at(idx)
      let (next, ..) = vertices.at(calc.rem(idx + 1, 5))
      let (ctrl1, ctrl2) = edge_ctrls.at(idx)
      if idx == 0 { bezier(pt, next, ctrl1, ctrl2) } else { bezier((), next, ctrl1, ctrl2) }
    }
  }

  on-layer(0, merge-path(pentagon, close: true, fill: gray.transparentize(70%), stroke: none))

  on-layer(1, {
    set-style(stroke: (paint: rgb("#00008b"), thickness: 0.8pt), fill: none)
    for (pt, start, stop) in vertices {
      for rad in (0.15, 0.3, 0.45, 0.6, 0.75, 0.9) {
        arc(pt, start: start, stop: stop, radius: rad, anchor: "origin")
      }
    }
  })

  on-layer(2, merge-path(pentagon, close: true, fill: none, stroke: (paint: rgb("#666"), thickness: 2pt)))

  on-layer(3, {
    let arrow_gray = rgb("#555")
    set-style(
      stroke: (paint: arrow_gray, thickness: 1.2pt),
      mark: (fill: arrow_gray, stroke: arrow_gray, scale: 0.8, start: "stealth", end: "stealth"),
    )

    for (idx, (off1, off2, ctrl1, ctrl2, lbl, lbl_pos, anchor)) in arrows.enumerate() {
      let (p1, ..) = vertices.at(idx)
      let (p2, ..) = vertices.at(calc.rem(idx + 1, 5))
      bezier(off(p1, off1), off(p2, off2), ctrl1, ctrl2)
      content(lbl_pos, lbl, anchor: anchor)
    }

    for (idx, (delta, lbl, anchor)) in labels.enumerate() {
      content(off(vertices.at(idx).at(0), delta), lbl, anchor: anchor)
    }

    content(
      (0, -0.5),
      align(center)[parameter space of \ #text(size: 1.4em, weight: "bold")[M-Theory]],
      anchor: "center",
    )
  })
})
