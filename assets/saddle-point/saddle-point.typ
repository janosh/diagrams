#import "@preview/plotsy-3d:0.2.1": plot-3d-surface

#set page(width: auto, height: auto, fill: none)

#let domain-size = 2

// F(T, V) = V^2 - T^2: convex along V, concave along T, so the origin is a saddle.
// Without an explicit `scale-dim` the package default of (1, 1, 0.5) renders a page
// roughly 12x too large, which is what left the committed asset out of date.
#plot-3d-surface(
  (v, t) => v * v - t * t,
  color-func: (..) => rgb("#00008B").transparentize(50%),
  subdivisions: 8,
  xdomain: (-domain-size, domain-size),
  ydomain: (-domain-size, domain-size),
  scale-dim: (0.1, 0.06, 0.03),
  axis-labels: ($V$, $T$, $F(T,V)$),
  axis-step: (1, 1, 2),
)
