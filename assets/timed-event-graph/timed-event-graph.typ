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
#let calc-bend-pt(a, b, e) = {
  let mid-pt = (0, 0, 0)
  mid-pt.at(0) = (a.at(0) + b.at(0)) / 2
  mid-pt.at(1) = (a.at(1) + b.at(1)) / 2
  mid-pt.at(2) = (a.at(2) + b.at(2)) / 2

  let orth-vec = (0, 0, 0)
  orth-vec.at(0) = a.at(1) - b.at(1)
  orth-vec.at(1) = b.at(0) - a.at(0)

  let scaled-orth-vec = cetz.vector.scale(orth-vec, e)

  return cetz.vector.add(mid-pt, scaled-orth-vec)
}
#let curve(a, b, mark: none, bend: 0) = {
  cetz.draw.bezier(a, b, ((a, b) => calc-bend-pt(a, b, bend), a, b), mark: mark)
}
#let bent-line(a, b, mark: none, bend: 0) = {
  let s = ((a, b) => calc-bend-pt(a, b, bend), a, b)
  cetz.draw.line(a, s)
  cetz.draw.line(s, b, mark: mark)
}

#cetz.canvas({
  cetz.draw.group(ctx => {
    cetz.draw.scale(1)
    cetz.draw.translate((-0.2, 0.3, 0))
    cetz.draw.set-origin((3, 0.3))

    transition((0, 0), name: "t0", content: $T_frak(I)$)
    transition((4, 0), name: "t2in", content: $T_(2_frak(I))$)
    transition((8, 0), name: "t2out", content: $T_(2_frak(O))$)
    transition((12, 0), name: "t1in", content: $T_(1_frak(I))$)
    transition((16, 0), name: "t1out", content: $T_(1_frak(O))$)
    transition((20, 0), name: "t6", content: $T_frak(O)$)

    place((rel: (2.3, 0), to: "t0.right"), name: "p02", content: $τ_(02)$)
    place((rel: (2.3, -1), to: "t2in.right"), name: "pr2", content: $ρ_(2)$)
    place((rel: (2.3, 1), to: "t2in.right"), name: "p22", content: $τ_(22)$)
    place((rel: (2.3, 0), to: "t2out.right"), name: "p21", content: $τ_(21)$)
    place((rel: (2.3, -1), to: "t1in.right"), name: "pr1", content: $ρ_(1)$)
    place((rel: (2.3, 1), to: "t1in.right"), name: "p11", content: $τ_(11)$)
    place((rel: (2.3, 0), to: "t1out.right"), name: "p16", content: $τ_(16)$)
    place(
      (rel: (3, -4), to: "t2out.right"),
      name: "p61",
      content: $τ_(60)$,
      token: true,
    )

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
