#import "@preview/cetz:0.5.2": canvas, draw
#import draw: arc, circle, content, line, rect, rotate, scope, translate
#import "../_shared/theme.typ": neutral

// === palette ===

// Opt-in dark palette for slide decks: compile with `--input dark=true`. Everything the
// collection commits is the light variant; the dark one exists only so this figure can go
// on a dark slide without the ink disappearing into the background.
#let dark = sys.inputs.at("dark", default: "false") == "true"

// Annotation and hairline greys have to flip with the background; `theme.neutral` is tuned
// for white and is unreadable on near-black.
#let ink = if dark { (annotation: rgb("#B9C3CE"), hairline: rgb("#8A94A0")) } else { neutral }

// Up red / down blue is the convention in spin-resolved band plots and DFT output, so it
// wins over the collection's series palette here. The dark variants keep the same hues but
// lift lightness, since the light ones are tuned for contrast against white.
#let spin-up = if dark { rgb("#F4586D") } else { rgb("#C0182B") }
#let spin-down = if dark { rgb("#4C9BF5") } else { rgb("#0B5FA5") }
#let atom-a = if dark { rgb("#D4707C") } else { rgb("#B8434F") }
#let atom-b = if dark { rgb("#6B9BD6") } else { rgb("#3A6EA8") }
#let atom-inert = rgb("#9AA4AE")
#let ligand-color = if dark { rgb("#6FBF7C") } else { rgb("#5FA86B") }

#let spin-paint(angle) = if calc.sin(angle) >= 0 { spin-up } else { spin-down }

// Solid for the up channel, dashed for the down channel, so a degenerate pair drawn one on
// top of the other still reads as two curves.
#let up-stroke = (paint: spin-up, thickness: 1.4pt)
#let down-stroke = (paint: spin-down, thickness: 1.4pt, dash: (2.2pt, 1.7pt))

// === real-space primitives ===

// Centered small print for panel captions. Pass `width` to make long captions wrap inside
// their panel instead of running out past its frame; 1 canvas unit is 1cm.
#let caption-text(body, width: auto) = text(
  size: 8.5pt,
  fill: ink.annotation,
  box(width: width, align(center, par(leading: 0.5em, body))),
)

// `angle` is measured from +x, so 90deg points up.
#let spin(pos, angle, len: 0.6, paint: auto, thickness: 1.4pt, mark-scale: 0.36) = {
  let paint = if paint == auto { spin-paint(angle) } else { paint }
  let (dx, dy) = (calc.cos(angle) * len / 2, calc.sin(angle) * len / 2)
  line(
    (pos.at(0) - dx, pos.at(1) - dy),
    (pos.at(0) + dx, pos.at(1) + dy),
    stroke: (paint: paint, thickness: thickness, cap: "round"),
    mark: (end: "stealth", fill: paint, stroke: paint, scale: mark-scale),
  )
}

#let atom(pos, color, radius: 0.15, stroke-width: 0.3pt) = circle(
  pos,
  radius: radius,
  stroke: stroke-width + color.darken(35%),
  fill: gradient.radial(
    color.lighten(70%),
    color,
    color.darken(20%),
    focal-center: (32%, 26%),
    focal-radius: 8%,
  ),
)

#let moment-site(pos, angle, len: 0.62, radius: 0.15, color: atom-inert) = {
  atom(pos, color, radius: radius)
  spin(pos, angle, len: len)
}

// Closed-shell site: the paired spins cancel, so the atom carries no permanent moment.
#let paired-site(pos, radius: 0.24, len: 0.38, offset: 0.1) = {
  atom(pos, atom-inert, radius: radius)
  for (dx, angle) in ((-offset, 90deg), (offset, -90deg)) {
    spin((pos.at(0) + dx, pos.at(1)), angle, len: len, thickness: 1pt, mark-scale: 0.25)
  }
}

