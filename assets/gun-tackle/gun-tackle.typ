#import "@preview/cetz:0.5.3"
#import cetz.draw: arc, content, get-ctx, line, merge-path, on-layer
#import cetz.vector: add, angle2, len, scale, sub

// Rope wound around pulleys, after pull-eh's `wind` (MIT, Clemens Koza), which only targets
// CeTZ <= 0.4. Each winding is a coordinate or (coord:, radius:) + cw/ccw; consecutive windings
// are joined by their common tangent and each pulley by the arc between its two tangents.
#let (cw, ccw) = ((direction: "cw"), (direction: "ccw"))
#let wind(..args) = get-ctx(ctx => {
  // signed radii: positive winds clockwise, negative counter-clockwise, 0 is a plain point
  let is-pulley(w) = type(w) == dictionary and "direction" in w
  let sign(w) = if w.direction == "ccw" { -1 } else { 1 }
  let radii = args.pos().map(w => if is-pulley(w) { sign(w) * w.radius } else { 0 })
  let coords = args.pos().map(w => if is-pulley(w) { w.coord } else { w })
  let (_, ..centers) = cetz.coordinate.resolve(ctx, ..coords)
  merge-path(..args.named(), {
    let prev-angle = none
    for ((c1, r1), (c2, r2)) in centers.zip(radii).windows(2) {
      // unit normal of the tangent: the center line's direction rotated by acos(-(r2 - r1) / d)
      let center-line = sub(c2, c1)
      let (dx, dy, _) = scale(center-line, 1 / len(center-line))
      let cos = -(r2 - r1) / len(center-line)
      let sin = calc.sqrt(1 - cos * cos)
      let normal = (dx * cos - dy * sin, dy * cos + dx * sin, 0)
      let (p1, p2) = (add(c1, scale(normal, r1)), add(c2, scale(normal, r2)))
      let angle = angle2(p1, p2)
      if prev-angle != none and r1 != 0 {
        // the arc's ends are normal to the incoming and outgoing tangents; clockwise arcs run
        // to decreasing angles, counter-clockwise ones to increasing angles
        let turn = if r1 > 0 { 90deg } else { -90deg }
        let (start, stop) = (prev-angle + turn, angle + turn)
        if r1 > 0 and stop > start { stop -= 360deg }
        if r1 < 0 and stop < start { stop += 360deg }
        arc(c1, anchor: "origin", radius: calc.abs(r1), start: start, stop: stop)
      }
      prev-angle = angle
      line(p1, p2)
    }
  })
})

#set page(width: auto, height: auto, margin: 5mm, fill: none)
#set text(size: 12pt)

#let tackle-block(coord, (w, h), ..args) = {
  // use the given coord as the center of the rect
  cetz.draw.rect((rel: (-w / 2, -h / 2), to: coord), (rel: (w, h)), fill: rgb("#cdd3da"), ..args)
}
#let fixing(coord, len) = {
  cetz.draw.line(stroke: 3pt, coord, (rel: len, to: coord))
  cetz.draw.circle(coord, fill: black, radius: 0.2)
}

#let tackle(separated: false) = cetz.canvas({
  let block1 = (4, 5.2)
  cetz.draw.circle((1, 4), radius: 1, fill: green, stroke: none, name: "pulley1")
  cetz.draw.circle(
    (if separated { 3 } else { 1 }, 0),
    radius: 1,
    fill: green,
    stroke: none,
    name: "pulley2",
  )

  on-layer(1, {
    if separated {
      fixing("pulley1.center", (0, 1.2))
      fixing("pulley2.center", (0, -1.2))
      line(stroke: 2pt, (rel: (-4.4, 0), to: block1), (rel: (0.4, 0), to: block1))
    } else {
      tackle-block(name: "block1", "pulley1", (0.4, 2.4))
      tackle-block(name: "block2", "pulley2", (0.4, 2.4))
      line(stroke: 2pt, (rel: (-1.4, 0), to: "block1.north"), (rel: (1.4, 0), to: "block1.north"))
    }
  })

  wind(
    stroke: 1.5pt,
    (rel: (if separated { -1.5 } else { 1.5 }, -2.5), to: "pulley1"),
    (coord: "pulley1", radius: 1) + (if separated { cw } else { ccw }),
    (coord: "pulley2", radius: 1) + ccw,
    if separated { block1 } else { "block1.south" },
  )

  on-layer(1, {
    let force-labels = if separated {
      ((3.4, -2), (1.4, -2), (-1.7, -1.5))
    } else { ((-1.4, -2), (-0.1, -2), (1.7, -1.5)) }
    for rel in force-labels { content((rel: rel, to: "pulley1"))[50N] }

    // every force arrow is captioned with its magnitude just to its right
    let mark = (end: (symbol: ">", length: 0.12cm, width: 0.15cm))
    for (coord, angle, label, offset) in (
      ((rel: (if separated { 1.5 } else { 0 }, 0.4), to: "pulley1.north"), 90deg, [150N], 0.7),
      ((rel: (0, -0.4), to: "pulley2.south"), -90deg, [100N], 0.7),
      (
        (rel: (if separated { -1.54 } else { 1.54 }, -2.7), to: "pulley1"),
        if separated { -102deg } else { -78deg },
        [50N],
        0.65,
      ),
    ) {
      line(coord, (rel: (angle, 0.8)), stroke: 4pt, mark: mark, name: "force")
      content((rel: (offset, 0), to: "force"))[#label]
    }
  })
})

#grid(
  columns: 2,
  column-gutter: 2cm,
  tackle(), tackle(separated: true),
)
