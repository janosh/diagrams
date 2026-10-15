#import "@preview/cetz:0.5.2": canvas, draw
#import draw: bezier, circle, content, line, on-layer

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 12pt, weight: "bold")

#let (main-r, item-r, spacing) = (1.6, 3.4, 8.5)

#canvas({
  // (position, title, color, node name, (item, angle in degrees) pairs)
  let circles = (
    (
      (0, 0),
      [Data\ Challenges],
      rgb(255, 200, 150),
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
      rgb(255, 255, 150),
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
      rgb(200, 200, 255),
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

  for ((cx, cy), title, color, name, items) in circles {
    circle((cx, cy), radius: main-r, fill: color, stroke: 1pt, name: name)
    content((cx, cy), text(size: 16pt, align(center, title)))
    for (idx, (item, angle)) in items.enumerate() {
      // longer labels sit further out so their boxes clear the circle
      let radius = item-r + item.len() * 0.035
      content(
        (cx + calc.cos(angle * 1deg) * radius, cy + calc.sin(angle * 1deg) * radius),
        text(weight: "regular", item),
        frame: "rect",
        fill: rgb("#cdd3da"),
        stroke: 0.5pt,
        padding: 2pt,
        radius: 0.03,
        name: name + "-item-" + str(idx),
      )
      on-layer(-1, line(name, name + "-item-" + str(idx), stroke: 1pt))
    }
  }

  // arrows from data to descriptor (below) and descriptor to model (above)
  let point-on-rim((cx, cy), angle) = (cx + calc.cos(angle) * main-r, cy + calc.sin(angle) * main-r)
  for (from-idx, direction) in ((0, -1), (1, 1)) {
    let start = point-on-rim(circles.at(from-idx).first(), direction * 70deg)
    let end = point-on-rim(circles.at(from-idx + 1).first(), direction * 110deg)
    bezier(
      start,
      end,
      (start.at(0) + 1.5, start.at(1) + direction * 1.5),
      (end.at(0) - 1.5, end.at(1) + direction * 1.5),
      stroke: 1.5pt,
      mark: (end: "stealth", scale: 1.2, fill: black),
    )
  }
})
