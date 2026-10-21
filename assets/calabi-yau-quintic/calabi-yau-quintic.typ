#set page(width: auto, height: auto, margin: 8pt, fill: none)

// Hanson's 2D cross-section of the quintic Calabi-Yau threefold: the complex curve
// z1^5 + z2^5 = 1 in C^2, built from 25 patches (k1, k2) via
// z1 = e^(2 pi i k1 / 5) cos(z)^(2/5), z2 = e^(2 pi i k2 / 5) sin(z)^(2/5), z = a + i b,
// projected to R^3 as (Re z1, Re z2, cos(alpha) Im z1 + sin(alpha) Im z2).
//
// Hidden surfaces are resolved exactly rather than by a plain depth sort: triangles that
// pierce each other are cut along each other's planes, and the depth order of the pieces is
// corrected wherever pairwise occlusion tests (Newell's plane tests) contradict it.
// Native Typst polygons are used instead of CeTZ since CeTZ is ~100x slower per element.
#let n-pow = 5
#let b-max = 1.2
#let n-s = 15 // cells from each singular point (z = 0 or pi/2) to the middle line a = pi/4
#let n-t = 2 * n-s // cells along b in [-b-max, b-max] (matching n-s keeps mesh rings closed)
#let alpha = calc.pi / 4 // mixes Im z1 and Im z2 into the third real axis
#let yaw = 0.62 // view rotation about the vertical axis
#let pitch = 0.42 // view tilt toward the viewer
#let unit = 4.2cm // drawing scale
#let ring-step = 2 // draw every n-th mesh ring
#let on-ring(k) = calc.rem(k, ring-step) == 0
#let mesh-stroke(shade) = (paint: shade.darken(22%), thickness: 0.4pt, cap: "round")
#let eps = 1e-9

// Complex numbers as (re, im) pairs.
#let c-cos((x, y)) = (calc.cos(x) * calc.cosh(y), -calc.sin(x) * calc.sinh(y))
#let c-sin((x, y)) = (calc.sin(x) * calc.cosh(y), calc.cos(x) * calc.sinh(y))
#let c-mul((a, b), (c, d)) = (a * c - b * d, a * d + b * c)
#let c-pow((x, y), p) = {
  // principal branch of w^p
  let r = calc.sqrt(x * x + y * y)
  if r == 0 { return (0.0, 0.0) }
  let phi = calc.atan2(x, y).rad() * p
  let rp = calc.pow(r, p)
  (rp * calc.cos(phi), rp * calc.sin(phi))
}

// Embed in R^3, then rotate into view coordinates (x right, y up, z toward the viewer).
#let to-view(z1, z2) = {
  let (x, y, z) = (z1.at(0), z2.at(0), calc.cos(alpha) * z1.at(1) + calc.sin(alpha) * z2.at(1))
  let (xr, zr) = (x * calc.cos(yaw) + z * calc.sin(yaw), -x * calc.sin(yaw) + z * calc.cos(yaw))
  (xr, y * calc.cos(pitch) - zr * calc.sin(pitch), y * calc.sin(pitch) + zr * calc.cos(pitch))
}

#let sub(p, q) = (p.at(0) - q.at(0), p.at(1) - q.at(1), p.at(2) - q.at(2))
#let dot(p, q) = p.at(0) * q.at(0) + p.at(1) * q.at(1) + p.at(2) * q.at(2)
#let cross(u, v) = (
  u.at(1) * v.at(2) - u.at(2) * v.at(1),
  u.at(2) * v.at(0) - u.at(0) * v.at(2),
  u.at(0) * v.at(1) - u.at(1) * v.at(0),
)
#let normalize(v) = {
  let n = calc.norm(..v)
  if n == 0 { (0.0, 0.0, 1.0) } else { v.map(c => c / n) }
}
#let lerp(p, q, t) = range(3).map(c => p.at(c) + (q.at(c) - p.at(c)) * t)
#let light = normalize((-0.45, 0.65, 0.62))
// Plane of a polygon: unit normal facing the viewer (+z) and a point on it.
#let plane-of(poly) = {
  let n = normalize(cross(sub(poly.at(1), poly.at(0)), sub(poly.at(2), poly.at(0))))
  (if n.at(2) < 0 { n.map(c => -c) } else { n }, poly.at(0))
}
#let signed-dists(poly, (n, p0)) = {
  let (nx, ny, nz) = n
  let offset = nx * p0.at(0) + ny * p0.at(1) + nz * p0.at(2)
  poly.map(((x, y, z)) => nx * x + ny * y + nz * z - offset)
}

