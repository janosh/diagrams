#import "@preview/cetz:0.3.4"
#import "@preview/pull-eh:0.1.0"
#import cetz.draw: content, line, on-layer
#import pull-eh: ccw, cw, wind

#set page(width: auto, height: auto, margin: 5mm, fill: none)
#set text(0.9em)

#let tackle-block(coord, (w, h), ..args) = {
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

// every force arrow is captioned with its magnitude just to its right
#let labeled-force(coord, angle, label, name: none, offset: 0.7) = {
  force(coord, (angle, 0.8), name: name)
  content((rel: (offset, 0), to: name))[#label]
}

#let tackle(separated: false) = cetz.canvas({
  let block1 = (4, 5.2)
  pulley(name: "pulley1", (1, 4))
  pulley(name: "pulley2", (if separated { 3 } else { 1 }, 0))

  on-layer(1, {
    if separated {
      fixing("pulley1.center", (0, 1.2))
      fixing("pulley2.center", (0, -1.2))
      line(
        stroke: 2pt,
        (rel: (-4.4, 0), to: block1),
        (rel: (0.4, 0), to: block1),
      )
    } else {
      tackle-block(name: "block1", "pulley1", (0.4, 2.4))
      tackle-block(name: "block2", "pulley2", (0.4, 2.4))
      line(
        stroke: 2pt,
        (rel: (-1.4, 0), to: "block1.north"),
        (rel: (1.4, 0), to: "block1.north"),
      )
    }
  })

  let first-turn = (coord: "pulley1", radius: 1) + (if separated { cw } else { ccw })
  wind(
    stroke: 1.5pt,
    (rel: (if separated { -1.5 } else { 1.5 }, -2.5), to: "pulley1"),
    first-turn,
    (coord: "pulley2", radius: 1) + ccw,
    if separated { block1 } else { "block1.south" },
  )

  on-layer(1, {
    let force-labels = if separated {
      ((3.4, -2), (1.4, -2), (-1.7, -1.5))
    } else { ((-1.4, -2), (-0.1, -2), (1.7, -1.5)) }
    for rel in force-labels { content((rel: rel, to: "pulley1"))[50N] }

    let force-specs = (
      (
        coord: (rel: (if separated { 1.5 } else { 0 }, 0.4), to: "pulley1.north"),
        angle: 90deg,
        label: [150N],
        name: "f-ceiling",
        offset: 0.7,
      ),
      (
        coord: (rel: (0, -0.4), to: "pulley2.south"),
        angle: -90deg,
        label: [100N],
        name: "f-load",
        offset: 0.7,
      ),
      (
        coord: (rel: (if separated { -1.54 } else { 1.54 }, -2.7), to: "pulley1"),
        angle: if separated { -102deg } else { -78deg },
        label: [50N],
        name: "f-rope",
        offset: 0.65,
      ),
    )
    for spec in force-specs {
      labeled-force(spec.coord, spec.angle, spec.label, name: spec.name, offset: spec.offset)
    }
  })
})

#grid(
  columns: 2,
  column-gutter: 2cm,
  tackle(), tackle(separated: true),
)
