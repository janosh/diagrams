#import "@preview/cetz:0.5.2": canvas, draw

#set page(width: auto, height: auto, margin: 12pt, fill: none)
#set text(font: "New Computer Modern", size: 12pt, fill: rgb("243247"))

#let incident_color = rgb("2563eb")
#let scattered_color = rgb("c26418")
#let electron_color = rgb("7454a3")
#let wavelength = 0.42
#let scattering_angle = 35deg
#let arrow(color) = (end: "stealth", fill: color, stroke: none, length: 5pt, width: 3.5pt)

// All wave packets use the same wavelength; their length only changes the cycle count.
#let wave(start_distance, angle, cycles, color) = draw.scope({
  draw.translate((start_distance * calc.cos(angle), start_distance * calc.sin(angle)))
  draw.rotate(angle)
  let wave_length = cycles * wavelength
  let points = range(cycles * 48 + 1).map(idx => {
    let distance = idx / 48 * wavelength
    (distance, 0.10 * calc.sin(360deg * distance / wavelength))
  })
  draw.line(..points, stroke: color + 1pt)
  draw.line((wave_length, 0), (wave_length + 0.23, 0), stroke: color + 1pt, mark: arrow(color))
})

#canvas({
  draw.content((0, 3.7), text(size: 16pt, weight: "bold")[Thomson scattering])
  draw.content((0, 3.12), text(size: 14pt)[Elastic scattering by a free electron])

  draw.scope({
    draw.scale(1.4)

    // The gray rays suggest other emission directions without implying equal intensity.
    for angle in (145deg, 225deg, 310deg) {
      wave(0.55, angle, 2, rgb("c3cbd5"))
    }
    draw.line((0.45, 0), (2.85, 0), stroke: (
      paint: rgb("b5bfcc"),
      thickness: 0.6pt,
      dash: "dashed",
    ))
    draw.content((2.85, -0.2), text(size: 12pt, fill: rgb("697586"))[forward direction])

    wave(-3.1, 0deg, 5, incident_color)
    draw.content((-2.0, 0.48), text(fill: incident_color)[Incident wave])
    draw.content((-2.0, -0.43), text(fill: incident_color)[$lambda_"in"$])

    wave(0.55, scattering_angle, 5, scattered_color)
    draw.content((1.0, 1.68), text(fill: scattered_color)[Scattered wave])
    draw.content((2.62, 1.1), text(fill: scattered_color)[$lambda_"out"$])
    draw.arc(
      (0, 0),
      start: 0deg,
      stop: scattering_angle,
      anchor: "origin",
      radius: 1.1,
      stroke: scattered_color + 0.8pt,
      mark: arrow(scattered_color),
    )
    draw.content((1.35, 0.37), text(fill: scattered_color)[$theta$])

    draw.line((0, -0.48), (0, 0.48), stroke: electron_color + 1pt, mark: (
      start: "stealth",
      ..arrow(electron_color),
    ))
    draw.circle((0, 0), radius: 0.27, fill: electron_color, stroke: none)
    draw.content((0, 0), text(fill: white, size: 12pt)[$e^-$])
    draw.content((0, -1.08), text(fill: electron_color, size: 12pt)[Electron])
  })

  draw.content((0, -2.32), text(
    size: 12pt,
  )[$lambda_"out" = lambda_"in" quad h nu_"out" = h nu_"in"$])
  draw.content((0, -3.0), text(
    size: 14pt,
  )[The electric field drives the electron; the accelerated charge reradiates.])
  draw.content((0, -3.6), text(
    size: 14pt,
    fill: rgb("697586"),
  )[Classical limit: photon energy $h nu lt.double m_e c^2$; recoil is neglected.])
})
