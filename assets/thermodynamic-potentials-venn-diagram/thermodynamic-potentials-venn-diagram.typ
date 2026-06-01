#import "@preview/cetz:0.5.2": canvas, draw
#import draw: arc-through, circle, content, merge-path, rect, rotate, scale, scope

#set page(width: auto, height: auto, margin: 8pt)

#canvas({
  // Scale up the diagram
  scale(2.5)

  // Create Venn diagram with three overlapping circles
  venn3(
    name: "venn",
    a-fill: blue.transparentize(40%), // Mechanical (blue)
    b-fill: red.transparentize(40%), // Thermal (red)
    c-fill: green.transparentize(40%), // Chemical (green)
    ab-fill: purple.transparentize(40%), // Overlap
    bc-fill: yellow.transparentize(40%), // Overlap
    ac-fill: teal.transparentize(40%), // Overlap
    abc-fill: gray.transparentize(70%), // Center
  )

  rect((-2.428, 2.153), (2.428, -2.528), fill: white, stroke: auto)

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
      arc-through(ab-inner, (rel: (0.866, -0.5), to: mechanical-center), ac-inner)
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
  content("venn.a", [Mechanical\ $F_[mu] = -P V$], anchor: "center", name: "mechanical")
  content("mechanical.south", text(.8em)[(Grand\ potential)], anchor: "north", padding: (top: 4pt))

  content("venn.b", [Thermal\ $H_[mu] = T S$], anchor: "center")

  content("venn.c", [Chemical\ $G = mu N$], anchor: "center")

  // Add labels for overlapping regions
  content("venn.ab", align(center, $U_[mu] =\ T S - P V$), anchor: "center", offset: (0, 0.3))

  content("venn.abc", text(.8em, align(center, $U = T S -\ P V + mu N$)))

  content("venn.ac", align(center, $F =\ -P V + mu N$), anchor: "center", offset: (-0.3, -0.3))

  content("venn.bc", align(center, $H =\ T S + mu N$), anchor: "center", offset: (0.3, -0.3))

  // Add outer circle label
  content((0, 1.6), $G_[mu]$)
  content((0, 1.4), text(.8em)[(Gibbs-Duhem)])
  circle((0, 0), radius: 1.75, fill: rgb(70%, 70%, 90%, 20%), stroke: rgb(0%, 0%, 0%))
})
