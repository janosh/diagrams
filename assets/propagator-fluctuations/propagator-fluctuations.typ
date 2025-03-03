#import "@preview/cetz:0.3.3": canvas, draw
#import "@preview/modpattern:0.1.0": modpattern
#import draw: line, content, circle, rect, group

#set page(width: auto, height: auto, margin: 8pt)

// TODO fix hatches rendering as black fill https://github.com/cetz-package/cetz/issues/805#issuecomment-2629554884
#let hatched = modpattern(
  (.1cm, .1cm),
  std.line(start: (0%, 100%), end: (100%, 0%), stroke: 0.5pt),
  background: white,
)

#canvas({
  // Define styles and constants
  let unit = 1
  let vertex-radius = 0.2 * unit
  let cross-radius = 0.15 * unit
  let ext-len = 2 * unit

  // Helper function for cross markers
  let cross(pos, label: none, label-offset: 2, rel-label: (0, -0.5)) = {
    let rad = cross-radius
    content(pos, text(size: 16pt)[$times.circle$], stroke: none, fill: white, frame: "circle", padding: -2.5pt)
    if label != none {
      content(
        (rel: rel-label, to: pos),
        eval(label, mode: "math"),
      )
    }
  }

  // Helper function for hatched vertices
  let vertex(pos, label: none, rel-label: (0.35, 0.35)) = {
    circle(pos, radius: vertex-radius, fill: hatched)

    if label != none {
      content(
        (rel: rel-label, to: pos),
        eval(label, mode: "math"),
      )
    }
  }

  // Diagram 1
  group(
    name: "diagram1",
    {
      // Main circle
      circle((0, 0), radius: unit, stroke: 1pt)

      // External lines
      line((-ext-len, 0), (-unit, 0), stroke: 1pt)
      line((unit, 0), (ext-len, 0), stroke: 1pt)

      // Cross marker
      cross((0, unit), label: "partial_k R_k")

      // Vertices
      vertex((-unit, 0), label: "Gamma_k^(3)", rel-label: (-0.35, 0.35))
      vertex((unit, 0), label: "Gamma_k^(3)")
    },
  )

  // Diagram 2
  group(
    name: "diagram2",
    {
      // Move right by 5 units
      let offset = (5, 0)

      // Main circle
      circle((offset.at(0), 0), radius: unit, stroke: 1pt)

      // External lines
      line((-ext-len + offset.at(0), 0), (-unit + offset.at(0), 0), stroke: 1pt)
      line((unit + offset.at(0), 0), (ext-len + offset.at(0), 0), stroke: 1pt)

      // Cross marker
      cross((offset.at(0), -unit), label: "partial_k R_k", rel-label: (0, 0.5))

      // Vertices
      vertex((-unit + offset.at(0), 0), label: "Gamma_k^(3)", rel-label: (-0.35, 0.35))
      vertex((unit + offset.at(0), 0), label: "Gamma_k^(3)")
    },
  )

  // Diagram 3
  group(
    name: "diagram3",
    {
      // Move right by 10 units
      let offset = (10, 0)

      // Main circle
      circle((offset.at(0), 0), radius: unit, stroke: 1pt)

      // External line
      line(
        (-ext-len + offset.at(0), -unit),
        (ext-len + offset.at(0), -unit),
        stroke: 1pt,
      )

      // Cross marker
      cross((offset.at(0), unit), label: "partial_k R_k")

      // Vertex
      vertex((offset.at(0), -unit), label: "Gamma_k^(4)")
    },
  )
})
