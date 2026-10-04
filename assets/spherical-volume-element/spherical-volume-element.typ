// sphere.typ
// Juan Falgueras 2026-10-04
// Spherical differential volumen in CeTZ
//

#set page(width: auto, height: auto, margin: 8pt, fill: none)


#import "@preview/cetz:0.4.2"
#import cetz.draw: *

// =====================================================================
//  VOLUME ELEMENT IN SPHERICAL COORDINATES
//  CeTZ only draws in 2D, so we build the "camera" ourselves:
//  every 3D point is orthographically projected onto the page.
// =====================================================================

// ---------------------------------------------------------------------
//  1. CAMERA
// ---------------------------------------------------------------------
// Viewing direction, with z pointing up.
//   cam-azimuth:   rotation around the z axis (0° = looking from +x)
//   cam-elevation: how much we look from above (0° = level with the equator)
#let cam-azimuth = 30deg
#let cam-elevation = 10deg

// ---------------------------------------------------------------------
//  2. COORDINATE TRANSFORMATIONS
// ---------------------------------------------------------------------

// (x, y, z) 3D  ->  (x, y) on screen  [orthographic projection]
//   - horizontal screen axis: perpendicular to the camera, in the xy plane
//   - vertical screen axis:   the "up" direction as seen by the camera
#let project(x, y, z) = (
  -x*calc.sin(cam-azimuth) + y*calc.cos(cam-azimuth),
  -x*calc.sin(cam-elevation)*calc.cos(cam-azimuth)
    - y*calc.sin(cam-elevation)*calc.sin(cam-azimuth)
    + z*calc.cos(cam-elevation),
)

// Spherical (r, θ, φ)  ->  Cartesian (x, y, z)
//   θ = angle from the z axis (colatitude), φ = azimuthal angle in the xy plane
#let sph-to-xyz(r, theta, phi) = (
  r*calc.sin(theta)*calc.cos(phi),
  r*calc.sin(theta)*calc.sin(phi),
  r*calc.cos(theta),
)

// Spherical (r, θ, φ)  ->  screen. This is the one we use to draw.
#let sph-to-screen(r, theta, phi) = project(..sph-to-xyz(r, theta, phi))

// ---------------------------------------------------------------------
//  3. VISIBILITY
// ---------------------------------------------------------------------
// Dot product of the 3D point with the camera direction.
//   > 0: the point is on the camera side (visible)
//   < 0: the point is behind the central plane (hidden by the sphere)
#let depth-toward-camera(xyz) = (
  xyz.at(0)*calc.cos(cam-azimuth)*calc.cos(cam-elevation)
  + xyz.at(1)*calc.sin(cam-azimuth)*calc.cos(cam-elevation)
  + xyz.at(2)*calc.sin(cam-elevation)
)

// ---------------------------------------------------------------------
//  4. DRAWING UTILITIES
// ---------------------------------------------------------------------

// Arrow styles
#let arrow-tip = (end: "stealth", fill: black, scale: .6)                         // axes and vector r
#let arrow-lengths = (end: "stealth", start: "stealth", fill: black, scale: .4)   // double arrows for lengths
#let stroke-lengths = (paint: blue, thickness: .5pt, cap: "round", join: "round")

// Curve on the sphere, split into n small segments.
// Each segment is drawn with style `front` or `back` depending on whether it
// is in front or behind. It is split because a single `line` has one style.
//   curve-xyz: function  parameter -> (x, y, z)
//   from, to:  parameter range
#let sphere-curve(curve-xyz, from, to, front, back, n: 120) = {
  for i in range(n) {
    let start = from + (to - from)*i/n
    let end = from + (to - from)*(i + 1)/n
    let midpoint = curve-xyz((start + end)/2)
    line(
      project(..curve-xyz(start)),
      project(..curve-xyz(end)),
      stroke: if depth-toward-camera(midpoint) >= 0 { front } else { back },
    )
  }
}

// Parametric curve already in screen coordinates, sampled with n+1 points.
//   curve-screen: function  parameter -> (sx, sy)
#let polyline-curve(curve-screen, from, to, n: 40, ..style) = {
  line(..range(n + 1).map(i => curve-screen(from + (to - from)*i/n)), ..style)
}

// ---------------------------------------------------------------------
//  5. VOLUME-ELEMENT HELPERS (corners are (r, θ, φ) triples)
// ---------------------------------------------------------------------

// Point at fraction u (0..1) between corners a and b, coordinate by coordinate.
// If a and b differ in a single coordinate, this walks along an edge of dV.
#let lerp-corner(a, b, u) = a.zip(b).map(((p, q)) => p + (q - p)*u)

