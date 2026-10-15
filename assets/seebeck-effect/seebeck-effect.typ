#import "@preview/cetz:0.5.2": canvas, decorations, draw
#import draw: circle, content, line, on-layer, rect

#set page(width: auto, height: auto, margin: 4pt, fill: none)
#set text(size: 12pt)

#let dy = 0.45
#let pillar-dx = 0.66
#let pillar-w = 2.45
#let pillar-h = 5.35
#let edge-stroke = (paint: black, thickness: 0.6pt)
#let circuit-stroke = (paint: black, thickness: 1.1pt)
#let field-color = black.transparentize(10%)
#let pillar-grad = gradient.linear(rgb("#d20a17"), rgb("#5660d4"), angle: 90deg)

// Box with front, right and top faces, receding by (depth-x, depth-y).
#let draw-prism(x0, y0, w, h, depth-x, front-fill, right-fill, top-fill, depth-y: dy) = {
  rect((x0, y0), (x0 + w, y0 + h), fill: front-fill, stroke: edge-stroke)
  line(
    (x0 + w, y0),
    (x0 + w + depth-x, y0 + depth-y),
    (x0 + w + depth-x, y0 + h + depth-y),
    (x0 + w, y0 + h),
    close: true,
    fill: right-fill,
    stroke: edge-stroke,
  )
  line(
    (x0, y0 + h),
    (x0 + w, y0 + h),
    (x0 + w + depth-x, y0 + h + depth-y),
    (x0 + depth-x, y0 + h + depth-y),
    close: true,
    fill: top-fill,
    stroke: edge-stroke,
  )
}

// Charge carrier drifting down from the hot to the cold end.
#let charge-marker(x, y, sign, fill) = {
  circle((x, y), radius: 0.2, fill: fill, stroke: none)
  content((x, y + 0.03), text(weight: "light")[#sign])
  line(
    (x, y - 0.22),
    (x, y - 0.72),
    stroke: (paint: black, thickness: 1.3pt),
    mark: (end: "stealth", fill: black, scale: 0.7),
  )
}

#let sink-block(x0, y0, w: 2.9, h: 0.85) = {
  let sink-side-blue = rgb("#0606cf")
  draw-prism(
    x0,
    y0,
    w,
    h,
    0.84,
    rgb("#0b0bff"),
    sink-side-blue,
    sink-side-blue.lighten(20%),
    depth-y: 0.58,
  )
  content((x0 + w / 2, y0 + h / 2), text(size: 14pt, fill: white)[heat sink])
}

#let pillar-block(x0, y0, label) = {
  let (w, h) = (pillar-w, pillar-h)
  rect((x0, y0), (x0 + w, y0 + h), fill: pillar-grad, stroke: none)
  line(
    (x0 + w, y0),
    (x0 + w + pillar-dx, y0 + dy),
    (x0 + w + pillar-dx, y0 + h + dy),
    (x0 + w, y0 + h),
    close: true,
    fill: pillar-grad,
    stroke: none,
  )
  circle((x0 + w / 2, y0 + h * 0.58), radius: 0.38, stroke: (
    paint: white.transparentize(25%),
    thickness: 0.7pt,
  ))
  content((x0 + w / 2, y0 + h * 0.58), text(size: 16pt, fill: white.transparentize(25%))[#label])
}

// The internal field points from the positively (+) to the negatively (−) charged end of a leg.
#let field-arrow(x, y-plus, y-minus, label-side) = {
  let mark = (end: "stealth", fill: field-color, scale: 0.55)
  line((x, y-plus), (x, y-minus), stroke: (paint: field-color, thickness: 1.0pt), mark: mark)
  let x-offset = if label-side == "west" { 0.18 } else { -0.18 }
  for (y, label) in ((y-plus, [+]), (y-minus, [−])) {
    content((x + x-offset, y), text(fill: field-color)[#label], anchor: label-side)
  }
}

#canvas({
  let left-sink-x = 1.05
  let right-sink-x = 7.9
  let sink-y = 0.8
  let pillar-y = sink-y + 0.95
  let left-field-x = left-sink-x + 0.35 + pillar-w + pillar-dx + 0.25
  let right-field-x = right-sink-x + 0.35 - 0.25

  // Electrons (N) and holes (P) both diffuse to the cold end, so the two fields point oppositely.
  for (sink-x, label, sign, fill, field-x, field-ys, label-side, charge-offsets) in (
    (
      left-sink-x,
      [N],
      [−],
      rgb("#11b7ef"),
      left-field-x,
      (pillar-y + pillar-h - 0.6, pillar-y + 0.6),
      "west",
      ((1.05, 5.2), (2.25, 5.2), (1.05, 2.3), (2.35, 2.45)),
    ),
    (
      right-sink-x,
      [P],
      [+],
      rgb("#ffa300"),
      right-field-x,
      (pillar-y + 0.55, pillar-y + pillar-h - 0.55),
      "east",
      ((1.02, 5.2), (2.2, 5.2), (1.02, 2.3), (2.32, 2.45)),
    ),
  ) {
    sink-block(sink-x, sink-y)
    pillar-block(sink-x + 0.35, pillar-y, label)
    field-arrow(field-x, ..field-ys, label-side)
    for (dx-offset, dy-offset) in charge-offsets {
      charge-marker(sink-x + dx-offset, sink-y + dy-offset, sign, fill)
    }
  }
  content(
    ((left-field-x + right-field-x) / 2, pillar-y + pillar-h * 0.55),
    text(size: 15pt, fill: field-color)[electric field],
  )

  // Top heat source bar (foreground so it occludes pillars/charges)
  on-layer(20, {
    draw-prism(1.0, 7.0, 9.95, 0.9, 0.66, rgb("#ef1313"), rgb("#de1313"), rgb("#ff2222"))
    content((6.05, 8.16), text(size: 15pt, fill: white)[heat source])
    content((5.68, 7.4), text(size: 20pt, fill: white)[$J arrow.r$])
  })

  // Bottom wire closing the electric circuit through a central load resistor.
  let wire-y = 0.12
  let left-wire-x = left-sink-x + 0.2
  let right-wire-x = right-sink-x + 2.55
  let zig-right-x = 5.85
  let zig-left-x = 4.65
  line(
    (right-wire-x, sink-y),
    (right-wire-x, wire-y),
    (zig-right-x, wire-y),
    stroke: circuit-stroke,
  )
  line((zig-left-x, wire-y), (left-wire-x, wire-y), (left-wire-x, sink-y), stroke: circuit-stroke)
  // Resistor zigzag, with arrow tips along the path showing the current direction.
  let circuit-mark = (symbol: "stealth", fill: black, scale: 0.5, shorten-to: none)
  decorations.zigzag(
    line(
      (zig-right-x, wire-y),
      (zig-left-x, wire-y),
      stroke: circuit-stroke,
      mark: (end: (20%, 50%, 80%).map(pos => (pos: pos, ..circuit-mark))),
    ),
    amplitude: 0.12,
    segment-length: 0.2,
  )
})
