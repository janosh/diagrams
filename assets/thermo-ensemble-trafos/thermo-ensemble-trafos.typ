#import "@preview/cetz:0.2.2"
#import cetz.draw: line, content, set-style

#let hd = 4
#let vd = 2

#cetz.canvas(length: 1cm, {
  set-style(content: (padding: .3))
  content((0, 0), [$Z_m (E)$], name: "Zm")
  content((hd, 0), [$Z_c(beta)$], name: "Zc")
  content((2*hd, 0), [$Z_g(mu)$], name: "Zg")

  content((0, -vd), [$sigma = frac(S_m, N)$], name: "Sm")
  content((hd, -vd), [$f = frac(F, N)$], name: "F")
  content((2*hd, -vd), [$frac(Omega, V)$], name: "O")

  line("Zm", "Sm", mark: (end: ">"), name: "ZmSm")
  line("Zc", "F", mark: (end: ">"), name: "ZcF")
  line("Zg", "O", mark: (end: ">"), name: "ZgO")

  line("Zm", "Zc", mark: (end: ">"), name: "ZmZc")
  content(("Zm", 0.5, "Zc"), [Laplace in $E$], anchor: "north-west")

  line("Zc", "Zg", mark: (end: ">"))
  content(("Zc", 2, "Zg"), [Laplace in $N$], anchor: "north")

  line("Sm", "F", mark: (end: ">"))
  content(("Sm", 2, "F"), [Legendre in $epsilon = frac(E, N)$], anchor: "south")

  line("F", "O", mark: (end: ">"))
  content(("F", 2, "O"), [Legendre in $rho = frac(N, V)$], anchor: "south")
})
