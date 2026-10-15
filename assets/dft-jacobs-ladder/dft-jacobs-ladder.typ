#import "@preview/cetz:0.5.2": canvas, draw
#import draw: circle, content, line, rect

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 14pt)

#canvas({
  let rung-sep = 2.2 // Vertical separation between rungs
  let width = 12.4 // Width of each rung
  let height = 1.5 // Height of each rung
  let circle-r = 0.8 // Radius of symbol circles
  let rung-stroke = rgb("888") + 0.4pt

  for (idx, (color, label, symbol)) in (
    (rgb("b4a7d6"), [0: *Hartree World*], none),
    (rgb("a4c2f4"), [1: *Local Density Approx. (LDA)*\ VWN, PW92], $rho(bold(r))$),
    (rgb("f9cb9c"), [2: *Generalized Gradient Approx. (GGA)*\ PBE, BLYP], $nabla rho(bold(r))$),
    (
      rgb("ffe599"),
      [3: *Meta-GGA*\ (r/r$""^2$)SCAN],
      [$\ nabla^(2) rho(bold(r))$ \ $tau(bold(r))$],
    ),
    (rgb("b6d7a8"), [4: *Occupied Hybrid Methods* \ B3LYP, CAM-B3LYP, M06-2X], ${phi_i^"occ"}$),
    (rgb("ea9999"), [5: *Virtual Double-Hybrids* \ B2PLYP], ${phi_i^"virt"}$),
    (rgb("ffb7c5"), [*Chemical accuracy*], none),
  ).enumerate() {
    let y = idx * rung-sep
    rect((-width / 2, y), (width / 2, y + height), fill: color, stroke: rung-stroke, name: "rung")
    let symbol-center = (rel: (1.15, 0), to: "rung.west") // Keep the symbols near the left edge
    // Left-align text next to the symbol circle
    content((rel: (circle-r + 0.2, 0), to: symbol-center), align(horizon, label), anchor: "west")
    if symbol != none {
      circle(symbol-center, radius: circle-r, fill: color, stroke: rung-stroke)
      content(symbol-center, align(center, symbol))
    }
  }

  // Ladder rails run from the ground to the top of the last rung
  for x in (-width / 2, width / 2) { line((x, 0), ((x, 0), "|-", "rung.north"), stroke: 0.7pt) }
})
