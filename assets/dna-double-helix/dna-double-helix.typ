#import "@preview/cetz:0.5.2": canvas, draw
#import draw: line

#set page(width: auto, height: auto, margin: 8pt)

#let pure-red = rgb(255, 0, 0)
#let pure-blue = rgb(0, 0, 255)
#let strand-w = 3.2pt
#let helix-h = .84
#let total-w = 7.53
#let n-groups = 8

// strand height + crossing-gap flag at position x: pure sinusoid with period 2,
// apex centered over each bond group (x = k + .25), gap where the strand
// descends through the crossing center; parity 0 = blue (top at even k), 1 = red
#let strand-state(x-pos, parity) = {
  let t = x-pos - .05
  let frac = t - calc.floor(t)
  let top-now = calc.rem-euclid(calc.floor(t) + parity, 2) == 0
  let phase = calc.cos(calc.pi * (frac - .2))
  let y = helix-h * (1 + if top-now { phase } else { -phase }) / 2
  (y: y, in-gap: top-now and frac > .63 and frac < .77)
}

#canvas(length: 2.2cm, {
  // === bonds: colored tips with dotted black middles, spanning strand to strand ===
  for grp in range(n-groups) {
    let (top-col, bot-col, top-par) = if calc.rem-euclid(grp, 2) == 0 {
      (pure-blue, pure-red, 0)
    } else { (pure-red, pure-blue, 1) }
    for off in (.1, .25, .4) {
      let bx = grp + off
      let y-top = strand-state(bx, top-par).y
      let y-bot = strand-state(bx, 1 - top-par).y
      let span = y-top - y-bot
      line((bx, y-bot), (bx, y-bot + .35 * span), stroke: bot-col + strand-w)
      // explicit dashes (rather than a dash pattern) so the dotted run starts
      // and ends flush against the colored tips with no white gap
      let n-dashes = 4
      let step = .3 * span / (2 * n-dashes - 1)
      for dash-idx in range(n-dashes) {
        let lo = y-bot + .35 * span + 2 * dash-idx * step
        line((bx, lo), (bx, lo + step), stroke: black + strand-w)
      }
      line((bx, y-bot + .65 * span), (bx, y-top), stroke: top-col + strand-w)
    }
  }

  // === strands: sampled polylines, descending strand gets a gap at each crossing ===
  let n-samples = 200
  for parity in (0, 1) {
    let color = if parity == 0 { pure-blue } else { pure-red }
    let segments = ()
    let current = ()
    for idx in range(n-samples + 1) {
      let x-pos = total-w * idx / n-samples
      let state = strand-state(x-pos, parity)
      if state.in-gap {
        if current.len() > 1 { segments.push(current) }
        current = ()
      } else {
        current.push((x-pos, state.y))
      }
    }
    if current.len() > 1 { segments.push(current) }
    for seg in segments { line(..seg, stroke: color + strand-w) }
  }
})
