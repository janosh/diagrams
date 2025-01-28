#import "@preview/cetz:0.3.2"
#import "@preview/cetz-venn:0.1.3": venn3

#set page(width: auto, height: auto, margin: 8pt)

#cetz.canvas({
  import cetz.draw: content, circle, scale

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

  // Add outer labels for main potentials
  content("venn.a", [Mechanical\ $F_[mu] = -P V$], anchor: "center", name: "mechanical")
  content("mechanical.south", text(.8em)[(Grand\ potential)], anchor: "north", padding: (top: 4pt))

  content("venn.b", [Thermal\ $H_[mu] = T S$], anchor: "center")

  content("venn.c", [Chemical\ $G = mu N$], anchor: "center")

  // Add labels for overlapping regions
  content(
    "venn.ab",
    text(.8em, align(center, $U_[mu] =\ T S - P V$)),
    anchor: "center",
    offset: (0, 0.3),
  )

  content(
    "venn.abc",
    text(.8em, align(center, $U = T S -\ P V + mu N$)),
  )

  content(
    "venn.ac",
    align(center, $F =\ -P V + mu N$),
    anchor: "center",
    offset: (-0.3, -0.3),
  )

  content(
    "venn.bc",
    align(center, $H =\ T S + mu N$),
    anchor: "center",
    offset: (0.3, -0.3),
  )

  // Add outer circle label
  content((0, 1.6), $G_[mu]$)
  content((0, 1.4), text(.8em)[(Gibbs-Duhem)])
  circle(
    (0, 0),
    radius: 1.75,
    fill: rgb(70%, 70%, 90%, 20%),
    stroke: rgb(0%, 0%, 0%),
  )
})
