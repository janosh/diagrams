#import "@preview/cetz:0.4.1": canvas, draw
#import draw: arc, circle, content, line, set-style

#set page(width: auto, height: auto, margin: 8pt)

// Constants
#let x-range = 3
#let y-range = 3
#let main-radius = y-range + 1.5
#let pole-radius = 0.5
#let dot-radius = 0.05
#let small-dot-radius = 0.03

// Styles
#let arrow-style = (mark: (end: "stealth", scale: 0.5))
#let dark-blue = blue.darken(20%)
#let marc-style = (symbol: "stealth", fill: dark-blue, scale: 0.5, shorten-to: none)
#let gray-line = (paint: gray, thickness: 0.2pt)

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

// Helper function to draw pole contours
#let draw-pole-contours() = {
  for i in range(1, 5) {
    let name = "p" + str(i)

    arc(
      name,
      radius: pole-radius,
      start: 0deg,
      stop: 360deg,
      stroke: dark-blue,
      mark: (
        end: (
          (pos: 25%, ..marc-style),
          (pos: 75%, ..marc-style),
        ),
      ),
      name: "c" + str(i),
      anchor: "origin",
    )

    content(
      (rel: (0, 0.8), to: "c" + str(i)),
      text(fill: dark-blue)[$C_#i$],
      anchor: "north",
    )
  }
}

#canvas({
  // Draw axes
  line((-main-radius, 0), (main-radius, 0), ..arrow-style, name: "x-axis")
  content("x-axis.end", $"Re"(p_0)$, anchor: "south-east", padding: 2pt)

  line((0, -main-radius), (0, main-radius), ..arrow-style, name: "y-axis")
  content("y-axis.97%", $"Im"(p_0)$, anchor: "north-east", padding: 2pt)

  // Draw Matsubara frequencies
  for n in range(-y-range, y-range + 1) {
    if n != 0 {
      circle((0, n), radius: small-dot-radius, fill: black, name: "freq-" + str(n))
      content("freq-" + str(n), $i omega_#text(size: 0.7em)[#n]$, anchor: "west", padding: (x: 3pt))
    }
  }

  // Draw origin
  circle((0, 0), radius: small-dot-radius, fill: black, name: "origin")
  content("origin", [0], anchor: "south-west", padding: (left: 3pt, bottom: 2pt))

  // Draw main contour
  arc(
    (0, 0),
    radius: main-radius,
    start: 0deg,
    stop: 360deg,
    stroke: dark-blue,
    mark: (
      end: (
        (pos: 12.5%, ..marc-style),
        (pos: 37.5%, ..marc-style),
        (pos: 62.5%, ..marc-style),
        (pos: 87.5%, ..marc-style),
      ),
    ),
    name: "main-contour",
    anchor: "origin",
  )

  content("main-contour.90%", text(fill: dark-blue)[$C$], anchor: "north-west", padding: 2pt)

  // Draw poles and pole contours
  draw-poles((2.5, 1.5))
  draw-pole-contours()
})
