#import "@preview/cetz:0.5.2": canvas, draw
#import draw: content, line

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(font: "DejaVu Sans Mono")

#let t-str = "ACAACG"
#let n-chars = t-str.len()
// cyclic rotations tagged with their shift, in lexicographic order
#let rotations = (
  range(n-chars).map(shift => (t-str.slice(shift) + t-str.slice(0, shift), shift)).sorted()
)

#let red-txt(s) = text(fill: rgb(255, 0, 0), s)
#let column(rows) = align(left, rows.join(linebreak()))

// unsorted view highlights the rotated-in suffix, sorted view the last character
#let suffix-col = column(rotations.map(((rot, shift)) => [#red-txt(rot.slice(
    0,
    n-chars - shift,
  ))#rot.slice(n-chars - shift)]))
#let last-col = column(rotations.map(((rot, shift)) => {
  if shift == 0 { red-txt(rot) } else [#rot.slice(0, -1)#red-txt(rot.slice(-1))]
}))

#let bwt-str = rotations.map(((rot, _)) => rot.last()).join()
#let orig-row = rotations.position(((_, shift)) => shift == 0) + 1

#let serif-italic(body) = text(
  font: "New Computer Modern",
  style: "italic",
  body,
)

#canvas({
  let arrow = (
    mark: (end: "stealth", fill: black, scale: .85),
    stroke: black + 1.6pt,
  )

  content((0, 0), t-str, name: "T")
  content((rel: (0, -.45), to: "T"), serif-italic[T])

  content((4.0, 0), suffix-col, name: "rot")
  content((8.0, 0), last-col, name: "sort")

  content((12.0, 0), [(#bwt-str, #orig-row)], name: "bwt")
  content((rel: (0, -.6), to: "bwt"), serif-italic[BWT(T)])

  for (from, to) in (("T", "rot"), ("rot", "sort"), ("sort", "bwt")) {
    line(from, to, ..arrow)
  }
})
