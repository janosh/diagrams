#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, hobby, line, on-layer

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 12pt)

#canvas({
  let arrow-style = (stroke: 0.8pt, mark: (end: "stealth", scale: 0.4, fill: black))
  let annotated-arrow(start, end, name, formula, caption: none, caption-padding: 0.1) = {
    line(start, end, ..arrow-style, name: name)
    content(name + ".mid", formula, anchor: "south", padding: 0.1)
    if caption != none {
      content(name + ".mid", text(size: 14pt, caption), anchor: "north", padding: caption-padding)
    }
  }

  let (y-real, y-fake) = (2, 0)

  for (pos, name, label, radius) in (
    ((0, y-fake), "zin", $arrow(z)_"in"$, 0.53),
    ((3, y-fake), "fake", $arrow(x)_"fake"$, 0.53),
    ((3, y-real), "real", $arrow(x)_"real"$, 0.53),
    ((6, y-real / 2), "D", $arrow(x)$, 0.4),
  ) {
    circle(pos, name: name, stroke: none, fill: rgb("#66B2B2"), radius: radius) // teal!60
    content(name, label)
  }
  content((rel: (3, 0), to: "D"), text(baseline: -1pt)[real?], name: "out", padding: 2pt)

  annotated-arrow((-3.2, y-fake), "zin", "zin-line", $p_z (arrow(z))$, caption: [latent noise])
  annotated-arrow("zin", "fake", "fake-line", $G(arrow(z))$, caption: [generator])
  annotated-arrow((rel: (-5, 0), to: "real"), "real", "real-line", $p_"data" (arrow(x))$)

  // fake and real samples feed into a switch (orange) that picks D's input
  for (idx, y) in ((1, y-fake), (2, y-real)) {
    circle((4.5, y), radius: 0.06, fill: black, name: "dot" + str(idx))
  }
  on-layer(1, circle(
    (4.25, 2 * y-real / 3),
    radius: 0.12,
    fill: orange,
    stroke: none,
    name: "dot3",
  ))
  for (start, end) in (("fake", "dot1"), ("real", "dot2"), ("dot3", "D")) {
    line(start, end, ..arrow-style)
  }
  hobby("dot1", (4.2, (y-real - y-fake) / 2), "dot2", stroke: (dash: "dashed"), omega: 2)

  annotated-arrow(
    "D",
    "out",
    "disc-line",
    $D(arrow(x))$,
    caption: [discriminator],
    caption-padding: 0.45,
  )
})
