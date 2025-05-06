#import "@preview/cetz:0.3.4"
#import "@preview/pull-eh:0.1.0"
#import cetz.draw: on-layer, line, content
#import pull-eh: wind, ccw, cw

#set page(width: auto, height: auto, margin: 5mm)
#set text(0.9em)

#let block(coord, (w, h), ..args) = {
  // use the given coord as the center of the rect
  let tl = (rel: (-w / 2, -h / 2), to: coord)
  let br = (rel: (w, h))
  cetz.draw.rect(tl, br, fill: white, ..args)
}
#let fixing(coord, len, ..args) = {
  cetz.draw.line(stroke: 3pt, coord, (rel: len, to: coord))
  cetz.draw.circle(coord, fill: black, radius: 0.2)
}
#let pulley(..args) = {
  cetz.draw.circle(fill: green, stroke: none, ..args)
}

#let force(coord, direction, ..args) = {
  let mark = (end: (symbol: ">", length: 0.12cm, width: 0.15cm))
  cetz.draw.line(coord, (rel: direction), stroke: 4pt, mark: mark, ..args)
}

#let gun-tackle = cetz.canvas({
  // the pulleys; on the default layer
  pulley(name: "pulley1", (1, 4))
  pulley(name: "pulley2", (1, 0))
  // the "fixed" parts of the diagram: ceiling and blocks. The blocks wrap around the pulleys
  // and thus hide them and the rope
  on-layer(
    1,
    {
      block(name: "block1", "pulley1", (0.4, 2.4))
      block(name: "block2", "pulley2", (0.4, 2.4))
      line(stroke: 2pt, (rel: (-1.4, 0), to: "block1.north"), (rel: (1.4, 0), to: "block1.north"))
    },
  )
  // the rope; drawn over the pulleys, but hidden by the blocks
  wind(
    stroke: 1.5pt,
    (rel: (1.5, -2.5), to: "pulley1"),
    (coord: "pulley1", radius: 1) + ccw,
    (coord: "pulley2", radius: 1) + ccw,
    "block1.south",
  )
  // the labels of the diagram
  on-layer(
    1,
    {
      content((rel: (-1.4, -2), to: "pulley1"))[50N]
      content((rel: (-0.1, -2), to: "pulley1"))[50N]
      content((rel: (1.7, -1.5), to: "pulley1"))[50N]

      force((rel: (0, 0.4), to: "pulley1.north"), (90deg, 0.8), name: "f-ceiling")
      content((rel: (0.7, 0), to: "f-ceiling"))[150N]

      force((rel: (0, -0.4), to: "pulley2.south"), (-90deg, 0.8), name: "f-load")
      content((rel: (0.7, 0), to: "f-load"))[100N]

      force((rel: (1.54, -2.7), to: "pulley1"), (-78deg, 0.8), name: "f-rope")
      content((rel: (0.65, 0), to: "f-rope"))[50N]
    },
  )
})

#let separated = cetz.canvas({
  let block1 = (4, 5.2)

  // the pulleys; on the default layer
  pulley(name: "pulley1", (1, 4))
  pulley(name: "pulley2", (3, 0))
  // the "fixed" parts of the diagram: ceiling and blocks. The blocks wrap around the pulleys
  // and thus hide them and the rope
  on-layer(
    1,
    {
      fixing("pulley1.center", (0, 1.2))
      fixing("pulley2.center", (0, -1.2))
      line(stroke: 2pt, (rel: (-4.4, 0), to: block1), (rel: (0.4, 0), to: block1))
    },
  )
  // the rope; drawn over the pulleys, but hidden by the blocks
  wind(
    stroke: 1.5pt,
    (rel: (-1.5, -2.5), to: "pulley1"),
    (coord: "pulley1", radius: 1) + cw,
    (coord: "pulley2", radius: 1) + ccw,
    block1,
  )
  // the labels of the diagram
  on-layer(
    1,
    {
      content((rel: (3.4, -2), to: "pulley1"))[50N]
      content((rel: (1.4, -2), to: "pulley1"))[50N]
      content((rel: (-1.7, -1.5), to: "pulley1"))[50N]

      force((rel: (1.5, 0.4), to: "pulley1.north"), (90deg, 0.8), name: "f-ceiling")
      content((rel: (0.7, 0), to: "f-ceiling"))[150N]

      force((rel: (0, -0.4), to: "pulley2.south"), (-90deg, 0.8), name: "f-load")
      content((rel: (0.7, 0), to: "f-load"))[100N]

      force((rel: (-1.54, -2.7), to: "pulley1"), (-102deg, 0.8), name: "f-rope")
      content((rel: (0.65, 0), to: "f-rope"))[50N]
    },
  )
})

#grid(
  columns: 2,
  column-gutter: 2cm,
  gun-tackle, separated,
)
