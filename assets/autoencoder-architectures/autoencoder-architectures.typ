#import "@preview/cetz:0.5.2": canvas, draw

#set page(width: 780pt, height: auto, margin: 22pt, fill: white)
#set text(font: "Avenir Next", size: 10.5pt, fill: rgb("#19324f"))
#set par(leading: 0.55em)

// Measure each drawing before fitting it; keep labels and geometry together.
#let fit-figure(body, height: 170pt) = layout(size => {
  let bounds = measure(body)
  let factor = calc.min(size.width / bounds.width, height / bounds.height)
  box(width: 100%, align(center + horizon, std.scale(
    x: factor * 100%,
    y: factor * 100%,
    reflow: true,
    body,
  )))
})
#let card(title, body, caption, height: 170pt) = block(
  width: 100%,
  inset: 12pt,
  radius: 8pt,
  fill: rgb("#f3f6fa"),
  breakable: false,
)[
  #text(size: 13pt, weight: "bold", title)
  #v(8pt)
  #fit-figure(body, height: height)
  #v(7pt)
  #caption
]
#let takeaway(body) = block(
  width: 100%,
  inset: 12pt,
  radius: 6pt,
  fill: rgb("#e9f5f2"),
  breakable: false,
)[#body]

// All variants share positions so the changing ingredient remains visible.
#let architecture(kind) = canvas({
  let arrow = (stroke: rgb("#61758a") + 1pt, mark: (end: "stealth", scale: .65))
  for (name, pos, label, fill) in (
    ("input", (0, 0), if kind == "denoise" { $tilde(x)$ } else { $x$ }, rgb("#d6e9f8")),
    ("encoder", (2, 0), [encoder], rgb("#d6e9f8")),
    (
      "latent",
      (4.2, 0),
      if kind in ("vae", "denoise") { $mu, sigma$ } else { $z$ },
      rgb("#d3ede5"),
    ),
    ("decoder", (6.4, 0), [decoder], rgb("#fbe4d4")),
    ("output", (8.5, 0), $hat(x)$, rgb("#fbe4d4")),
  ) {
    draw.content(pos, label, name: name, frame: "rect", fill: fill, stroke: none, padding: (
      x: 8pt,
      y: 9pt,
    ))
  }
  for (left, right) in (
    ("input", "encoder"),
    ("encoder", "latent"),
    ("latent", "decoder"),
    ("decoder", "output"),
  ) {
    draw.line(left + ".east", right + ".west", ..arrow)
  }
  if kind == "sparse" {
    for idx in range(8) {
      draw.circle(
        (3.2 + idx * .28, -1),
        radius: .09,
        fill: if idx in (1, 5) { rgb("#008580") } else { white },
        stroke: rgb("#008580") + .5pt,
      )
    }
    draw.content((4.2, -1.65), [few active components])
  } else if kind in ("vae", "denoise") {
    draw.content((5.3, .6), [sample $z$])
    draw.content((4.2, -1.1), $z = mu + sigma dot epsilon$)
    draw.content((4.2, -1.7), $epsilon ~ cal(N)(0, I)$)
  } else if kind == "conv" {
    for (start, side) in ((1.2, "encode"), (5.7, "decode")) {
      for idx in range(3) {
        let width = if side == "encode" { .7 - idx * .15 } else { .4 + idx * .15 }
        draw.rect(
          (start + idx * .55, -1.4),
          (rel: (width, width)),
          fill: rgb("#d6e9f8"),
          stroke: rgb("#537da0") + .5pt,
        )
      }
    }
    draw.content((4.2, -1.8), [spatial feature maps])
  } else {
    draw.content((4.2, -1.1), [compact bottleneck])
  }
  if kind == "denoise" {
    draw.content((0, .95), [corrupt $x$])
    draw.line((0, .65), "input.north", ..arrow)
    draw.content((8.5, .95), [target: clean $x$])
  }
})

// === 1  Autoencoder ===
#let figure-0 = [
  #architecture("plain")
]

// === 2  Sparse autoencoder ===
#let figure-1 = [
  #architecture("sparse")
]

// === 3  Variational autoencoder ===
#let figure-2 = [
  #architecture("vae")
]

// === 4  Denoising variational autoencoder ===
#let figure-3 = [
  #architecture("denoise")
]

// === 5  Convolutional autoencoder ===
#let figure-4 = [
  #architecture("conv")
]

// === 6  These choices can be combined ===
#let figure-5 = [
  #align(center)[
    #text(size: 16pt, fill: rgb("#008580"))[representation]\
    #v(9pt)
    bottleneck · sparse · stochastic\
    #v(18pt)
    #text(size: 16pt, fill: rgb("#c2570a"))[architecture and training]\
    #v(9pt)
    convolutional · denoising
  ]
]

#text(size: 27pt, weight: "bold")[Autoencoder Architectures]
#v(5pt)
Every autoencoder learns to reconstruct an input through an intermediate representation. Compare the changing constraint or architecture while the common data path stays fixed.
#v(14pt)
#grid(
  columns: (1fr, 1fr),
  gutter: 12pt,
  card(
    [1  Autoencoder],
    figure-0,
    [Encode $x$ into a bottleneck $z$, then reconstruct $hat(x)$. A reconstruction loss rewards retaining useful information.],
    height: 130pt,
  ),
  card(
    [2  Sparse autoencoder],
    figure-1,
    [Penalize latent activity so only a few components activate for one input. The latent layer may be wider than the input; sparsity is the constraint.],
    height: 130pt,
  ),

  card(
    [3  Variational autoencoder],
    figure-2,
    [The encoder predicts a distribution over $z$, not just one code. Reconstruction and a KL-divergence term train it toward an explicit prior.],
    height: 130pt,
  ),
  card(
    [4  Denoising variational autoencoder],
    figure-3,
    [Corrupt the input, then reconstruct the clean target. The stochastic latent step remains; robustness and distribution learning are separate ingredients.],
    height: 130pt,
  ),

  card(
    [5  Convolutional autoencoder],
    figure-4,
    [Convolutions share filters over spatial locations. Feature maps change resolution through the encoder and decoder; this is an architectural choice.],
    height: 130pt,
  ),
  card(
    [6  These choices can be combined],
    figure-5,
    [A convolutional model can also be sparse, variational, or denoising. These names describe different design dimensions, not mutually exclusive model families.],
    height: 130pt,
  ),
)
#v(12pt)
#takeaway[*Notation:* $x$ = input, $hat(x)$ = reconstruction, $z$ = latent code, $mu$ and $sigma$ = latent mean and standard deviation. The sampled noise $epsilon$ enables the reparameterization step.]
