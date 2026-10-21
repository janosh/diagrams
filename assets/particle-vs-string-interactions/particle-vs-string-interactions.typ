#import "@preview/cetz:0.5.3": canvas, draw
#import draw: bezier, circle, content, line, merge-path

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 18pt, font: "New Computer Modern", fill: rgb("#343a40"))

#let ink = rgb("#1d3557")
#let interior = rgb("#5b7fa6")
// lit from above: light upper tube, darker lower tube
#let surface = gradient.linear(rgb("#c3d7ec"), rgb("#9dbbdb"), rgb("#7299c2"), angle: 90deg)

// geometry: length of the diagram, end-tube radii and offsets of the outgoing tubes
#let len = 6.6
#let (rx0, ry0) = (.3, .9) // incoming tube rim (projected ellipse)
#let (rx1, ry1) = (.2, .58) // outgoing tube rims
#let spread = 1.2 // vertical offset of the outgoing tubes
#let crotch-depth = 1.9 // how far the inner U reaches back from the outgoing rims

#let outer-top = ((0, ry0), (len * .42, ry0), (len * .62, spread + ry1), (len, spread + ry1))
#let outer-bot = outer-top.map(((x, y)) => (x, -y))
#let crotch = (
  (len, spread - ry1),
  (len - crotch-depth, spread - ry1),
  (len - crotch-depth, -spread + ry1),
  (len, -spread + ry1),
)
#let x-pinch = len - .75 * crotch-depth // leftmost point of the crotch, where the string splits

// cubic bezier through control points (start, c1, c2, end), and its point at parameter t
#let curve(pts, ..style) = bezier(pts.at(0), pts.at(3), pts.at(1), pts.at(2), ..style)
#let bez-at(pts, t) = {
  let (p0, p1, p2, p3) = pts
  let u = 1 - t
  range(2).map(k => (
    u * u * u * p0.at(k)
      + 3 * u * u * t * p1.at(k)
      + 3 * u * t * t * p2.at(k)
      + t * t * t * p3.at(k)
  ))
}
// height of a curve at x by bisection over t in [lo, hi], along which x increases or decreases
#let y-at(pts, x, lo: 0.0, hi: 1.0) = {
  let rising = bez-at(pts, hi).at(0) > bez-at(pts, lo).at(0)
  for _ in range(40) {
    let mid = (lo + hi) / 2
    if (bez-at(pts, mid).at(0) < x) == rising { lo = mid } else { hi = mid }
  }
  bez-at(pts, lo).at(1)
}

// points on an axis-aligned ellipse from angle a to b (degrees)
#let ellipse-pts(center, rx, ry, a, b, n: 24) = range(n + 1).map(i => {
  let t = (a + (b - a) * i / n) * 1deg
  (center.at(0) + rx * calc.cos(t), center.at(1) + ry * calc.sin(t))
})
// a loop of string on the worldsheet: near (left) half solid, far half dashed
#let slice(center, ry, rx-per-ry: rx0 / ry0) = {
  let rx = ry * rx-per-ry
  line(..ellipse-pts(center, rx, ry, 90, 270), stroke: ink.transparentize(25%) + .8pt)
  line(..ellipse-pts(center, rx, ry, -90, 90), stroke: (
    paint: ink.transparentize(45%),
    thickness: .6pt,
    dash: (2pt, 2pt),
  ))
}

#canvas(length: 1cm, {
  // ---------- strings: pair of pants, viewed slightly from the right ----------
  let (top, bot) = ((len, spread), (len, -spread))

  // tube interiors seen through the outgoing openings
  for c in (top, bot) { circle(c, radius: (rx1, ry1), fill: interior, stroke: none) }

  // outer surface: near (left) halves of every rim bound it
  merge-path(fill: surface, stroke: none, close: true, {
    line(..ellipse-pts((0, 0), rx0, ry0, -90, -270))
    curve(outer-top)
    line(..ellipse-pts(top, rx1, ry1, 90, 270))
    curve(crotch)
    line(..ellipse-pts(bot, rx1, ry1, 90, 270))
    curve(outer-bot.rev())
  })

  // the string at successive times: one loop, a figure-eight at the split, then two loops
  for x in (1.7, 3.3) { slice((x, 0), y-at(outer-top, x)) }
  let h-pinch = y-at(outer-top, x-pinch) / 2
  for y in (h-pinch, -h-pinch) { slice((x-pinch, y), h-pinch) }
  let x-two = (x-pinch + len) / 2
  let (y-out, y-in) = (y-at(outer-top, x-two), y-at(crotch, x-two, hi: .5))
  for sign in (1, -1) {
    slice((x-two, sign * (y-out + y-in) / 2), (y-out - y-in) / 2, rx-per-ry: rx1 / ry1)
  }

  // outlines
  let edge = ink + 1.2pt
  for pts in (outer-top, outer-bot, crotch) { curve(pts, stroke: edge) }
  line(..ellipse-pts((0, 0), rx0, ry0, 90, 270), stroke: edge)
  line(..ellipse-pts((0, 0), rx0, ry0, -90, 90), stroke: (
    paint: ink,
    thickness: .8pt,
    dash: (2pt, 2pt),
  ))
  for c in (top, bot) { circle(c, radius: (rx1, ry1), stroke: edge) } // we look into the openings

  content((-.35, spread + .45), [strings], anchor: "west")

  // ---------- particles: cubic vertex, aligned with the string's split ----------
  let y0 = 2 * spread + ry1 + .85 // vertical position of the particle panel
  let v = (x-pinch, y0)
  line((x-pinch, y0 - .25), (x-pinch, y-at(outer-top, x-pinch) + .15), stroke: (
    paint: ink.transparentize(60%),
    thickness: .6pt,
    dash: "dotted",
  ))
  line((-.3, y0), v, stroke: ink + 1.6pt)
  for dy in (spread, -spread) { line(v, (len + .1, y0 + dy), stroke: ink + 1.6pt) }
  circle(v, radius: .08, fill: ink, stroke: none)

  content((-.35, y0 + spread + .05), [particles], anchor: "west")
})
