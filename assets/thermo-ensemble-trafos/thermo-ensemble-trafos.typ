#import "@preview/cetz:0.4.0": draw, canvas
#import draw: line, content, set-style

#let horizontal_dist = 4
#let vertical_dist = 2
#set page(width: auto, height: auto, margin: 8pt)
#let mark_style = (end: "stealth", fill: black)

#canvas(
  length: 1cm,
  {
    set-style(content: (frame: "rect", stroke: none, padding: 0.2))

    content((0, 0), [$Z_m (E)$], name: "Zm")
    content((horizontal_dist, 0), [$Z_c(beta)$], name: "Zc")
    content((2 * horizontal_dist, 0), [$Z_g(mu)$], name: "Zg")

    content((0, -vertical_dist), [$sigma = frac(S_m, N)$], name: "Sm")
    content((horizontal_dist, -vertical_dist), [$f = frac(F, N)$], name: "F")
    content((2 * horizontal_dist, -vertical_dist), [$frac(Omega, V)$], name: "O")

    line("Zm", "Sm", mark: mark_style, name: "ZmSm")
    line("Zc", "F", mark: mark_style, name: "ZcF")
    line("Zg", "O", mark: mark_style, name: "ZgO")

    line("Zm", "Zc", mark: mark_style, name: "ZmZc")
    content(("Zm", 0.5, "Zc"), [Laplace in $E$], anchor: "north-west")

    line("Zc", "Zg", mark: mark_style)
    content(("Zc", 2, "Zg"), [Laplace in $N$], anchor: "north")

    line("Sm", "F", mark: mark_style)
    content(("Sm", 2, "F"), [Legendre in $epsilon = frac(E, N)$], anchor: "south")

    line("F", "O", mark: mark_style)
    content(("F", 2, "O"), [Legendre in $rho = frac(N, V)$], anchor: "south")
  },
)
