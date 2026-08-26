#import "@preview/cetz:0.5.2"

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#let transition(coords, name: none, content: none, color: black) = {
  cetz.draw.group(name: name, {
    let top-pos = (rel: (0, 0.5), to: coords)
    let bottom-pos = (rel: (0, -0.5), to: coords)

    cetz.draw.line(top-pos, bottom-pos, stroke: (thickness: 4pt, paint: color))

    cetz.draw.anchor("default", coords)
    cetz.draw.anchor("center", coords)
    cetz.draw.anchor("left", coords)
    cetz.draw.anchor("right", coords)
    cetz.draw.anchor("top", top-pos)
    cetz.draw.anchor("bottom", bottom-pos)

    if content != none {
      cetz.draw.content((rel: (-0, -1.0), to: coords))[
        #set text(size: 15pt)
        #content
      ]
    }
  })
}

#let place(coords, name: none, content: none, token: false) = {
  cetz.draw.group(name: name, {
    let radius = 0.4

    cetz.draw.arc(coords, start: 0deg, stop: 360deg, radius: radius)

    cetz.draw.anchor("default", coords)
    cetz.draw.anchor("center", coords)
    cetz.draw.anchor("north", (rel: (0, radius), to: coords))
    cetz.draw.anchor("south", (rel: (0, -radius), to: coords))
    cetz.draw.anchor("east", (rel: (radius, 0), to: coords))
    cetz.draw.anchor("west", (rel: (-radius, 0), to: coords))
    cetz.draw.anchor("left", (rel: (-2 * radius, 0), to: coords))
    cetz.draw.anchor("right", (rel: (0, 0), to: coords))
    let diag = radius * calc.cos(45deg)
    cetz.draw.anchor("north-east", (rel: (diag, diag), to: coords))
    cetz.draw.anchor("north-west", (rel: (-diag, diag), to: coords))
    cetz.draw.anchor("south-east", (rel: (diag, -diag), to: coords))
    cetz.draw.anchor("south-west", (rel: (-diag, -diag), to: coords))

    if content != none {
      cetz.draw.arc(
        (rel: (-.1, 0), to: coords),
        start: 0deg,
        stop: 360deg,
        radius: 0.4 - 0.1,
      )
    }

    if token {
      cetz.draw.arc(
        (rel: (-.35, 0), to: coords),
        start: 0deg,
        stop: 360deg,
        radius: 0.4 - 0.35,
        fill: black,
      )
    }

    if content != none {
      cetz.draw.content((rel: (-0.35, -0.7), to: coords))[
        #set text(size: 15pt)
        #content
      ]
    }
  })
}
#let calc-bend-pt(start, end, bend) = {
  let midpoint = (
    (start.at(0) + end.at(0)) / 2,
    (start.at(1) + end.at(1)) / 2,
    (start.at(2) + end.at(2)) / 2,
  )
  let orthogonal = (start.at(1) - end.at(1), end.at(0) - start.at(0), 0)
  cetz.vector.add(midpoint, cetz.vector.scale(orthogonal, bend))
}
#let curve(start, end, mark: none, bend: 0) = {
  cetz.draw.bezier(
    start,
    end,
    ((start, end) => calc-bend-pt(start, end, bend), start, end),
    mark: mark,
  )
}
#let bent-line(start, end, mark: none, bend: 0) = {
  let bend-point = ((start, end) => calc-bend-pt(start, end, bend), start, end)
  cetz.draw.line(start, bend-point)
  cetz.draw.line(bend-point, end, mark: mark)
}

#cetz.canvas({
  cetz.draw.group(ctx => {
    cetz.draw.scale(1)
    cetz.draw.translate((-0.2, 0.3, 0))
    cetz.draw.set-origin((3, 0.3))

    for (x-pos, name, label) in (
      (0, "t0", $T_(frak(I))$),
      (4, "t2in", $T_(2_frak(I))$),
      (8, "t2out", $T_(2_frak(O))$),
      (12, "t1in", $T_(1_frak(I))$),
      (16, "t1out", $T_(1_frak(O))$),
      (20, "t6", $T_(frak(O))$),
    ) { transition((x-pos, 0), name: name, content: label) }

    for (rel, target, name, label, token) in (
      ((2.3, 0), "t0.right", "p02", $τ_(02)$, false),
      ((2.3, -1), "t2in.right", "pr2", $ρ_(2)$, false),
      ((2.3, 1), "t2in.right", "p22", $τ_(22)$, false),
      ((2.3, 0), "t2out.right", "p21", $τ_(21)$, false),
      ((2.3, -1), "t1in.right", "pr1", $ρ_(1)$, false),
      ((2.3, 1), "t1in.right", "p11", $τ_(11)$, false),
      ((2.3, 0), "t1out.right", "p16", $τ_(16)$, false),
      ((3, -4), "t2out.right", "p61", $τ_(60)$, true),
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
    bent-line("t6.right", "p61.right", mark: (end: ">"), bend: 0.2)
    bent-line("p61.left", "t0.left", mark: (end: ">"), bend: 0.18)
  })
});
