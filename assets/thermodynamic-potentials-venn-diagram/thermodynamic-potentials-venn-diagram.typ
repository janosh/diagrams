#import "@preview/cetz:0.5.3": canvas, draw
#import draw: boolean, circle, content, rect, scale

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 12pt)

#canvas({
  // Scale up the diagram
  scale(4)

  // Unit circles for the mechanical (a), thermal (b) and chemical (c) work terms
  let centers = (a: (-0.65, 0.375), b: (0.65, 0.375), c: (0, -0.75))
  let disc(term) = circle(centers.at(term), radius: 1)
  let lens(first, second) = boolean(disc(first), disc(second), op: "intersection")
  let fills = (a: blue, b: red, c: green, ab: purple, bc: yellow, ac: teal)

  rect((-1.95, 1.95), (1.95, -1.95))

  // Exact Venn regions: each set alone, each pairwise overlap minus the third set,
  // then the triple overlap.
  for (region, others) in (("a", ("b", "c")), ("b", ("a", "c")), ("c", ("a", "b"))) {
    boolean(
      disc(region),
      others.map(disc).join(),
      fill: fills.at(region).transparentize(40%),
      stroke: none,
    )
  }
  for (region, third) in (("ab", "c"), ("bc", "a"), ("ac", "b")) {
    let (first, second) = region.clusters()
    boolean(
      lens(first, second),
      disc(third),
      fill: fills.at(region).transparentize(40%),
      stroke: none,
    )
  }
  boolean(
    lens("a", "b"),
    disc("c"),
    op: "intersection",
    fill: gray.transparentize(70%),
    stroke: none,
  )
  for term in centers.keys() { disc(term) }

  for (pos, body) in (
    ((-0.992, 0.573), [#text(size: 16pt)[Mechanical]\ $F_[mu] = -P V$]),
    ((-0.95, 0.28), text(size: 14pt)[(Grand potential)]),
    ((0.992, 0.573), [#text(size: 16pt)[Thermal]\ $H_[mu] = T S$]),
    ((0, -1.146), [#text(size: 16pt)[Chemical]\ $G = mu N$]),
    ((0, 0.523), align(center, $U_[mu] =\ T S - P V$)),
    ((0, 0), align(center, $U = T S -\ P V + mu N$)),
    ((-0.496, -0.336), align(center, $F =\ -P V + mu N$)),
    ((0.496, -0.336), align(center, $H =\ T S + mu N$)),
    ((0, 1.6), $G_[mu]$),
    ((0, 1.4), text(size: 14pt)[(Gibbs-Duhem)]),
  ) { content(pos, body) }
  circle((0, 0), radius: 1.75, fill: rgb(70%, 70%, 90%, 20%), stroke: black)
})
