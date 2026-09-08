#import "@preview/cetz:0.5.2": canvas, draw
#import "@preview/cetz-plot:0.1.4": chart
#import draw: arc, content

#set page(width: auto, height: auto, margin: 8pt, fill: none)

#canvas({
  let radius = 3
  let arrow-radius = radius * 1.15 // Slightly larger for arrows

  let dimensions = (
    ("veracity", "Veracity", rgb("#FFA500")),
    ("volume", "Volume", rgb("#0000FF")),
    ("velocity", "Velocity", rgb("#00FF00")),
    ("variety", "Variety", rgb("#FFFF00")),
  )
  let data = ()
  for (name, label, paint) in dimensions {
    data.push((name + "-main", 75, label, paint.lighten(80%)))
    data.push((name + "-sub", 15, "", paint.lighten(60%)))
  }

  chart.piechart(
    data,
    value-key: 1,
    label-key: 2,
    radius: radius,
    slice-style: data.map(itm => itm.at(3)),
    stroke: .5pt,
    inner-label: (
      content: (value, label) => text(weight: "regular")[#label],
      radius: 120%,
    ),
    outer-label: (
      content: (),
    ),
    legend: (label: ()),
  )

  let arrow-style = (
    stroke: .5pt,
    mark: (end: "stealth", fill: black, offset: 5pt, scale: .75),
  )

  let arrows = (
    (
      name: "veracity",
      pos: (arrow-radius, 0),
      start: 0deg,
      labels: (
        (suffix: ".5%", body: [high variance], args: (anchor: "south-west", padding: 3pt)),
        (suffix: ".95%", body: [reference data], args: (anchor: "south-west", padding: 3pt)),
      ),
    ),
    (
      name: "volume",
      pos: (0, arrow-radius),
      start: 90deg,
      labels: (
        (suffix: ".5%", body: [kilobytes], args: (anchor: "south-east")),
        (suffix: ".95%", body: [terabytes], args: (anchor: "south-east", padding: 3pt)),
      ),
    ),
    (
      name: "velocity",
      pos: (-arrow-radius, 0),
      start: 180deg,
      labels: (
        (suffix: ".5%", body: [static], args: (anchor: "east", padding: 3pt)),
        (suffix: ".95%", body: [dynamic], args: (anchor: "north-east", padding: 3pt)),
      ),
    ),
    (
      name: "variety",
      pos: (0, -arrow-radius),
      start: 270deg,
      labels: (
        (suffix: ".start", body: [clustered], args: (anchor: "north-west", padding: 3pt)),
        (suffix: ".95%", body: [heterogeneous], args: (anchor: "north-west", padding: 3pt)),
      ),
    ),
  )
  for spec in arrows {
    arc(
      spec.pos,
      start: spec.start,
      stop: spec.start + 90deg,
      radius: arrow-radius,
      ..arrow-style,
      name: spec.name,
    )
    for label in spec.labels {
      content(
        spec.name + label.suffix,
        text(size: .8em, label.body),
        ..label.args,
      )
    }
  }
})
