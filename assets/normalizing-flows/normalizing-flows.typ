#import "@preview/cetz:0.5.3": canvas, draw
#import "@preview/cetz-plot:0.1.4": plot
#import draw: circle, content, group, hobby, line, polygon, rect, translate
#let label-size = 12pt
#let paragraph-size = 14pt
#let heading-size = 16pt

#let card_body(title, body, caption) = block(
  width: 100%,
  inset: 12pt,
  radius: 8pt,
  fill: rgb("#cdd3da"),
  breakable: false,
)[
  #text(size: heading-size, weight: "bold", title)
  #v(8pt)
  // Measure unconstrained artwork before scaling, including content wider than its card.
  #layout(size => {
    let artwork = text(size: label-size, body)
    std.scale(size.width / measure(artwork).width * 100%, reflow: true, artwork)
  })
  #v(7pt)
  #text(size: paragraph-size, caption)
]

#let card-grid(columns: 2, ..cards) = layout(size => {
  let rows = cards
    .pos()
    .chunks(columns)
    .map(row => {
      let ratios = row.map(card => {
        let bounds = measure(text(size: label-size, card.at(1)))
        bounds.width / bounds.height
      })
      let available = size.width - 12pt * (row.len() - 1) - 24pt * row.len()
      grid(
        columns: ratios.map(ratio => 24pt + available * ratio / ratios.sum()),
        gutter: 12pt,
        ..row.map(args => card_body(..args)),
      )
    })
  stack(dir: ttb, spacing: 12pt, ..rows)
})

#let takeaway(body) = block(
  width: 100%,
  inset: 12pt,
  radius: 6pt,
  fill: rgb("#c6d8d2"),
  breakable: false,
  text(size: paragraph-size, body),
)

#set page(width: 780pt, height: auto, margin: 22pt, fill: none)
#set text(font: "Avenir Next", size: paragraph-size, fill: rgb("#19324f"))
#set par(leading: 0.55em)

// === 1  Compose invertible maps ===
#let gaussian(x, mu: 0, sigma: 0.2) = (
  (1 / (sigma * calc.sqrt(2 * calc.pi))) * calc.exp(-0.5 * calc.pow((x - mu) / sigma, 2))
)
// Weighted sum of Gaussians given as (weight, mu, sigma) triples.
#let mixture(params) = x => (
  params.map(((weight, mu, sigma)) => weight * gaussian(x, mu: mu, sigma: sigma)).sum()
)

// Density sketch in a dashed circle below a node.
#let draw-distro(x, y, dist-fn, name: none) = {
  circle((x, y + 0.3), radius: 1, stroke: (dash: "dashed"), name: name)
  line((x - 0.8, y), (x + 0.8, y), mark: (end: ">", scale: 0.5, fill: black))
  line((x, y - 0.5), (x, y + 1.1), mark: (end: ">", scale: 0.5, fill: black))
  group({
    translate((x - 0.8, y))
    plot.plot(size: (1.6, 1.1), axis-style: none, y-min: 0, y-max: 1.5, {
      plot.add(
        style: (stroke: blue.darken(20%) + 1.2pt),
        domain: (-0.8, 0.8),
        samples: 100,
        dist-fn,
      )
    })
  })
}

#let flow-chain = canvas(length: .82cm, {
  let node-spacing = 3
  for (idx, label, stroke, name) in (
    (0, $z_0$, red, "z0"),
    (1, $z_1$, none, "z1"),
    (2, $z_i$, none, "zi"),
    (3, $z_(i+1)$, none, "zi1"),
    (4, $z_k$, rgb("#2d862d"), "zk"),
  ) {
    circle(
      (idx * node-spacing, 0),
      radius: 0.5,
      fill: gray.transparentize(70%),
      stroke: stroke,
      name: name,
    )
    content(name, label)
  }

  content((rel: (0.7, 0), to: "z1"), $dots.c$, name: "dots1", padding: 4pt)
  content((rel: (0.7, 0), to: "zi1"), $dots.c$, name: "dots2", padding: 4pt)
  content((rel: (0.9, 0), to: "zk"), $= x$)

  for (from, to, edge, position, label) in (
    ("z0", "z1", "z0-z1", "mid", $f_(1)(z_0)$),
    ("dots1.east", "zi", "z1-zi", "30%", $f_i (z_(i-1))$),
    ("zi", "zi1", "zi-zi1", "mid", $f_(i+1) (z_i)$),
    ("dots2.east", "zk", "zi1-zk", "30%", $f_k (z_(k-1))$),
  ) {
    line(from, to, mark: (end: ">", fill: black, scale: 0.8, offset: 0.1), name: edge)
    content(edge + "." + position, label, anchor: "south", padding: (bottom: 3pt))
  }

  for (idx, dist-fn, label) in (
    (0, x => 0.55 * gaussian(x), $z_0 ~ p_(0)(z_0)$),
    (2, mixture(((0.6, -0.3, 0.2), (0.4, 0.4, 0.25))), $z_i ~ p_(i)(z_i)$),
    (4, mixture(((0.4, -0.4, 0.15), (0.3, 0, 0.12), (0.3, 0.4, 0.15))), $z_k ~ p_(k)(z_k)$),
  ) {
    draw-distro(idx * node-spacing, -2, dist-fn, name: "distro")
    content("distro.south", label, anchor: "north", padding: (top: 3pt))
  }
})

