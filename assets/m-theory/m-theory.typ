#import "@preview/cetz:0.5.3": canvas, draw
#import draw: arc, bezier, content, merge-path, on-layer, set-style

#set page(width: auto, height: auto, margin: 10pt, fill: none)
#set text(size: 14pt)

#canvas(length: 1.2cm, {
  // (cusp position, arc start, arc stop, label offset, label, label anchor)
  let vertices = (
    ((-4.5, -1.2), -34deg, 45deg, (-0.6, -0.3), align(center)[heterotic\ $"SO"(32)$], "east"),
    ((-2.8, 3.5), -90deg, -11deg, (-0.3, 0.6), align(center)[heterotic\ $E_8 times E_8$], "south"),
    ((4.5, 3), 180deg, 256deg, (0.5, 0.3), [Type IIA], "west"),
    ((5, -2.3), 124deg, 194deg, (0.5, 0), [Type IIB], "west"),
    ((0, -5.2), 56deg, 124deg, (0, -0.5), [Type I], "north"),
  )
  // control points of the pentagon edge from each vertex to the next
  let edge-ctrls = (
    ((-3.2, 0.2), (-2.8, 1.8)),
    ((0.2, 2.8), (2.2, 2.8)),
    ((4, 0.8), (4, -0.2)),
    ((3, -2.8), (1.2, -3.5)),
    ((-1.2, -3.5), (-2.8, -2.3)),
  )
  // duality arrow from each vertex to the next:
  // (start offset, end offset, control 1, control 2, label, label position, label anchor)
  let arrows = (
    ((-0.3, 0.3), (-0.3, -0.3), (-5.4, 0.5), (-4.5, 2.4), [T-duality], (-4.5, 2.1), "east"),
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
  let next-vertex(idx) = vertices.at(calc.rem(idx + 1, 5)).first()

  let pentagon = for (idx, (pt, ..)) in vertices.enumerate() {
    bezier(if idx == 0 { pt } else { () }, next-vertex(idx), ..edge-ctrls.at(idx))
  }
  on-layer(0, merge-path(pentagon, close: true, fill: gray.transparentize(70%), stroke: none))

  on-layer(1, {
    set-style(stroke: (paint: rgb("#00008b"), thickness: 0.8pt), fill: none)
    for (pt, start, stop, ..) in vertices {
      for radius in (0.15, 0.3, 0.45, 0.6, 0.75, 0.9) {
        arc(pt, start: start, stop: stop, radius: radius, anchor: "origin")
      }
    }
  })

  let rim = (paint: rgb("#666"), thickness: 2pt)
  on-layer(2, merge-path(pentagon, close: true, fill: none, stroke: rim))

  on-layer(3, {
    let arrow-gray = rgb("#555")
    set-style(
      stroke: (paint: arrow-gray, thickness: 1.2pt),
      mark: (fill: arrow-gray, stroke: arrow-gray, scale: 0.8, start: "stealth", end: "stealth"),
    )
    for (idx, arrow) in arrows.enumerate() {
      let (start-offset, end-offset, ctrl1, ctrl2, label, label-pos, anchor) = arrow
      let start = vertices.at(idx).first()
      bezier((rel: start-offset, to: start), (rel: end-offset, to: next-vertex(idx)), ctrl1, ctrl2)
      content(label-pos, label, anchor: anchor)
    }
    for (pt, _, _, offset, label, anchor) in vertices {
      content((rel: offset, to: pt), label, anchor: anchor)
    }
    content((0, -0.5), align(
      center,
    )[parameter space of \ #text(size: 1.4em, weight: "bold")[M-Theory]])
  })
})
