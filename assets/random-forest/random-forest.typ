#import "@preview/cetz:0.3.2": canvas, draw
#import draw: line, content, circle, rect, group, set-style, on-layer

#set page(width: auto, height: auto, margin: 8pt)

// TODO add arrows next to each connecting line between red nodes

// Define styles and constants
#let arrow-style = (mark: (end: "stealth", fill: black, scale: 0.5))
#let red-arrow-style = (
  fill: red,
  stroke: none,
  mark: (start: ">", end: ">", scale: 1.2),
)
#let node-box-style = (
  stroke: black + 0.3pt,
  fill: white,
  radius: 3pt,
)
#let tree-box-style = (
  stroke: black + 0.3pt,
  fill: none,
  radius: 3pt,
)

#canvas({
  // Set global content frame style
  set-style(
    content: (
      frame: "rect",
      stroke: 0.1pt,
      fill: white,
      inset: 3pt,
      radius: 3pt,
      padding: (3pt, 5pt, 2pt),
    ),
  )

  // Helper function for tree nodes
  let tree-node(pos, fill: blue.lighten(40%), name: none) = {
    circle(pos, radius: 0.2, fill: fill, stroke: black + 0.3pt, name: name)
  }

  // Helper function to draw a complete tree
  let draw-tree(x-pos, tree-name, path-nodes: ()) = {
    let y-pos = -2
    let level-spacing = 1.2 // Vertical spacing between levels
    let node-spacing = 1.0 // Base horizontal spacing between nodes

    group(
      name: tree-name,
      {
        // Root node (level 0)
        tree-node(
          (x-pos, y-pos),
          name: "root",
          fill: if "root" in path-nodes { red.lighten(30%) } else { blue.lighten(40%) },
        )

        // Level 1 nodes (2 nodes, evenly spaced)
        tree-node(
          (x-pos - node-spacing, y-pos - level-spacing),
          name: "left",
          fill: if "left" in path-nodes { red.lighten(30%) } else { blue.lighten(40%) },
        )
        tree-node(
          (x-pos + node-spacing, y-pos - level-spacing),
          name: "right",
          fill: if "right" in path-nodes { red.lighten(30%) } else { blue.lighten(40%) },
        )

        // Level 2 nodes - different structure for each tree
        if tree-name == "tree1" {
          // Tree 1: left node splits into 3, right into 1
          let left-spacing = node-spacing * 0.67 // Tighter spacing for 3 nodes
          for (i, offset) in (-1, 0, 1).enumerate() {
            tree-node(
              (x-pos - node-spacing + offset * left-spacing, y-pos - 2 * level-spacing),
              name: "l" + str(i),
              fill: if "l" + str(i) in path-nodes { red.lighten(30%) } else { blue.lighten(40%) },
            )
          }
          tree-node(
            (x-pos + node-spacing, y-pos - 2 * level-spacing),
            name: "r0",
            fill: if "r0" in path-nodes { red.lighten(30%) } else { blue.lighten(40%) },
          )
        } else if tree-name == "tree2" {
          // Tree 2: left node splits into 2, right into 2
          let side-spacing = node-spacing * 0.5 // Half spacing for 2 nodes each side
          for (i, offset) in (-1, 1).enumerate() {
            tree-node(
              (x-pos - node-spacing + offset * side-spacing, y-pos - 2 * level-spacing),
              name: "l" + str(i),
              fill: if "l" + str(i) in path-nodes { red.lighten(30%) } else { blue.lighten(40%) },
            )
          }
          for (i, offset) in (-1, 1).enumerate() {
            tree-node(
              (x-pos + node-spacing + offset * side-spacing, y-pos - 2 * level-spacing),
              name: "r" + str(i),
              fill: if "r" + str(i) in path-nodes { red.lighten(30%) } else { blue.lighten(40%) },
            )
          }
        } else {
          // Tree 3: left node splits into 1, right into 3
          tree-node(
            (x-pos - node-spacing, y-pos - 2 * level-spacing),
            name: "l0",
            fill: if "l0" in path-nodes { red.lighten(30%) } else { blue.lighten(40%) },
          )
          let right-spacing = node-spacing * 0.67 // Tighter spacing for 3 nodes
          for (i, offset) in (-1, 0, 1).enumerate() {
            tree-node(
              (x-pos + node-spacing + offset * right-spacing, y-pos - 2 * level-spacing),
              name: "r" + str(i),
              fill: if "r" + str(i) in path-nodes { red.lighten(30%) } else { blue.lighten(40%) },
            )
          }
        }

        // Connect nodes
        line("root", "left")
        line("root", "right")

        // Connect level 2 to 3 based on tree structure
        if tree-name == "tree1" {
          for idx in range(3) { line("left", "l" + str(idx)) }
          line("right", "r0")
        } else if tree-name == "tree2" {
          for idx in range(2) {
            line("left", "l" + str(idx))
            line("right", "r" + str(idx))
          }
        } else {
          line("left", "l0")
          for idx in range(3) { line("right", "r" + str(idx)) }
        }

        // Tree box and label (made slightly wider)
        rect(
          (x-pos - 2.6, y-pos - 2.6 * level-spacing),
          (x-pos + 2.6, y-pos + 0.5),
          stroke: black + 0.3pt,
          fill: none,
          radius: 3pt,
          name: tree-name,
        )
        content(
          (x-pos - 1.7, y-pos + 0.1),
          [Tree #if tree-name == "tree3" { $n$ } else { tree-name.last() }],
        )
      },
    )
  }

  // Draw main nodes
  content((0, 0), [Training Data], name: "training")
  content((0, 1), [Sample and Feature Bagging], name: "bagging")

  // Draw trees with different paths highlighted
  draw-tree(-6, "tree1", path-nodes: ("root", "left", "l1"))
  draw-tree(0, "tree2", path-nodes: ("root", "right", "r0"))
  draw-tree(6.75, "tree3", path-nodes: ("root", "right", "r2"))

  // Add dots between trees
  content((3.375, -3.5), text(size: 1.2em)[$dots.c$])

  // Draw mean/prediction nodes
  content(
    (0, -6.5),
    align(center)[Mean in regression or\ majority vote in classification],
    name: "mean",
    padding: (5pt, 5pt, 1.5pt),
  )
  content((0, -8), [Prediction], name: "pred", padding: (4pt, 5pt, 3pt))

  // Connect everything
  for tree in ("tree1", "tree2", "tree3") {
    line("training", tree + ".north", ..arrow-style)
    line(tree + ".south", "mean", ..arrow-style)
  }
  line("bagging", "training", ..arrow-style)
  line("mean", "pred", ..arrow-style)
})
