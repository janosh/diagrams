#import "@preview/cetz:0.5.2": canvas, draw
#import "../_shared/layout.typ": card-grid, paragraph-size, takeaway

#set page(width: 780pt, height: auto, margin: 22pt, fill: none)
#set text(font: "Avenir Next", size: paragraph-size, fill: rgb("#19324f"))
#set par(leading: 0.55em)

#let worldsheet(kind) = canvas(
  length: if kind == "sphere" { 2.9cm } else { 3.35cm },
  {
    let blue = rgb("#377db5")
    let teal = rgb("#008580")
    if kind == "sphere" {
      draw.circle((0, 0), radius: 1.65, fill: rgb("#bfd0de"), stroke: blue + 1pt)
      draw.arc((0, 0), radius: (1.65, .5), start: 0deg, stop: 180deg, anchor: "origin", stroke: (
        paint: blue,
        dash: "dashed",
      ))
      draw.arc(
        (0, 0),
        radius: (1.65, .5),
        start: 180deg,
        stop: 360deg,
        anchor: "origin",
        stroke: blue + 1pt,
      )
      draw.content((0, -2.15), [$g=0, b=0, chi=2$])
    } else if kind == "torus" {
      draw.circle((0, 0), radius: (2, 1.3), fill: rgb("#bfd0de"), stroke: blue + 1pt)
      draw.circle((0, .1), radius: (.85, .4), fill: rgb("#cdd3da"), stroke: blue + 1pt)
      draw.arc(
        (0, -.1),
        radius: (.9, .6),
        start: 15deg,
        stop: 165deg,
        anchor: "origin",
        stroke: blue + 1pt,
      )
      draw.content((0, -2.15), [$g=1, b=0, chi=0$])
    } else if kind == "disk" {
      draw.circle((0, 0), radius: 1.65, fill: rgb("#bfd5cc"), stroke: teal + 2pt)
      draw.content((0, 0), [one boundary])
      draw.content((0, -2.15), [$g=0, b=1, chi=1$])
    } else {
      draw.circle((0, 0), radius: 1.65, fill: rgb("#bfd5cc"), stroke: teal + 2pt)
      draw.circle((0, 0), radius: .8, fill: rgb("#cdd3da"), stroke: teal + 2pt)
      draw.content((0, -2.15), [$g=0, b=2, chi=0$])
    }
  },
)

A moving string sweeps out a two-dimensional worldsheet. Perturbation theory sums over surface topologies; adding a handle or a boundary changes the contribution.
#v(14pt)
#card-grid(
  (
    [Closed sector: sphere],
    worldsheet("sphere"),
    [No handles and no boundaries. External closed-string insertions would be marked points on this surface; none are drawn here.],
  ),
  (
    [Closed sector: torus],
    worldsheet("torus"),
    [Add one handle to obtain the next closed-string loop topology. The central opening is a handle, not a boundary edge.],
  ),

  (
    [Open sector: disk],
    worldsheet("disk"),
    [The edge is a true worldsheet boundary, traced by open-string endpoints. The interior is a two-dimensional surface.],
  ),
  (
    [Open sector: annulus],
    worldsheet("annulus"),
    [Add a second boundary. The annulus is topologically a cylinder; its inner rim is a boundary, not a handle.],
  ),
)
#v(12pt)
#takeaway[*Count handles and boundary components:* $chi=2-2g-b$ for a connected orientable surface. $g$ is genus (handle count); $b$ counts boundaries. Shown are unpunctured oriented topologies; nonorientable surfaces are outside this comparison.]
