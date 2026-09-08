#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, line, mark

#set page(width: 780pt, height: auto, margin: 22pt, fill: white)
#set text(font: "Avenir Next", size: 10.5pt, fill: rgb("#19324f"))
#set par(leading: 0.55em)

// Measure each drawing before fitting it; keep labels and geometry together.
#let fit-figure(body, height: 170pt) = layout(size => {
  let bounds = measure(body)
  let factor = calc.min(size.width / bounds.width, height / bounds.height)
  box(width: 100%, align(center + horizon, std.scale(factor * 100%, reflow: true, body)))
})
#let card(title, body, caption, height: 145pt) = block(
  width: 100%,
  inset: 12pt,
  radius: 8pt,
  fill: rgb("#f3f6fa"),
  breakable: false,
)[
  #text(size: 13pt, weight: "bold", title)
  #v(8pt)
  #fit-figure(body, height: height)
  #v(7pt)
  #caption
]
#let takeaway(body) = block(
  width: 100%,
  inset: 12pt,
  radius: 6pt,
  fill: rgb("#e9f5f2"),
  breakable: false,
)[#body]

// Diagonal hatching marking a vertex as dressed rather than bare.
#let hatched = tiling(size: (.1cm, .1cm))[
  #place(std.rect(width: 100%, height: 100%, fill: white, stroke: none))
  #place(std.line(start: (0%, 100%), end: (100%, 0%), stroke: 0.4pt))
]

// Hairline tying a label to whatever it names: pole callouts, semi-axis leaders,
// off-diagram vertex captions.
#let leader = (paint: rgb("#78828C"), thickness: 0.5pt)

// === 1  Recognize the two topologies ===
#let figure-0 = [

  #let radius = 1 // \radius in original
  // Dressed vertices use hatching; trailing options position their labels.
  #let vertex(pos, label, offset, radius: 0.25 * radius, name: none, ..style) = {
    circle(pos, radius: radius, fill: hatched, name: name, stroke: auto)
    content((rel: offset, to: pos), $#label$, anchor: "south", ..style)
  }

  #canvas({
    draw.set-style(legend: (fill: white))
    // Gamma^(3) loop: two dressed three-point vertices on the external legs
    circle((0, 0), radius: radius, stroke: 1pt, name: "loop")
    line((-2 * radius, 0), (-radius, 0), stroke: 1pt, name: "left-external")
    line((radius, 0), (2 * radius, 0), stroke: 1pt, name: "right-external")
    vertex((-radius, 0), $Gamma_k^((3))$, (-0.3, 0.3), name: "vertex-left")
    vertex((radius, 0), $Gamma_k^((3))$, (0.3, 0.3), name: "vertex-right")

    content((3 * radius, 0), $-$)

    // Gamma^(4) tadpole: one dressed four-point vertex on a single external line
    circle((5 * radius, 0), radius: radius, stroke: 1pt, name: "loop2")
    line((3 * radius, -radius), (7 * radius, -radius), stroke: 1pt, name: "external2")
    vertex((5 * radius, -radius), $Gamma_k^((4))$, (0, 0.35), name: "vertex-four")
  })
]