// Two ligands on an axis through the site: the projected elongation axis of an octahedron
// seen down [001], not a full cage. Turning this axis by 90deg between the two sublattices
// is what removes the translation and inversion links; together with compensated collinear
// order, that is what leaves only a rotation and makes the crystal altermagnetic.
#let ligand-cage(pos, angle, half-len: 0.36, radius: 0.08) = {
  let (cx, cy) = (pos.at(0), pos.at(1))
  let (dx, dy) = (calc.cos(angle) * half-len, calc.sin(angle) * half-len)
  line((cx - dx, cy - dy), (cx + dx, cy + dy), stroke: 0.5pt + ligand-color.darken(10%))
  atom((cx - dx, cy - dy), ligand-color, radius: radius)
  atom((cx + dx, cy + dy), ligand-color, radius: radius)
}

// Typst has no RNG at compile time, so the disordered paramagnetic supercell uses a hash.
// The seed is not arbitrary: it was picked so that the supercell sums to under 5% of its
// saturation moment. A caption claiming the moments compensate has to be true of the
// arrangement actually on the page, and the obvious seeds are not -- the first one tried
// left a 23% net moment pointing visibly up and to the right.
#let pseudo-random(col-idx, row-idx) = {
  let val = calc.sin((col-idx + 164) * 12.9898 + row-idx * 78.233) * 43758.5453
  val - calc.floor(val)
}

// === curves ===

#let plot-curve(func, sx, sy, stroke: 1pt) = {
  let samples = 90
  let pts = range(samples + 1).map(idx => {
    let t = -1 + 2 * idx / samples
    (t * sx, func(t) * sy)
  })
  line(..pts, stroke: stroke)
}

// Both M(H) helpers return the (function, stroke) pairs `plot-curve` consumes, so a response
// panel is just a list of branches and knows nothing about which order it is drawing.

// Clamped straight line: the linear, remanence-free response of everything that is not a
// ferro- or ferrimagnet. A negative slope is a diamagnet.
#let linear-response(slope) = (
  (
    h => calc.max(-1.0, calc.min(1.0, slope * h)),
    (paint: ink.annotation, thickness: 1.2pt),
  ),
)

// Two tanh branches offset by the coercive field: the textbook hysteresis loop.
#let hysteresis(m-sat, coercive) = {
  let stroke = (paint: spin-up, thickness: 1.2pt)
  let branch(shift) = (h => m-sat * calc.tanh((h + shift) / 0.16), stroke)
  (branch(coercive), branch(-coercive))
}

// === reciprocal-space spin-splitting maps ===

// Spin-splitting form factors, all bounded by 1 over the zone.
//
// The altermagnetic one is the lattice-periodic d_xy form. The bare k_x k_y of the k.p
// expansion is only valid near Gamma: it is not periodic, so it would hand the equivalent
// zone corners (pi, pi) and (pi, -pi) opposite splittings. sin k_x sin k_y is still odd
// under C4 and even under inversion, and it correctly forces Delta to vanish on the k_x and
// k_y axes and on the zone boundary.
#let dwave(kx, ky) = calc.sin(calc.pi * kx) * calc.sin(calc.pi * ky)
// Uniform and negative because the majority (up) channel of a ferromagnet sits below the
// minority one at every k, so Delta = E_up - E_down keeps one sign across the zone.
#let swave(kx, ky) = -0.9
#let no-splitting(kx, ky) = 0.0

