#import "@preview/cetz:0.5.2": canvas
#import "../_shared/signal-plot.typ": signal-row

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#let domain-x(x) = 11 * calc.pi * x
#let msg(x) = 2.5 + 2 * calc.sin(.5 * domain-x(x))
#let carrier(x) = 2 * calc.sin(6 * domain-x(x))
#let am(x) = msg(x) * carrier(x)

#canvas({
  signal-row("msg", 4.6, $x(t)$, msg, black, (0, 7.5))
  signal-row("carrier", 2.05, [carrier wave], carrier, blue, (-2.4, 2.4))
  signal-row("am", -.6, [AM wave], am, red, (-9.5, 9.5))
})