// Split a convex polygon by a plane into its parts with at least 3 vertices. Each polygon carries a flag
// per edge (edge i runs from vertex i to i + 1) marking mesh lines; new cut edges are unflagged.
#let clip((poly, flags), pl) = {
  let d = signed-dists(poly, pl)
  if calc.min(..d) >= -eps or calc.max(..d) <= eps { return ((poly, flags),) }
  let (front, front-flags, back, back-flags) = ((), (), (), ())
  let k = poly.len()
  for i in range(k) {
    let (p, q, dp, dq, f) = (
      poly.at(i),
      poly.at(calc.rem(i + 1, k)),
      d.at(i),
      d.at(calc.rem(i + 1, k)),
      flags.at(i),
    )
    let x = if (dp > 0 and dq < 0) or (dp < 0 and dq > 0) { lerp(p, q, dp / (dp - dq)) }
    if dp >= 0 {
      front.push(p)
      front-flags.push((dp > 0 or dq >= 0) and f)
    }
    if dp <= 0 {
      back.push(p)
      back-flags.push((dp < 0 or dq <= 0) and f)
    }
    if x != none {
      front.push(x)
      front-flags.push(dp < 0 and f) // entering the front side continues edge p -> q
      back.push(x)
      back-flags.push(dp > 0 and f)
    }
  }
  ((front, front-flags), (back, back-flags)).filter(part => part.at(0).len() >= 3)
}

// Interval covered by a triangle on the line where it crosses another triangle's plane.
#let crossing-interval(tri, d, dir) = {
  let vals = ()
  for i in range(3) {
    let (p, q, dp, dq) = (tri.at(i), tri.at(calc.rem(i + 1, 3)), d.at(i), d.at(calc.rem(i + 1, 3)))
    if (dp > 0 and dq < 0) or (dp < 0 and dq > 0) {
      vals.push(dot(lerp(p, q, dp / (dp - dq)), dir))
    } else if dp == 0 { vals.push(dot(p, dir)) }
  }
  if vals.len() == 0 { none } else { (calc.min(..vals), calc.max(..vals)) }
}

// 2D separating-axis test for convex polygons; touching polygons do not overlap.
#let overlap-2d(p, q) = {
  for poly in (p, q) {
    let k = poly.len()
    for i in range(k) {
      let (a, b) = (poly.at(i), poly.at(calc.rem(i + 1, k)))
      let (ax, ay) = (a.at(1) - b.at(1), b.at(0) - a.at(0))
      let tol = eps * (calc.abs(ax) + calc.abs(ay))
      let pp = p.map(v => v.at(0) * ax + v.at(1) * ay)
      let qq = q.map(v => v.at(0) * ax + v.at(1) * ay)
      if calc.max(..pp) <= calc.min(..qq) + tol or calc.max(..qq) <= calc.min(..pp) + tol {
        return false
      }
    }
  }
  true
}

// Uniform 3D grid for finding pairs of polygons whose bounding boxes overlap.
#let cell = 0.1
#let bbox(poly) = {
  let (xs, ys, zs) = (poly.map(p => p.at(0)), poly.map(p => p.at(1)), poly.map(p => p.at(2)))
  (calc.min(..xs), calc.max(..xs), calc.min(..ys), calc.max(..ys), calc.min(..zs), calc.max(..zs))
}
#let close-pairs(boxes) = {
  let ranges = boxes.map(bb => bb.map(v => int(calc.floor(v / cell))))
  let lo = range(3).map(ax => calc.min(..ranges.map(r => r.at(2 * ax))))
  let size = range(3).map(ax => calc.max(..ranges.map(r => r.at(2 * ax + 1))) - lo.at(ax) + 1)
  let grid = range(size.product()).map(_ => ())
  for (n, r) in ranges.enumerate() {
    for cx in range(r.at(0), r.at(1) + 1) {
      for cy in range(r.at(2), r.at(3) + 1) {
        for cz in range(r.at(4), r.at(5) + 1) {
          grid
            .at(((cx - lo.at(0)) * size.at(1) + cy - lo.at(1)) * size.at(2) + cz - lo.at(2))
            .push(n)
        }
      }
    }
  }
  let pairs = ()
  for (c, members) in grid.enumerate() {
    if members.len() < 2 { continue }
    let cz = calc.rem(c, size.at(2)) + lo.at(2)
    let cy = calc.rem(calc.div-euclid(c, size.at(2)), size.at(1)) + lo.at(1)
    let cx = calc.div-euclid(c, size.at(2) * size.at(1)) + lo.at(0)
    for (i, m) in members.enumerate() {
      let (bm, rm) = (boxes.at(m), ranges.at(m))
      for n in members.slice(i + 1) {
        let rn = ranges.at(n)
        // report each pair only in the first cell both share
        if (
          calc.max(rm.at(0), rn.at(0)) != cx
            or calc.max(rm.at(2), rn.at(2)) != cy
            or calc.max(rm.at(4), rn.at(4)) != cz
        ) { continue }
        let bn = boxes.at(n)
        if (
          bm.at(1) <= bn.at(0)
            or bn.at(1) <= bm.at(0)
            or bm.at(3) <= bn.at(2)
            or bn.at(3) <= bm.at(2)
        ) { continue }
        if bm.at(5) <= bn.at(4) or bn.at(5) <= bm.at(4) { continue }
        pairs.push((m, n))
      }
    }
  }
  pairs
}

