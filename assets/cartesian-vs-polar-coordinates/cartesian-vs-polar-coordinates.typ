#import "@preview/cetz:0.5.2": canvas, draw
#import draw: arc, circle, content, line

#set page(width: auto, height: auto, margin: 8pt)

#canvas({
  let (radius, angle) = (2.5, 60deg)
  let point = (radius * calc.cos(angle), radius * calc.sin(angle))
  let axis = (mark: (end: "stealth", fill: black, scale: .65), stroke: .8pt)

  line((-3, 0), (3, 0), ..axis, name: "x-axis")
  line((0, -3), (0, 3), ..axis, name: "y-axis")
  circle((0, 0), radius: radius, stroke: .55pt)

  line((0, 0), (point.at(0), 0), stroke: red + 1.4pt, name: "x-proj")
  line((0, 0), point, stroke: green.darken(15%) + 1.4pt, name: "radius")
  line("radius.end", "x-proj.end", stroke: blue + 1.4pt, name: "y-proj")
  arc((0, 0), radius: 1, start: 0deg, stop: angle, anchor: "origin", stroke: .55pt, name: "alpha-arc")

  circle("radius.end", radius: .055, fill: black, stroke: none)
  content("x-axis.end", $x$, anchor: "west", padding: 2pt)
  content("y-axis.end", $y$, anchor: "south", padding: 2pt)
  content("radius.end", $P$, anchor: "south-west", padding: 3pt)
  content("x-proj.mid", text(fill: red)[$x$], anchor: "north")
  content("y-proj.mid", text(fill: blue)[$y$], anchor: "west")
  content("radius.mid", text(fill: green.darken(15%))[$r$], anchor: "north-west")
  content("alpha-arc.50%", $alpha$, anchor: "south-west", padding: 1pt)
})