// === 2  A coupling layer is reversible ===
#let coupling-layer = canvas(length: .65cm, {
  let spacing = (node: 2.5, row: 2.5)
  let arrow-style = (mark: (end: "stealth", fill: black, scale: 0.75), stroke: 0.7pt)
  let diamond(pos, name, label, fill) = {
    polygon(pos, 4, radius: 1.1, angle: 90deg, stroke: 0.7pt, fill: fill, name: name)
    content(pos, label)
  }
  let circle-node(pos, name, label) = {
    circle(pos, radius: 0.5, name: name, stroke: 0.7pt, fill: rgb("#ffa64d").lighten(40%))
    content(pos, label)
  }

  // The inverse uses the same two rows, with reversed data arrows and conditioning from x.
  for (prefix, offset, inverse) in (
    ("forward-", 0, false),
    ("inverse-", 3.2 * spacing.node, true),
  ) {
    let name(node) = prefix + node
    let at(column, row) = (offset + column * spacing.node, -row * spacing.row)
    diamond(at(0, 0), name("z1"), $arrow(z)_(1:d)$, rgb("#cce5ff"))
    circle-node(at(1, 0), name("eq"), "=")
    diamond(at(2, 0), name("x1"), $arrow(x)_(1:d)$, rgb("#cce5ff"))
    diamond(at(0, 1), name("z2"), $arrow(z)_(d+1:D)$, rgb("#ccffcc"))
    circle-node(at(1, 1), name("g"), if inverse { $arrow(g)^(-1)$ } else { $arrow(g)$ })
    diamond(at(2, 1), name("x2"), $arrow(x)_(d+1:D)$, rgb("#fff5cc"))
    circle-node(at(if inverse { 1.5 } else { 0.5 }, 0.5), name("m"), "m")

    for (left, right) in (("z1", "eq"), ("eq", "x1"), ("z2", "g"), ("g", "x2")) {
      let (from, to) = if inverse { (right, left) } else { (left, right) }
      line(name(from), name(to), ..arrow-style)
    }
    line(name(if inverse { "x1" } else { "z1" }), name("m"), ..arrow-style)
    line(name("m"), name("g"), ..arrow-style)
    content(
      (rel: (0, -1.4), to: name("g")),
      if inverse { [inverse pass] } else { [forward pass] },
      anchor: "north",
    )
  }
})

