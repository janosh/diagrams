#import "@preview/cetz:0.5.2": canvas, draw
#import draw: content
#import "../_shared/phase-space.typ": energy-shell

#set page(width: auto, height: auto, margin: 3pt, fill: none)

#canvas({
  energy-shell(4, 2.2)
  content((3, 1), text(fill: blue)[$P$])
})
