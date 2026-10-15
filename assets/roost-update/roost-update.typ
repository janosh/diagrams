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
  content((-4.8, 0), [La#sub[2]CuO#sub[4]], anchor: "east")
  line((-4.5, 0), (-3.7, 0), mark: (end: "stealth", fill: black, size: 0.2))

  line((2, -1.95), (2, 2.75), stroke: 1.8pt + black)

  let (rt, tp1) = ((7, 0.75), (13, -1.25)) // right-t and t+1 La positions
  tri(rt, labels: ($h_"La"^t$, $h_"O"^t$, $h_"Cu"^t$))
  tri(tp1, labels: ($h_"La"^(t+1)$, none, none))

  // Braces over the La-Cu and La-O edges that each message is computed from.
  for (start, end) in (((-2.65, 1.15), (-0.15, 0.35)), ((-0.15, -0.35), (-2.65, -1.15))) {
    decorations.flat-brace(
      (rt.at(0) + start.at(0), rt.at(1) + start.at(1)),
      (rt.at(0) + end.at(0), rt.at(1) + end.at(1)),
      stroke: (thickness: 1.3pt, paint: black),
      fill: none,
      amplitude: 0.35,
    )
  }

  // Message nodes: (y, color, label, attention-label, sign for curve direction)
  let msg-nodes = (
    (2.25, rgb("#c00"), [$g(h_"La"^t || h_"Cu"^t)$], $alpha_"LaCu"$, 1),
    (-0.7, rgb("#282"), [$g(h_"La"^t || h_"O"^t)$], $alpha_"LaO"$, -1),
  )
  let alpha = (rt.at(0) + 2, rt.at(1))

  for (gy, col, lbl, _, sign) in msg-nodes {
    circle((5.85, gy), radius: small-r, fill: col, stroke: (thickness: 2pt))
    content((5.85, gy + sign * 0.5), lbl, anchor: if sign > 0 { "south" } else { "north" })
  }
  circle(alpha, radius: small-r, fill: yellow, stroke: (thickness: 2pt))

  // Dashed arrows from g nodes to alpha
  let dashed = (dash: "dashed", thickness: 1.5pt, paint: black)
  set-style(mark: (fill: black, size: 0.15, end: "stealth"))
  for (gy, _, _, attn, sign) in msg-nodes {
    bezier(
      (5.85 + small-r, gy),
      (alpha.at(0), alpha.at(1) + sign * small-r),
      (6.75, gy + sign * 0.05),
      (alpha.at(0) - 0.6, alpha.at(1) + sign * 0.9),
      stroke: dashed,
    )
    content((7.35, gy + sign * 0.1), attn, anchor: "west")
  }

  // Plus and final arrow
  content((alpha.at(0) + 0.5, alpha.at(1)), text(weight: "bold", size: 1.2em)[+], anchor: "west")
  bezier(
    (alpha.at(0) + 0.9, alpha.at(1)),
    (tp1.at(0), tp1.at(1) + node-r),
    (alpha.at(0) + 2.2, alpha.at(1) - 0.2),
    (tp1.at(0) - 0.3, tp1.at(1) + 1),
    stroke: dashed,
  )
})
