#import "@preview/cetz:0.5.2": canvas, draw
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

// All variants share positions so the changing ingredient remains visible.
#let architecture(kind) = canvas(
  length: (plain: 1.38cm, sparse: 1.05cm, vae: 1.21cm, denoise: 1.08cm, conv: 1.7cm).at(kind),
  {
    let arrow = (stroke: rgb("#61758a") + 1pt, mark: (end: "stealth", scale: .65))
    let input-label = if kind == "denoise" { $tilde(x)$ } else { $x$ }
    let latent-label = if kind in ("vae", "denoise") { $mu, sigma$ } else { $z$ }
    let box-style = (frame: "rect", stroke: none, padding: (x: 8pt, y: 9pt))
    for (name, x, label, fill) in (
      ("input", 0, input-label, rgb("#d6e9f8")),
      ("encoder", 2, [encoder], rgb("#d6e9f8")),
      ("latent", 4.2, latent-label, rgb("#d3ede5")),
      ("decoder", 6.4, [decoder], rgb("#fbe4d4")),
      ("output", 8.5, $hat(x)$, rgb("#fbe4d4")),
    ) {
      draw.content((x, 0), label, name: name, fill: fill, ..box-style)
    }
    for (left, right) in ("input", "encoder", "latent", "decoder", "output").windows(2) {
      draw.line(left + ".east", right + ".west", ..arrow)
    }
    if kind == "sparse" {
      for idx in range(8) {
        let fill = if idx in (1, 5) { rgb("#008580") } else { rgb("#cdd3da") }
        draw.circle((3.2 + idx * .28, -1), radius: .09, fill: fill, stroke: rgb("#008580") + .5pt)
      }
      draw.content((rel: (0, -1.65), to: "latent"), [few active components])
    } else if kind in ("vae", "denoise") {
      draw.content((rel: (0, .6), to: ("latent", 50%, "decoder")), [sample $z$])
      draw.content((rel: (0, -1.1), to: "latent"), $z = mu + sigma dot epsilon$)
      draw.content((rel: (0, -1.7), to: "latent"), $epsilon ~ cal(N)(0, I)$)
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
      draw.content((rel: (0, -1.8), to: "latent"), [spatial feature maps])
    } else {
      draw.content((rel: (0, -1.1), to: "latent"), [compact bottleneck])
    }
    if kind == "denoise" {
      draw.content((rel: (0, .95), to: "input"), [corrupt $x$])
      draw.line((rel: (0, .65), to: "input"), "input.north", ..arrow)
      draw.content((rel: (0, .95), to: "output"), [target: clean $x$])
    }
  },
)

// === 6  These choices can be combined ===
#let figure-5 = [
  #align(center)[
    #text(size: 16pt, fill: rgb("#006560"))[representation]\
    #v(9pt)
    bottleneck · sparse · stochastic\
    #v(18pt)
    #text(size: 16pt, fill: rgb("#8f4007"))[architecture and training]\
    #v(9pt)
    convolutional · denoising
  ]
]

Every autoencoder learns to reconstruct an input through an intermediate representation. Compare the changing constraint or architecture while the common data path stays fixed.
#v(14pt)
#card-grid(
  (
    [1  Autoencoder],
    architecture("plain"),
    [Encode $x$ into a bottleneck $z$, then reconstruct $hat(x)$. A reconstruction loss rewards retaining useful information.],
  ),
  (
    [2  Sparse autoencoder],
    architecture("sparse"),
    [Penalize latent activity so only a few components activate for one input. The latent layer may be wider than the input; sparsity is the constraint.],
  ),
  (
    [3  Variational autoencoder],
    architecture("vae"),
    [The encoder predicts a distribution over $z$, not just one code. Reconstruction and a KL-divergence term train it toward an explicit prior.],
  ),
  (
    [4  Denoising variational autoencoder],
    architecture("denoise"),
    [Corrupt the input, then reconstruct the clean target. The stochastic latent step remains; robustness and distribution learning are separate ingredients.],
  ),
  (
    [5  Convolutional autoencoder],
    architecture("conv"),
    [Convolutions share filters over spatial locations. Feature maps change resolution through the encoder and decoder; this is an architectural choice.],
  ),
  (
    [6  These choices can be combined],
    figure-5,
    [A convolutional model can also be sparse, variational, or denoising. These names describe different design dimensions, not mutually exclusive model families.],
  ),
)
#v(12pt)
#takeaway[*Notation:* $x$ = input, $hat(x)$ = reconstruction, $z$ = latent code, $mu$ and $sigma$ = latent mean and standard deviation. The sampled noise $epsilon$ enables the reparameterization step.]
