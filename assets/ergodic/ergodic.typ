#import "@preview/cetz:0.5.2": canvas, draw
#import draw: content, hobby, rect
#import "../_shared/phase-space.typ": energy-shell

#set page(width: auto, height: auto, margin: 3pt, fill: none)

#canvas({
  let (rx, ry) = (5, 3)
  energy-shell(rx, ry)
  content((rx - 0.6, 0.2), text(fill: blue)[$P$])

  // rectangle scaled so its corners sit on the ellipse
  let rect-scale = calc.sqrt(2) / 2
  let (half-w, half-h) = (rx * rect-scale, ry * rect-scale)
  rect(
    (-half-w, -half-h),
    (half-w, half-h),
    stroke: rgb("#ffa500"),
    fill: rgb(100%, 65%, 0%, 10%),
    name: "rect",
  )
  content((-rx / 4, ry / 2), text(fill: rgb("#ffa500"))[$R$ for $omega in.not QQ$])

  // a rational frequency ratio closes the trajectory after two passes; each pass dips
  // to the given (x, height above the rectangle's bottom edge) control points
  for dips in (
    ((-1.1, .4), (-.5, .1), (.1, .4)),
    ((-.1, .4), (.5, .1), (1.1, .45)),
  ) {
    hobby(
      (-half-w, half-h),
      ..dips.map(((x, dy)) => (x, -half-h + dy)),
      (half-w, half-h),
      omega: 0,
      stroke: red,
    )
  }
  content((2.5, -1.3), align(center, text(fill: red)[$R$ for\ $omega = 2 in QQ$]))
})
