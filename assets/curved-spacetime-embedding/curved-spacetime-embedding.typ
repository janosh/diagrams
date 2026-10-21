#import "@preview/cetz:0.5.3": canvas, draw
#import draw: circle, content, line

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 18pt)

// Flamm's paraboloid: the equatorial plane of the Schwarzschild metric embedded in flat 3D
// space has height z(r) = 2 sqrt(r_s (r - r_s)). All lengths are in units of r_s.
#let r-max = 5.0
#let height(r) = 2 * calc.sqrt(calc.max(r - 1, 0))
#let slope(r) = 1 / calc.sqrt(calc.max(r - 1, 1e-6)) // dz/dr
#let z-top = height(r-max)
#let r-of-z(z) = 1 + z * z / 4 // inverse of height(r)
#let r-orbit = 3.3 // outside the ISCO at 3 r_s, so a stable circular orbit
#let r-peri = 2.1 // periapsis of the light ray (photon sphere at 1.5 r_s)
#assert(r-peri > 1.5, message: "rays with periapsis inside the photon sphere are captured")

#let wire-color = rgb("#24507f")
#let ring-color = rgb("#0f8a7a")
#let ray-color = rgb("#d6336c")

// === perspective camera looking down into the well ===
#let elev = 52deg
#let cam-dist = 26.0
#let z-aim = z-top * 0.45
#let (ce, se) = (calc.cos(elev), calc.sin(elev))
#let cam = (0.0, -cam-dist * ce, z-aim + cam-dist * se)
#let view-depth((x, y, z)) = y * ce - (z - z-aim) * se
#let project((x, y, z)) = {
  let s = cam-dist / (cam-dist + view-depth((x, y, z)))
  (x * s, (y * se + (z - z-aim) * ce) * s)
}
#let surf(r, phi, lift: 0) = (r * calc.cos(phi), r * calc.sin(phi), height(r) + lift)
#let normal(r, phi) = {
  let (m, c, s) = (slope(r), calc.cos(phi), calc.sin(phi))
  let len = calc.sqrt(1 + m * m)
  (-m * c / len, -m * s / len, 1 / len)
}
#let dot(a, b) = a.zip(b).map(((p, q)) => p * q).sum()
#let sub(a, b) = a.zip(b).map(((p, q)) => p - q)

// The mass sits in the throat; it doubles as an occluder in the visibility test.
#let star-pos = (0.0, 0.0, 0.8)
#let star-rad = 1.08

// March from a point towards the camera; it is hidden if the ray pierces the surface
// (changes sides) or the star before rising above the rim.
#let visible(p, above: true) = {
  let d = sub(cam, p)
  let u = d.map(c => c / calc.norm(..d))
  let t = 0.06
  while true {
    let q = p.zip(u).map(((a, b)) => a + t * b)
    let (qx, qy, qz) = q
    if qz > z-top + 0.01 { return true }
    let rq = calc.sqrt(qx * qx + qy * qy)
    if rq >= 1 and rq <= r-max {
      let gap = qz - height(rq)
      if (above and gap < -0.005) or (not above and gap > 0.005) { return false }
    }
    let to-star = sub(q, star-pos)
    if dot(to-star, to-star) < star-rad * star-rad { return false }
    t += 0.07
  }
}
#let faces-camera(r, phi) = {
  let p = surf(r, phi)
  dot(normal(r, phi), sub(cam, p)) > 0
}

// Split a 3D polyline, given as (point, front-facing) pairs, into its visible projected runs.
#let visible-runs(samples) = {
  let (runs, run) = ((), ())
  for (p, above) in samples {
    if visible(p, above: above) { run.push(project(p)) } else {
      if run.len() > 1 { runs.push(run) }
      run = ()
    }
  }
  if run.len() > 1 { runs.push(run) }
  runs
}
#let draw-visible(samples, style) = for run in visible-runs(samples) { line(..run, ..style) }
// a surface point lifted slightly off the surface, with whether its upper side faces the camera
#let sample(r, phi, lift: 0.01) = (surf(r, phi, lift: lift), faces-camera(r, phi))
#let ring(r, n, lift: 0.01) = range(n + 1).map(i => sample(r, i * 2 * calc.pi / n, lift: lift))

// Light ray in the equatorial plane: u'' + u = (3/2) r_s u^2 with u = 1/r, RK4 in phi.
#let ray-points = {
  let b = r-peri / calc.sqrt(1 - 1 / r-peri)
  let accel(u) = -u + 1.5 * u * u
  let (u, w, phi, h) = (1 / 40, 0.0, 0.0, 0.01)
  w = calc.sqrt(1 / (b * b) - u * u + u * u * u)
  let pts = ()
  let phi-peri = none
  while u > 1 / 41 or phi-peri == none {
    let (k1u, k1w) = (w, accel(u))
    let (k2u, k2w) = (w + h / 2 * k1w, accel(u + h / 2 * k1u))
    let (k3u, k3w) = (w + h / 2 * k2w, accel(u + h / 2 * k2u))
    let (k4u, k4w) = (w + h * k3w, accel(u + h * k3u))
    let w-new = w + h / 6 * (k1w + 2 * k2w + 2 * k3w + k4w)
    u += h / 6 * (k1u + 2 * k2u + 2 * k3u + k4u)
    if phi-peri == none and w-new < 0 { phi-peri = phi }
    w = w-new
    phi += h
    if 1 / u <= r-max { pts.push((1 / u, phi)) }
  }
  // rotate the periapsis to phi = 0 (+x), so the ray swings around the right of the throat
  pts.map(((r, phi)) => (r, phi - phi-peri))
}

