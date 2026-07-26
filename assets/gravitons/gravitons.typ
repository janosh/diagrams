#import "@preview/cetz:0.5.2": canvas, decorations, draw
#import draw: content, line
#import "../_shared/flow-equation.typ" as flow

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#canvas({
  content((-2.55, 0), $partial_t V_g space =$, anchor: "east")
  // graviton legs are wavy like the loop propagators
  flow.flow-diagrams(
    $p$,
    (from, to) => decorations.wave(line(from, to), ..flow.wavy),
  )
})
