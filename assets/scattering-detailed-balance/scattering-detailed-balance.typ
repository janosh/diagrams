#import "@preview/cetz:0.3.4": canvas, draw, coordinate
#import draw: line, content, circle

#set page(width: auto, height: auto, margin: 8pt)

#canvas({
  // Diagram dimensions
  let circle_radius = 0.3
  let circle_spacing = 3 // distance of circles from center
  let arrow_length = 2
  let arrow_rise = 1 // vertical displacement of arrows
  let equals_size = 24pt // font size for equals sign

  // Colors and styles
  let arrow_style = (
    mark: (start: "stealth", fill: black, scale: 0.5),
    stroke: (thickness: 1.1pt),
  )

  // Draw equals sign at center
  content((0, 0), text(size: equals_size)[=])

  // Draw circles on either side
  circle((-circle_spacing, 0), radius: circle_radius, fill: gray.lighten(50%), stroke: gray, name: "left-circle")
  circle((circle_spacing, 0), radius: circle_radius, fill: gray.lighten(50%), stroke: gray, name: "right-circle")

  // Left node arrows and labels
  line((rel: (arrow_length, arrow_rise), to: "left-circle"), "left-circle", ..arrow_style, name: "left-ne")
  content("left-ne.start", $p'$, anchor: "west")

  line((rel: (arrow_length, -arrow_rise), to: "left-circle"), "left-circle", ..arrow_style, name: "left-se")
  content("left-se.start", $k'$, anchor: "west")

  line("left-circle", (rel: (-arrow_length, arrow_rise), to: "left-circle"), ..arrow_style, name: "left-nw")
  content("left-nw.end", $p$, anchor: "east")

  line("left-circle", (rel: (-arrow_length, -arrow_rise), to: "left-circle"), ..arrow_style, name: "left-sw")
  content("left-sw.end", $k$, anchor: "east")

  // Right node arrows and labels
  line((rel: (arrow_length, arrow_rise), to: "right-circle"), "right-circle", ..arrow_style, name: "right-ne")
  content("right-ne.start", $p$, anchor: "west")

  line((rel: (arrow_length, -arrow_rise), to: "right-circle"), "right-circle", ..arrow_style, name: "right-se")
  content("right-se.start", $k$, anchor: "west")

  line("right-circle", (rel: (-arrow_length, arrow_rise), to: "right-circle"), ..arrow_style, name: "right-nw")
  content("right-nw.end", $p'$, anchor: "east")

  line("right-circle", (rel: (-arrow_length, -arrow_rise), to: "right-circle"), ..arrow_style, name: "right-sw")
  content("right-sw.end", $k'$, anchor: "east")
})
