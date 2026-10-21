#import "@preview/cetz:0.5.3": canvas, draw
#import "@preview/cetz-plot:0.1.4": plot

// Power-law ROC curves y = x^a, whose area under the curve is 1 / (1 + a).
#let classifiers = (
  ("Near-Perfect", 0.01),
  ("Excellent", 0.15),
  ("Good", 0.3),
  ("Fair", 0.6),
  ("Poor", 0.8),
)
#let auc(exponent) = calc.round(1 / (1 + exponent), digits: 2)

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 12pt)

#canvas({
  let axis-mark = (end: "stealth", fill: black, scale: 0.7)
  draw.set-style(axes: (
    x: (mark: axis-mark, label: (anchor: "south-east", offset: 1.2)),
    y: (mark: axis-mark, label: (anchor: "south-east", offset: 1.2, angle: 90deg)),
  ))

  plot.plot(
    size: (8, 8),
    x-label: "False Positive Rate (1-Specificity)",
    y-label: "True Positive Rate (Sensitivity)",
    x-min: 0,
    x-max: 1,
    y-min: 0,
    y-max: 1,
    x-tick-step: 0.25,
    y-tick-step: 0.25,
    x-grid: true,
    y-grid: true,
    axis-style: "left",
    legend: "inner-north",
    legend-style: (
      fill: rgb("#cdd3da"),
      item: (spacing: 0.15),
      padding: 0.15,
      stroke: none,
      offset: (7.8, 0.3),
    ),
    {
      plot.add(
        style: (stroke: (paint: rgb("#4A5560"), dash: "dashed", thickness: 0.8pt)),
        domain: (0, 1),
        samples: 2,
        x => x,
        label: "Random Guess (AUC = 0.5)",
      )
      for ((name, exponent), stroke) in classifiers.zip((
        rgb("#0B5FA5") + 1.5pt,
        rgb("#C2570A") + 1.5pt,
        rgb("#12793F") + 1.5pt,
        rgb("#A81E7A") + 1.5pt,
        (paint: rgb("#7A3E9D"), thickness: 1.5pt, dash: "dashed"),
      )) {
        plot.add(
          style: (stroke: stroke),
          domain: (0, 1),
          samples: 100,
          x => calc.pow(x, exponent),
          label: [#name Classifier (AUC = #auc(exponent))],
        )
      }
    },
  )
})
