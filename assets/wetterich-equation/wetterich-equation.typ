#import "@preview/cetz:0.4.1": canvas, draw
#import "@preview/modpattern:0.1.0": modpattern
#import draw: circle, content, line, mark

#set page(width: auto, height: auto, margin: 8pt)

// Define styles and constants
#let radius = 1.25 // \lrad in original
#let med-rad = 0.175 * radius // \mrad
#let small-rad = 0.15 * radius // \srad

// Create hatched pattern for vertices
#let hatched = modpattern(
  (.1cm, .1cm),
  std.line(start: (0%, 100%), end: (100%, 0%), stroke: 0.5pt),
  background: white,
)

// Helper functions
#let cross(pos, label: none, rel-label: (0, 0), name: none, ..rest) = {
  let txt = text(size: 16pt, baseline: -0.2pt)[$times.circle$]
  content(pos, txt, stroke: none, fill: white, frame: "circle", padding: -2.75pt, name: name)
  if label != none {
    let label-pos = if rel-label != none { (rel: rel-label, to: pos) } else { pos }
    content(label-pos, $#label$, ..rest)
  }
}

#let dressed-vertex(pos, label: none, rel-label: none, name: none, radius: med-rad, ..rest) = {
  circle(pos, radius: radius, fill: hatched, name: name, stroke: 0.5pt)
  if label != none {
    let label-pos = if rel-label != none { (rel: rel-label, to: pos) } else { pos }
    content(label-pos, $#label$, ..rest)
  }
}

#canvas({
  // Main loop
  circle((0, 0), radius: radius, stroke: 1pt, name: "loop")

  // Add momentum arrows and labels around loop
  for (ii, pos) in ((1, "0.25"), (2, "0.75")) {
    let angle = float(pos) * 360
    let label-angle = (angle - 3) * 1deg

    // Add momentum labels
    let rel-pos = (0.75 * radius * calc.cos(label-angle), 0.75 * radius * calc.sin(label-angle))
    content(
      (rel: rel-pos, to: "loop"),
      $p_#ii$,
      size: 8pt,
    )

    // Add arrow marks
    mark(
      symbol: "stealth",
      (name: "loop", anchor: angle * 1deg),
      (name: "loop", anchor: (angle + 1) * 1deg),
      ..(width: .25, length: .15, stroke: .7pt, angle: 60deg, scale: .7, fill: black),
    )
  }

  // Add regulator cross with label
  cross(
    (-radius, 0),
    label: $partial_k R_(k,i j)(p_1,p_2)$,
    rel-label: (-0.25, 0),
    name: "regulator",
    anchor: "east",
  )

  // Add dressed vertex with inverse propagator
  dressed-vertex(
    (radius, 0),
    label: $[Gamma_k^((2)) + R_k]_(j i)^(-1)(p_2,p_1)$,
    rel-label: (0.25, 0),
    name: "vertex",
    anchor: "west",
  )
})
