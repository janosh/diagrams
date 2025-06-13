#import "@preview/cetz:0.4.0": canvas, draw
#import draw: line, content, circle, arc, set-style

#set page(width: auto, height: auto, margin: 8pt)

// Constants
#let x-range = 3
#let y-range = 3

// Define styles
#let arrow-style = (
  mark: (end: "stealth", fill: black, scale: 0.5),
  stroke: 0.5pt,
)
#let dark-blue = blue.darken(20%)

// Helper function to draw poles
#let draw-poles(poles-label-pos) = {
  // Draw poles label and connecting lines
  content(poles-label-pos, [poles of $h(p_0)$], name: "poles-label")

  // Draw the poles
  circle((1.5, 3), radius: 0.05, fill: black, name: "p1")
  circle((2, -2), radius: 0.05, fill: black, name: "p2")
  circle((-3, 1), radius: 0.05, fill: black, name: "p3")
  circle((-2, -1.5), radius: 0.05, fill: black, name: "p4")

  // Add pole labels
  content("p1", $p_1$, anchor: "west", padding: 2pt)
  content("p2", $p_2$, anchor: "north", padding: 2pt)
  content("p3", $p_3$, anchor: "south", padding: 2pt)
  content("p4", $p_4$, anchor: "north", padding: 2pt)

  // Connect poles to label with thin gray lines
  let stroke = (stroke: (paint: gray, thickness: 0.2pt))
  line("poles-label", "p1", ..stroke)
  line("poles-label", "p2", ..stroke)
  line("poles-label.west", "p3", ..stroke)
  line("poles-label", "p4", ..stroke)
}

#canvas({
  // Draw axes
  line((-x-range - 1, 0), (x-range + 1, 0), ..arrow-style, name: "x-axis")
  content("x-axis.end", $"Re"(p_0)$, anchor: "south-east", padding: 2pt)

  line((0, -y-range - 0.7), (0, y-range + 0.7), ..arrow-style, name: "y-axis")
  content((rel: (-1, 0), to: "y-axis.95%"), $"Im"(p_0)$, name: "y-label", anchor: "south-east", padding: 2pt)
  line("y-axis.98%", "y-label", stroke: (paint: gray, thickness: 0.2pt))

  // Draw Matsubara frequencies
  for n in range(-y-range, y-range + 1) {
    if n != 0 {
      circle((0, n), radius: 0.03, fill: black, name: "freq-" + str(n))
      content(
        "freq-" + str(n),
        $i omega_#text(size: 0.7em)[#n]$,
        anchor: "west",
        padding: (x: 3pt),
      )
    }
  }

  // Draw origin
  circle((0, 0), radius: 0.03, fill: black, name: "origin")
  content("origin", [0], anchor: "south-west", padding: (left: 3pt, bottom: 2pt))

  // Draw contour line
  // Right vertical line
  // Base line with name
  line(
    (1, -y-range - 0.3),
    (1, y-range + 0.3),
    stroke: dark-blue,
    mark: (end: "stealth", scale: 0.5),
    name: "right-line",
  )


  // Top semicircle - positioned to fully enclose the y-axis
  arc(
    (0, y-range + 0.6),
    radius: 1,
    start: 0deg,
    stop: 180deg,
    stroke: dark-blue,
    mark: (end: "stealth", scale: 0.5),
    name: "top-arc",
    anchor: "center",
  )

  // Left vertical line
  line(
    (-1, y-range + 0.3),
    (-1, -y-range - 0.3),
    stroke: dark-blue,
    name: "left-line",
    mark: (end: "stealth", scale: 0.5),
  )

  // Bottom semicircle - positioned to fully enclose the y-axis
  arc(
    (0, -y-range - 0.5),
    radius: 1,
    start: 180deg,
    stop: 360deg,
    stroke: dark-blue,
    mark: (end: "stealth", scale: 0.5),
    name: "bottom-arc",
    anchor: "center",
  )

  // Add contour label
  content("right-line.end", text(fill: dark-blue)[$C$], anchor: "south-west", padding: 2pt)

  // Draw poles
  draw-poles((2.75, 1.5))
})
