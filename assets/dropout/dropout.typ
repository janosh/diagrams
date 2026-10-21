#import "@preview/cetz:0.5.3": canvas, draw
#import draw: circle, content, line

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(size: 12pt)

#canvas({
  let (layer-gap, node-gap) = (2.5, 1.5)
  let arrow-style = (mark: (end: "stealth", scale: 0.7), fill: black)
  // Unit heights (in multiples of node-gap): input and two hidden layers of 5 units, 2 outputs.
  let layers = ((1, 2, 3, 4, 5),) * 3 + ((2, 4),)

  // Draw the MLP starting at x-start, cross out the `dropped` (layer-idx, height) units and
  // fully connect the remaining units of adjacent layers.
  let network(x-start, prefix, dropped: ()) = {
    let prev-kept = ()
    for (layer-idx, heights) in layers.enumerate() {
      let node-name(height) = prefix + str(layer-idx) + "-" + str(height)
      let kept = heights.filter(height => (layer-idx, height) not in dropped)
      for height in heights {
        circle(
          (x-start + layer-idx * layer-gap, height * node-gap),
          radius: 0.3,
          stroke: 0.8pt,
          name: node-name(height),
        )
        if height not in kept {
          content(node-name(height), text(fill: red, weight: "bold", size: 4em, baseline: -4pt)[×])
        }
      }
      for from in prev-kept {
        for height in kept {
          line(prefix + str(layer-idx - 1) + "-" + str(from), node-name(height), ..arrow-style)
        }
      }
      prev-kept = kept
    }
  }

  network(0, "full")
  line(
    (3.5 * layer-gap, 3 * node-gap),
    (4.5 * layer-gap, 3 * node-gap),
    ..arrow-style,
    name: "dropout-arrow",
  )
  content(
    "dropout-arrow.mid",
    text(weight: "bold", size: 16pt)[dropout],
    anchor: "south",
    padding: 3pt,
  )
  network(5 * layer-gap, "drop", dropped: ((0, 1), (0, 3), (1, 1), (1, 3), (1, 4), (2, 2), (2, 4)))
})
