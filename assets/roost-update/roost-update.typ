#import "@preview/cetz:0.4.2": canvas, draw
#import "@preview/cetz:0.4.2"

#set page(width: auto, height: auto, margin: 10pt)
#set text(size: 14pt)

#canvas(length: 1cm, {
  import draw: *
  scale(1.2)

  let colors = (rgb("#2a9d8f"), rgb("#6a7fdb"), rgb("#f8961e")) // La, O, Cu
  let (node_r, small_r) = (0.3, 0.22)
  let thick = (thickness: 2.5pt, paint: black)

  // Draw triangle with La at origin_pos, O at (-3, -1), Cu at (-3, +1) relative offset
  let tri(origin, labels: none) = {
    let pts = (origin, (origin.at(0) - 3, origin.at(1) - 1), (origin.at(0) - 3, origin.at(1) + 1))
    set-style(stroke: thick)
    line(..pts, close: true)
    for (idx, pt) in pts.enumerate() { circle(pt, radius: node_r, fill: colors.at(idx), stroke: thick) }
    if labels != none {
      content((pts.at(0).at(0) + 0.45, pts.at(0).at(1)), labels.at(0), anchor: "west")
      for idx in (1, 2) { content((pts.at(idx).at(0) - 0.45, pts.at(idx).at(1)), labels.at(idx), anchor: "east") }
    }
  }

  // Left input triangle with formula
  tri((0, 0), labels: ([$h_"La"$], [$h_"O"$], [$h_"Cu"$]))
  content((-4.8, 0), [La#sub[2]CuO#sub[4]], anchor: "east")
  line((-4.5, 0), (-3.7, 0), mark: (end: "stealth", fill: black, size: 0.2))

  // Separator and triangles
  set-style(stroke: (thickness: 1.8pt, paint: black))
  line((2, -1.95), (2, 2.75))

  let (rt, tp1) = ((7, 0.75), (13, -1.25)) // right-t and t+1 La positions
  set-style(stroke: thick)
  tri(rt, labels: ([$h_"La"^t$], [$h_"O"^t$], [$h_"Cu"^t$]))
  tri(tp1, labels: none)
  content((tp1.at(0) + 0.45, tp1.at(1)), [$h_"La"^(t+1)$], anchor: "west")

  // Braces on edges
  let brace = (stroke: (thickness: 1.3pt, paint: black), fill: none, amplitude: 0.35, flip: false)
  cetz.decorations.flat-brace((rt.at(0) - 2.65, rt.at(1) + 1.15), (rt.at(0) - 0.15, rt.at(1) + 0.35), ..brace)
  cetz.decorations.flat-brace((rt.at(0) - 0.15, rt.at(1) - 0.35), (rt.at(0) - 2.65, rt.at(1) - 1.15), ..brace)

  // Message nodes: (y, color, label, attention_label, sign for curve direction)
  let msg_nodes = (
    (2.25, rgb("#c00"), [$g(h_"La"^t || h_"Cu"^t)$], $alpha_"LaCu"$, 1),
    (-0.7, rgb("#282"), [$g(h_"La"^t || h_"O"^t)$], $alpha_"LaO"$, -1),
  )
  let alpha = (rt.at(0) + 2, rt.at(1))

  for (gy, col, lbl, attn, sign) in msg_nodes {
    circle((5.85, gy), radius: small_r, fill: col, stroke: (thickness: 2pt))
    content((5.85, gy + sign * 0.5), lbl, anchor: if sign > 0 { "south" } else { "north" })
  }
  circle(alpha, radius: small_r, fill: yellow, stroke: (thickness: 2pt))

  // Dashed arrows from g nodes to alpha
  let dashed = (dash: "dashed", thickness: 1.5pt, paint: black)
  set-style(mark: (fill: black, size: 0.15, end: "stealth"))
  for (gy, _, _, attn, sign) in msg_nodes {
    bezier(
      (5.85 + small_r, gy),
      (alpha.at(0), alpha.at(1) + sign * small_r),
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
    (tp1.at(0), tp1.at(1) + node_r),
    (alpha.at(0) + 2.2, alpha.at(1) - 0.2),
    (tp1.at(0) - 0.3, tp1.at(1) + 1),
    stroke: dashed,
  )
})
