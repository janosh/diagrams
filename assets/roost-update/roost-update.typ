#import "@preview/cetz:0.5.2": canvas, decorations, draw
#import draw: bezier, circle, content, line, scale, set-style

#set page(width: auto, height: auto, margin: 10pt, fill: none)
#set text(size: 14pt)

#canvas(length: 1cm, {
  scale(1.2)

  let colors = (rgb("#2a9d8f"), rgb("#6a7fdb"), rgb("#f8961e")) // La, O, Cu
  let (node-r, small-r) = (0.3, 0.22)
  let thick = (thickness: 2.5pt, paint: black)

  // Triangle with La at `origin`, O at (-3, -1) and Cu at (-3, +1) relative to it. La's
  // label sits to its right, the others to their left.
  let tri(origin, labels: (none, none, none)) = {
    let (x, y) = origin
    let pts = (origin, (x - 3, y - 1), (x - 3, y + 1))
    set-style(stroke: thick)
    line(..pts, close: true)
    for (idx, ((pt-x, pt-y), label)) in pts.zip(labels).enumerate() {
      circle((pt-x, pt-y), radius: node-r, fill: colors.at(idx), stroke: thick)
      if label != none {
        let side = if idx == 0 { 1 } else { -1 }
        content((pt-x + side * 0.45, pt-y), label, anchor: if idx == 0 { "west" } else { "east" })
      }
    }
  }

  // Left input triangle with formula
  tri((0, 0), labels: ($h_"La"$, $h_"O"$, $h_"Cu"$))
  line((-4.5, 0), (-3.7, 0), mark: (end: "stealth", fill: black, size: 0.2), name: "input")
  content((rel: (-0.3, 0), to: "input.start"), [La#sub[2]CuO#sub[4]], anchor: "east")

  line((2, -1.95), (2, 2.75), stroke: 1.8pt + black)

  let (rt, tp1) = ((7, 0.75), (13, -1.25)) // right-t and t+1 La positions
  tri(rt, labels: ($h_"La"^t$, $h_"O"^t$, $h_"Cu"^t$))
  tri(tp1, labels: ($h_"La"^(t+1)$, none, none))

  // Braces over the La-Cu and La-O edges that each message is computed from.
  for (start, end) in (((-2.65, 1.15), (-0.15, 0.35)), ((-0.15, -0.35), (-2.65, -1.15))) {
    decorations.flat-brace(
      (rel: start, to: rt),
      (rel: end, to: rt),
      stroke: (thickness: 1.3pt, paint: black),
      fill: none,
      amplitude: 0.35,
    )
  }

  // Message nodes: (y offset from rt, color, label, attention-label, sign for curve direction)
  let msg-nodes = (
    (1.5, rgb("#c00"), [$g(h_"La"^t || h_"Cu"^t)$], $alpha_"LaCu"$, 1),
    (-1.45, rgb("#282"), [$g(h_"La"^t || h_"O"^t)$], $alpha_"LaO"$, -1),
  )
  circle((rel: (2, 0), to: rt), radius: small-r, fill: yellow, stroke: 2pt + black, name: "alpha")

  // Dashed arrows from g nodes to alpha
  let dashed = (dash: "dashed", thickness: 1.5pt, paint: black)
  set-style(mark: (fill: black, size: 0.15, end: "stealth"))
  for (dy, col, lbl, attn, sign) in msg-nodes {
    circle((rel: (-1.15, dy), to: rt), radius: small-r, fill: col, stroke: 2pt + black, name: "g")
    content((rel: (0, sign * 0.5), to: "g"), lbl, anchor: if sign > 0 { "south" } else { "north" })
    bezier(
      "g.east",
      (rel: (0, sign * small-r), to: "alpha"),
      (rel: (0.9, sign * 0.05), to: "g"),
      (rel: (-0.6, sign * 0.9), to: "alpha"),
      stroke: dashed,
    )
    content((rel: (1.5, sign * 0.1), to: "g"), attn, anchor: "west")
  }

  // Plus and final arrow
  content((rel: (0.5, 0), to: "alpha"), text(weight: "bold", size: 1.2em)[+], anchor: "west")
  bezier(
    (rel: (0.9, 0), to: "alpha"),
    (rel: (0, node-r), to: tp1),
    (rel: (2.2, -0.2), to: "alpha"),
    (rel: (-0.3, 1), to: tp1),
    stroke: dashed,
  )
})