// Edge between two corners, as a polyline on screen. Use n: 1 for straight
// (radial) edges and n: 6 or so for curved ones (θ or φ edges).
#let corner-edge(a, b, n: 6, ..style) = {
  polyline-curve(u => sph-to-screen(..lerp-corner(a, b, u)), 0, 1, n: n, ..style)
}

// The 3 corner indices adjacent to a corner index, e.g. (0,0,1) -> (1,0,1), (0,1,1), (0,0,0)
#let index-neighbors(idx) = range(3).map(axis =>
  idx.enumerate().map(((i, v)) => if i == axis { 1 - v } else { v }))

// The 6 corner indices forming the silhouette of the box, in cyclic order.
// Seen from outside, a box hides 2 opposite corners (the farthest one and the
// nearest one); the other 6 form a hexagon and consecutive ones share an edge.
//   farthest: index triple of the farthest corner, e.g. (0, 0, 1)
#let silhouette-ring(farthest) = {
  let nearest = farthest.map(i => 1 - i)
  let previous = none
  let current = index-neighbors(farthest).first()
  let ring = (current,)
  for _ in range(5) {
    let next = index-neighbors(current)
      .filter(c => c != farthest and c != nearest and c != previous)
      .first()
    previous = current
    current = next
    ring.push(current)
  }
  ring
}

