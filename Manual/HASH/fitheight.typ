#let fitmaxHeight(images, gutter: 0cm, ..rest) = layout(size => context {
  let maxHeight = calc.max(..images.map(it => measure(it).height))
  let spaceForWidths = size.width - gutter * (images.len()-1)
  let totalScaledWidth = images.map(it => {
    let (width, height) = measure(it)
    width * (maxHeight / height)
  }).sum()
  set align(center)
  set image(height: maxHeight * calc.min(1, spaceForWidths / totalScaledWidth))
  grid(
    columns: images.len(),
    column-gutter: gutter,
    rows: 1,
    ..images
  )
})

#let fitminHeight(images, gutter: 0cm, ..rest) = layout(size => context {
  let minHeight = calc.min(..images.map(it => measure(it).height))
  let spaceForWidths = size.width - gutter * (images.len()-1)
  let totalScaledWidth = images.map(it => {
    let (width, height) = measure(it)
    width * (minHeight / height)
  }).sum()
  set align(center)
  set image(height: minHeight * (spaceForWidths / totalScaledWidth))
  grid(
    columns: images.len(),
    column-gutter: gutter,
    rows: 1,
    ..images
  )
})