// Coarse raster of the 2D Brillouin zone tinted by `form`, which takes k in units of pi and
// must return a value in [-1, 1]. A cheap stand-in for a filled contour plot that stays
// legible at figure size. Red means the up channel sits higher in energy, blue the down
// channel. `cells` trades smoothness for SVG size: a map that varies with k costs one rect
// per cell, so raising it eats into the collection's 500 kB SVG budget quadratically.
#let splitting-map(form, size: 2.0, cells: 22) = {
  let step = size / cells
  let corner = -size / 2
  let grid = range(cells).map(row-idx => {
    let ky = -1 + (row-idx + 0.5) * 2 / cells
    range(cells).map(col-idx => form(-1 + (col-idx + 0.5) * 2 / cells, ky))
  })
  // Runs of equal-valued cells are emitted as a single rect, merged first across identical
  // rows and then along each row. Two reasons: the tiles are semi-transparent, so every
  // internal seam between two abutting tiles darkens into a visible hairline, and each tile
  // costs SVG bytes the collection's 500 kB budget cannot spare. A map with no k dependence
  // (s-wave) collapses to one rect; a d-wave map has no equal neighbors and is untouched.
  let row-start = 0
  for row-idx in range(cells) {
    if row-idx == cells - 1 or grid.at(row-idx + 1) != grid.at(row-idx) {
      let vals = grid.at(row-idx)
      let start = 0
      for col-idx in range(cells) {
        if col-idx == cells - 1 or vals.at(col-idx + 1) != vals.at(col-idx) {
          let val = vals.at(col-idx)
          // Skip tiles below visibility: the unsplit map would otherwise emit a full grid of
          // fully transparent rects, and every one of them costs SVG bytes for nothing.
          if calc.abs(val) > 0.005 {
            let paint = if val >= 0 { spin-up } else { spin-down }
            rect(
              (corner + start * step, corner + row-start * step),
              (corner + (col-idx + 1) * step, corner + (row-idx + 1) * step),
              stroke: none,
              fill: paint.transparentize(100% - 80% * calc.abs(val)),
            )
          }
          start = col-idx + 1
        }
      }
      row-start = row-idx + 1
    }
  }
  rect((corner, corner), (-corner, -corner), stroke: 0.6pt + ink.annotation)
}

// === page setup ===

// Committed assets are the light variant. The dark one is for slide decks and is rendered
// on demand with `typst compile --input dark=true`; it is not part of the collection.
#let page-fill = if dark { rgb("#0D1117") } else { none }

#set page(width: auto, height: auto, margin: 8pt, fill: page-fill)
// Titles and axis labels inherit this, so they have to flip with the background.
#set text(font: "New Computer Modern", fill: if dark { rgb("#E6EDF3") } else { black })

#let mark-to(color, scale: 0.4) = (end: "stealth", fill: color, stroke: color, scale: scale)
#let hairline = (paint: ink.hairline, thickness: 0.5pt)
#let axis-stroke = (paint: ink.hairline, thickness: 0.7pt)
#let annotate = (paint: ink.annotation, thickness: 0.9pt)
#let annotate-mark = mark-to(ink.annotation)
#let frame-stroke = 0.6pt + (if dark { rgb("#39424E") } else { rgb("#C3CAD2") })

// Landscape matrix so the figure drops onto a 16:9 slide: the three orders that are never
// mistaken for an altermagnet stack down a narrow left column, and the three collinear orders
// run as rows against the four observables that tell them apart.
#let row-y = (3.76, 0.0, -3.76)
#let frame-half = 1.84
// panels sit slightly high in their row so the note below them has room
#let panel-rise = 0.38
#let note-drop = 0.98
#let (side-x, side-half) = (-8.5, 2.15)
#let side-text-width = (2 * side-half - 0.3) * 1cm
#let label-x = -5.8
#let label-width = 4.0cm
// The four observables the collinear rows are compared across: column center, header, and the
// note width each one may use. The widths overlap the gutters slightly, which is fine as no
// two notes collide.
#let obs-columns = (
  (x: 0.5, header: [real-space structure], note-width: 3.6cm),
  (x: 4.0, header: [response $M(H)$], note-width: 2.9cm),
  (x: 7.9, header: [spin-resolved bands], note-width: 3.8cm),
  (x: 11.65, header: [spin splitting $Delta(bold(k))$], note-width: 3.0cm),
)
#let (right-x0, right-x1) = (-6.05, 13.3)
#let right-mid = (right-x0 + right-x1) / 2