// ---------------------------------------------------------------------
//  6. FIGURE
// ---------------------------------------------------------------------
#cetz.canvas(length: 1cm, {

  // --- 6.1 Parameters ---------------------------------------------------
  let sphere-radius = 4

  // Limits of the volume element (exaggerated; in theory infinitesimal)
  let (r-min, r-max) = (3, 3.5)                // dr
  let (theta-min, theta-max) = (55deg, 67deg)  // dθ
  let (phi-min, phi-max) = (50deg, 64deg)      // dφ

  // Vector r: tip at the corner (r-min, theta-max, phi-min)
  let (r-vec, theta-vec, phi-vec) = (r-min, theta-max, phi-min)

  // Axes
  let axis-overshoot = 0.8        // how far the positive axes go beyond the sphere
  let axis-label-offset = 1.1     // distance of the x, y, z labels beyond the sphere
  let negative-axis-factor = 1.1  // length of negative half-axes (times sphere-radius)

  // Angle arcs and their labels (radii measured from the origin)
  let theta-arc-radius = .5
  let theta-label-radius = .3
  let phi-arc-radius = 1.2
  let phi-label-radius = 1

  // Labels along vector r and its projection on the xy plane
  let vector-label-radius = 2
  let foot-label-radius = 2

  // Length arrows are pushed slightly outside the element (factor on the angle)
  let length-offset = 1.03

  // Samples per curved edge (θ and φ edges, and the fill outline)
  let edge-samples = 6

  // --- Styles ------------------------------------------------------------
  let style-guide = (paint: gray, thickness: 0.5pt)                                      // visible
  let style-guide-hidden = (paint: gray.lighten(25%), thickness: 0.5pt, dash: "dotted") // hidden
  let style-angle = (paint: red, thickness: .5pt, cap: "round")
  let style-projection = (dash: "dashed", paint: gray, thickness: 0.3pt)
  let style-origin-extension = (paint: gray.lighten(60%), thickness: 0.6pt, dash: "dotted")
  let style-edge-visible = (paint: blue, thickness: 1pt, cap: "round", join: "round")
  let style-edge-hidden = (paint: blue.lighten(60%), thickness: 0.6pt, dash: "dotted", cap: "round")
  let style-fill = blue.transparentize(90%)    // very weak fill of dV

  // --- 6.2 Corners of dV --------------------------------------------------
  // Naming: c-ABC, where A, B, C = 0 (min) or 1 (max) for r, θ, φ respectively.
  //   c-000 = (r-min, θ-min, φ-min)    c-100 = (r-max, θ-min, φ-min)
  //   c-010 = (r-min, θ-max, φ-min)    c-110 = (r-max, θ-max, φ-min)
  //   c-001 = (r-min, θ-min, φ-max)    c-101 = (r-max, θ-min, φ-max)
  //   c-011 = (r-min, θ-max, φ-max)    c-111 = (r-max, θ-max, φ-max)
  let corner-at(ir, itheta, iphi) = (
    (r-min, r-max).at(ir),
    (theta-min, theta-max).at(itheta),
    (phi-min, phi-max).at(iphi),
  )
  let c-000 = corner-at(0, 0, 0)
  let c-100 = corner-at(1, 0, 0)
  let c-010 = corner-at(0, 1, 0)
  let c-110 = corner-at(1, 1, 0)
  let c-001 = corner-at(0, 0, 1)
  let c-101 = corner-at(1, 0, 1)
  let c-011 = corner-at(0, 1, 1)
  let c-111 = corner-at(1, 1, 1)

  // Corner indices, in case we need to loop over all 8 corners
  let corner-indices = ((0,0,0), (1,0,0), (0,1,0), (1,1,0), (0,0,1), (1,0,1), (0,1,1), (1,1,1))

  // Hidden corner: the one farthest from the camera. Its 3 edges are drawn faint.
  let farthest-index = corner-indices.sorted(key: idx =>
    depth-toward-camera(sph-to-xyz(..corner-at(..idx)))).first()
  let farthest-corner = corner-at(..farthest-index)

  // Silhouette: the 6 corners surrounding dV on screen, in cyclic order.
  // (With the current camera: c-101, c-111, c-011, c-010, c-000, c-100,
  //  and the two corners that fall inside the outline are c-001 and c-110.)
  // To force them by hand, replace the right-hand side with e.g.
  //   (c-000, c-100, c-101, c-111, c-011, c-010)
  let silhouette-corners = silhouette-ring(farthest-index).map(idx => corner-at(..idx))

  // Style of an edge: faint if it touches the hidden corner. Takes both end corners.
  let edge-style(a, b) = if a == farthest-corner or b == farthest-corner {
    style-edge-hidden
  } else {
    style-edge-visible
  }

  // Draws the edge between corners a and b with the style that corresponds to it.
  let draw-edge(a, b, n: edge-samples) = corner-edge(a, b, n: n, stroke: edge-style(a, b))

  // --- 6.3 Fill of dV (drawn first, below every line) --------------------
  // Closed outline: each silhouette corner joined to the next along the real
  // edge (sampled), so the curved θ and φ edges are followed.
  let outline = silhouette-corners.enumerate().map(((i, a)) => {
    let b = silhouette-corners.at(calc.rem(i + 1, silhouette-corners.len()))
    range(edge-samples).map(k => sph-to-screen(..lerp-corner(a, b, k/edge-samples)))
  }).join()
  line(..outline, close: true, fill: style-fill, stroke: none)

  // --- 6.4 Sphere ----------------------------------------------------------
  // The apparent outline of a sphere in orthographic projection is always
  // a circle of radius R centred at the origin.
  circle((0, 0), radius: sphere-radius, stroke: style-guide)
  // Equator (θ = 90°, φ runs 0..360°)
  sphere-curve(phi => sph-to-xyz(sphere-radius, 90deg, phi),
    0deg, 360deg, style-guide, style-guide-hidden)
  // Meridian in the xz plane (φ = 0°, θ runs 0..360°)
  sphere-curve(theta => sph-to-xyz(sphere-radius, theta, 0deg),
    0deg, 360deg, style-guide, style-guide-hidden)
  // Meridian in the yz plane (φ = 90°)
  sphere-curve(theta => sph-to-xyz(sphere-radius, theta, 90deg),
    0deg, 360deg, style-guide, style-guide-hidden)

  // --- 6.5 Angle arcs θ and φ ------------------------------------------------
  // θ: arc in the vertical plane of azimuth phi-vec, from 0 up to theta-vec
  polyline-curve(theta => sph-to-screen(theta-arc-radius, theta, phi-vec),
    0deg, theta-vec, stroke: style-angle)
  content(sph-to-screen(theta-label-radius, theta-vec/2, phi-vec), text(red)[$theta$],
    anchor: "east", padding: 0.1)
  // -z half-axis: drawn BEFORE the φ arc so the arc ends up on top of it
  line(project(0,0,0), project(0,0,-negative-axis-factor*sphere-radius), stroke: style-guide-hidden)
  // φ: arc in the xy plane, from 0 up to phi-vec
  polyline-curve(phi => sph-to-screen(phi-arc-radius, 90deg, phi),
    0deg, phi-vec, stroke: style-angle)
  content(sph-to-screen(phi-label-radius, 90deg, phi-vec/2), text(red)[$phi$],
    anchor: "north", padding: 0.0)

  // --- 6.6 Axes -------------------------------------------------------------------
  // Negative half-axes: faint (behind the centre)
  line(project(0,0,0), project(-negative-axis-factor*sphere-radius,0,0), stroke: style-guide-hidden)
  line(project(0,0,0), project(0,-negative-axis-factor*sphere-radius,0), stroke: style-guide-hidden)

  // Positive half-axes: with arrow tip (in front)
  line(project(0,0,0), project(0,0,sphere-radius + axis-overshoot), mark: arrow-tip)
  line(project(0,0,0), project(sphere-radius + axis-overshoot,0,0), mark: arrow-tip)
  line(project(0,0,0), project(0,sphere-radius + axis-overshoot,0), mark: arrow-tip)
  content(project(0,0,sphere-radius + axis-label-offset), $z$)
  content(project(sphere-radius + axis-label-offset,0,0), $x$)
  content(project(0,sphere-radius + axis-label-offset,0), $y$)

  // --- 6.7 Edges of dV (12) ------------------------------------------------------
  // The drawing order matters: faint/hidden edges go first so they never end
  // up painted over the front ones. Three families of 4, by the coordinate that varies.

  // (a) RADIAL edges (4): θ and φ fixed, r goes from r-min to r-max. Length: dr.
  draw-edge(c-000, c-100, n: 1)
  draw-edge(c-010, c-110, n: 1)
  draw-edge(c-001, c-101, n: 1)
  draw-edge(c-011, c-111, n: 1)

  // Extension of the inner radial edges back to the origin O
  // (c-010 is skipped: vector r is drawn there later)
  for corner in (c-000, c-001, c-011) {
    line((0, 0), sph-to-screen(..corner), stroke: style-origin-extension)
  }

  // (c) one φ edge drawn early so it goes under the θ edges:
  //     r-min, θ-min, φ from min to max  (it touches the hidden corner)
  draw-edge(c-000, c-001)

  // (b) θ edges (4): r and φ fixed, θ goes from theta-min to theta-max.
  //     Arcs of a great circle, length r·dθ.
  draw-edge(c-000, c-010)   // r-min, φ-min
  draw-edge(c-100, c-110)   // r-max, φ-min
  draw-edge(c-001, c-011)   // r-min, φ-max
  draw-edge(c-101, c-111)   // r-max, φ-max

  // (c) φ edges (the other 3): r and θ fixed, φ goes from phi-min to phi-max.
  //     Arcs of a parallel, length r·sin θ·dφ.
  //     (The 4th one, c-000 -> c-001, was drawn before the θ edges.)
  draw-edge(c-100, c-101)   // r-max, θ-min
  draw-edge(c-010, c-011)   // r-min, θ-max
  draw-edge(c-110, c-111)   // r-max, θ-max

  // --- 6.8 Length arrows -------------------------------------------------------------
  // r sin θ dφ: double arrow along φ, at r-min, slightly beyond theta-max
  polyline-curve(phi => sph-to-screen(r-min, theta-max*length-offset, phi),
    phi-min, phi-max, n: edge-samples, stroke: stroke-lengths, mark: arrow-lengths)
  // r dθ: double arrow along θ, at r-max, slightly beyond phi-max
  polyline-curve(theta => sph-to-screen(r-max, theta, phi-max*length-offset),
    theta-min, theta-max, n: edge-samples, stroke: stroke-lengths, mark: arrow-lengths)

  // --- 6.9 Vector r and its projection on the xy plane -------------------------------
  // The projection of the tip of r on the xy plane is at distance r·sin θ from
  // the origin, with the same azimuth φ. It must use the SAME θ as the tip.
  let r-tip = sph-to-screen(r-vec, theta-vec, phi-vec)
  let foot-on-xy-plane = sph-to-screen(r-vec*calc.sin(theta-vec), 90deg, phi-vec)
  line(r-tip, foot-on-xy-plane, stroke: style-projection)   // vertical, parallel to z
  line((0, 0), foot-on-xy-plane, stroke: style-projection)  // length r·sin θ
  content(sph-to-screen(foot-label-radius, 90deg, phi-vec), text(fill: gray, $r sin theta$),
    anchor: "north", padding: 0.0)
  line((0, 0), r-tip, stroke: 1.2pt, mark: arrow-tip)
  content(sph-to-screen(vector-label-radius, theta-vec, phi-vec), $arrow(r)$,
    anchor: "south-east", padding: 0.0)

  // --- 6.10 Length labels and volume label ------------------------------------------------
  // dr: on the radial edge at corner (θ-min, φ-min)
  content(sph-to-screen(..c-100), text(blue)[$d r$],
    anchor: "east", padding: .1)
  // r dθ: next to a θ edge
  content(sph-to-screen(r-max, (theta-min + theta-max)/2, phi-max), text(blue)[$r d theta$],
    anchor: "west", padding: .15)
  // r sin θ dφ: next to a φ edge
  content(sph-to-screen(r-min, theta-max, (phi-min + phi-max)/2),
    text(blue)[$r sin theta d phi$], anchor: "north-west", padding: 0.08)
  // dV: full formula, placed above the element
  content(sph-to-screen((r-min + r-max)/2, theta-min, (phi-min + phi-max)/2),
    text(blue, size: 1em)[$d V = r^2 sin theta d theta d phi d r$],
    anchor: "south-west", padding: .3)
})