// === 2  Resolve the internal labels ===
#let figure-1 = [

  #let momentum-arrow = (
    mark: (end: "stealth", fill: black, scale: .5),
    stroke: (thickness: 0.75pt),
  )

  #let radius = 1.25
  #let med-rad = 0.175 * radius
  // Dressed vertices use hatching; trailing options position their labels.
  #let vertex(pos, label, offset, radius: 0.15 * radius, name: none, ..style) = {
    circle(pos, radius: radius, fill: hatched, name: name, stroke: 0.5pt)
    content((rel: offset, to: pos), $#label$, ..style)
  }
  // Momentum labels and arrowheads around the loop; fractions set their positions.
  #let momenta(momenta) = {
    for (idx, fraction) in momenta {
      let turn = fraction * 360deg
      // trail the label a few degrees behind its arrowhead
      let lag = turn - 3deg
      let offset = ((0.75 * radius) * calc.cos(lag), (0.75 * radius) * calc.sin(lag))
      content((rel: offset, to: "loop"), $p_#idx$, size: 8pt)
      mark(
        (name: "loop", anchor: turn),
        (name: "loop", anchor: turn + 1deg),
        symbol: "stealth",
        width: .25,
        length: .15,
        stroke: .7pt,
        scale: .7,
        angle: 60deg,
        fill: black,
      )
    }
  }

  // Momentum arrow of length 0.6*radius, drawn just above height `y`.
  #let momentum(idx, x-center, y) = {
    let half = 0.3 * radius
    let name = "q" + str(idx)
    line(
      (x-center - half, y + 0.15),
      (x-center + half, y + 0.15),
      ..momentum-arrow,
      name: name,
    )
    content((rel: (0, 0.3), to: name + ".mid"), $q_#idx$)
  }

  // Gamma^(3) box: loop closed by two dressed propagators, one on each side

  #stack(
    dir: ltr,
    spacing: 12pt,
    canvas({
      circle((0, 0), radius: radius, stroke: 1pt, name: "loop")
      momenta(((1, 0.125), (2, 0.375), (3, 0.625), (4, 0.875)))

      vertex((0, radius), $G_(k,i j)(p_1,p_2)$, (0, 0.2), anchor: "south", name: "vertex-top")
      vertex((0, -radius), $G_(k,k l)(p_3,p_4)$, (0, -0.3), anchor: "north", name: "vertex-bottom")

      line((-2 * radius, 0), (-radius, 0), stroke: 1pt, name: "left-external")
      line((radius, 0), (2 * radius, 0), stroke: 1pt, name: "right-external")
      content("left-external.start", $phi_a$, anchor: "east", padding: 0.1)
      content("right-external.end", $phi_b$, anchor: "west", padding: 0.1)
      momentum(1, -1.6 * radius, 0)
      momentum(2, 1.6 * radius, 0)

      for (name, side, label) in (
        ("gamma-left", -1, $Gamma_(k,a j k)^((3))(q_1,p_2,-p_3)$),
        ("gamma-right", 1, $Gamma_(k,b l i)^((3))(-q_2,-p_1,p_4)$),
      ) {
        content((side * 2.1 * radius, radius), label, name: name)
        line(name, (side * radius, 0), stroke: leader)
        circle((side * radius, 0), radius: med-rad, fill: hatched, stroke: 0.5pt)
      }
    }),
    canvas({
      circle((0, 0), radius: radius, stroke: 1pt, name: "loop")
      momenta(((1, 0), (2, 0.5)))

      vertex((0, radius), $G_(k,i j)(p_1,p_2)$, (0, 0.2), anchor: "south", name: "vertex-top")

      line((-2 * radius, -radius), (2 * radius, -radius), stroke: 1pt, name: "external")
      content((rel: (-0.1, 0), to: "external.start"), $phi_a$, anchor: "east")
      content((rel: (0.1, 0), to: "external.end"), $phi_b$, anchor: "west")
      momentum(1, -1.6 * radius, -radius)
      momentum(2, 1.6 * radius, -radius)

      vertex(
        (0, -radius),
        $Gamma_(k,a b j i)^((4))(q_1,-q_2,-p_1,p_2)$,
        (0, -0.3),
        radius: med-rad,
        anchor: "north",
      )
    }),
  )
]

