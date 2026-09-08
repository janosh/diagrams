#import "@preview/cetz:0.5.2": canvas, draw, vector

#set page(width: auto, height: auto, margin: 12pt, fill: none)
#set text(font: "New Computer Modern", size: 10pt, fill: rgb("243247"))

#let u_color = rgb("2563eb")
#let v_color = rgb("138579")
#let basis_u = (1, 0.2)
#let basis_v = (0.2, 1)
#let norm_squared = vector.dot(basis_u, basis_u)
// Complex division v/u applies the same rotation and scaling to both generators.
#let normalized_basis = (
  vector.dot(basis_u, basis_v) / norm_squared,
  (basis_u.at(0) * basis_v.at(1) - basis_u.at(1) * basis_v.at(0)) / norm_squared,
)
#let arrow(color) = (end: "stealth", fill: color, stroke: none, length: 5pt, width: 4pt)

#let panel(first_basis, second_basis, labels: ($2 pi u$, $2 pi v$)) = box(
  width: 5.8cm,
  height: 5.2cm,
  clip: true,
  canvas({
    draw.hide(bounds: true, draw.rect((-0.8, -0.7), (5, 4.5), stroke: none))
    draw.floating({
      let project(col_idx, row_idx) = (
        3 * (first_basis.at(0) * col_idx + second_basis.at(0) * row_idx),
        3 * (first_basis.at(1) * col_idx + second_basis.at(1) * row_idx),
      )
      for grid_idx in range(-2, 4) {
        for endpoints in (
          (project(grid_idx, -2), project(grid_idx, 3)),
          (project(-2, grid_idx), project(3, grid_idx)),
        ) {
          draw.line(..endpoints, stroke: (paint: rgb("d7dee6"), thickness: 0.5pt, dash: "dashed"))
        }
        for row_idx in range(-2, 4) {
          draw.circle(project(grid_idx, row_idx), radius: 0.035, fill: rgb("a8b3c2"), stroke: none)
        }
      }
      let first = project(1, 0)
      let second = project(0, 1)
      let diagonal = project(1, 1)
      draw.line((0, 0), first, diagonal, second, close: true, fill: rgb("edf4f8"), stroke: none)
      // Matching colors and directions identify the pairs of opposite edges.
      for (start, end, color) in (
        ((0, 0), first, u_color),
        (second, diagonal, u_color),
        ((0, 0), second, v_color),
        (first, diagonal, v_color),
      ) {
        draw.line(start, end, stroke: color + 1.2pt, mark: (
          pos: 0.55,
          shorten-to: none,
          ..arrow(color),
        ))
      }
      for point in ((0, 0), first, second, diagonal) {
        draw.circle(point, radius: 0.045, fill: rgb("243247"), stroke: none)
      }
      draw.content(vector.scale(diagonal, 0.5), text(size: 9pt)[Fundamental cell])
      draw.content((0, -0.2), $0$)
      draw.content(vector.add(vector.scale(first, 0.5), (0, -0.28)), text(
        fill: u_color,
        labels.at(0),
      ))
      draw.content(
        vector.add(vector.scale(second, 0.5), (-0.18, 0)),
        text(fill: v_color, labels.at(1)),
        anchor: "east",
      )
    })
  }),
)

#canvas({
  draw.content((6.3, 6.15), text(size: 16pt, weight: "bold")[A torus from a repeating lattice])
  draw.content((2.9, 5.5), text(size: 11pt, weight: "bold")[Choose two generators])
  draw.content((9.7, 5.5), text(size: 11pt, weight: "bold")[Normalize the first generator])
  draw.content((0, 0), panel(basis_u, basis_v), anchor: "south-west")
  draw.content(
    (6.8, 0),
    panel((1, 0), normalized_basis, labels: ($2 pi$, $2 pi tau$)),
    anchor: "south-west",
  )

  draw.line((5.4, 2.25), (6.6, 2.25), stroke: rgb("697586") + 1pt, mark: arrow(rgb("697586")))
  draw.content((6.0, 2.7), $z mapsto z \/ u$)
  draw.content((6.0, 1.65), text(size: 8pt)[#align(center)[Rotate + scale]])

  draw.content((2.9, -0.15), $z equiv z + 2 pi u equiv z + 2 pi v$)
  draw.content((9.7, -0.15), $tau = v \/ u, quad op("Im") tau > 0$)
  draw.content((6.3, -0.85), text(size: 11pt)[Glue each pair of matching edges to obtain a torus.])
  draw.content((6.3, -1.3), text(
    size: 9pt,
    fill: rgb("697586"),
  )[Rotation and uniform scaling preserve the conformal shape; $tau$ describes it.])
})
