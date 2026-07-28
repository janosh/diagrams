#import "@preview/cetz:0.5.2": canvas, draw
#import draw: content, line, set-style

#let horizontal-dist = 4
#let vertical-dist = 2
#set page(width: auto, height: auto, margin: 8pt, fill: none)
#let mark-style = (end: "stealth", fill: black)

#canvas(length: 1cm, {
  set-style(content: (frame: "rect", stroke: none, padding: 0.2))

  content((0, 0), [$Z_m (E)$], name: "Zm")
  content((horizontal-dist, 0), [$Z_(c)(beta)$], name: "Zc")
  content((2 * horizontal-dist, 0), [$Z_(g)(mu)$], name: "Zg")

  content((0, -vertical-dist), [$sigma = frac(S_m, N)$], name: "Sm")
  content((horizontal-dist, -vertical-dist), [$f = frac(F, N)$], name: "F")
  content((2 * horizontal-dist, -vertical-dist), [$frac(Omega, V)$], name: "O")

  line("Zm", "Sm", mark: mark-style, name: "ZmSm")
  line("Zc", "F", mark: mark-style, name: "ZcF")
  line("Zg", "O", mark: mark-style, name: "ZgO")

  line("Zm", "Zc", mark: mark-style, name: "ZmZc")
  content(("Zm", 0.5, "Zc"), [Laplace in $E$], anchor: "north-west")

  line("Zc", "Zg", mark: mark-style)
  content(("Zc", 2, "Zg"), [Laplace in $N$], anchor: "north")

  line("Sm", "F", mark: mark-style)
  content(("Sm", 2, "F"), [Legendre in $epsilon = frac(E, N)$], anchor: "south")

  line("F", "O", mark: mark-style)
  content(("F", 2, "O"), [Legendre in $rho = frac(N, V)$], anchor: "south")
})
