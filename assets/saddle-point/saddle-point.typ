#import "@preview/plotsy-3d:0.2.1": plot-3d-surface

#set page(width: auto, height: auto)

#let saddle_func(x, y) = x * x - y * y

// Define a color function for the surface
#let color_func(x, y, z, x_lo, x_hi, y_lo, y_hi, z_lo, z_hi) = {
  return rgb("#00008B").transparentize(50%)
}

// Define domain and scaling
#let domain_size = 2
#let scale_factor = 0.2
#let (x_scale, y_scale, z_scale) = (0.5, 0.3, 0.15)
#let scale_dim = (x_scale * scale_factor, y_scale * scale_factor, z_scale * scale_factor)

// Plot the 3D surface
#plot-3d-surface(
  saddle_func,
  color-func: color_func,
  subdivisions: 8,
  xdomain: (-domain_size, domain_size),
  ydomain: (-domain_size, domain_size),
  // axis-labels: ($V$, $T$, $F(T,V)$), // Compiler error: Unexpected argument
  // axis-step: (1, 1, 2), // Adjust axis steps if needed
  // axis-label-size: 1.2em, // Adjust label size if needed
  // rotation-matrix: ((-2, 2, 4), (0, -1, 0)), // Optional: Adjust view angle
)
