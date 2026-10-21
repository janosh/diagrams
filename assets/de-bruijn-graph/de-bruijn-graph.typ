#import "@preview/cetz:0.5.3": canvas, draw
#import draw: arc, circle, content, line

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(font: "DejaVu Sans Mono", size: 12pt)

#let pure-red = rgb(255, 0, 0)
#let node-r = .43
#let tour-r = .58
#let red-dash = (dash: "dashed", paint: pure-red, thickness: 1.2pt)

// point on circle of radius rr around center at angle (degrees)
#let on-ring(center, ang, rr) = (
  center.at(0) + rr * calc.cos(ang * 1deg),
  center.at(1) + rr * calc.sin(ang * 1deg),
)

#canvas({
  let unit = 2.5
  let nodes = (
    AT: (0, 2),
    TG: (1, 2),
    GG: (2, 2),
    GC: (2, 1),
    CG: (2, 0),
    GT: (1, 0),
    CA: (0, 0),
    AA: (0, 1),
  )
  let pos(name) = nodes.at(name).map(coord => coord * unit)

  // solid directed edges with labeled midpoints
  let edge(from, to, label, frac: .5) = {
    line(from, to, mark: (end: "stealth", fill: black, scale: .9), stroke: black + 1.7pt)
    let (x0, y0) = pos(from)
    let (x1, y1) = pos(to)
    let mid = (x0 + (x1 - x0) * frac, y0 + (y1 - y0) * frac)
    content(mid, label, frame: "rect", fill: rgb("#cdd3da"), stroke: none, padding: 1.5pt)
  }

  for (name, _) in nodes {
    circle(pos(name), radius: node-r, fill: rgb("#cdd3da"), stroke: 1.7pt, name: name)
    content(pos(name), raw(name))
  }

  // red dashed Eulerian tour: arcs around nodes joined by straight segments
  // connecting each arc's stop angle to the next arc's start angle
  let tour = (
    ("AT", -200, -340),
    ("TG", -200, -340),
    ("GG", -200, -400),
    ("GC", -320, -400),
    ("CG", -320, -520),
    ("GT", -380, -580),
    ("TG", -500, -440),
    ("GC", -550, -540),
    ("CA", -660, -590),
    ("AA", -490, -590),
    ("AT", -490, -590),
  )
  // The tour visits every 3-mer edge once, from its 2-mer prefix to its 2-mer suffix.
  for ((from, ..), (to, ..)) in tour.windows(2) {
    // shift the GCA label off its crossing with the GTG edge
    edge(from, to, [#(from + to.last())], frac: if from + to == "GCCA" { .3 } else { .5 })
  }

  for (name, start, stop) in tour {
    arc(
      pos(name),
      start: start * 1deg,
      stop: stop * 1deg,
      radius: tour-r,
      anchor: "origin",
      stroke: red-dash,
    )
  }
  for ((name-a, _, stop-a), (name-b, start-b, _)) in tour.windows(2) {
    line(
      on-ring(pos(name-a), stop-a, tour-r),
      on-ring(pos(name-b), start-b, tour-r),
      stroke: red-dash,
    )
  }
})
