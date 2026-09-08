#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, line

#set page(width: 780pt, height: auto, margin: 22pt, fill: none)
#set text(font: "Avenir Next", size: 10.5pt, fill: rgb("#19324f"))
#set par(leading: 0.55em)

#let card-grid(columns: 2, ..cards) = layout(size => {
  let rows = cards
    .pos()
    .chunks(columns)
    .map(row => {
      let ratios = row.map(card => {
        let bounds = measure(card.at(1))
        bounds.width / bounds.height
      })
      let available = size.width - 12pt * (row.len() - 1) - 24pt * row.len()
      grid(
        columns: ratios.map(ratio => 24pt + available * ratio / ratios.sum()),
        gutter: 12pt,
        ..row.map(((title, body, caption)) => block(
          width: 100%,
          inset: 12pt,
          radius: 8pt,
          fill: rgb("#cdd3da"),
          breakable: false,
        )[
          #text(size: 13pt, weight: "bold", title)
          #v(8pt)
          // Fill the available width; each drawing keeps its own aspect ratio.
          #layout(size => std.scale(
            size.width / measure(body).width * 100%,
            reflow: true,
            body,
          ))
          #v(7pt)
          #caption
        ]),
      )
    })
  stack(dir: ttb, spacing: 12pt, ..rows)
})
#let takeaway = block.with(
  width: 100%,
  inset: 12pt,
  radius: 6pt,
  fill: rgb("#c6d8d2"),
  breakable: false,
)

// Diagonal hatching marking a vertex as dressed rather than bare.
#let hatched = tiling(size: (.1cm, .1cm))[
  #place(std.rect(width: 100%, height: 100%, fill: rgb("#cdd3da"), stroke: none))
  #place(std.line(start: (0%, 100%), end: (100%, 0%), stroke: 0.4pt))
]

// The propagator and regulator insertion share external legs and momentum arrows.
#let two-point(regulator: false) = canvas({
  let momentum-arrow = (
    mark: (end: "stealth", fill: black, scale: .5),
    stroke: (thickness: 0.75pt),
  )
  line((-2.25, 0), (2.25, 0), stroke: 1pt, name: "a-to-b")
  content("a-to-b.start", $phi_a$, anchor: "east", padding: 3pt)
  content("a-to-b.end", $phi_b$, anchor: "west", padding: 3pt)
  for (idx, x-start) in ((1, -2), (2, 1)) {
    line((x-start, 0.15), (x-start + 1, 0.15), ..momentum-arrow)
    content((x-start + 0.5, 0.45), $p_#idx$)
  }
  if regulator {
    content(
      (0, 0),
      text(size: 16pt, baseline: -0.3pt)[$times.o$],
      stroke: none,
      fill: rgb("#cdd3da"),
      frame: "circle",
      padding: -2.4pt,
      name: "vertex",
    )
  } else {
    circle((0, 0), radius: 0.25, fill: hatched, name: "vertex")
  }
  content(
    (rel: (0, 0.5), to: "vertex"),
    if regulator { $partial_t R_(k,a b)(p_1,p_2)$ } else { $G_(k,a b)(p_1,p_2)$ },
  )
})

// === 3  Three-point vertex ===
#let figure-2 = [

  #canvas({
    let arrow = (mark: (end: "stealth", fill: black, scale: .3), stroke: (thickness: 0.5pt))

    line((-2, 0), (0, 0), name: "in")
    line((0, 0), (1.5, 1.5), name: "up")
    line((0, 0), (1.5, -1.5), name: "down")
    content("in.start", $phi_a$, anchor: "east", padding: 1pt)
    content("up.end", $phi_b$, anchor: "south-west", padding: 1pt)
    content("down.end", $phi_c$, anchor: "north-west", padding: 1pt)

    // momentum arrows point inward along each leg
    for (idx, start, end, label-offset) in (
      (1, (-1.7, 0.15), (-0.7, 0.15), (0, 0.3)),
      (2, (1.0, 1.2), (0.3, 0.5), (-0.3, 0.3)),
      (3, (1.4, -1.2), (0.6, -0.4), (0.3, 0.3)),
    ) {
      line(start, end, ..arrow, name: "p" + str(idx))
      content((rel: label-offset, to: "p" + str(idx)), $p_#idx$)
    }

    circle((0, 0), radius: 0.25, fill: hatched, name: "vertex")
    content(
      (rel: (0.35, -.05), to: "vertex"),
      $Gamma_(k,a b c)^((3))(p_1,p_2,p_3)$,
      anchor: "west",
    )
  })
]

// === 4  Four-point vertex ===
#let figure-3 = [

  // draw the four-point vertex on axes rotated 45 deg so the legs run diagonally
  #let rot45(x, y) = ((x - y) / calc.sqrt(2), (x + y) / calc.sqrt(2))

  #canvas({
    let arrow = (mark: (end: "stealth", fill: black, scale: .3), stroke: (thickness: 0.5pt))

    line(rot45(-2, 0), rot45(2, 0), name: "horiz")
    line(rot45(0, 2), rot45(0, -2), name: "vert")
    content("horiz.start", $phi_a$, anchor: "north-east", padding: -1pt)
    content("horiz.end", $phi_c$, anchor: "south-west", padding: 1pt)
    content("vert.start", $phi_b$, anchor: "south-east", padding: 1pt)
    content("vert.end", $phi_d$, anchor: "north-west", padding: 1pt)

    // all four momenta flow into the vertex
    for (idx, outer, inner, label-offset) in (
      (1, (-1.7, 0.15), (-0.7, 0.15), (-0.1, 0.3)),
      (3, (1.7, 0.15), (0.7, 0.15), (-0.1, 0.3)),
      (2, (0.15, 1.7), (0.15, 0.7), (0.3, 0.2)),
      (4, (0.15, -1.7), (0.15, -0.7), (0.3, 0.1)),
    ) {
      line(rot45(..outer), rot45(..inner), ..arrow, name: "p" + str(idx))
      content((rel: label-offset, to: "p" + str(idx)), $p_#idx$)
    }

    circle(rot45(0, 0), radius: 0.25, fill: hatched, name: "vertex")
    content(
      (rel: (0.35, -.05), to: "vertex"),
      $Gamma_(k,a b c d)^((4))(p_1,p_2,p_3,p_4)$,
      anchor: "west",
    )
  })
]

Read a functional renormalization-group diagram one symbol at a time. Lines connect fields; vertices encode their interactions.
#v(14pt)
#card-grid(
  (
    [1  Propagator],
    two-point(),
    [The full propagator $G_k$ describes a two-point correlation at scale $k$. “Full” includes interaction corrections.],
  ),
  (
    [2  Regulator insertion],
    two-point(regulator: true),
    [The circled cross means $partial_k R_k$: change the momentum cutoff. It is an insertion on a line, not a new particle.],
  ),

  (
    [3  Three-point vertex],
    figure-2,
    [$Gamma_k^((3))$ couples three field legs. Each $p_i$ labels a momentum; letter indices label field components.],
  ),
  (
    [4  Four-point vertex],
    figure-3,
    [$Gamma_k^((4))$ couples four field legs. The hatched disc marks a dressed vertex, including fluctuation effects.],
  ),
)
#v(12pt)
#takeaway[*Read the connections, then the labels.* $k$ is a coarse-graining scale; $Gamma_k$ is the effective action. Repeated internal indices are summed and loop momenta are integrated.]
