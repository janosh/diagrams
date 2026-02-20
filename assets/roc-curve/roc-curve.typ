#import "@preview/cetz:0.4.2": canvas, draw
#import "@preview/cetz-plot:0.1.3": plot

#set page(width: auto, height: auto, margin: 8pt)

// ROC curve functions for different classifiers
#let clamp_unit_interval(x, interior_value) = {
  if x <= 0 { return 0 }
  if x >= 1 { return 1 }
  interior_value
}

#let perfect_classifier(x) = {
  if x == 0 { return 0 }
  if x == 1 { return 1 }
  if x > 0 { return 0.99 }
  return 0
}

#let excellent_classifier(x) = clamp_unit_interval(x, calc.pow(x, 0.15))
#let good_classifier(x) = clamp_unit_interval(x, calc.pow(x, 0.3))
#let fair_classifier(x) = clamp_unit_interval(x, calc.pow(x, 0.6))
#let poor_classifier(x) = clamp_unit_interval(x, 0.2 * x + 0.8 * x * x)

#let random_classifier(x) = x

#canvas({
  let mark = (end: "stealth", fill: black, scale: 0.7)
  draw.set-style(axes: (
    y: (label: (anchor: "south-east", offset: 1.2, angle: 90deg), mark: mark),
    x: (label: (anchor: "south-east", offset: 1.2), mark: mark),
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
    legend-style: (item: (spacing: 0.15), padding: 0.15, stroke: none, offset: (7.8, 0.3)),
    {
      plot.add(
        style: (stroke: gray),
        domain: (0, 1),
        samples: 2,
        random_classifier,
        label: "Random Guess (AUC = 0.5)",
      )

      plot.add(
        style: (stroke: green),
        domain: (0, 1),
        samples: 50,
        perfect_classifier,
        label: "Near-Perfect Classifier (AUC = 0.99)",
      )

      plot.add(
        style: (stroke: blue),
        domain: (0, 1),
        samples: 100,
        excellent_classifier,
        label: "Excellent Classifier (AUC = 0.93)",
      )

      plot.add(
        style: (stroke: purple),
        domain: (0, 1),
        samples: 100,
        good_classifier,
        label: "Good Classifier (AUC = 0.85)",
      )

      plot.add(
        style: (stroke: orange),
        domain: (0, 1),
        samples: 100,
        fair_classifier,
        label: "Fair Classifier (AUC = 0.73)",
      )

      plot.add(
        style: (stroke: red),
        domain: (0, 1),
        samples: 100,
        poor_classifier,
        label: "Poor Classifier (AUC = 0.65)",
      )
    },
  )
})
