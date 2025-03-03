#import "@preview/cetz:0.3.3": canvas, draw
#import draw: line, content, circle, rect, group, set-style, on-layer

#set page(width: auto, height: auto, margin: 8pt)

// TODO add arrows next to each connecting line between red nodes

// Define styles and constants
#let arrow-style = (
  mark: (end: "stealth", fill: black, scale: 0.5),
  stroke: 0.5pt,
)
#let line-style = (stroke: 0.5pt)
#let red-arrow-style = (
  stroke: red,
  fill: red,
  mark: (end: "stealth", scale: 0.6, offset: 0.2, start: (symbol: "|", width: 1pt)),
  stroke-width: 1.2pt,
)
#let node-box-style = (
  stroke: 0.3pt,
  fill: white,
  radius: 3pt,
)
#let tree-box-style = (
  stroke: 0.3pt,
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
  let tree-node(position, fill: blue.lighten(40%), name: none) = {
    circle(position, radius: 0.2, fill: fill, stroke: 0.3pt, name: name)
  }

  // Helper function to draw a complete tree
  let draw-tree(x-position, tree-name, path-nodes: ()) = {
    let y-position = -2
    let level-spacing = 1.2 // Vertical spacing between levels
    let node-spacing = 1.0 // Base horizontal spacing between nodes
    let arrow-offset = 0.15 // Offset for red arrows

    group(
      name: tree-name,
      {
        // Root node (level 0)
        tree-node(
          (x-position, y-position),
          name: "root",
          fill: if "root" in path-nodes { red.lighten(30%) } else { blue.lighten(40%) },
        )

        // Level 1 nodes (2 nodes, evenly spaced)
        tree-node(
          (x-position - node-spacing, y-position - level-spacing),
          name: "left",
          fill: if "left" in path-nodes { red.lighten(30%) } else { blue.lighten(40%) },
        )
        tree-node(
          (x-position + node-spacing, y-position - level-spacing),
          name: "right",
          fill: if "right" in path-nodes { red.lighten(30%) } else { blue.lighten(40%) },
        )

        // Connect nodes with black lines
        line("root", "left", ..line-style)
        line("root", "right", ..line-style)

        // Add red arrows for paths
        if "root" in path-nodes and "left" in path-nodes {
          line(
            (x-position - arrow-offset, y-position),
            (x-position - node-spacing - arrow-offset, y-position - level-spacing),
            ..red-arrow-style,
          )
        }
        if "root" in path-nodes and "right" in path-nodes {
          line(
            (x-position + arrow-offset, y-position),
            (x-position + node-spacing + arrow-offset, y-position - level-spacing),
            ..red-arrow-style,
          )
        }

        // Level 2 nodes - different structure for each tree
        if tree-name == "tree1" {
          // Tree 1: left node splits into 3, right into 1
          let left-spacing = node-spacing * 0.67 // Tighter spacing for 3 nodes
          for (node-idx, offset-factor) in (-1, 0, 1).enumerate() {
            let child-x = x-position - node-spacing + offset-factor * left-spacing
            let child-y = y-position - 2 * level-spacing
            let node-name = "l" + str(node-idx)

            tree-node(
              (child-x, child-y),
              name: node-name,
              fill: if node-name in path-nodes { red.lighten(30%) } else { blue.lighten(40%) },
            )
            // Black line
            line("left", node-name, ..line-style)
            // Red arrow if in path
            if "left" in path-nodes and node-name in path-nodes {
              // Determine offset direction based on node position
              let offset-direction = if offset-factor < 0 { -arrow-offset } else { arrow-offset }
              line(
                (x-position - node-spacing + offset-direction, y-position - level-spacing),
                (child-x + offset-direction, child-y),
                ..red-arrow-style,
              )
            }
          }
          // Right side
          let right-child-x = x-position + node-spacing
          let right-child-y = y-position - 2 * level-spacing
          tree-node(
            (right-child-x, right-child-y),
            name: "r0",
            fill: if "r0" in path-nodes { red.lighten(30%) } else { blue.lighten(40%) },
          )
          line("right", "r0", ..line-style)
          if "right" in path-nodes and "r0" in path-nodes {
            line(
              (x-position + node-spacing + arrow-offset, y-position - level-spacing),
              (right-child-x + arrow-offset, right-child-y),
              ..red-arrow-style,
            )
          }
        } else if tree-name == "tree2" {
          // Tree 2: left node splits into 2, right into 2
          let side-spacing = node-spacing * 0.5 // Half spacing for 2 nodes each side
          for (node-idx, offset-factor) in (-1, 1).enumerate() {
            let child-x = x-position - node-spacing + offset-factor * side-spacing
            let child-y = y-position - 2 * level-spacing
            let node-name = "l" + str(node-idx)

            tree-node(
              (child-x, child-y),
              name: node-name,
              fill: if node-name in path-nodes { red.lighten(30%) } else { blue.lighten(40%) },
            )
            // Black line
            line("left", node-name, ..line-style)
            // Red arrow if in path
            if "left" in path-nodes and node-name in path-nodes {
              // Determine offset direction based on node position
              let offset-direction = if offset-factor < 0 { -arrow-offset } else { arrow-offset }
              line(
                (x-position - node-spacing + offset-direction, y-position - level-spacing),
                (child-x + offset-direction, child-y),
                ..red-arrow-style,
              )
            }
          }
          for (node-idx, offset-factor) in (-1, 1).enumerate() {
            let child-x = x-position + node-spacing + offset-factor * side-spacing
            let child-y = y-position - 2 * level-spacing
            let node-name = "r" + str(node-idx)

            tree-node(
              (child-x, child-y),
              name: node-name,
              fill: if node-name in path-nodes { red.lighten(30%) } else { blue.lighten(40%) },
            )
            // Black line
            line("right", node-name, ..line-style)
            // Red arrow if in path
            if "right" in path-nodes and node-name in path-nodes {
              // Determine offset direction based on node position
              let offset-direction = if offset-factor < 0 { -arrow-offset } else { arrow-offset }
              line(
                (x-position + node-spacing + offset-direction, y-position - level-spacing),
                (child-x + offset-direction, child-y),
                ..red-arrow-style,
              )
            }
          }
        } else {
          // Tree 3: left node splits into 1, right into 3
          let left-child-x = x-position - node-spacing
          let left-child-y = y-position - 2 * level-spacing
          tree-node(
            (left-child-x, left-child-y),
            name: "l0",
            fill: if "l0" in path-nodes { red.lighten(30%) } else { blue.lighten(40%) },
          )
          line("left", "l0", ..line-style)
          if "left" in path-nodes and "l0" in path-nodes {
            line(
              (x-position - node-spacing - arrow-offset, y-position - level-spacing),
              (left-child-x - arrow-offset, left-child-y),
              ..red-arrow-style,
            )
          }

          let right-spacing = node-spacing * 0.67 // Tighter spacing for 3 nodes
          for (node-idx, offset-factor) in (-1, 0, 1).enumerate() {
            let child-x = x-position + node-spacing + offset-factor * right-spacing
            let child-y = y-position - 2 * level-spacing
            let node-name = "r" + str(node-idx)

            tree-node(
              (child-x, child-y),
              name: node-name,
              fill: if node-name in path-nodes { red.lighten(30%) } else { blue.lighten(40%) },
            )
            // Black line
            line("right", node-name, ..line-style)
            // Red arrow if in path
            if "right" in path-nodes and node-name in path-nodes {
              // Determine offset direction based on node position
              let offset-direction = if offset-factor < 0 { -arrow-offset } else { arrow-offset }
              line(
                (x-position + node-spacing + offset-direction, y-position - level-spacing),
                (child-x + offset-direction, child-y),
                ..red-arrow-style,
              )
            }
          }
        }

        // Tree box and label (made slightly wider)
        rect(
          (x-position - 2.6, y-position - 2.6 * level-spacing),
          (x-position + 2.6, y-position + 0.5),
          stroke: 0.3pt,
          fill: none,
          radius: 3pt,
          name: tree-name,
        )
        content(
          (x-position - 1.7, y-position + 0.1),
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
  for tree-name in ("tree1", "tree2", "tree3") {
    line("training", tree-name + ".north", ..arrow-style)
    line(tree-name + ".south", "mean", ..arrow-style)
  }
  line("bagging", "training", ..arrow-style)
  line("mean", "pred", ..arrow-style)
})