#let patch-color(k1, k2) = oklch((62 + 4 * k2) * 1%, 0.17, (k1 * 72 + k2 * 25) * 1deg)

// Parameter grid: each half of the strip a in [0, pi/2] is meshed outward from its singular
// point with a radial r^1.5 stretch, so cells stay evenly sized after the 2/5 power.
#let z-grid = (0, 1).map(half => range(n-s + 1).map(i => range(n-t + 1).map(j => {
  let (s, t) = (i / n-s, 2 * j / n-t - 1)
  let r = calc.pow(calc.max(s, calc.abs(t)), 1.5)
  let a = calc.pi / 4 * s * r
  (if half == 0 { a } else { calc.pi / 2 - a }, b-max * t * r)
})))

// Triangles of all 25 patches: (vertices, color, mesh-line flag per edge).
#let triangles = {
  let roots = range(n-pow).map(k => (
    calc.cos(2 * calc.pi * k / n-pow),
    calc.sin(2 * calc.pi * k / n-pow),
  ))
  let powers = z-grid.map(half => half.map(row => row.map(z => (
    c-pow(c-cos(z), 2 / n-pow),
    c-pow(c-sin(z), 2 / n-pow),
  ))))
  let out = ()
  for k1 in range(n-pow) {
    for k2 in range(n-pow) {
      let base = patch-color(k1, k2)
      for half in powers {
        let pts = half.map(row => row.map(((w1, w2)) => to-view(c-mul(roots.at(k1), w1), c-mul(
          roots.at(k2),
          w2,
        ))))
        // Lambert shading from vertex normals (averaged over adjacent cells) for smooth gradients
        let cell-normals = range(n-s).map(i => range(n-t).map(j => normalize(cross(
          sub(pts.at(i + 1).at(j + 1), pts.at(i).at(j)),
          sub(pts.at(i).at(j + 1), pts.at(i + 1).at(j)),
        ))))
        let lit = range(n-s + 1).map(i => range(n-t + 1).map(j => {
          let adjacent = ((i - 1, j - 1), (i - 1, j), (i, j - 1), (i, j)).filter(((u, v)) => (
            u >= 0 and v >= 0 and u < n-s and v < n-t
          ))
          let normal = normalize(
            range(3).map(c => adjacent.map(((u, v)) => cell-normals.at(u).at(v).at(c)).sum()),
          )
          calc.abs(dot(normal, light))
        }))
        let shade(ids) = base.darken(
          (1 - (0.35 + 0.65 * ids.map(((u, v)) => lit.at(u).at(v)).sum() / 3)) * 100%,
        )
        for i in range(n-s) {
          for j in range(n-t) {
            let (p00, p10, p11, p01) = (
              pts.at(i).at(j),
              pts.at(i + 1).at(j),
              pts.at(i + 1).at(j + 1),
              pts.at(i).at(j + 1),
            )
            // Mesh lines are iso-a lines where |t| <= s and iso-b lines where s <= |t|; together
            // they form closed rings around the singular point. Flag every ring-step-th ring.
            let (t0, t1) = (calc.abs(j - n-s), calc.abs(j + 1 - n-s))
            let on-i = on-ring(i) and calc.max(t0, t1) <= i
            let on-i1 = on-ring(i + 1) and calc.max(t0, t1) <= i + 1
            let on-j = on-ring(t0) and i + 1 <= t0
            let on-j1 = on-ring(t1) and i + 1 <= t1
            out.push((
              (p00, p10, p11),
              shade(((i, j), (i + 1, j), (i + 1, j + 1))),
              (on-j, on-i1, false),
            ))
            out.push((
              (p00, p11, p01),
              shade(((i, j), (i + 1, j + 1), (i, j + 1))),
              (false, on-j1, on-i),
            ))
          }
        }
      }
    }
  }
  out
}

