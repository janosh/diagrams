#import "@preview/cetz:0.5.2": canvas, draw
#import draw: content, line
#import "../_shared/flow-equation.typ" as flow

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#canvas({
  content((-2.55, 0), $partial_t (partial^2 V) / (partial^2 chi) space =$, anchor: "east")
  // the external field chi propagates as a straight line, unlike the loop
  flow.flow-diagrams($q$, (from, to) => line(from, to, stroke: .9pt))
})