// === 3  Insert the changing cutoff ===
#let figure-2 = [

  // Regulator insertion: a circled cross on an opaque white disc.
  #let cross(pos, label, offset, name: none) = {
    content(
      pos,
      text(size: 16pt)[$times.o$],
      stroke: none,
      fill: white,
      frame: "circle",
      padding: -2.5pt,
      name: name,
    )
    content((rel: offset, to: pos), $#label$)
  }

  #let radius = 1.25 // \lrad in original
  #let med-rad = 0.13 * radius
  // Dressed vertices use hatching; trailing options position their labels.
  #let vertex(pos, label, offset, radius: 0.1 * radius, name: none, ..style) = {
    circle(pos, radius: radius, fill: hatched, name: name, stroke: 0.5pt)
    content((rel: offset, to: pos), $#label$, ..style)
  }
  #let q-arrow = (
    mark: (end: "barbed", fill: black, scale: .5, width: .25, length: .2, angle: 60deg),
    stroke: .5pt,
  )

  #let at(pos) = (rel: pos, to: "main-loop")
  // Point on the loop at `turn` around it, measured counter-clockwise from 3 o'clock.
  #let on-loop(turn) = at((radius * calc.cos(turn), radius * calc.sin(turn)))

  // Barbed momentum arrows around the loop, indexed clockwise from the top.
  // Momentum labels and arrowheads around the loop; fractions set their positions.
  #let loop-momenta(momenta) = {
    for (idx, fraction) in momenta {
      let turn = fraction * 360deg
      // trail the label a few degrees behind its arrowhead
      let lag = turn - 3deg
      let offset = ((0.75 * radius) * calc.cos(lag), (0.75 * radius) * calc.sin(lag))
      content((rel: offset, to: "main-loop"), $p_#idx$, size: 8pt)
      mark(
        (name: "main-loop", anchor: turn),
        (name: "main-loop", anchor: turn + 0.1deg),
        symbol: "barbed",
        width: .25,
        length: .15,
        stroke: .7pt,
        scale: .7,
        angle: 70deg,
        fill: none,
      )
    }
  }

  // Straight external legs meeting the loop at 9 and 3 o'clock, each capped by a vertex.
  #let side-legs() = {
    for (name, side, turn, label) in (
      ("left-external", -1, 180deg, $phi_a$),
      ("right-external", 1, 0deg, $phi_b$),
    ) {
      line(on-loop(turn), at((side * 2 * radius, 0)), stroke: 1pt, name: name)
      content((rel: (side * 0.2, -0.3), to: name + ".mid"), label)
    }
    for (side, name) in ((-1, "left"), (1, "right")) {
      circle(
        at((side * radius, 0)),
        radius: med-rad,
        fill: hatched,
        stroke: 0.5pt,
        name: "vertex-" + name + "-external",
      )
    }
  }

  // Incoming q_1 and outgoing q_2, both pointing right, at height `y`.
  #let external-momenta(inner, outer, y: 0.15) = {
    for (idx, x-start, x-end) in ((1, -outer, -inner), (2, inner, outer)) {
      let name = "q" + str(idx) + "-arrow"
      line(at((x-start, y)), at((x-end, y)), ..q-arrow, name: name)
      content(name + ".mid", $q_#idx$, anchor: "south", padding: (0, 0, 2pt))
    }
  }

  // Off-diagram Gamma^(3) label tied to the vertex it names by a hairline.
  #let gamma-callout(name, pos, label, target) = {
    content(at(pos), label, name: name)
    line(name, target, stroke: leader)
  }

  // Regulator at the top, dressed propagators at 3, 9 and 6 o'clock

  #stack(
    dir: ltr,
    spacing: 12pt,
    canvas({
      circle((0, 0), radius: radius, stroke: 1pt, name: "main-loop")
      loop-momenta(((6, 0.0625), (1, 0.1875), (2, 0.3125), (3, 0.4375), (4, 0.625), (5, 0.875)))

      cross(at((0, radius)), $partial_k R_(k,i j) (p_1,p_2)$, (0, 0.5), name: "regulator")
      vertex(on-loop(135deg), $G_(k,j k)(p_2,p_3)$, (-1.2, 0.3))
      vertex(on-loop(45deg), $G_(k,n i)(p_6,p_1)$, (1.2, 0.3))
      vertex(at((0, -radius)), $G_(k,l m) (p_4,p_5)$, (0, -.8))

      side-legs()
      external-momenta(1.4, 2.3)
      gamma-callout("gamma-left", (-2, -1.5), $Gamma_(k,a k l)^((3))(q_1,p_3,-p_4)$, at((
        -radius,
        0,
      )))
      gamma-callout("gamma-right", (2, -1.5), $Gamma_(k,b m n)^((3))(-q_2,p_5,-p_6)$, at((
        radius,
        0,
      )))
    }),
    canvas({
      circle((0, 0), radius: radius, stroke: 1pt, name: "main-loop")
      loop-momenta(((6, 0.125), (3, 0.375), (4, 0.5625), (1, 0.6875), (2, 0.8125), (5, 0.9375)))

      cross(at((0, -radius)), $partial_k R_(k,i j)(p_1,p_2)$, (0, -0.5))
      vertex(on-loop(-45deg), $G_(k,j m)(p_2,p_5)$, (1.2, -0.3))
      vertex(on-loop(225deg), $G_(k,l i)(p_4,p_1)$, (-1.2, -0.3))
      vertex(at((0, radius)), $G_(k,n k)(p_6,p_3)$, (0, 0.3))

      side-legs()
      external-momenta(1.6, 2.4)
      // pushed further out than in the first diagram to clear the propagator labels
      gamma-callout(
        "gamma-left",
        (-2.4, 1.1),
        $Gamma_(k,a k l)^((3))(q_1,p_3,-p_4)$,
        "vertex-left-external",
      )
      gamma-callout(
        "gamma-right",
        (2.5, 1.1),
        $Gamma_(k,b m n)^((3))(-q_2,p_5,-p_6)$,
        "vertex-right-external",
      )
    }),
    canvas({
      circle((0, 0), radius: radius, stroke: 1pt, name: "main-loop")
      loop-momenta(((1, 0.125), (2, 0.375), (3, 0.625), (4, 0.875)))

      cross(at((0, radius)), $partial_k R_(k,i j)(p_1,p_2)$, (0, 0.4))
      vertex(at((-radius, 0)), $G_(k,j k)(p_2,p_3)$, (-1.2, 0))
      vertex(at((radius, 0)), $G_(k,l i)(p_4,p_1)$, (1.2, 0))

      line(
        at((-2.2 * radius, -radius)),
        at((2.2 * radius, -radius)),
        stroke: 1pt,
        name: "external-line",
      )
      circle(at((0, -radius)), radius: med-rad, fill: hatched, stroke: 0.5pt)
      content(at((0, -2)), $Gamma_(k,a b k l)^((4))(q_1,-q_2,p_3,-p_4)$)
      content(at((-2, -1.5)), $phi_a$)
      content(at((2, -1.5)), $phi_b$)

      external-momenta(1.3, 2.3, y: -radius + 0.15)
    }),
  )
]

#text(size: 27pt, weight: "bold")[Regulated and Unregulated Propagators]
#v(5pt)
Compare the loop structures before and after inserting a scale-dependent regulator. The compact view introduces the topology; the detailed views show momentum and field indices.
#v(14pt)
#grid(
  columns: (1fr,),
  gutter: 12pt,
  card(
    [1  Recognize the two topologies],
    figure-0,
    [A loop with two three-point vertices and a tadpole with one four-point vertex. Signs and symmetry factors belong to the defining equation and conventions.],
  ),
  card(
    [2  Resolve the internal labels],
    figure-1,
    [The same building blocks with explicit external legs and loop momenta. Without a regulator, integration is not restricted by the running cutoff.],
  ),
  card(
    [3  Insert the changing cutoff],
    figure-2,
    [Each circled cross is $partial_k R_k$. Different insertion positions contribute to the scale derivative of the two-point function; these sketches show the terms, not their prefactors.],
  ),
)
#v(12pt)
#takeaway[*The cross makes a flow diagram scale selective.* With a suitable regulator, low-momentum modes are suppressed and the derivative weights the modes being integrated out near scale $k$. $G_k$ is a full propagator; $Gamma_k^((n))$ couples $n$ field legs. Hatched discs denote dressed vertices.]
