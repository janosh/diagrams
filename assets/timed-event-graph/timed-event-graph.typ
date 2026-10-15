#import "@preview/cetz:0.5.2"

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 12pt)

// Transition: a thick vertical bar, entered and left at its center.
#let transition(coords, name: none, content: none) = {
  cetz.draw.group(name: name, {
    cetz.draw.line((rel: (0, 0.5), to: coords), (rel: (0, -0.5), to: coords), stroke: 4pt)
    cetz.draw.anchor("left", coords)
    cetz.draw.anchor("right", coords)
    if content != none {
      cetz.draw.content((rel: (0, -1.0), to: coords), text(size: 15pt, content))
    }
  })
}

// Place: a double circle whose rightmost point sits at `coords` (cetz arcs start at their position).
#let place(coords, name: none, content: none, token: false) = {
  cetz.draw.group(name: name, {
    let radius = 0.4
    let ring(offset, ring-radius, ..style) = cetz.draw.arc(
      (rel: (-offset, 0), to: coords),
      start: 0deg,
      stop: 360deg,
      radius: ring-radius,
      ..style,
    )
    ring(0, radius)
    cetz.draw.anchor("left", (rel: (-2 * radius, 0), to: coords))
    cetz.draw.anchor("right", coords)
    if content != none { ring(.1, radius - 0.1) }
    if token { ring(.35, radius - 0.35, fill: black) }
    if content != none {
      cetz.draw.content((rel: (-0.35, -0.7), to: coords), text(size: 15pt, content))
    }
  })
}

// Arcs bend through a point offset perpendicular to the chord's midpoint.
#let bend-point(start, end, bend) = (
  (start, end) => {
    let midpoint = cetz.vector.scale(cetz.vector.add(start, end), 0.5)
    let orthogonal = (start.at(1) - end.at(1), end.at(0) - start.at(0), 0)
    cetz.vector.add(midpoint, cetz.vector.scale(orthogonal, bend))
  },
  start,
  end,
)
#let curve(start, end, mark: none, bend: 0) = {
  cetz.draw.bezier(start, end, bend-point(start, end, bend), mark: mark)
}
#let bent-line(start, end, mark: none, bend: 0) = {
  cetz.draw.line(start, bend-point(start, end, bend))
  cetz.draw.line(bend-point(start, end, bend), end, mark: mark)
}

#cetz.canvas({
  for (idx, (name, label)) in (
    ("t0", $T_(frak(I))$),
    ("t2in", $T_(2_frak(I))$),
    ("t2out", $T_(2_frak(O))$),
    ("t1in", $T_(1_frak(I))$),
    ("t1out", $T_(1_frak(O))$),
    ("t6", $T_(frak(O))$),
  ).enumerate() { transition((4 * idx, 0), name: name, content: label) }

  for (rel, target, name, label, token) in (
    ((2.3, 0), "t0.right", "p02", $τ_(02)$, false),
    ((2.3, -1), "t2in.right", "pr2", $ρ_(2)$, false),
    ((2.3, 1), "t2in.right", "p22", $τ_(22)$, false),
    ((2.3, 0), "t2out.right", "p21", $τ_(21)$, false),
    ((2.3, -1), "t1in.right", "pr1", $ρ_(1)$, false),
    ((2.3, 1), "t1in.right", "p11", $τ_(11)$, false),
    ((2.3, 0), "t1out.right", "p16", $τ_(16)$, false),
    ((3, -4), "t2out.right", "p60", $τ_(60)$, true),
  ) { place((rel: rel, to: target), name: name, content: label, token: token) }

  // the critical path threads every node left to right in one chain
  let chain = ("t0", "p02", "t2in", "pr2", "t2out", "p21", "t1in", "pr1", "t1out", "p16", "t6")
  for (from, to) in chain.zip(chain.slice(1)) {
    cetz.draw.line(from + ".right", to + ".left", mark: (end: ">"))
  }
  // holding places branch off each input transition and rejoin at its output
  for (from, to) in (("t2in", "p22"), ("p22", "t2out"), ("t1in", "p11"), ("p11", "t1out")) {
    curve(from + ".right", to + ".left", mark: (end: ">"), bend: 0.3)
  }
  // the marked feedback place returns the output event to the input
  bent-line("t6.right", "p60.right", mark: (end: ">"), bend: 0.2)
  bent-line("p60.left", "t0.left", mark: (end: ">"), bend: 0.18)
})
