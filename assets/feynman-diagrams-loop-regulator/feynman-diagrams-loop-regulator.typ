#import "@preview/cetz:0.5.2": canvas, draw
#import draw: arc, circle, content, group, line, translate

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 12pt)

#canvas({
  let radius = 1.5
  let dark-blue = rgb("#4040d9")
  let arrow-style = (
    mark: (end: "stealth", fill: dark-blue, scale: .5),
    stroke: (paint: dark-blue, thickness: 0.75pt),
  )

  // One-loop diagram with the regulator on the lower (or upper) propagator and the loop
  // momentum arrow along the opposite propagator.
  let draw-diagram(offset: 0, regulator-top: false) = group({
    translate((offset, 0))
    circle((0, 0), radius: radius, stroke: 1pt, name: "loop")
    content("loop.north", $m_1^2, gamma_1^2$, anchor: "south", padding: (bottom: 7pt))

    arc(
      (rel: (.23, 0), to: if regulator-top { "loop.35%" } else { "loop.15%" }),
      radius: 0.85 * radius,
      start: if regulator-top { 220deg } else { 140deg },
      stop: if regulator-top { 320deg } else { 40deg },
      ..arrow-style,
      name: "momentum-arrow",
    )
    content(
      "momentum-arrow.mid",
      text(fill: dark-blue)[$q_0$],
      anchor: if regulator-top { "south" } else { "north" },
      padding: if regulator-top { (bottom: 3pt) } else { none },
    )

    // Regulator insertion: a circled cross on an opaque gray disc.
    content(
      "loop." + if regulator-top { "0%" } else { "50%" },
      text(size: 16pt, baseline: -0.5pt)[$times.o$],
      stroke: none,
      fill: rgb("#cdd3da"),
      frame: "circle",
      padding: -2.5pt,
    )
    content("loop.50%", $m_2^2, gamma_2^2$, anchor: "north", padding: (top: 7pt))

    // External legs with coupling vertices and incoming/outgoing momentum arrows.
    for side in (-1, 1) {
      let vertex = (side * radius, 0)
      circle(vertex, radius: 2pt, fill: black)
      content((rel: (side * 0.2, -0.2), to: vertex), $g$)
      line(vertex, (side * 2 * radius, 0), stroke: 1pt, name: "leg")
      line((rel: (-0.55, 0.15), to: "leg.mid"), (rel: (0.55, 0.15), to: "leg.mid"), ..arrow-style)
      content((rel: (0, 0.3), to: "leg.mid"), text(fill: dark-blue)[$q_0$], anchor: "south")
    }
  })

  draw-diagram()
  content((4, 0), text(size: 18pt)[$+$])
  draw-diagram(offset: 8, regulator-top: true)
})
