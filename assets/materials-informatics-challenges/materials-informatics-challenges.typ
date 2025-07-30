#import "@preview/cetz:0.4.1": canvas, draw
#import draw: bezier, circle, content, line, on-layer, rect

#set page(width: auto, height: auto, margin: 8pt)
#set text(weight: "bold")

// Constants
#let (main-r, item-r, spacing) = (1.2, 2.2, 6)
#let (main-stroke, item-stroke, arrow-stroke) = (1pt, 1pt, 1.5pt)
#let (main-font, item-font) = (11pt, 7pt)
#let (data-color, descriptor-color, model-color) = (rgb(255, 200, 150), rgb(255, 255, 150), rgb(200, 200, 255))
#let (item-bg, item-border) = (white, black)
#let (arrow-offset, arrow-scale) = (1.5, 1.2)
#let (length-factor, base-offset) = (0.02, 0)

#let challenge-node(pos, txt, color, name) = {
  circle(pos, radius: main-r, fill: color, stroke: main-stroke + item-border, name: name)
  content(pos, text(fill: item-border, size: main-font, weight: "bold", align(center, txt)))
}

#let challenge-item(center, base-radius, angle, txt, center-name, name) = {
  // Adjust distance based on text length - continuous scaling
  let text-length = txt.len()
  let extra-distance = base-offset + text-length * length-factor
  let actual-radius = base-radius + extra-distance

  let pos = (center.at(0) + calc.cos(angle) * actual-radius, center.at(1) + calc.sin(angle) * actual-radius)
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

  // Draw all circles and their items
  for (pos, title, color, name, items) in circles {
    challenge-node(pos, title, color, name + "-node")
    for (idx, (item, angle)) in items.enumerate() {
      challenge-item(pos, item-r, angle * 1deg, item, name + "-node", name + "-item-" + str(idx))
    }
  }

  // Arrows between circles
  let ((data-pos, ..), (desc-pos, ..), (model-pos, ..)) = (circles.at(0), circles.at(1), circles.at(2))

  // Data → Descriptor (bend down)
  let s1 = (data-pos.at(0) + calc.cos(-70deg) * main-r, data-pos.at(1) + calc.sin(-70deg) * main-r)
  let e1 = (desc-pos.at(0) + calc.cos(-110deg) * main-r, desc-pos.at(1) + calc.sin(-110deg) * main-r)
  bezier(
    s1,
    e1,
    (s1.at(0) + arrow-offset, s1.at(1) - arrow-offset),
    (e1.at(0) - arrow-offset, e1.at(1) - arrow-offset),
    stroke: arrow-stroke + item-border,
    mark: (end: "stealth", scale: arrow-scale, fill: item-border),
  )

  // Descriptor → Model (bend up)
  let s2 = (desc-pos.at(0) + calc.cos(70deg) * main-r, desc-pos.at(1) + calc.sin(70deg) * main-r)
  let e2 = (model-pos.at(0) + calc.cos(110deg) * main-r, model-pos.at(1) + calc.sin(110deg) * main-r)
  bezier(
    s2,
    e2,
    (s2.at(0) + arrow-offset, s2.at(1) + arrow-offset),
    (e2.at(0) - arrow-offset, e2.at(1) + arrow-offset),
    stroke: arrow-stroke + item-border,
    mark: (end: "stealth", scale: arrow-scale, fill: item-border),
  )
})
