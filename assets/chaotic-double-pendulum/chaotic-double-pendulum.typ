#import "@preview/cetz:0.5.3": canvas, draw
#import draw: circle, content, line

#set page(width: auto, height: auto, margin: 8pt, fill: none)

// Double pendulum with equal masses and rod lengths (m = l = g = 1), state (θ1, θ2, ω1, ω2)
// with angles measured from the downward vertical. Exact Lagrangian equations of motion.
#let rhs(s) = {
  let (t1, t2, w1, w2) = s
  let d = t1 - t2
  let den = 3 - calc.cos(2 * d)
  let a1 = (
    (
      -3 * calc.sin(t1)
        - calc.sin(t1 - 2 * t2)
        - 2 * calc.sin(d) * (w2 * w2 + w1 * w1 * calc.cos(d))
    )
      / den
  )
  let a2 = 2 * calc.sin(d) * (2 * w1 * w1 + 2 * calc.cos(t1) + w2 * w2 * calc.cos(d)) / den
  (w1, w2, a1, a2)
}

#let axpy(s, h, k) = s.zip(k).map(((x, dx)) => x + h * dx)

#let rk4-step(s, h) = {
  let k1 = rhs(s)
  let k2 = rhs(axpy(s, h / 2, k1))
  let k3 = rhs(axpy(s, h / 2, k2))
  let k4 = rhs(axpy(s, h, k3))
  s.zip(k1, k2, k3, k4).map(((x, a, b, c, d)) => x + h / 6 * (a + 2 * b + 2 * c + d))
}

// Total energy, conserved by the exact dynamics (checks the integrator below)
#let energy(s) = {
  let (t1, t2, w1, w2) = s
  w1 * w1 + w2 * w2 / 2 + w1 * w2 * calc.cos(t1 - t2) - 2 * calc.cos(t1) - calc.cos(t2)
}

#let dt = 0.01
#let t-end = 14
#let n-steps = int(calc.round(t-end / dt))

// Integrate and return the full state history.
#let integrate(s0) = {
  let states = (s0,)
  let s = s0
  for _ in range(n-steps) {
    s = rk4-step(s, dt)
    states.push(s)
  }
  states
}

#let theta1 = 165deg.rad()
#let theta2 = 150deg.rad()
#let eps = 1e-3
#let run-a = integrate((theta1, theta2, 0.0, 0.0))
#let run-b = integrate((theta1 + eps, theta2, 0.0, 0.0))
#for run in (run-a, run-b) {
  let e0 = energy(run.first())
  assert(
    run.all(s => calc.abs(energy(s) - e0) < 1e-6 * calc.abs(e0)),
    message: "RK4 energy drift too large",
  )
}

#let joints(s) = {
  let (t1, t2, ..) = s
  let p1 = (calc.sin(t1), -calc.cos(t1))
  (p1, (p1.at(0) + calc.sin(t2), p1.at(1) - calc.cos(t2)))
}
#let bob-a = run-a.map(s => joints(s).at(1))
#let bob-b = run-b.map(s => joints(s).at(1))

#let col-a = rgb("#1c6dd0")
#let col-b = rgb("#e8590c")
#let ink = rgb("#2b2f36")

#canvas(length: 2.1cm, {
  // Lower-bob traces, fading from panel gray (early) to full color (late). Chunks of both runs
  // are interleaved so the later chunk always lies on top.
  let chunk = 10
  let n-chunks = calc.ceil(n-steps / chunk)
  let fade = rgb("#cdd3da")
  for c in range(n-chunks) {
    let i0 = c * chunk
    let i1 = calc.min(i0 + chunk, n-steps)
    let f = c / (n-chunks - 1)
    let width = 1.1pt + 2.5pt * f
    // While both bobs coincide, the orange run is drawn as a thin core on top of the blue
    // run (two-tone line); after they separate, both get the same width.
    let (qa, qb) = (bob-a.at(i1), bob-b.at(i1))
    let sep = calc.min(1, calc.norm(qa.at(0) - qb.at(0), qa.at(1) - qb.at(1)) / 0.5)
    let core = 0.45 + 0.55 * sep * sep * (3 - 2 * sep) // smoothstep from thin core to full width
    let mix = 0.45 + 0.55 * f
    for (bob, col, w) in ((bob-a, col-a, width), (bob-b, col-b, width * core)) {
      let paint = color.mix((col, 100% * mix), (fade, 100% * (1 - mix)))
      line(..bob.slice(i0, i1 + 1), stroke: (
        paint: paint,
        thickness: w,
        cap: "round",
        join: "round",
      ))
    }
  }

  // Initial position of the lower bob
  let start = bob-a.first()
  circle(start, radius: 0.06, fill: ink, stroke: none)
  content((rel: (-0.08, 0), to: start), anchor: "east", text(14pt, fill: ink)[$t = 0$])
  content((-2, 2), anchor: "north-west", text(14pt, fill: ink)[$Delta theta_1 = 10^(-3) "rad"$])

  // Pendulums at the final time
  let draw-pendulum(run, col) = {
    let (p1, p2) = joints(run.last())
    line((0, 0), p1, p2, stroke: (paint: ink, thickness: 2.4pt, cap: "round", join: "round"))
    circle(p1, radius: 0.11, fill: col, stroke: ink + 1.4pt)
    circle(p2, radius: 0.15, fill: col, stroke: ink + 1.4pt)
  }
  draw-pendulum(run-a, col-a)
  draw-pendulum(run-b, col-b)

  // Pivot
  circle((0, 0), radius: 0.08, fill: ink, stroke: none)
})
