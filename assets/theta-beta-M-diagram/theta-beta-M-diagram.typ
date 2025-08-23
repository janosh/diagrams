#import "@preview/cetz:0.4.1"
#import "@preview/epsilon:0.1.0": secant
#import "@preview/lilaq:0.4.0" as lq

#{
  let KAPPA = 1.4

  /// Find the maximum of a function in a given interval.
  let golden-section-search(f, a, b, tolerance: 1e-7) = {
    let phi-inv = (calc.sqrt(5) - 1) / 2

    while b - a > tolerance {
      let c = b - (b - a) * phi-inv
      let d = a + (b - a) * phi-inv

      if f(c) > f(d) {
        b = d
      } else {
        a = c
      }
    }

    (b + a) / 2
  }

  /// Convert radians to degrees.
  let deg(x) = x * 180 / calc.pi
  /// Convert degrees to degrees.
  let rad(x) = x * calc.pi / 180

  /// Calculate the deflection angle for a given shock angle.
  let shock-polar(M, beta) = {
    calc.atan(
      2
        / calc.tan(beta)
        * (calc.pow(M, 2) * calc.pow(calc.sin(beta), 2) - 1)
        / (calc.pow(M, 2) * (KAPPA + calc.cos(2 * beta)) + 2),
    )
  }

  /// Calculate the normal mach number before the shock.
  let normal-mach(M, beta) = M * calc.sin(beta)
  /// Calculate the mach number after the shock from the normal mach number after the shock.
  let mach-shock(M-normal, beta, theta) = M-normal / calc.sin(beta - theta)

  /// Calculate the normal mach number after a shock.
  let normal-mach-shock(M) = (
    calc.sqrt(
      (2 + (KAPPA - 1) * calc.pow(M, 2))
        / (2 * KAPPA * calc.pow(M, 2) - (KAPPA - 1)),
    )
  )

  /// Calculate the mach number after the shock from the mach number before the shock.
  let shock-mach(M, beta, theta) = {
    let M-normal = normal-mach(M, beta)
    let M-normal-shock = normal-mach-shock(M-normal)
    let M-shock = mach-shock(M-normal-shock, beta, theta)

    M-shock
  }

  // Can't start at 0, because there's a division by tan(shock-angle) = 0.
  let shock-angles = lq.linspace(1e-9, 90, num: 256)
  // float.inf doesn't produce the correct result.
  let infinity = 1e100
  let mach-numbers = (
    1.05,
    1.1,
    1.15,
    1.2,
    1.25,
    1.3,
    1.35,
    1.4,
    1.45,
    1.5,
    1.6,
    1.7,
    1.8,
    1.9,
    2,
    2.1,
    2.2,
    2.3,
    2.4,
    2.5,
    2.6,
    2.8,
    3,
    3.2,
    3.4,
    3.5,
    3.6,
    3.8,
    4,
    4.5,
    5,
    6,
    8,
    10,
    15,
    20,
    infinity,
  )
  let highlighted-mach-numbers = (1.5, 2, 2.5, 3, 3.5, 4, 5, 10)

  let shock-angle-plots = (
    mach-numbers
      .map(M => {
        let deflection-angles = shock-angles.map(b => shock-polar(
          M,
          rad(b),
        ).deg())

        let max-deflection-angle = calc.max(..deflection-angles)
        let weak-solution-index = deflection-angles.position(t => (
          t == max-deflection-angle
        ))

        let thickness = if M in highlighted-mach-numbers {
          1.2pt
        } else {
          0.5pt
        }

        (
          // weak solution
          lq.plot(
            deflection-angles.slice(0, weak-solution-index + 1),
            shock-angles.slice(0, weak-solution-index + 1),
            color: black,
            stroke: (thickness: thickness),
            mark: none,
          ),
          // strong solution
          lq.plot(
            deflection-angles.slice(weak-solution-index),
            shock-angles.slice(weak-solution-index),
            color: black,
            stroke: (thickness: thickness, dash: "dashed"),
            mark: none,
          ),
        )
      })
      .flatten()
  )

  // The maximum deflection angle for M = infinity.
  let max-deflection-angle = shock-polar(infinity, golden-section-search(
    b => shock-polar(infinity, b),
    0,
    rad(90),
  )).rad()

  let solution-border-shock-angles = (
    lq
      .linspace(0, max-deflection-angle, num: 128)
      .enumerate()
      // Near a deflection angle of 0° the slope approaches infinity.
      // Therefore we need more resolution in this area.
      .map(((i, t)) => {
        if i == 1 {
          lq.linspace(0, t, num: 10)
        } else {
          (t,)
        }
      })
      .flatten()
      .map(deflection-angle => {
        // Find the Mach number for which the given deflection angle is the maximum.
        let M = secant(
          M => {
            let shock-angle = golden-section-search(
              b => shock-polar(M, b),
              0,
              rad(90),
            )
            shock-polar(M, shock-angle).rad() - deflection-angle
          },
          rad(60),
          rad(70),
        )
        // If M is infinity (or 1e100) the root finding won't converge in a reasonable number of iterations.
        if M == none {
          M = infinity
        }

        let maximum-shock-angle = golden-section-search(
          b => shock-polar(M, b),
          0,
          rad(90),
        )

        (M, maximum-shock-angle)
      })
  )
  let solution-border-plot = lq.plot(
    solution-border-shock-angles.map(((M, b)) => shock-polar(M, b).deg()),
    solution-border-shock-angles.map(((_, b)) => deg(b)),
    color: black,
    mark: none,
  )

  let mach-1 = (
    lq
      .linspace(0, max-deflection-angle, num: 128)
      .enumerate()
      // Near a deflection angle of 0° the slope approaches infinity.
      // Therefore we need more resolution in this area.
      .map(((i, t)) => {
        if i == 1 {
          lq.linspace(0, t, num: 10)
        } else {
          (t,)
        }
      })
      .flatten()
      .map(deflection-angle => {
        // We need a valid Mach number for our given deflection angle.
        // Finding the Mach number for which the given deflection angle is the maximum will guarantee a valid mach number.
        let M = secant(
          M => {
            let shock-angle = golden-section-search(
              b => shock-polar(M, b),
              0,
              rad(90),
            )
            shock-polar(M, shock-angle).rad() - deflection-angle
          },
          rad(60),
          rad(70),
        )
        // If M is infinity (or 1e100) the root finding won't converge in a reasonable number of iterations.
        if M == none {
          M = infinity
        }

        let mach-1-root(shock-angle) = {
          shock-mach(M, shock-angle, shock-polar(M, shock-angle).rad()) - 1
        }
        let shock-angle = secant(mach-1-root, rad(60), rad(70), tolerance: 1e-6)

        (M, shock-angle)
      })
  )
  let mach-1-plot = lq.plot(
    mach-1.map(((M, b)) => shock-polar(M, b).deg()),
    mach-1.map(((_, b)) => deg(b)),
    color: black,
    stroke: (dash: "dash-dotted"),
    mark: none,
  )

  let label-text-size = 9pt
  let custom-label-placements = (
    "3.4": (coordinates: (34, 68), line: ((34.7, 67.9), 67)),
    "3.8": (coordinates: (38.8, 68.5), line: ((38.8, 68.5), 67.3)),
    "15": (coordinates: (45.2, 69.2), line: ((45.2, 69.2), 69)),
    "20": (coordinates: (45.1, 72.3), line: ((45.1, 72.3), 71.2)),
    str(infinity): (coordinates: (45.2, 63), line: ((45.5, 63.6), 64.1)),
  )

  let label-plots = (
    mach-numbers
      .enumerate()
      .map(((i, M)) => {
        let maximum-shock-angle = golden-section-search(
          b => shock-polar(M, b),
          0,
          rad(90),
        )
        let deflection-angle = shock-polar(M, maximum-shock-angle).deg()

        let align = if M in highlighted-mach-numbers {
          top + left
        } else {
          bottom + left
        }
        let label = if M == infinity {
          $#sym.infinity$
        } else {
          [#M]
        }
        if M in highlighted-mach-numbers {
          label = strong(label)
        }

        let (x, y, pad-x, pad-y) = if str(M) not in custom-label-placements {
          (deflection-angle, deg(maximum-shock-angle), 0.07em, 0.3em)
        } else {
          (
            custom-label-placements.at(str(M)).at("coordinates"),
            0em,
            0em,
          ).flatten()
        }

        let labels = (
          lq.place(
            x,
            y,
            align: align,
            pad(x: pad-x, y: pad-y)[#text(size: label-text-size)[$#label$]],
          ),
        )

        if str(M) in custom-label-placements {
          let line = custom-label-placements.at(str(M)).at("line")

          let y = (line.at(0).at(1), line.at(1))
          let x = (line.at(0).at(0), shock-polar(M, rad(y.at(1))).deg())


          labels.push(
            lq.plot(x, y, color: black, stroke: (thickness: 0.5pt), mark: none),
          )
        }

        labels
      })
      .flatten()
      // hat(M) = 1 label.
      + (63,).map(shock-angle => {
        let M = 1.4
        let mach-1-root(shock-angle) = {
          shock-mach(M, shock-angle, shock-polar(M, shock-angle).rad()) - 1
        }
        let shock-angle = deg(secant(mach-1-root, rad(60), rad(70)))
        let deflection-angle = shock-polar(M, rad(shock-angle)).deg()

        lq.place(
          deflection-angle,
          shock-angle,
          align: top + right,
          pad(0.2em)[#text(size: label-text-size)[$hat(M) = 1$]],
        )
      })
  )

  let geometry-drawing = cetz.canvas(
    length: 3cm,
    background: white,
    stroke: (thickness: 0.5pt, paint: black),
    padding: 0.2cm,
    {
      import cetz.draw: *

      let theta = 15deg
      let beta = 65deg
      let M-length = 0.8
      let M-shock-length = 0.7

      set-style(
        mark: (fill: black, scale: 1.5),
        stroke: (thickness: 0.5pt),
        angle: (
          radius: 0.3,
          label-radius: .22,
        ),
        content: (padding: 2pt),
      )

      // angles
      cetz.angle.angle(
        (0, 0),
        (1, 0),
        (1, calc.tan(beta)),
        radius: 0.45,
        label: $#sym.beta$,
        label-radius: 80%,
        mark: (end: ">", scale: 0.5),
      )
      cetz.angle.angle(
        (0, 0),
        (1, 0),
        (1, calc.tan(theta)),
        radius: 0.54,
        label: $#sym.theta$,
        label-radius: 120%,
        mark: (end: ">", scale: 0.5),
      )

      let strong-stroke = (thickness: 1.2pt)

      // arrows
      line(
        (-M-length, 0),
        (0, 0),
        mark: (end: "stealth"),
        stroke: strong-stroke,
        name: "mach",
      )
      content("mach.mid", $M$, anchor: "south")
      line(
        (0, 0),
        (M-shock-length * calc.cos(theta), M-shock-length * calc.sin(theta)),
        mark: (end: "stealth"),
        stroke: strong-stroke,
        name: "mach-shock",
      )
      content(
        ("mach-shock.start", 90%, "mach-shock.end"),
        $hat(M)$,
        angle: "mach-shock.end",
        padding: 0.07,
        anchor: "south",
      )
      line((0, 0), (M-length, 0), stroke: strong-stroke + (dash: (8pt, 4pt)))

      // shock
      let slope = calc.tan(beta)
      let (x1, x2) = (-0.2, 0.4)
      line((x1, x1 * slope), (x2, x2 * slope))

      let shift = 0.01
      line(
        (x1 - shift, x1 * slope + shift),
        (x2 - shift, x2 * slope + shift),
        name: "shock-line",
      )

      let text-x = 0.2
      content(
        ("shock-line.start", 65%, "shock-line.end"),
        text(size: 8pt)[shock],
        angle: "shock-line.end",
        anchor: "south",
      )
    },
  )

  let drawing-plot = lq.place(
    80%,
    88%,
    geometry-drawing,
  )

  // Invisible plots to create the legend.
  let legend-plots = (
    lq.plot(
      (),
      (),
      color: black,
      mark: none,
      label: "strong solution",
    ),
    lq.plot(
      (),
      (),
      color: black,
      stroke: (dash: "dashed"),
      mark: none,
      label: "weak solution",
    ),
  )

  let plots = (
    shock-angle-plots
      + (solution-border-plot, mach-1-plot, drawing-plot)
      + legend-plots
      + label-plots
  )

  set page(margin: 1cm)
  set text(font: "New Computer Modern")

  set align(center)

  let axis = (
    tick-distance: 2,
    subticks: 1,
  )
  let dof = calc.round(2 / (KAPPA - 1), digits: 3)

  lq.diagram(
    width: 18cm,
    height: 26cm,
    xlim: (0, 46),
    ylim: (0, 90),
    xaxis: axis,
    yaxis: axis,
    title: [$theta$--$beta$--$M$ Diagram for Diatomic Gases ($f = dof$, $kappa = KAPPA$)],
    xlabel: [deflection angle $theta$ [°]],
    ylabel: [shock angle $beta$ [°]],
    ..plots,
  )
}