// Cut each triangle along the planes of the triangles it intersects.
#let pieces = {
  let tris = triangles.map(t => t.at(0))
  let planes = tris.map(plane-of)
  let cuts = tris.map(_ => ())
  for (m, n) in close-pairs(tris.map(bbox)) {
    let (tm, tn) = (tris.at(m), tris.at(n))
    let dm = signed-dists(tm, planes.at(n))
    if calc.min(..dm) >= 0 or calc.max(..dm) <= 0 { continue }
    let dn = signed-dists(tn, planes.at(m))
    if calc.min(..dn) >= 0 or calc.max(..dn) <= 0 { continue }
    // mesh neighbors sharing an edge only touch; a single shared vertex can still pierce
    if tm.filter(p => tn.any(q => sub(p, q).map(calc.abs).sum() < eps)).len() >= 2 { continue }
    let dir = cross(planes.at(m).at(0), planes.at(n).at(0))
    let (im, itv-n) = (crossing-interval(tm, dm, dir), crossing-interval(tn, dn, dir))
    if im == none or itv-n == none or im.at(1) <= itv-n.at(0) or itv-n.at(1) <= im.at(0) {
      continue
    }
    cuts.at(m).push(n)
    cuts.at(n).push(m)
  }
  let out = ()
  for (m, (tri, shade, flags)) in triangles.enumerate() {
    let parts = ((tri, flags),)
    for n in cuts.at(m) { parts = parts.map(part => clip(part, planes.at(n))).join() }
    for (part, part-flags) in parts { out.push((part, shade, planes.at(m), part-flags)) }
  }
  out
}

// Painter order. Start from the mean depth and, for every pair of overlapping pieces whose
// depth ranges overlap, enforce the order given by Newell's plane tests (a piece entirely
// behind the other's plane, or with the other entirely in front of its own plane, goes first)
// by relaxing the sort keys until all these constraints hold.
#let draw-order = {
  let polys = pieces.map(p => p.at(0))
  let planes = pieces.map(p => p.at(2))
  let tol = 1e-7
  let constraints = ()
  for (m, n) in close-pairs(polys.map(bbox)) {
    let (poly-m, poly-n) = (polys.at(m), polys.at(n))
    let (dm, dn) = (signed-dists(poly-m, planes.at(n)), signed-dists(poly-n, planes.at(m)))
    let (dm-lo, dm-hi, dn-lo, dn-hi) = (
      calc.min(..dm),
      calc.max(..dm),
      calc.min(..dn),
      calc.max(..dn),
    )
    let pair = if dm-hi <= tol and dm-lo < -tol or dn-lo >= -tol and dn-hi > tol {
      (m, n)
    } else if (
      dn-hi <= tol and dn-lo < -tol or dm-lo >= -tol and dm-hi > tol
    ) { (n, m) } else { none }
    if pair != none and overlap-2d(poly-m, poly-n) { constraints.push(pair) }
  }
  let key = polys.map(poly => poly.map(p => p.at(2)).sum() / poly.len())
  // a cycle of constraints (cyclic overlap) would never settle, so fail instead of misdrawing
  let settled = false
  for _ in range(100) {
    if settled { break }
    settled = true
    for (first, second) in constraints {
      if key.at(first) >= key.at(second) {
        key.at(second) = key.at(first) + 1e-6
        settled = false
      }
    }
  }
  assert(settled, message: "painter order did not converge (cyclic overlap)")
  range(polys.len()).sorted(key: i => key.at(i))
}

#{
  let all-pts = pieces.map(p => p.at(0)).join()
  let (x0, x1) = (calc.min(..all-pts.map(p => p.at(0))), calc.max(..all-pts.map(p => p.at(0))))
  let (y0, y1) = (calc.min(..all-pts.map(p => p.at(1))), calc.max(..all-pts.map(p => p.at(1))))
  box(width: (x1 - x0) * unit, height: (y1 - y0) * unit, {
    for i in draw-order {
      let (poly, shade, _, flags) = pieces.at(i)
      let pts = poly.map(p => ((p.at(0) - x0) * unit, (y1 - p.at(1)) * unit))
      // a hairline in the fill color hides antialiasing seams between neighboring polygons
      place(polygon(
        fill: shade,
        stroke: (paint: shade, thickness: 0.3pt, join: "round"),
        ..pts,
      ))
      for (k, flag) in flags.enumerate() {
        if flag {
          place(line(
            start: pts.at(k),
            end: pts.at(calc.rem(k + 1, pts.len())),
            stroke: mesh-stroke(shade),
          ))
        }
      }
    }
  })
}
