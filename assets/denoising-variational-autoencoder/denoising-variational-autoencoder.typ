#import "@preview/cetz:0.5.1": canvas, decorations, draw
#import draw: anchor, circle, content, line, rect

#set page(width: auto, height: auto, margin: 8pt)

#canvas({
  let green = rgb("#009900")
  let edge-stroke = .65pt
  let arr = (mark: (end: "stealth", fill: black, scale: .5), stroke: edge-stroke)
  let bg = (paint: black, dash: "dashed", thickness: .9pt)
  let node-r = .14
  let at(pos) = (rel: pos, to: "origin")
  let point-name(point) = point.at(0)
  let point-pos(point) = point.at(1)
  let layer(prefix, x, n, step: .72, y: 0) = range(n).map(idx => (
    prefix + str(idx),
    (x, y + (float(n - 1) / 2 - float(idx)) * step),
  ))
  let trim(start, end, start-pad: node-r, end-pad: node-r) = {
    let delta-x = end.at(0) - start.at(0)
    let delta-y = end.at(1) - start.at(1)
    let length = calc.sqrt(delta-x * delta-x + delta-y * delta-y)
    (
      (start.at(0) + delta-x / length * start-pad, start.at(1) + delta-y / length * start-pad),
      (end.at(0) - delta-x / length * end-pad, end.at(1) - delta-y / length * end-pad),
    )
  }
  let dense(a, b) = {
    for start in a {
      for end in b {
        let (trimmed-start, trimmed-end) = trim(point-pos(start), point-pos(end))
        line(at(trimmed-start), at(trimmed-end), ..arr)
      }
    }
  }
  let snake(start, end, segments: 7, amplitude: .035) = {
    let (trimmed-start, trimmed-end) = trim(point-pos(start), point-pos(end))
    let delta-x = trimmed-end.at(0) - trimmed-start.at(0)
    let delta-y = trimmed-end.at(1) - trimmed-start.at(1)
    let length = calc.sqrt(delta-x * delta-x + delta-y * delta-y)
    let straight-length = .12
    let wave-end = (
      trimmed-end.at(0) - delta-x / length * straight-length,
      trimmed-end.at(1) - delta-y / length * straight-length,
    )
    decorations.wave(line(at(trimmed-start), at(wave-end)), amplitude: amplitude, segments: segments, stroke: edge-stroke)
    line(at(wave-end), at(trimmed-end), ..arr)
  }
  let node(point, fill: white, label: none, stroke: .8pt) = {
    circle(at(point-pos(point)), radius: node-r, fill: fill, stroke: stroke, name: point-name(point))
    if label != none { content(point-name(point), text(size: 7pt)[#label]) }
  }
  let region(name, south-west, north-east, fill) = rect(
    at(south-west),
    at(north-east),
    stroke: bg,
    fill: fill,
    radius: .08,
    name: name,
  )

  anchor("origin", (0, 0))

  let input-x = 0
  let corrupt-x = input-x + .8
  let enc-x = corrupt-x + 1.55
  let stats-x = enc-x + 1.4
  let z-x = stats-x + 1.4
  let dec-x = z-x + 1.4
  let out-mu-x = dec-x + 1.55
  let out-x = out-mu-x + .95

  let x-pts = layer("x", input-x, 7)
  let corrupt = layer("corrupt", corrupt-x, 7)
  let enc = layer("enc", enc-x, 5)
  let mu-pts = layer("mu", stats-x, 4, step: .45, y: 1.125)
  let sigma-pts = layer("sigma", stats-x, 4, step: .45, y: -1.125)
  let z-pts = layer("z", z-x, 4, step: .75)
  let dec = layer("dec", dec-x, 5)
  let out-mu = layer("out-mu", out-mu-x, 7)
  let out-pts = layer("out", out-x, 7)

  region("encoder-bg", (corrupt-x - .25, -2.65), (z-x + .3, 2.65), green.transparentize(88%))
  region("decoder-bg", (z-x - .3, -2.45), (out-x + .4, 2.45), red.transparentize(88%))
  region("corrupt-bg", (input-x - .45, -2.75), (corrupt-x + .35, 2.75), blue.transparentize(88%))
  region("corrupt-overlap", (corrupt-x - .25, -2.75), (corrupt-x + .35, 2.75), blue.transparentize(82%))
  content((rel: (0, -.15), to: "corrupt-bg.south"), [corrupt], anchor: "north")
  content((rel: (0, -.15), to: "encoder-bg.south"), [encoder], anchor: "north")
  content((rel: (0, -.15), to: "decoder-bg.south"), [decoder], anchor: "north")

  for idx in range(7) { snake(x-pts.at(idx), corrupt.at(idx), segments: 6) }
  dense(corrupt, enc)
  dense(enc, mu-pts)
  dense(enc, sigma-pts)
  for idx in range(4) {
    snake(mu-pts.at(idx), z-pts.at(idx), segments: 12)
    snake(sigma-pts.at(idx), z-pts.at(idx), segments: 12)
  }
  dense(z-pts, dec)
  dense(dec, out-mu)
  for idx in range(7) { snake(out-mu.at(idx), out-pts.at(idx), segments: 6) }

  for point in x-pts { node(point) }
  for point in corrupt { node(point, fill: red.lighten(50%), label: $~$) }
  for point in enc { node(point) }
  for point in mu-pts { node(point, label: $mu$) }
  for point in sigma-pts { node(point, label: $sigma$) }
  for point in z-pts { node(point, fill: gray.lighten(55%)) }
  for point in dec { node(point) }
  for point in out-mu { node(point, label: $mu$) }
  for point in out-pts { node(point) }

  content((rel: (-.5, 0), to: "x3"), $arrow(x)$, anchor: "east")
  content((rel: (0, .5), to: "z0"), $arrow(z)$, anchor: "south")
  content((rel: (.5, 0), to: "out3"), $arrow(x)'$, anchor: "west")
})
