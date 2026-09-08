#import "@preview/cetz:0.5.2": canvas, draw
#import draw: bezier, circle, content, line, on-layer, rect

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(weight: "bold")

#let (main-r, item-r, spacing) = (1.2, 2.2, 6)
#let (main-stroke, item-stroke, arrow-stroke) = (1pt, 1pt, 1.5pt)
#let (main-font, item-font) = (11pt, 7pt)
#let (data-color, descriptor-color, model-color) = (
  rgb(255, 200, 150),
  rgb(255, 255, 150),
  rgb(200, 200, 255),
)
#let (item-bg, item-border) = (white, black)
#let (arrow-offset, arrow-scale) = (1.5, 1.2)
#let (length-factor, base-offset) = (0.02, 0)

#let challenge-node(pos, txt, color, name) = {
  circle(pos, radius: main-r, fill: color, stroke: main-stroke + item-border, name: name)
  content(pos, text(fill: item-border, size: main-font, weight: "bold", align(
    center,
    txt,
  )))
}

#let challenge-item(center, base-radius, angle, txt, center-name, name) = {
  // Adjust distance based on text length - continuous scaling
  let actual-radius = base-radius + base-offset + txt.len() * length-factor

  let pos = (
    center.at(0) + calc.cos(angle) * actual-radius,
    center.at(1) + calc.sin(angle) * actual-radius,
  )
  content(
    pos,
    text(fill: item-border, size: item-font, weight: "regular", txt),
    frame: "rect",
    fill: item-bg,
    stroke: 0.5pt + item-border,
    padding: 2pt,
    radius: 0.03,
    anchor: "center",
    name: name,
  )
  on-layer(-1, line(center-name, name, stroke: item-stroke + item-border))
}

#canvas({
  // All circle data: (position, title, color, node-name, items-with-angles)
  let circles = (
    (
      (0, 0),
      [Data\ Challenges],
      data-color,
      "data",
      (
        ("volume", 120),
        ("velocity", 135),
        ("variety", 150),
        ("veracity", 165),
        ("visualization", 180),
        ("long-term storage", 195),
        ("standardization", 210),
      ),
    ),
    (
      (spacing, 0),
      [Descriptor\ Challenges],
      descriptor-color,
      "descriptor",
      (
        ("symmetry invariance", 140),
        ("translation", 155),
        ("rotation", 170),
        ("permutation", 185),
        ("efficiency", 30),
        ("speed", 15),
        ("compactness", 0),
      ),
    ),
    (
      (spacing * 2, 0),
      [Model\ Challenges],
      model-color,
      "model",
      (
        ("reproducibility", 70),
        ("benchmarking", 54),
        ("transfer learning", 38),
        ("extrapolation", 22),
        ("sharing model+results", 6),
        ("computational cost", -10),
        ("incorporate physics", -26),
      ),
    ),
  )

  for (pos, title, color, name, items) in circles {
    challenge-node(pos, title, color, name + "-node")
    for (idx, (item, angle)) in items.enumerate() {
      challenge-item(
        pos,
        item-r,
        angle * 1deg,
        item,
        name + "-node",
        name + "-item-" + str(idx),
      )
    }
  }

  // Arrows between circles
  let ((data-pos, ..), (desc-pos, ..), (model-pos, ..)) = (
    circles.at(0),
    circles.at(1),
    circles.at(2),
  )

  for (start-center, end-center, direction) in (
    (data-pos, desc-pos, -1),
    (desc-pos, model-pos, 1),
  ) {
    let start = (
      start-center.at(0) + calc.cos(direction * 70deg) * main-r,
      start-center.at(1) + calc.sin(direction * 70deg) * main-r,
    )
    let end = (
      end-center.at(0) + calc.cos(direction * 110deg) * main-r,
      end-center.at(1) + calc.sin(direction * 110deg) * main-r,
    )
    bezier(
      start,
      end,
      (start.at(0) + arrow-offset, start.at(1) + direction * arrow-offset),
      (end.at(0) - arrow-offset, end.at(1) + direction * arrow-offset),
      stroke: arrow-stroke + item-border,
      mark: (end: "stealth", scale: arrow-scale, fill: item-border),
    )
  }
})
