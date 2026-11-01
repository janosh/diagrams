#import "@preview/cetz:0.5.3": canvas, draw
#import draw: content, line, set-style

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 12pt)

#canvas({
  set-style(
    content: (frame: "rect", stroke: none, padding: 0.2),
    mark: (end: "stealth", fill: black),
  )
  // Microcanonical, canonical and grand canonical columns: partition function above its intensive potential.
  for (idx, (top, partition, ensemble, bottom, potential, potential-name)) in (
    ("Zm", $Z_m (E)$, [microcanonical], "Sm", $sigma = S_m \/ N$, [entropy per particle]),
    ("Zc", $Z_c (beta)$, [canonical], "F", $f = F \/ N$, [free energy per particle]),
    ("Zg", $Z_g (mu)$, [grand canonical], "O", $Omega \/ V$, [grand potential per volume]),
  ).enumerate() {
    content((5.5 * idx, 0), partition, name: top)
    content((5.5 * idx, -2), potential, name: bottom)
    line(top, bottom)
    // Name each ensemble's partition function and intensive potential in words
    content(top + ".north", text(fill: gray.darken(40%), ensemble), anchor: "south", padding: 0)
    content(
      bottom + ".south",
      text(fill: gray.darken(40%), potential-name),
      anchor: "north",
      padding: 0,
    )
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