// === 3  Affine coupling ===
#let affine-coupling = canvas(length: 1.2cm, {
  let (horiz-sep, vert-sep) = (1.2, 4)
  let arrow-style = (end: "stealth", fill: black, scale: .5)
  let (orange, blue, teal) = (rgb("#e8c268"), rgb("#63a7e390"), rgb("#008080"))
  // White glyphs vanish on the pale orange fill, so orange circles get dark ones.
  let ink = (orange: rgb("#19324f"), teal: white)
  // Column offsets (in horiz-sep) and name suffixes of the 1..d and d+1..D blocks.
  let columns = (
    (0, "1", blue),
    (1, "2", blue),
    (3, "d", blue),
    (5, "d-plus-1", orange),
    (7, "D", orange),
  )
  let transformed = ("d-plus-1", "D")

  for (prefix, y-pos, labels) in (
    ("x", 0, ($x_1$, $x_2$, $x_d$, $x_(d+1)$, $x_D$)),
    ("z", -vert-sep, ($z_1$, $z_2$, $z_d$, $z_(d+1)$, $z_D$)),
  ) {
    for ((column, suffix, fill), label) in columns.zip(labels) {
      let name = prefix + suffix
      rect((column * horiz-sep, y-pos), (rel: (1, 0.6)), fill: fill, stroke: 0.3pt, name: name)
      content(name, label)
    }
    for (left, right) in (("2", "d"), ("d-plus-1", "D")) {
      content((prefix + left, 50%, prefix + right), text(size: 14pt)[$dots.c$])
    }
  }
  for (_, suffix, _) in columns {
    line("z" + suffix, "x" + suffix, mark: arrow-style, name: "line-" + suffix)
  }

  // Scale and translate functions: a labeled circle and its conditioning triangle.
  for (name, pos, baseline, color, glyph, transparency) in (
    ("t", (4.3 * horiz-sep, 0.4 * -vert-sep), 0pt, teal, ink.teal, 40%),
    ("s", (rel: (.6, -.75), to: "t-circle"), -1pt, orange, ink.orange, 30%),
  ) {
    content(
      pos,
      text(fill: glyph, baseline: baseline, name),
      frame: "circle",
      name: name + "-circle",
      stroke: none,
      fill: color,
      padding: 2pt,
    )
    line(
      "z1.north-west",
      name + "-circle",
      "zd.north-east",
      fill: color.transparentize(transparency),
      close: true,
      stroke: none,
    )
  }

  // Multiply by s then add t along each transformed coordinate.
  for suffix in transformed {
    for (source, label, color, glyph, pos) in (
      ("s", $dot.o$, orange, ink.orange, "40%"),
      ("t", $plus.o$, teal, ink.teal, "70%"),
    ) {
      content(
        "line-" + suffix + "." + pos,
        text(fill: glyph, baseline: -.2pt, label),
        frame: "circle",
        name: "op-" + source + suffix,
        stroke: none,
        fill: color,
        padding: .1pt,
      )
    }
  }
  for suffix in transformed {
    for (source, color) in (("s", orange), ("t", teal)) {
      hobby(
        source + "-circle",
        "op-" + source + suffix,
        mark: (..arrow-style, offset: 5pt),
        stroke: color + 0.75pt,
      )
    }
  }
})

// === 4  Autoregressive conditioning ===
#let autoregressive = canvas(length: 1.5cm, {
  let teal = rgb("#008580")
  for idx in range(4) {
    for (prefix, row, label, fill) in (
      ("x", 0, $x_#(idx + 1)$, rgb("#d6e9f8")),
      ("z", -2, $z_#(idx + 1)$, rgb("#fbe4d4")),
    ) {
      content(
        (idx * 2.1, row),
        label,
        name: prefix + str(idx),
        frame: "rect",
        padding: 8pt,
        fill: fill,
        stroke: none,
      )
    }
    line("x" + str(idx) + ".south", "z" + str(idx) + ".north", stroke: teal + 1pt, mark: (
      end: "stealth",
    ))
    for earlier in range(idx) {
      line("x" + str(earlier) + ".south", ("x" + str(idx), 50%, "z" + str(idx)), stroke: (
        paint: teal,
        thickness: .7pt,
        dash: "dashed",
      ))
    }
  }
  content((3.2, -3), $z_i=(x_i-mu_i (x_(<i))) exp(-s_i (x_(<i)))$)
})

Build a complicated density by composing invertible transformations of a simple one. The Jacobian determinant keeps track of the volume change, so density stays normalized.
#v(14pt)
#card-grid(
  (
    [1  Compose invertible maps],
    flow-chain,
    [A base sample $z_0$ moves through $f_1, f_2, dots, f_k$ to become a data-space sample. Every step must have a computable inverse and density correction.],
  ),
  (
    [2  A coupling layer is reversible],
    coupling-layer,
    [Leave one block unchanged; use it to condition an invertible map of the other block. The conditioner itself does not need to be invertible.],
  ),
  (
    [3  Affine coupling],
    affine-coupling,
    [Keep $x_A=z_A$ and transform $x_B=z_B dot exp(s(z_A))+t(z_A)$. Scale and shift depend only on the unchanged block; alternate which block is transformed.],
  ),
  (
    [4  Autoregressive conditioning],
    autoregressive,
    [For a masked autoregressive flow, coordinate $i$ is conditioned on all earlier data coordinates. A masked network evaluates density in parallel; generation follows the ordering sequentially.],
  ),
)
#v(12pt)
#takeaway[*Change of variables:* for $x=f(z)$, $log p_X (x)=log p_Z (z)-log abs(det J_f (z))$. Triangular Jacobians make the determinant cheap: multiply the diagonal entries, or add their logarithms.]
