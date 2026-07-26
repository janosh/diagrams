#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, rect
#import "../_shared/network.typ": fully-connect, node-stroke
#import "../_shared/theme.typ": line-weight, neutral

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#let node-r = .32
#let pill-h = 1.3
#let light-gray = rgb(191, 191, 191)

#canvas({
  // capsule-shaped layer container
  let pill(center, width, fill) = rect(
    (center.at(0) - width / 2, center.at(1) - pill-h / 2),
    (center.at(0) + width / 2, center.at(1) + pill-h / 2),
    radius: pill-h / 2,
    fill: fill,
    stroke: 2.2pt,
  )

  let row(prefix, count, y) = {
    for idx in range(count) {
      let x-pos = (idx - (count - 1) / 2) * 1.0
      circle(
        (x-pos, y),
        radius: node-r,
        fill: white,
        stroke: node-stroke,
        name: prefix + str(idx),
      )
    }
  }

  for (center-y, width, fill, label, prefix, count) in (
    (0, 9.2, white, $arrow(x)$, "a", 9),
    (3.8, 5.15, light-gray, $arrow(h)_1$, "b", 5),
    (7.6, 5.15, light-gray, $arrow(h)_2$, "c", 5),
  ) {
    pill((0, center-y), width, fill)
    content(
      (-width / 2 - .35, center-y),
      text(size: 14pt, label),
      anchor: "east",
    )
    row(prefix, count, center-y)
  }

  let arr = (
    mark: (end: "stealth", fill: black, scale: .6),
    stroke: neutral.annotation + line-weight.hairline,
  )
  let bi-arr = (
    mark: (start: "stealth", end: "stealth", fill: black, scale: .6),
    stroke: neutral.annotation + line-weight.hairline,
  )
  fully-connect("a", "b", 9, 5, start: 0, ..arr)
  fully-connect("b", "c", 5, 5, start: 0, ..bi-arr)

  content((4.3, 2.0), text(size: 14pt, $bold(W)_1$))
  content((3.4, 5.8), text(size: 14pt, $bold(W)_2$))
})
