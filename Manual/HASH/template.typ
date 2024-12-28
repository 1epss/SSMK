#let project(title: "", subtitle: "", authors: (), logo: none, main: none, body) = {
  // Set the document's basic properties.
  set document(author: authors, title: title)
  set page(numbering: "1", number-align: center)

  // Save heading and body font families inv ariables.
  let body-font = ("Times New Roman Cyr", "Malgun Gothic")
  let sans-font = "Times New Roman Cyr"

  // Set body font family.
  set text(font: body-font, lang: "ko", weight: "light")
  show heading: set text(font: sans-font, size:13pt)
  set heading(numbering: "1.1")

  // Title page.
  // The page can contain a logo if you pass one with `logo: "logo.png"`.
  v(0.6fr)
  if logo != none {
    align(right, image(logo, width: 26%))
  }
  v(0.6fr)

  if main != none {
    align(center, image(main, width: 60%))
  }
  
  v(2.6fr)

  text(font: sans-font, 2em, weight: 700, title)
  v(0.6fr)
  text(font: sans-font, 1.5em, weight: 100, subtitle)

  // Author information.
  pad(
    top: 0.7em,
    right: 20%,
    grid(
      columns: (1fr,) * calc.min(3, authors.len()),
      gutter: 1em,
      ..authors.map(author => align(start, strong(author))),
    ),
  )

  v(2.4fr)
  pagebreak()


  // Table of contents.
  outline(depth: 2, indent: true)
  pagebreak()


  // Main body.
  set par(justify: true)

  body
}