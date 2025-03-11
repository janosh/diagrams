#import "@preview/cetz:0.3.4": canvas
#import "@preview/cetz-plot:0.1.1": chart

#set page(width: auto, height: auto, margin: 0pt)

#canvas({
  // Data for pie chart (equal thirds)
  let data = (
    ("physics", 1, "Ψ", rgb("#4a90e2")),
    ("chemistry", 1, "ΔG", rgb("#50c878")),
    ("ml", 1, "∑", rgb("#ff7f50")),
  )

  // Draw pie chart
  chart.piechart(
    data,
    value-key: 1,
    label-key: 2,
    radius: 3,
    slice-style: data.map(itm => itm.at(-1)),
    stroke: white + .2pt,
    inner-label: (content: (value, label) => [#text(label, size: 4em)], radius: 120%),
    outer-label: (content: ()), // hide outer labels
    legend: (label: ()), // hide legend
  )
})