#let cell-frame(x0, x1, y) = rect(
  (x0, y - frame-half),
  (x1, y + frame-half),
  stroke: frame-stroke,
  radius: 0.12,
)

// === Magnetization response M(H) ===

// Small enough to sit beside a real-space icon in the strip and still be legible in a column.
#let response-cell(branches, sx: 0.85, sy: 0.6) = {
  let tip = mark-to(ink.annotation, scale: 0.3)
  line((-sx - 0.12, 0), (sx + 0.18, 0), stroke: axis-stroke, mark: tip)
  line((0, -sy - 0.12), (0, sy + 0.18), stroke: axis-stroke, mark: tip)
  content((sx + 0.28, -0.02), text(size: 8pt, fill: ink.annotation)[$H$])
  content((-0.1, sy + 0.28), text(size: 8pt, fill: ink.annotation)[$M$], anchor: "east")
  for (func, stroke) in branches {
    plot-curve(func, sx, sy, stroke: stroke)
  }
}

// === Top strip: the three orders that nobody confuses with an altermagnet ===

// Closed shells, so the only response is the induced orbital moment opposing the applied
// field. Drawn in the annotation grey, not a spin color: it is orbital, and the paired
// arrows on the sites are spins.
#let dia-icon = {
  for col-idx in range(3) {
    paired-site((-1.0 + col-idx * 0.48, 0), radius: 0.18, len: 0.28, offset: 0.075)
  }
  line(
    (0.62, -0.52),
    (0.62, 0.52),
    stroke: 2pt + ink.hairline,
    mark: mark-to(ink.hairline, scale: 0.42),
  )
  content((0.62, 0.72), text(size: 8.5pt, fill: ink.annotation)[$bold(B)$])
  spin((1.12, 0.06), -90deg, len: 0.5, paint: ink.annotation, thickness: 1.2pt)
  content((1.14, -0.44), text(size: 7.5pt, fill: ink.annotation)[$bold(m)_"orb"$])
}

// The dashed box is load-bearing: it says the vanishing moment is a supercell average, not
// an absence of moments.
#let para-icon = {
  rect(
    (-1.0, -0.58),
    (1.0, 0.58),
    stroke: (paint: ink.hairline, dash: "dashed", thickness: 0.5pt),
  )
  for col-idx in range(6) {
    for row-idx in range(3) {
      spin(
        ((col-idx - 2.5) * 0.32, (row-idx - 1) * 0.34),
        pseudo-random(col-idx, row-idx) * 360deg,
        len: 0.26,
        thickness: 0.9pt,
        mark-scale: 0.2,
      )
    }
  }
}

#let ferri-icon = {
  for col-idx in range(4) {
    for row-idx in range(2) {
      let pos = ((col-idx - 1.5) * 0.46, (row-idx - 0.5) * 0.54)
      if calc.even(col-idx + row-idx) {
        moment-site(pos, 90deg, len: 0.46, radius: 0.13, color: atom-a)
      } else {
        moment-site(pos, -90deg, len: 0.25, radius: 0.09, color: atom-b)
      }
    }
  }
}

// === The three collinear orders, told apart by their spin splitting ===

#let cell = 0.95
// The checkerboard of moments plus ligand axes that the ferromagnet, antiferromagnet and
// altermagnet panels all draw; they differ only in `cage-of` and `moment-of`, which is the
// point -- two independent switches, one on the spin pattern and one on the ligand geometry.
// 4x2 rather than a square patch: the even site count makes the drawn crop compensate
// exactly (an odd one would show a net moment while the caption claims M = 0), two rows
// still make the alternation and both cage orientations legible, and the four columns of
// this figure are wide enough already.
#let crystal(cage-of, moment-of: up => if up { 90deg } else { -90deg }) = {
  for col-idx in range(4) {
    for row-idx in range(2) {
      let pos = ((col-idx - 1.5) * cell, (row-idx - 0.5) * cell)
      let up = calc.even(col-idx + row-idx)
      ligand-cage(pos, cage-of(up))
      moment-site(pos, moment-of(up), len: 0.52, radius: 0.13)
    }
  }
}

