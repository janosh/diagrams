#import "@preview/cetz:0.5.2": canvas, draw
#import draw: bezier, circle, content, line

#set page(width: auto, height: auto, margin: 8pt)

#canvas({
  let r = .42
  let arr = (mark: (end: "stealth", fill: black, scale: .7), stroke: black + 1pt)

  let vertices = (
    a-real: ((0, 0), $arrow(a)_"real"$),
    b-fake: ((3, 0), $arrow(b)_"fake"$),
    a-rec: ((5.6, 0), $arrow(a)_"rec"$),
    b-real: ((1.7, 3.9), $arrow(b)_"real"$),
    b-disc: ((4.6, 2.5), $arrow(b)$),
  )
  for (name, (pos, label)) in vertices.pairs() {
    circle(pos, radius: r, fill: white, stroke: 1pt, name: name)
    content(name, label)
  }

  // labeled arrow with text above and below its midpoint
  let labeled(from, to, name, above, below, dy: .35, dy-below: auto) = {
    let below-dy = if dy-below == auto { dy } else { dy-below }
    line(from, to, ..arr, name: name)
    content((rel: (0, dy), to: name + ".mid"), above)
    content((rel: (0, -below-dy), to: name + ".mid"), below)
  }

  // input arrows
  labeled((-2.4, 0), "a-real", "in-a", [real data], [(type A)])
  labeled((-.7, 3.9), "b-real", "in-b", [real data], [(type B)])

  // generators
  labeled("a-real", "b-fake", "gen1", $G_(A B)(arrow(a))$, align(center)[generator \ ($A -> B$)], dy: .4, dy-below: .55)
  labeled("b-fake", "a-rec", "gen2", $G_(B A)(arrow(b))$, align(center)[generator \ ($B -> A$)], dy: .4, dy-below: .55)

  // discriminator
  line("b-disc", (7.6, 2.5), ..arr, name: "disc")
  content((rel: (0, .4), to: "disc.mid"), $D_B (arrow(b))$)
  content((rel: (0, -.62), to: "disc.mid"), align(center)[discriminator \ (type B)])
  content((7.7, 2.5), [real?], anchor: "west")

  // routing dots
  let pt1 = (3, 1.7)
  let pt2 = (3, 4.0)
  let pt3 = (2.85, 3.35)
  circle(pt1, radius: .07, fill: black, stroke: none)
  circle(pt2, radius: .07, fill: black, stroke: none)

  // solid feeds
  line((rel: (0, r), to: "b-fake"), (rel: (0, -.07), to: pt1), ..arr)
  line((rel: (r, 0), to: "b-real"), (rel: (-.07, 0), to: pt2), ..arr)

  // dashed selector curve pt1 ↔ pt2, bowing left through the switch pivot pt3,
  // which is drawn after the dash so its white fill occludes it
  bezier(pt1, pt2, (2.63, 2.85), stroke: (dash: "dashed", paint: black, thickness: 1pt))
  circle(pt3, radius: .09, fill: white, stroke: .9pt)
  // switch output to the discriminator, starting at pt3's rim
  line((rel: (.085, -.031), to: pt3), (rel: (-r * .8, r * .8), to: "b-disc"), ..arr)

  // dashed cyclic-consistency loop
  line(
    (rel: (0, -r), to: "a-real"),
    (rel: (0, -1.35), to: "a-real"),
    (rel: (0, -1.35), to: "a-rec"),
    (rel: (0, -r), to: "a-rec"),
    stroke: (dash: "dashed", paint: black, thickness: 1pt),
    mark: (start: "stealth", end: "stealth", fill: black, scale: .7),
  )
})
