#import "@preview/cetz:0.5.2": canvas
#import "../_shared/signal-plot.typ": signal-row

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#let domain-x(x) = 11 * x
#let msg(x) = 2 * calc.sin(2 * calc.pi * .25 * domain-x(x))
#let carrier(x) = 2 * calc.sin(6 * calc.pi * domain-x(x))
// phase modulation: the message integrates into the carrier's argument
#let fm(x) = (
  2
    * calc.sin(
      2 * calc.pi * 3 * domain-x(x) - 8 * calc.cos(2 * calc.pi * .25 * domain-x(x)),
    )
)

#canvas({
  let green = green.darken(15%)
  signal-row("msg", 4.6, $x(t)$, msg, black, (-2.4, 2.4))
  signal-row("carrier", 2.05, [carrier wave], carrier, blue, (-2.4, 2.4))
  signal-row("fm", -.6, [FM wave], fm, green, (-2.4, 2.4))
})
