#import "@preview/cetz:0.5.2": canvas
#import "@preview/cetz-plot:0.1.4": plot
#import "../_shared/plot.typ": stealth, style-axes
#import "../_shared/theme.typ": line-weight, neutral, series

#set page(width: auto, height: auto, margin: 8pt, fill: none)

// ROC curve functions for different classifiers
#let clamp-unit-interval(x, interior-value) = {
  if x <= 0 { return 0 }
  if x >= 1 { return 1 }
  interior-value
}

#let perfect-classifier(x) = if x == 0 { 0 } else if x == 1 { 1 } else if x > 0 { 0.99 } else { 0 }

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
      let curves = (
        (
          func: random-classifier,
          samples: 2,
          stroke: (paint: neutral.annotation, dash: "dashed", thickness: line-weight.thin),
          label: "Random Guess (AUC = 0.5)",
        ),
        (
          func: perfect-classifier,
          samples: 50,
          stroke: series(0),
          label: "Near-Perfect Classifier (AUC = 0.99)",
        ),
        (
          func: excellent-classifier,
          samples: 100,
          stroke: series(1),
          label: "Excellent Classifier (AUC = 0.93)",
        ),
        (
          func: good-classifier,
          samples: 100,
          stroke: series(2),
          label: "Good Classifier (AUC = 0.85)",
        ),
        (
          func: fair-classifier,
          samples: 100,
          stroke: series(3),
          label: "Fair Classifier (AUC = 0.73)",
        ),
        (
          func: poor-classifier,
          samples: 100,
          stroke: series(4),
          label: "Poor Classifier (AUC = 0.65)",
        ),
      )
      for curve in curves {
        plot.add(
          style: (stroke: curve.stroke),
          domain: (0, 1),
          samples: curve.samples,
          curve.func,
          label: curve.label,
        )
      }
    },
  )
})
