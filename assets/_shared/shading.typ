// Shared 3D-looking atom rendering for the crystal-structure and molecule diagrams.

#import "@preview/cetz:0.5.2": draw

// Off-center radial gradient reading as a highlight on a lit sphere.
#let sphere-fill(color) = gradient.radial(
  color.lighten(75%),
  color,
  color.darken(15%),
  focal-center: (30%, 25%),
  focal-radius: 5%,
  center: (35%, 30%),
)

// The flat disc underneath is fully covered by the gradient, but drawing both
// doubles up the antialiased rim so the sphere keeps a crisp edge.
#let sphere(pos, radius: 0.25, fill: luma(50), ..args) = {
  draw.circle(pos, radius: radius, stroke: none, fill: fill, ..args)
  draw.circle(pos, radius: radius, stroke: none, fill: sphere-fill(fill))
}
