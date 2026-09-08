#import "@preview/cetz:0.5.2": canvas, draw

#set page(width: 780pt, height: auto, margin: 22pt, fill: white)
#set text(font: "Avenir Next", size: 10.5pt, fill: rgb("#19324f"))
#set par(leading: 0.55em)

// Measure each drawing before fitting it; keep labels and geometry together.
#let fit-figure(body, height: 170pt) = layout(size => {
  let bounds = measure(body)
  let factor = calc.min(size.width / bounds.width, height / bounds.height)
  box(width: 100%, align(center + horizon, std.scale(
    x: factor * 100%,
    y: factor * 100%,
    reflow: true,
    body,
  )))
})
#let card(title, body, caption, height: 170pt) = block(
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

#let worldsheet(kind) = canvas({
  let blue = rgb("#377db5")
  let teal = rgb("#008580")
  if kind == "sphere" {
    draw.circle((0, 0), radius: 1.65, fill: rgb("#e1eef8"), stroke: blue + 1pt)
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
    draw.circle((0, 0), radius: (2, 1.3), fill: rgb("#e1eef8"), stroke: blue + 1pt)
    draw.circle((0, .1), radius: (.85, .4), fill: rgb("#f3f6fa"), stroke: blue + 1pt)
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
    draw.circle((0, 0), radius: 1.65, fill: rgb("#e0f1ec"), stroke: teal + 2pt)
    draw.content((0, 0), [one boundary])
    draw.content((0, -2.15), [$g=0, b=1, chi=1$])
  } else {
    draw.circle((0, 0), radius: 1.65, fill: rgb("#e0f1ec"), stroke: teal + 2pt)
    draw.circle((0, 0), radius: .8, fill: rgb("#f3f6fa"), stroke: teal + 2pt)
    draw.content((0, -2.15), [$g=0, b=2, chi=0$])
  }
})

// === Closed sector: sphere ===
#let figure-0 = [
  #worldsheet("sphere")
]

// === Closed sector: torus ===
#let figure-1 = [
  #worldsheet("torus")
]

// === Open sector: disk ===
#let figure-2 = [
  #worldsheet("disk")
]

// === Open sector: annulus ===
#let figure-3 = [
  #worldsheet("annulus")
]

#text(size: 27pt, weight: "bold")[String Worldsheet Topologies]
#v(5pt)
A moving string sweeps out a two-dimensional worldsheet. Perturbation theory sums over surface topologies; adding a handle or a boundary changes the contribution.
#v(14pt)
#grid(
  columns: (1fr, 1fr),
  gutter: 12pt,
  card(
    [Closed sector: sphere],
    figure-0,
    [No handles and no boundaries. External closed-string insertions would be marked points on this surface; none are drawn here.],
    height: 160pt,
  ),
  card(
    [Closed sector: torus],
    figure-1,
    [Add one handle to obtain the next closed-string loop topology. The central opening is a handle, not a boundary edge.],
    height: 160pt,
  ),

  card(
    [Open sector: disk],
    figure-2,
    [The edge is a true worldsheet boundary, traced by open-string endpoints. The interior is a two-dimensional surface.],
    height: 160pt,
  ),
  card(
    [Open sector: annulus],
    figure-3,
    [Add a second boundary. The annulus is topologically a cylinder; its inner rim is a boundary, not a handle.],
    height: 160pt,
  ),
)
#v(12pt)
#takeaway[*Count handles and boundary components:* $chi=2-2g-b$ for a connected orientable surface. $g$ is genus (handle count); $b$ counts boundaries. Shown are unpunctured oriented topologies; nonorientable surfaces are outside this comparison.]
