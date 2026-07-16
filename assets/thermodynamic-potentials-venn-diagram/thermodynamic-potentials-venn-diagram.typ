#import "@preview/cetz:0.5.2": canvas, draw
#import draw: arc-through, circle, content, merge-path, rect, rotate, scale, scope

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#canvas({
  // Scale up the diagram
  scale(2.5)

  // Create Venn diagram with three overlapping circles
  let mechanical-center = (-0.65, 0.375)
  let thermal-center = (0.65, 0.375)
  let chemical-center = (0, -0.75)

  let ab-outer = (0, 1.135)
  let ab-inner = (0, -0.385)
  let ac-outer = (-0.983, -0.568)
  let ac-inner = (0.334, 0.193)
  let bc-inner = (-0.334, 0.193)

  let fills = (
    a: blue.transparentize(40%), // Mechanical (blue)
    b: red.transparentize(40%), // Thermal (red)
    c: green.transparentize(40%), // Chemical (green)
    ab: purple.transparentize(40%), // Overlap
    bc: yellow.transparentize(40%), // Overlap
    ac: teal.transparentize(40%), // Overlap
    abc: gray.transparentize(70%), // Center
  )

  rect((-2.428, 2.153), (2.428, -2.528), fill: none, stroke: auto)

  for (region, angle) in (("ab", 0deg), ("ac", 120deg), ("bc", 240deg)) {
    scope({
      rotate(angle)
      merge-path(
        {
          arc-through(bc-inner, (rel: (-1, 0), to: thermal-center), ab-outer)
          arc-through((), (rel: (+1, 0), to: mechanical-center), ac-inner)
          arc-through((), (rel: (0, +1), to: chemical-center), bc-inner)
        },
        fill: fills.at(region),
        stroke: none,
        close: true,
      )
    })
  }

  merge-path(
    {
      arc-through(
        ab-inner,
        (rel: (0.866, -0.5), to: mechanical-center),
        ac-inner,
      )
      arc-through((), (rel: (0, 1), to: chemical-center), bc-inner)
      arc-through((), (rel: (-0.866, -0.5), to: thermal-center), ab-inner)
    },
    fill: fills.abc,
    stroke: auto,
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
        fill: fills.at(region),
        stroke: auto,
        close: true,
      )
    })
  }

  // Add outer labels for main potentials
  content((-0.992, 0.573), [Mechanical\ $F_[mu] = -P V$], anchor: "center")
  content((-0.95, 0.28), text(.8em)[(Grand potential)], anchor: "center")

  content((0.992, 0.573), [Thermal\ $H_[mu] = T S$], anchor: "center")

  content((0, -1.146), [Chemical\ $G = mu N$], anchor: "center")

  // Add labels for overlapping regions
  content((0, 0.523), align(center, $U_[mu] =\ T S - P V$), anchor: "center")

  content((0, 0), text(.8em, align(center, $U = T S -\ P V + mu N$)))

  content((-0.496, -0.336), align(center, $F =\ -P V + mu N$), anchor: "center")

  content((0.496, -0.336), align(center, $H =\ T S + mu N$), anchor: "center")

  // Add outer circle label
  content((0, 1.6), $G_[mu]$)
  content((0, 1.4), text(.8em)[(Gibbs-Duhem)])
  circle((0, 0), radius: 1.75, fill: rgb(70%, 70%, 90%, 20%), stroke: rgb(
    0%,
    0%,
    0%,
  ))
})
