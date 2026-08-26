#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, line

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#canvas({
  // Diagram dimensions
  let circle-radius = 0.3
  let circle-spacing = 3 // distance of circles from center
  let arrow-length = 2
  let arrow-rise = 1 // vertical displacement of arrows
  let equals-size = 24pt // font size for equals sign

  // Colors and styles
  let arrow-style = (
    mark: (start: "stealth", fill: black, scale: 0.5),
    stroke: (thickness: 1.1pt),
  )

  content((0, 0), text(size: equals-size)[=])

  let nodes = (
    (side: "left", x: -circle-spacing, incoming: ($p'$, $k'$), outgoing: ($p$, $k$)),
    (side: "right", x: circle-spacing, incoming: ($p$, $k$), outgoing: ($p'$, $k'$)),
  )
  for node in nodes {
    circle(
      (node.x, 0),
      radius: circle-radius,
      fill: gray.lighten(50%),
      stroke: gray,
      name: node.side + "-circle",
    )
  }
  for node in nodes {
    let circle-name = node.side + "-circle"
    for (vertical, suffix, label) in (
      (1, "ne", node.incoming.at(0)),
      (-1, "se", node.incoming.at(1)),
    ) {
      let name = node.side + "-" + suffix
      line(
        (rel: (arrow-length, vertical * arrow-rise), to: circle-name),
        circle-name,
        ..arrow-style,
        name: name,
      )
      content(name + ".start", label, anchor: "west")
    }
    for (vertical, suffix, label) in (
      (1, "nw", node.outgoing.at(0)),
      (-1, "sw", node.outgoing.at(1)),
    ) {
      let name = node.side + "-" + suffix
      line(
        circle-name,
        (rel: (-arrow-length, vertical * arrow-rise), to: circle-name),
        ..arrow-style,
        name: name,
      )
      content(name + ".end", label, anchor: "east")
    }
  }
})
