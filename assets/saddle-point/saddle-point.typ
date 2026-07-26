#import "@preview/plotsy-3d:0.2.1": plot-3d-surface

#set page(width: auto, height: auto, fill: none)

#let domain-size = 2

#plot-3d-surface(
  (x, y) => x * x - y * y,
  color-func: (..) => rgb("#00008B").transparentize(50%),
  subdivisions: 8,
  xdomain: (-domain-size, domain-size),
  ydomain: (-domain-size, domain-size),
)
