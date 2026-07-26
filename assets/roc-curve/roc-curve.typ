#import "@preview/cetz:0.5.2": canvas
#import "@preview/cetz-plot:0.1.4": plot
#import "../_shared/plot.typ": stealth, style-axes

#set page(width: auto, height: auto, margin: 8pt, fill: none)

// ROC curve functions for different classifiers
#let clamp-unit-interval(x, interior-value) = {
  if x <= 0 { return 0 }
  if x >= 1 { return 1 }
  interior-value
}

#let perfect-classifier(x) = {
  if x == 0 { return 0 }
  if x == 1 { return 1 }
  if x > 0 { return 0.99 }
  return 0
}

#let excellent-classifier(x) = clamp-unit-interval(x, calc.pow(x, 0.15))
#let good-classifier(x) = clamp-unit-interval(x, calc.pow(x, 0.3))
#let fair-classifier(x) = clamp-unit-interval(x, calc.pow(x, 0.6))
#let poor-classifier(x) = clamp-unit-interval(x, 0.2 * x + 0.8 * x * x)

#let random-classifier(x) = x

#canvas({
  style-axes(
    x-label: (anchor: "south-east", offset: 1.2),
    y-label: (anchor: "south-east", offset: 1.2, angle: 90deg),
    mark: (..stealth, scale: 0.7),
  )

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
      item: (spacing: 0.15),
      padding: 0.15,
      stroke: none,
      offset: (7.8, 0.3),
    ),
    {
      plot.add(
        style: (stroke: gray),
        domain: (0, 1),
        samples: 2,
        random-classifier,
        label: "Random Guess (AUC = 0.5)",
      )

      plot.add(
        style: (stroke: green),
        domain: (0, 1),
        samples: 50,
        perfect-classifier,
        label: "Near-Perfect Classifier (AUC = 0.99)",
      )

      plot.add(
        style: (stroke: blue),
        domain: (0, 1),
        samples: 100,
        excellent-classifier,
        label: "Excellent Classifier (AUC = 0.93)",
      )

      plot.add(
        style: (stroke: purple),
        domain: (0, 1),
        samples: 100,
        good-classifier,
        label: "Good Classifier (AUC = 0.85)",
      )

      plot.add(
        style: (stroke: orange),
        domain: (0, 1),
        samples: 100,
        fair-classifier,
        label: "Fair Classifier (AUC = 0.73)",
      )

      plot.add(
        style: (stroke: red),
        domain: (0, 1),
        samples: 100,
        poor-classifier,
        label: "Poor Classifier (AUC = 0.65)",
      )
    },
  )
})
