#import "@preview/cetz:0.5.2": canvas, draw
#import draw: arc-through, circle, content, merge-path, rect, rotate, scale, scope

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 12pt)

#canvas({
  // Scale up the diagram
  scale(4)

  let mechanical-center = (-0.65, 0.375)
  let thermal-center = (0.65, 0.375)
  let chemical-center = (0, -0.75)

  let ab-outer = (0, 1.135)
  let ab-inner = (0, -0.385)
  let ac-outer = (-0.983, -0.568)
  let ac-inner = (0.334, 0.193)
  let bc-inner = (-0.334, 0.193)

  // Single-term regions: mechanical (a), thermal (b), chemical (c), then their overlaps
  let fills = (a: blue, b: red, c: green, ab: purple, bc: yellow, ac: teal)

  rect((-1.95, 1.95), (1.95, -1.95))

  for (region, angle) in (("ab", 0deg), ("ac", 120deg), ("bc", 240deg)) {
    scope({
      rotate(angle)
      merge-path(
        {
          arc-through(bc-inner, (rel: (-1, 0), to: thermal-center), ab-outer)
          arc-through((), (rel: (+1, 0), to: mechanical-center), ac-inner)
          arc-through((), (rel: (0, +1), to: chemical-center), bc-inner)
        },
        fill: fills.at(region).transparentize(40%),
        stroke: none,
        close: true,
      )
    })
  }

  merge-path(
    {
      arc-through(ab-inner, (rel: (0.866, -0.5), to: mechanical-center), ac-inner)
      arc-through((), (rel: (0, 1), to: chemical-center), bc-inner)
      arc-through((), (rel: (-0.866, -0.5), to: thermal-center), ab-inner)
    },
    fill: gray.transparentize(70%),
    close: true,
  )

  for (region, angle) in (("a", 0deg), ("c", 120deg), ("b", 240deg)) {
    scope({
      rotate(angle)
      merge-path(
        {
          arc-through(ab-outer, (rel: (-1, 0), to: mechanical-center), ac-outer)
          arc-through((), (rel: (-0.5, 0.866), to: chemical-center), bc-inner)
          arc-through((), (rel: (-1, 0), to: thermal-center), ab-outer)
        },
        fill: fills.at(region).transparentize(40%),
        close: true,
      )
    })
  }

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