#canvas(length: 0.72cm, {
  let n-z = 15
  let n-phi = 60
  let light = (-0.45, -0.55, 0.7).map(c => c / calc.norm(-0.45, -0.55, 0.7))

  // shaded surface patches plus the star as (depth, element), painted back to front
  let star-c = project(star-pos)
  let items = ()
  for k in range(n-z) {
    let (r0, r1) = (r-of-z(k * z-top / n-z), r-of-z((k + 1) * z-top / n-z))
    for ip in range(n-phi) {
      let (p0, p1) = (ip * 2 * calc.pi / n-phi, (ip + 1) * 2 * calc.pi / n-phi)
      let corners = ((r0, p0), (r1, p0), (r1, p1), (r0, p1)).map(((r, p)) => surf(r, p))
      let (rm, pm) = ((r0 + r1) / 2, (p0 + p1) / 2)
      let n = normal(rm, pm)
      let front = faces-camera(rm, pm)
      // the inner face is lit from the light; the outer face is in shadow
      let lit = if front { 0.35 + 0.65 * calc.max(0, dot(n, light)) } else { 0.15 }
      let fill = color.mix((rgb("#5f84b0"), 100% - lit * 100%), (rgb("#d3dce8"), lit * 100%))
      let pts = corners.map(project)
      items.push((
        corners.map(view-depth).sum() / 4,
        line(..pts, close: true, fill: fill, stroke: fill + 0.4pt),
      ))
    }
  }
  items.push((
    view-depth(star-pos),
    circle(star-c, radius: star-rad * 0.95, stroke: rgb("#c2410c") + 0.8pt, fill: gradient.radial(
      // narrow lightness range so the star still reads as glowing once inverted
      rgb("#ffa94d"),
      rgb("#f76707"),
      rgb("#e8590c"),
      focal-center: (35%, 35%),
    )),
  ))
  for (_, element) in items.sorted(key: it => -it.at(0)) { element }

  // warm glow of the star on the surrounding surface, clear over the star itself
  circle(star-c, radius: 2.6, stroke: none, fill: gradient.radial(
    (rgb("#ff9f1c").transparentize(100%), 0%),
    (rgb("#ff9f1c").transparentize(100%), 30%),
    (rgb("#ff9f1c").transparentize(35%), 38%),
    (rgb("#ff9f1c").transparentize(100%), 100%),
  ))

  // wireframe: rings evenly spaced in height and radial lines every 15 deg
  let wire = (stroke: wire-color + 0.85pt)
  for k in range(1, 9) {
    draw-visible(ring(r-of-z(k * z-top / 8), 180), if k == 8 {
      (stroke: wire-color + 1.4pt)
    } else { wire })
  }
  for ip in range(24) {
    let phi = ip * 2 * calc.pi / 24
    draw-visible(range(0, 61).map(i => sample(r-of-z(i * z-top / 60), phi)), wire)
  }
  // throat circle r = r_s
  draw-visible(ring(1.0, 180).map(((p, _)) => (p, true)), (stroke: wire-color + 1.4pt))

  // planetary orbit
  draw-visible(ring(r-orbit, 240, lift: 0.02), (
    stroke: (paint: ring-color, thickness: 1.8pt, dash: "dashed"),
  ))

  // bent light ray, traveling from the near rim around the mass to the far rim
  let ray-runs = visible-runs(
    ray-points.map(((r, phi)) => sample(r, phi, lift: 0.03)),
  )
  for (idx, run) in ray-runs.enumerate() {
    let last = idx == ray-runs.len() - 1
    line(..run, stroke: ray-color + 2.2pt, mark: if last {
      (end: "stealth", fill: ray-color, scale: 1.4)
    })
  }

  // planet
  let planet-phi = -125deg / 1rad
  let planet = project(surf(r-orbit, planet-phi, lift: 0.25))
  circle(planet, radius: 0.45, stroke: rgb("#0b5d52") + 0.8pt, fill: gradient.radial(
    rgb("#38c9a0"),
    rgb("#0f8a7a"),
    focal-center: (35%, 35%),
  ))

  // embedding height below the funnel
  let bottom = project(surf(r-max, -90deg / 1rad)).at(1)
  content((0, bottom - 0.45), $z(r) = 2 sqrt(r_s (r - r_s))$, anchor: "north")
})
