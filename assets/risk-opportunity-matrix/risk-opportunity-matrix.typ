#import "@preview/cetz:0.5.2"
#import cetz.draw: content, line, rect

#set page(width: auto, height: auto, margin: 4mm, fill: none)
#set text(size: 12pt)
// #set text(lang: "de")

#let en-de(en, de) = context {
  if text.lang == "de" { de } else { en }
}

#cetz.canvas(length: 1.3cm, {
  // localizable texts
  let intensities = (
    en-de[Very Low][Sehr Klein],
    en-de[Low][Klein],
    en-de[Medium][Mittel],
    en-de[High][Hoch],
    en-de[Very High][Sehr Hoch],
  )

  let probability = en-de[Probability][Eintrittswahrscheinlichkeit]
  let pos-impact = en-de[Positive Impact][Positive Auswirkung]
  let neg-impact = en-de[Negative Impact][Negative Auswirkung]

  let risks = en-de[Risks][Risiken]
  let opportunities = en-de[Opportunities][Chancen]

  let attention-arrow = en-de[Arrow of Attention][Pfeil der Aufmerksamkeit]

  let cell(x, y) = ((x, y), (x + 1, y + 1))

  // main grid of impact/probability assessments
  let (l, m, h) = (
    l: green.saturate(-50%),
    m: yellow.saturate(-50%),
    h: red.saturate(-50%),
  )
  let cells = (
    (m, m, h, h, h),
    (l, m, m, h, h),
    (l, l, m, h, h),
    (l, l, m, m, h),
    (l, l, l, l, m),
  )
  let (width, height) = (2 * cells.first().len(), cells.len())
  // risks on the left, mirrored opportunities on the right
  for (row-idx, row) in cells.enumerate() {
    let y = height - row-idx - 1
    for (col-idx, fill) in row.enumerate() {
      rect(..cell(col-idx, y), fill: fill)
      rect(..cell(width - col-idx - 1, y), fill: fill)
    }
  }

  // risk/opportunity grid labels
  let big-label(..args, label) = content(..args, {
    set text(21.12pt, weight: "bold", fill: black, stroke: 0.3pt + gray)
    set align(center + horizon)
    label
  })

  big-label((2, 1.5), risks)
  big-label((width - 2, 1.5), opportunities)

  // intensity grid labels
  for (idx, intensity) in intensities.enumerate() {
    let intensity = pad(4pt, align(center + horizon, intensity))
    content(..cell(-1.25, idx), intensity)
    content(..cell(width + 0.25, idx), intensity)
    content(..cell(idx, -1), intensity)
    content(..cell(width - idx - 1, -1), intensity)
  }

  // axis labeling arrows, labels read along the arrow (ltr) or against it (rtl)
  let labeled-arrow(start, end, label, dir, align) = {
    line(start, end, name: "axis", stroke: gray, mark: (end: ">", fill: gray))
    content(
      ("axis.start", 50%, "axis.end"),
      angle: if dir == ltr { "axis.end" } else { "axis.start" },
      padding: if align == top { (bottom: 0.3) } else { (top: 0.3) },
      anchor: if align == top { "south" } else { "north" },
      text(1.2em, label),
    )
  }

  let arrow-inset = 0.3
  for (start, end, label, dir, align) in (
    ((-1.6, arrow-inset), (-1.6, height - arrow-inset), probability, ltr, top),
    ((width + 1.6, arrow-inset), (width + 1.6, height - arrow-inset), probability, rtl, top),
    ((arrow-inset, -1), (width / 2 - arrow-inset, -1), neg-impact, ltr, bottom),
    ((width - arrow-inset, -1), (width / 2 + arrow-inset, -1), pos-impact, rtl, bottom),
  ) {
    labeled-arrow(start, end, label, dir, align)
  }

  // arrow of attention
  let cone-start = 1
  let cone-length = height - cone-start + 0.7
  line(
    (width / 2, cone-start),
    (width / 2 - cone-length, cone-start + cone-length),
    (width / 2 + cone-length, cone-start + cone-length),
    close: true,
    fill: gray.transparentize(80%),
    stroke: gray,
  )
  content((width / 2, (height + cone-start + cone-length) / 2), {
    set text(1.7em)
    set align(center + horizon)
    attention-arrow
  })
})
