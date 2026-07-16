#import "@preview/cetz:0.5.2": canvas, draw
#import draw: content, line, rect

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#canvas({
  let cyan = rgb("#2cb1e1")
  let green = rgb("#009900")
  let mauve = rgb("#9400d3")
  let arr = (mark: (end: "stealth", fill: black, scale: .6), stroke: 1pt)
  let arrow-y = 1.08
  let cuboid(x, y, w, h, d, fill, label, name) = {
    let o = (-d, d * .45)
    let a = (x, y)
    let b = (x + w, y)
    let c = (x + w, y + h)
    let d0 = (x, y + h)
    let a2 = (a.at(0) + o.at(0), a.at(1) + o.at(1))
    let c2 = (c.at(0) + o.at(0), c.at(1) + o.at(1))
    let d2 = (d0.at(0) + o.at(0), d0.at(1) + o.at(1))
    line(a, b, c, d0, a, fill: fill, stroke: 1pt)
    line(d0, d2, c2, c, d0, fill: fill.lighten(45%), stroke: 1pt)
    line(a, a2, d2, d0, a, fill: fill.lighten(30%), stroke: 1pt)
    if label != none {
      content((x + w / 2, y + h / 2), label, name: name)
    }
  }
  let right-rim(x, w) = (x + w, arrow-y)
  let left-rim(x, d) = (x - d, arrow-y)

  rect(
    (-1.0, -1.15),
    (13.85, 2.8),
    stroke: (paint: black, dash: "dashed", thickness: .8pt),
    fill: green.transparentize(88%),
    radius: .08,
    name: "encoder-bg",
  )
  rect(
    (11.7, -1.075),
    (20.6, 2.725),
    stroke: (paint: black, dash: "dashed", thickness: .8pt),
    fill: red.transparentize(88%),
    radius: .08,
    name: "decoder-bg",
  )
  content((rel: (0, -.13), to: "encoder-bg.south"), [encoder], anchor: "north")
  content((rel: (0, -.13), to: "decoder-bg.south"), [decoder], anchor: "north")

  let blocks = (
    ("x", 0, 0, 1.6, 1.9, .22, green.lighten(50%), $bold(X)$),
    ("c1", 3.2, 0, 1.8, 1.9, .70, cyan.lighten(55%), none),
    ("p1", 6.8, .35, 1.0, 1.2, .55, red.lighten(55%), none),
    ("c2", 9.8, .35, 1.05, 1.2, 1.05, cyan.lighten(55%), none),
    ("z", 12.8, .62, .55, .65, .65, red.lighten(55%), $bold(z)$),
    ("u1", 15.0, .35, 1.0, 1.2, .55, mauve.lighten(55%), none),
    ("out", 18.6, 0, 1.6, 1.9, .22, mauve.lighten(55%), $bold(X)'$),
  )
  for (name, x, y, w, h, dep, fill, label) in blocks {
    cuboid(x, y, w, h, dep, fill, label, name)
  }

  for (from, to, top, bottom) in (
    (blocks.at(0), blocks.at(1), [Conv.], [ReLU]),
    (blocks.at(1), blocks.at(2), [Pool], none),
    (blocks.at(2), blocks.at(3), [Conv.], [ReLU]),
    (blocks.at(3), blocks.at(4), [Pool], none),
    (blocks.at(4), blocks.at(5), [Deconv.], [ReLU]),
    (blocks.at(5), blocks.at(6), [Deconv.], [logistic]),
  ) {
    let (from-name, x1, y1, w1, h1, d1, ..) = from
    let (to-name, x2, y2, w2, h2, d2, ..) = to
    let a = right-rim(x1, w1)
    let b = left-rim(x2, d2)
    let edge = from-name + "-" + to-name
    line(a, b, ..arr, name: edge)
    content(
      (rel: (0, .22), to: edge + ".mid"),
      text(size: 7pt)[#top],
      fill: white,
      padding: .5pt,
    )
    if bottom != none {
      content(
        (rel: (0, -.22), to: edge + ".mid"),
        text(size: 7pt)[#bottom],
        fill: white,
        padding: .5pt,
      )
    }
  }
})
