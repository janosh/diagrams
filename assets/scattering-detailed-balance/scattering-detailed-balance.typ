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

  circle(
    (-circle-spacing, 0),
    radius: circle-radius,
    fill: gray.lighten(50%),
    stroke: gray,
    name: "left-circle",
  )
  circle(
    (circle-spacing, 0),
    radius: circle-radius,
    fill: gray.lighten(50%),
    stroke: gray,
    name: "right-circle",
  )

  // Left node arrows and labels
  line(
    (rel: (arrow-length, arrow-rise), to: "left-circle"),
    "left-circle",
    ..arrow-style,
    name: "left-ne",
  )
  content("left-ne.start", $p'$, anchor: "west")

  line(
    (rel: (arrow-length, -arrow-rise), to: "left-circle"),
    "left-circle",
    ..arrow-style,
    name: "left-se",
  )
  content("left-se.start", $k'$, anchor: "west")

  line(
    "left-circle",
    (rel: (-arrow-length, arrow-rise), to: "left-circle"),
    ..arrow-style,
    name: "left-nw",
  )
  content("left-nw.end", $p$, anchor: "east")

  line(
    "left-circle",
    (rel: (-arrow-length, -arrow-rise), to: "left-circle"),
    ..arrow-style,
    name: "left-sw",
  )
  content("left-sw.end", $k$, anchor: "east")

  // Right node arrows and labels
  line(
    (rel: (arrow-length, arrow-rise), to: "right-circle"),
    "right-circle",
    ..arrow-style,
    name: "right-ne",
  )
  content("right-ne.start", $p$, anchor: "west")

  line(
    (rel: (arrow-length, -arrow-rise), to: "right-circle"),
    "right-circle",
    ..arrow-style,
    name: "right-se",
  )
  content("right-se.start", $k$, anchor: "west")

  line(
    "right-circle",
    (rel: (-arrow-length, arrow-rise), to: "right-circle"),
    ..arrow-style,
    name: "right-nw",
  )
  content("right-nw.end", $p'$, anchor: "east")

  line(
    "right-circle",
    (rel: (-arrow-length, -arrow-rise), to: "right-circle"),
    ..arrow-style,
    name: "right-sw",
  )
  content("right-sw.end", $k'$, anchor: "east")
})
