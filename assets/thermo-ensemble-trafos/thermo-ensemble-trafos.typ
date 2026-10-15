#import "@preview/cetz:0.5.2": canvas, draw
#import draw: content, line, set-style

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 12pt)

#canvas({
  set-style(
    content: (frame: "rect", stroke: none, padding: 0.2),
    mark: (end: "stealth", fill: black),
  )
  // Microcanonical, canonical and grand canonical columns: partition function above its intensive potential.
  for (idx, (top, partition, bottom, potential)) in (
    ("Zm", $Z_m (E)$, "Sm", $sigma = S_m \/ N$),
    ("Zc", $Z_c (beta)$, "F", $f = F \/ N$),
    ("Zg", $Z_g (mu)$, "O", $Omega \/ V$),
  ).enumerate() {
    content((5.5 * idx, 0), partition, name: top)
    content((5.5 * idx, -2), potential, name: bottom)
    line(top, bottom)
  }
  for (from, to, label, anchor) in (
    ("Zm", "Zc", [Laplace in $E$], "north"),
    ("Zc", "Zg", [Laplace in $N$], "north"),
    ("Sm", "F", [Legendre in $epsilon = E \/ N$], "south"),
    ("F", "O", [Legendre in $rho = N \/ V$], "south"),
  ) {
    line(from, to)
    content((from, 50%, to), label, anchor: anchor)
  }
})
