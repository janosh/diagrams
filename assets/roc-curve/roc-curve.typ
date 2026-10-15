#import "@preview/cetz:0.5.2": canvas, draw
#import "@preview/cetz-plot:0.1.4": plot

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
      // A power-law ROC curve y = x^a has AUC = 1 / (1 + a).
      for (name, exponent, stroke) in (
        ("Near-Perfect", 0.01, rgb("#0B5FA5") + 1.5pt),
        ("Excellent", 0.15, rgb("#C2570A") + 1.5pt),
        ("Good", 0.3, rgb("#12793F") + 1.5pt),
        ("Fair", 0.6, rgb("#A81E7A") + 1.5pt),
        ("Poor", 0.8, (paint: rgb("#7A3E9D"), thickness: 1.5pt, dash: "dashed")),
      ) {
        let auc = calc.round(1 / (1 + exponent), digits: 2)
        plot.add(
          style: (stroke: stroke),
          domain: (0, 1),
          samples: 100,
          x => calc.pow(x, exponent),
          label: [#name Classifier (AUC = #auc)],
        )
      }
    },
  )
})
