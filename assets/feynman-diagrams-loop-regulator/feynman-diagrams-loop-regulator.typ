#import "@preview/cetz:0.4.0": canvas, draw
#import draw: line, content, circle, arc, group, translate

#set page(width: auto, height: auto, margin: 8pt)

#canvas({
  // Define styles and constants
  let radius = 1.5
  let dark-blue = rgb("#4040d9")
  let arrow-style = (
    mark: (end: "stealth", fill: dark-blue, scale: .5),
    stroke: (paint: dark-blue, thickness: 0.75pt),
  )

  // Helper functions
  let cross(pos, name: none) = {
    content(
      pos,
      text(size: 16pt, baseline: -0.5pt)[$times.circle$],
      stroke: none,
      fill: white,
      frame: "circle",
      padding: -2.5pt,
      name: name,
    )
  }

  let vertex(pos, label: none, rel-label: (-0.2, -0.2)) = {
    circle(pos, radius: 2pt, fill: black)
    if label != none {
      content((rel: rel-label, to: pos), $#label$)
    }
  }

  let momentum-arrow(start, end, label-pos, anchor: "south") = {
    line(start, end, ..arrow-style)
    content(label-pos, text(fill: dark-blue)[$q_0$], anchor: anchor)
  }

  let draw-diagram(offset: 0, cross-pos: "50%", arc-start: 140deg, arc-stop: 40deg) = {
    group({
      if offset != 0 { translate((offset, 0)) }

      // Main circle and labels
      circle((0, 0), radius: radius, stroke: 1pt, name: "loop")
      content((0, radius), $m_1^2, gamma_1^2$, anchor: "south", padding: (bottom: 7pt))

      // Momentum arrow on loop
      arc(
        (rel: (.23, 0), to: if arc-start > 180deg { "loop.35%" } else { "loop.15%" }),
        radius: 0.85 * radius,
        start: arc-start,
        stop: arc-stop,
        ..arrow-style,
        name: "momentum-arrow",
      )
      content(
        "momentum-arrow.mid",
        text(fill: dark-blue)[$q_0$],
        anchor: if arc-start > 180deg { "south" } else { "north" },
        padding: if arc-start > 180deg { (bottom: 3pt) } else { none },
      )

      // Cross marker
      cross("loop." + cross-pos, name: "cross")
      content(
        "loop.50%",
        $m_2^2, gamma_2^2$,
        anchor: "north",
        padding: (top: 7pt),
      )

      // External lines and vertices
      let ext-len = 2 * radius
      vertex((-radius, 0), label: "g")
      vertex((radius, 0), label: "g", rel-label: (0.2, -0.2))
      line((-ext-len, 0), (-radius, 0), stroke: 1pt)
      line((radius, 0), (ext-len, 0), stroke: 1pt)

      // External momentum arrows
      momentum-arrow(
        (-ext-len + 0.2, 0.15),
        (-radius - 0.2, 0.15),
        (-1.5 * radius, 0.3),
      )
      momentum-arrow(
        (radius + 0.2, 0.15),
        (ext-len - 0.2, 0.15),
        (1.5 * radius, 0.3),
      )
    })
  }

  // Draw diagrams
  draw-diagram()
  content((4, 0), text(size: 18pt)[$+$])
  draw-diagram(
    offset: 8,
    cross-pos: "0%",
    arc-start: 220deg,
    arc-stop: 320deg,
  )
})