#let (band-sx, band-sy) = (1.9, 0.9)

// `split-at` places a double arrow between the two spin channels at that point on the
// path. Measuring the gap from the band functions themselves keeps the arrow pinned to
// the curves instead of to coordinates that go stale the moment a dispersion changes.
#let band-panel(bands, split-at: none) = {
  rect((-band-sx, -band-sy), (band-sx, band-sy), stroke: 0.6pt + ink.hairline)
  line((0, -band-sy), (0, band-sy), stroke: hairline)
  line((-band-sx, 0), (band-sx, 0), stroke: (..hairline, dash: "dashed"))
  content((band-sx + 0.3, 0), text(size: 8.5pt, fill: ink.annotation)[$E_F$])
  content(
    (-band-sx - 0.06, band-sy + 0.04),
    text(size: 9pt, fill: ink.annotation)[$E$],
    anchor: "south-east",
  )
  for (func, stroke) in bands {
    plot-curve(func, band-sx, band-sy, stroke: stroke)
  }
  // Labeled by direction rather than by high-symmetry point: the zone corners reached
  // along the two diagonals differ by a reciprocal lattice vector and are the same k point,
  // so naming them M and M' would imply an inequivalence that does not exist.
  for (x, glyph) in ((-band-sx, $(-k, k)$), (0, $Gamma$), (band-sx, $(k, k)$)) {
    content((x, -band-sy - 0.08), text(size: 8.5pt, fill: ink.annotation, glyph), anchor: "north")
  }
  if split-at != none {
    let ys = bands.map(band => band.at(0)(split-at) * band-sy)
    let (upper, lower) = (calc.max(..ys), calc.min(..ys))
    let x = split-at * band-sx
    line(
      (x, lower),
      (x, upper),
      stroke: annotate,
      mark: (..mark-to(ink.annotation, scale: 0.35), start: "stealth"),
    )
    content(
      (x + 0.16, (upper + lower) / 2),
      text(size: 9pt, fill: ink.annotation)[$Delta$],
      anchor: "west",
    )
  }
}

#let metal(s) = -0.6 * calc.cos(calc.pi * s)
// Exchange splitting of a ferromagnet: rigid, so it does not depend on k at all.
#let ferro-split = 0.5
// The periodic d_xy form sin(k_x) sin(k_y) walked out along k = (pi|s|, pi s): zero at
// Gamma and at the zone edge, opposite sign on the two C4-related diagonals.
#let alter-split(s) = 0.58 * calc.sin(calc.pi * calc.abs(s)) * calc.sin(calc.pi * s)

// The two spin channels' Fermi contours. Free-electron d_xy altermagnet:
// (k_x^2 + k_y^2)/2m + sigma alpha k_x k_y is constant, i.e. an ellipse whose major axis lies
// along the diagonal on which that spin channel is pushed down in energy. Spin up gets
// alpha k_x k_y > 0 in the first quadrant, so its contour is pinched along [110] and stretched
// along [1-10]. Tilting the two by -/+ `tilt` makes them 90deg rotations of each other by
// construction rather than by two hand-written angles that could drift apart.
#let fermi-pair(up-radius, down-radius, tilt: 0deg) = {
  for (stroke, radius, sign) in ((up-stroke, up-radius, -1), (down-stroke, down-radius, 1)) {
    scope({
      rotate(sign * tilt)
      circle((0, 0), radius: radius, stroke: stroke)
    })
  }
}

