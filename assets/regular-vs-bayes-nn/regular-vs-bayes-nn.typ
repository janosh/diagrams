#import "@preview/cetz:0.5.2": canvas, draw
#import "@preview/cetz-plot:0.1.4": plot
#import draw: bezier, circle, content, group, line, translate

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#canvas({
  let spacing = (layer: 3.5, node: 1.5)
  let arrow-style = (
    mark: (end: "stealth", scale: 0.7),
    stroke: gray + 0.7pt,
    fill: gray,
  )

  let neuron(pos, fill: white, label: none, name: none) = {
    content(
      pos,
      if label != none { $#label$ },
      frame: "circle",
      fill: fill,
      stroke: none,
      radius: 0.4,
      padding: 3pt,
      name: name,
    )
  }

  // unit shift vector along start->end, scaled by dist
  let line-shift(start, end, dist) = {
    let dx = end.at(0) - start.at(0)
    let dy = end.at(1) - start.at(1)
    let len = calc.sqrt(dx * dx + dy * dy)
    (x: dist * dx / len, y: dist * dy / len)
  }

  let weight-label(start, end, ii, jj, offset: 0) = {
    let mid-x = (start.at(0) + end.at(0)) / 2
    let mid-y = (start.at(1) + end.at(1)) / 2
    let shift = if offset != 0 {
      let s = line-shift(start, end, offset * 0.4)
      (s.x, s.y)
    } else { (0, 0) }
    content(
      (mid-x + shift.at(0), mid-y + shift.at(1)),
      [#calc.round(0.35 * ii - jj * 0.15, digits: 2)],
      frame: "rect",
      fill: white,
      stroke: none,
      padding: 1.5pt,
    )
  }

  let gaussian(start, end, offset: 0, shift: 0) = {
    let width = 0.6
    let height = 0.25
    let x-mid = (start.at(0) + end.at(0)) / 2
    let y-mid = (start.at(1) + end.at(1)) / 2
    let mu = offset * 0.15
    let s = if shift != 0 { line-shift(start, end, shift * 0.4) } else {
      (x: 0, y: 0)
    }
    group({
      translate((x-mid - width / 2 + s.x, y-mid - height / 2 + s.y))
      plot.plot(size: (width, height), axis-style: none, {
        plot.add(
          style: (stroke: orange + 1pt, fill: orange.lighten(80%)),
          domain: (-1, 1),
          samples: 50,
          x => {
            let variance = 0.3 + calc.abs(offset) * 0.1
            let peak = 0.8 + calc.rem(calc.abs(offset), 0.4)
            peak * calc.exp(-5 * calc.pow(x - mu, 2) / variance)
          },
        )
      })
    })
  }

  // 2-4-1 network; decorate_ih/decorate_ho draw the per-edge annotation (weight or distribution)
  let draw-network(name, x0, decorate_ih, decorate_ho) = group(name: name, {
    for ii in range(2) {
      neuron(
        (x0, (ii + 1) * spacing.node + 1),
        fill: rgb("#90EE90"),
        label: "ii" + str(ii + 1),
        name: "ii" + str(ii + 1),
      )
    }
    for ii in range(4) {
      neuron(
        (x0 + spacing.layer, (ii + 1) * spacing.node),
        fill: rgb("#ADD8E6"),
        label: "h" + str(ii + 1),
        name: "h" + str(ii + 1),
      )
    }
    neuron(
      (x0 + 2 * spacing.layer, 2.5 * spacing.node),
      fill: rgb("#FFB6C6"),
      label: "o",
      name: "o",
    )

    for ii in range(2) {
      for jj in range(4) {
        line("ii" + str(ii + 1), "h" + str(jj + 1), ..arrow-style)
        decorate_ih(
          (x0, (ii + 1) * spacing.node + 1),
          (x0 + spacing.layer, (jj + 1) * spacing.node),
          ii,
          jj,
        )
      }
    }
    for ii in range(4) {
      line("h" + str(ii + 1), "o", ..arrow-style)
      decorate_ho(
        (x0 + spacing.layer, (ii + 1) * spacing.node),
        (x0 + 2 * spacing.layer, 2.5 * spacing.node),
        ii,
      )
    }
  })

  draw-network(
    "regular",
    0,
    (start, end, ii, jj) => weight-label(
      start,
      end,
      ii + 1,
      jj + 1,
      offset: if ii == 0 { 1.5 } else { -1 },
    ),
    (start, end, ii) => weight-label(start, end, ii + 1, 1),
  )
  draw-network(
    "bayes",
    3 * spacing.layer,
    (start, end, ii, jj) => gaussian(start, end, offset: ii - jj, shift: if ii == 0 { 1.5 } else {
      -1
    }),
    (start, end, ii) => gaussian(start, end, offset: ii),
  )
})
