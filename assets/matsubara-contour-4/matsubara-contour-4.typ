#import "@preview/cetz:0.4.1": canvas, decorations, draw
#import draw: arc, circle, content, line, set-style

#set page(width: auto, height: auto, margin: 8pt)

#canvas({
  // Constants
  let x-range = 4
  let y-range = 1
  let y-offset = 0.25
  let zigzag-start = 0.5
  let contour-radius = y-range / 4

  // Styles
  let arrow-style = (mark: (end: "stealth", fill: black, scale: 0.5))
  let dark-blue = blue.darken(20%)
  let marc-style = (symbol: "stealth", fill: dark-blue, scale: 0.5, shorten-to: none)
  let contour-style = (paint: dark-blue, thickness: 0.8pt)
  let zigzag-style = (amplitude: 0.2, segment-length: 0.3)

  // Helper function to draw a horizontal contour line with arrows
  let draw-contour-line(start, end, name) = {
    line(
      start,
      end,
      stroke: contour-style,
      mark: (
        end: (
          (pos: 25%, ..marc-style),
          (pos: 75%, ..marc-style),
        ),
      ),
      name: name,
    )
  }

  // Helper function to draw a semicircle with given center and angles
  let draw-semicircle(center, start-angle, end-angle, name) = {
    arc(
      center,
      radius: contour-radius,
      start: start-angle,
      stop: end-angle,
      stroke: contour-style,
      name: name,
      anchor: "arc-center",
    )
  }

  // Draw x-axis with zigzag on both sides
  // Center straight segment
  line((-zigzag-start, 0), (zigzag-start, 0), stroke: 0.8pt, name: "x-axis-center")

  // Left side zigzag
  decorations.zigzag(
    line((-1.05 * x-range, 0), (-zigzag-start, 0)),
    ..zigzag-style,
    stroke: 0.8pt,
    name: "x-axis-left",
  )

  // Right side zigzag - ending a bit earlier to make room for straight arrow
  decorations.zigzag(
    line((zigzag-start, 0), (1.05 * x-range - 0.4, 0)),
    ..zigzag-style,
    stroke: 0.8pt,
    name: "x-axis-right-zigzag",
  )

  // Straight arrow segment at the end
  line(
    (1.05 * x-range - 0.4, 0),
    (1.05 * x-range, 0),
    stroke: 0.8pt,
    ..arrow-style,
    name: "x-axis-right-arrow",
  )

  content("x-axis-right-arrow.end", $"Re"(p_0)$, anchor: "west", padding: 2pt)

  // Draw y-axis
  line((0, -y-range), (0, y-range), ..arrow-style, name: "y-axis")
  content("y-axis.end", $"Im"(p_0)$, anchor: "north-west", padding: 4pt)

  // Draw left contour (C_b)
  draw-semicircle((contour-radius, 0), 270deg, 90deg, "left-arc")
  draw-contour-line((x-range, -contour-radius), "left-arc.start", "bottom-line")
  draw-contour-line("left-arc.end", (x-range, contour-radius), "top-line")

  // Add C_b label
  content("top-line.end", text(fill: dark-blue)[$C_b$], anchor: "south-east", padding: 2pt)

  // Draw right contour
  draw-semicircle((-contour-radius, 0), -90deg, 90deg, "right-arc")
  draw-contour-line((-x-range, contour-radius), "right-arc.end", "right-top-line")
  draw-contour-line("right-arc.start", (-x-range, -contour-radius), "right-bottom-line")
})
