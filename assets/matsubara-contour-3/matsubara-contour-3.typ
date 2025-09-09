#import "@preview/cetz:0.4.2": canvas, draw
#import draw: arc, circle, content, line, set-style

#set page(width: auto, height: auto, margin: 8pt)

// Constants
#let x-range = 3
#let y-range = 3
#let main-radius = y-range + 1.5
#let pole-radius = 0.5
#let dot-radius = 0.05
#let small-dot-radius = 0.03
#let y-offset = 0.25

// Styles
#let arrow-style = (mark: (end: "stealth", scale: 0.5))
#let dark-blue = blue.darken(20%)
#let marc-style = (symbol: "stealth", fill: dark-blue, scale: 0.5, shorten-to: none)
#let gray-line = (paint: gray, thickness: 0.2pt)
#let contour-style = (paint: dark-blue, thickness: 0.8pt)

// Helper function to draw poles
#let draw-poles(poles-label-pos) = {
  content(poles-label-pos, [poles of $h(p_0)$], name: "poles-label")

  // Pole positions: (x, y, name, anchor)
  let pole-positions = (
    (1.5, 3, "p1", "west"),
    (2, -2, "p2", "north"),
    (-3, 1, "p3", "south"),
    (-2, -1.5, "p4", "north"),
  )

  for (x, y, name, anchor) in pole-positions {
    circle((x, y), radius: dot-radius, fill: black, name: name)
    content(name, $p_#name.last()$, anchor: anchor, padding: 2pt)

    let connect-point = if name == "p3" { "poles-label.west" } else { "poles-label" }
    line(connect-point, name, stroke: gray-line)
  }
}

// Helper function to draw a semicircle with arrows
#let draw-semicircle(center-x, start-angle, end-angle, name) = {
  arc(
    (center-x, 0),
    radius: main-radius,
    start: start-angle,
    stop: end-angle,
    stroke: contour-style,
    mark: (
      end: (
        (pos: 25%, ..marc-style),
        (pos: 50%, ..marc-style),
        (pos: 75%, ..marc-style),
      ),
    ),
    name: name,
    anchor: "origin",
  )
}

// Helper function to draw a vertical line with arrows
#let draw-vertical-line(x, start-y, end-y, name) = {
  line(
    (x, start-y),
    (x, end-y),
    stroke: contour-style,
    mark: (
      end: (
        (pos: 25%, ..marc-style),
        (pos: 50%, ..marc-style),
        (pos: 75%, ..marc-style),
      ),
    ),
    name: name,
  )
}

#canvas({
  // Draw axes
  line((-main-radius - y-offset, 0), (main-radius + y-offset, 0), ..arrow-style, name: "x-axis")
  content("x-axis.end", $"Re"(p_0)$, anchor: "south-east", padding: 2pt)

  line((0, -main-radius), (0, main-radius), ..arrow-style, name: "y-axis")
  content("y-axis.97%", $"Im"(p_0)$, anchor: "north-east", padding: (right: 8pt))

  // Draw Matsubara frequencies
  for n in range(-y-range, y-range + 1) {
    if n != 0 {
      circle((0, n), radius: small-dot-radius, fill: black, name: "freq-" + str(n))
      content("freq-" + str(n), $i omega_#text(size: 0.7em)[#n]$, anchor: "west", padding: (left: 10pt))
    }
  }

  // Draw origin
  circle((0, 0), radius: small-dot-radius, fill: black, name: "origin")
  content("origin", [0], anchor: "south-west", padding: (left: 10pt, bottom: 3pt))

  // Draw split contour
  // Right half (C₁): vertical line down + right semicircle
  draw-vertical-line(y-offset, main-radius, -main-radius, "right-line")
  draw-semicircle(y-offset, -90deg, 90deg, "right-arc")

  // Left half (C₂): vertical line up + left semicircle
  draw-vertical-line(-y-offset, -main-radius, main-radius, "left-line")
  draw-semicircle(-y-offset, 90deg, 270deg, "left-arc")

  // Add contour labels
  content("right-line.end", text(fill: dark-blue)[$C_1$], anchor: "south-west", padding: 4pt)
  content("left-line.start", text(fill: dark-blue)[$C_2$], anchor: "south-east", padding: 4pt)

  // Draw poles
  draw-poles((2.5, 1.5))
})