#let bz-size = 1.92
#let bz-panel(form, contours, nodal: false) = {
  splitting-map(form, size: bz-size, cells: 20)
  if nodal {
    let dashed = (paint: ink.annotation, thickness: 0.9pt, dash: "dashed")
    line((-bz-size / 2, 0), (bz-size / 2, 0), stroke: dashed)
    line((0, -bz-size / 2), (0, bz-size / 2), stroke: dashed)
  }
  content(
    (0, 0),
    text(size: 8pt, fill: ink.annotation)[$Gamma$],
    frame: "rect",
    fill: if dark { page-fill } else { white },
    stroke: none,
    padding: 0.5pt,
  )
  contours
  content((bz-size / 2 + 0.22, 0), text(size: 8.5pt)[$k_x$])
  content((0, bz-size / 2), text(size: 8.5pt)[$k_y$], anchor: "south")
}

#canvas({
  // === left column: the three orders nobody confuses with an altermagnet ===
  // Icon and its M(H) response side by side, so each cell is short enough that three of them
  // stack level with the three rows on the right.
  let side = (
    (
      [Diamagnetism],
      dia-icon,
      linear-response(-0.3),
      [$bold(m)_"orb"$ opposes $bold(B)$, so $chi < 0$ \ closed shells, $|chi| tilde 10^(-5)$],
    ),
    (
      [Paramagnetism],
      para-icon,
      linear-response(0.8),
      [disordered moments, $chevron.l bold(m) chevron.r = 0$ \ $chi = C \/ T tilde 10^(-3) > 0$],
    ),
    (
      [Ferrimagnetism],
      ferri-icon,
      hysteresis(0.55, 0.3),
      [antiparallel but $|bold(m)_A| != |bold(m)_B|$ \ $M_s = |bold(M)_A + bold(M)_B| != 0$],
    ),
  )
  for (idx, (name, icon, branches, note)) in side.enumerate() {
    let y = row-y.at(idx)
    cell-frame(side-x - side-half, side-x + side-half, y)
    content((side-x, y + 1.44), text(weight: "bold", size: 11.5pt, name))
    scope({
      translate((side-x - 0.88, y + 0.16))
      icon
    })
    scope({
      translate((side-x + 1.05, y + 0.16))
      response-cell(branches, sx: 0.6, sy: 0.44)
    })
    content((side-x, y - 0.66), caption-text(note, width: side-text-width), anchor: "north")
  }

  // === ferromagnet / antiferromagnet / altermagnet ===
  // Same lattice in all three; only two switches change, the spin pattern and whether the
  // ligand axes of the two sublattices agree.
  let orders = (
    (
      name: [Ferromagnetism],
      subtitle: [one sublattice, every moment parallel],
      structure: crystal(up => 45deg, moment-of: up => 90deg),
      structure-note: [identical ligand axes],
      branches: hysteresis(0.86, 0.34),
      response-note: [hysteretic, $M_r != 0$],
      bands: (
        (s => metal(s) - ferro-split / 2, up-stroke),
        (s => metal(s) + ferro-split / 2, down-stroke),
      ),
      split-at: 0.5,
      band-note: [rigid $s$-wave split, same sign at every $bold(k)$],
      form: swave,
      nodal: false,
      contours: fermi-pair(0.76, 0.46),
      bz-note: [concentric contours, majority larger],
    ),
    (
      name: [Antiferromagnetism],
      subtitle: [sublattices related by a translation $bold(t)$, or by inversion],
      structure: {
        crystal(up => 45deg)
        let t-y = -0.5 * cell - 0.5
        line((-1.5 * cell, t-y), (-0.5 * cell, t-y), stroke: annotate, mark: annotate-mark)
        content(
          (-1.5 * cell - 0.12, t-y),
          text(size: 9.5pt, fill: ink.annotation)[$bold(t)$],
          anchor: "east",
        )
      },
      structure-note: [identical ligand axes],
      branches: linear-response(0.4),
      response-note: [linear, no remanence],
      bands: ((metal, up-stroke), (metal, down-stroke)),
      split-at: none,
      band-note: [$E_arrow.t (bold(k)) = E_arrow.b (bold(k))$ everywhere],
      form: no-splitting,
      nodal: false,
      contours: fermi-pair(0.6, 0.6),
      bz-note: [one doubly degenerate contour],
    ),
    (
      name: [Altermagnetism],
      subtitle: [sublattices related only by a $C_4$ rotation],
      structure: {
        crystal(up => if up { 45deg } else { -45deg })
        arc(
          (0, 0),
          start: 200deg,
          stop: 70deg,
          radius: 0.35,
          anchor: "origin",
          stroke: annotate,
          mark: annotate-mark,
        )
        content((0, 0), text(size: 9pt, fill: ink.annotation)[$C_4$])
      },
      structure-note: [ligand axes rotated $90degree$],
      branches: linear-response(0.4),
      response-note: [identical to the antiferromagnet],
      bands: (
        (s => metal(s) + alter-split(s) / 2, up-stroke),
        (s => metal(s) - alter-split(s) / 2, down-stroke),
      ),
      split-at: 0.5,
      band-note: [$Delta$ flips between the $C_4$-related diagonals],
      form: dwave,
      nodal: true,
      contours: fermi-pair((0.78, 0.44), (0.78, 0.44), tilt: 45deg),
      bz-note: [$Delta prop sin k_x sin k_y$, nodal on axes],
    ),
  )

  let (banner-y, header-y) = (6.75, 5.85)
  content(
    (right-mid, banner-y),
    text(size: 9pt, fill: ink.annotation)[
      all three rows are collinear; $M(H)$ singles out the ferromagnet, and only the spin
      splitting $Delta(bold(k)) = E_arrow.t (bold(k)) - E_arrow.b (bold(k))$ separates the other two
    ],
  )
  for col in obs-columns {
    content((col.x, header-y), text(weight: "bold", size: 9.5pt, col.header))
  }

  for (idx, order) in orders.enumerate() {
    let y = row-y.at(idx)
    cell-frame(right-x0, right-x1, y)
    content(
      (label-x, y),
      box(width: label-width)[
        #text(weight: "bold", size: 11pt, order.name)
        #v(2pt)
        #text(size: 8.5pt, fill: ink.annotation, par(leading: 0.5em, order.subtitle))
      ],
      anchor: "west",
    )
    let cells = (
      (order.structure, order.structure-note),
      (response-cell(order.branches), order.response-note),
      (band-panel(order.bands, split-at: order.split-at), order.band-note),
      (bz-panel(order.form, order.contours, nodal: order.nodal), order.bz-note),
    )
    for (col, (panel, note)) in obs-columns.zip(cells) {
      scope({
        translate((col.x, y + panel-rise))
        panel
      })
      content((col.x, y - note-drop), caption-text(note, width: col.note-width), anchor: "north")
    }
  }

  let frame-bottom = row-y.at(2) - frame-half

  content(
    (right-mid - 1.2, frame-bottom - 0.71),
    align(center, text(size: 9pt, fill: ink.annotation)[
      #box(width: 12pt, height: 1.5pt, fill: spin-up) #h(2pt) $E_arrow.t$
      #h(9pt)
      #box(width: 12pt, height: 1.5pt, fill: spin-down) #h(2pt) $E_arrow.b$
      #h(9pt) curves drawn on top of each other are spin degenerate
      #h(15pt)
      #box(fill: spin-up.transparentize(30%), width: 10pt, height: 7pt) #h(2pt) $Delta > 0$
      #h(9pt)
      #box(fill: spin-down.transparentize(30%), width: 10pt, height: 7pt) #h(2pt) $Delta < 0$ \
      non-relativistic limit throughout; $M(H)$ axes not to scale across panels;
      $d$-wave altermagnet shown, $g$- and $i$-wave also exist
    ]),
  )
})
