#import "@preview/cetz:0.5.2": canvas, decorations, draw
#import draw: bezier, content, line, rect

#set page(width: auto, height: auto, margin: 8pt)

#canvas({
  let arrow = (mark: (end: "stealth", fill: black, scale: .55), stroke: .9pt)
  let heavy = (mark: (end: "stealth", fill: black, scale: .65), stroke: 1.3pt)
  let panel-w = 1.65
  let marker-w = .65
  let y-box = -3.9
  let state-gap = 4.8
  let x0 = 0
  let x1 = state-gap
  let x2 = 2 * state-gap
  let west-rim(x) = (x - .03, y-box + panel-w / 2)

  let wave-arrow(start, end, segments: 8, straight-end: .18) = {
    let direction = (end.at(0) - start.at(0), end.at(1) - start.at(1))
    let distance = calc.sqrt(direction.at(0) * direction.at(0) + direction.at(1) * direction.at(1))
    let straight-start = (
      end.at(0) - straight-end * direction.at(0) / distance,
      end.at(1) - straight-end * direction.at(1) / distance,
    )
    decorations.wave(line(start, straight-start), amplitude: .035, segments: segments, stroke: .9pt)
    line(straight-start, end, ..arrow)
  }
  let transition(start, end, ctrl-1, ctrl-2, label-pos, label) = {
    bezier(start, end, ctrl-1, ctrl-2, ..heavy)
    content(label-pos, label, anchor: "east", fill: white, padding: 2pt)
  }
  let state(x, idx, q, action, reward, reward-label, mark-pos, wiggle-x, dollar-pos) = {
    let id = "s" + str(idx)
    let mid = x + panel-w / 2
    let marker = (x + mark-pos.at(0), y-box + mark-pos.at(1))
    let panel = ((x, y-box), (x + panel-w, y-box + panel-w))
    let panel-name = id + "-panel"
    let panel-sw = panel-name + ".south-west"
    let policy = id + "-policy"
    let reward-arrow = id + "-reward"
    rect(panel.at(0), panel.at(1), stroke: none, fill: rgb("#f5f5f5"), name: panel-name)
    rect(
      (rel: mark-pos, to: panel-sw),
      (rel: (mark-pos.at(0) + marker-w, mark-pos.at(1) + marker-w), to: panel-sw),
      fill: rgb("#aaaaff"),
      stroke: none,
    )
    rect(panel.at(0), panel.at(1), stroke: 1.2pt, fill: none)
    content((rel: dollar-pos, to: panel-sw), text(fill: green)[\$ \$], anchor: "center")
    content((rel: (0, -.28), to: panel-name + ".south"), $s_#idx$, anchor: "north")

    line(panel-name + ".north", (rel: (0, 1.6), to: panel-name + ".north"), ..heavy, name: policy)
    content((rel: (-.55, -.8), to: policy + ".end"), $pi_theta(s_#idx)$, anchor: "east")
    content((rel: (0, .2), to: policy + ".end"), q, anchor: "south")

    wave-arrow((mid + wiggle-x, y-box + 3.85), (mid, y-box + 4.95))
    content((rel: (0, 1.8), to: policy + ".end"), action, anchor: "south")
    line((rel: (0, 2.2), to: policy + ".end"), (rel: (0, 3.1), to: policy + ".end"), ..heavy, name: reward-arrow)
    content((rel: (-.5, .05), to: reward-arrow + ".mid"), reward-label, anchor: "east")
    content((rel: (0, .25), to: reward-arrow + ".end"), reward, anchor: "south")
  }

  state(x0, 0, $[0.12, bold(0.64), 0.07, 0.17]$, [up], $r_0 = 0$, $cal(R)(s_0, "↑")$, (0, 0), -.35, (1.18, 1.24))
  state(
    x1,
    1,
    $[0.03, 0.24, bold(0.47), 0.26]$,
    [right],
    $r_1 = 0$,
    $cal(R)(s_1, "→")$,
    (0, panel-w - marker-w),
    .35,
    (1.18, 1.24),
  )
  state(
    x2,
    2,
    $[bold(0.82), 0.04, 0.08, 0.06]$,
    [pick up],
    $r_2 = 2$,
    $cal(R)(s_2, "⋆")$,
    (panel-w - marker-w, panel-w - marker-w),
    -.65,
    (panel-w - marker-w / 2, panel-w - marker-w / 2),
  )

  transition((1.35, 1.10), west-rim(x1), (3.65, 1.10), (3.55, -3.0), (x1 - .25, -3.18), $cal(T)(s_0, "↑")$)
  transition(
    (x1 + 1.35, 1.10),
    west-rim(x2),
    (x1 + 3.65, 1.10),
    (x1 + 3.55, -3.0),
    (x2 - .25, -3.18),
    $cal(T)(s_1, "→")$,
  )
})
