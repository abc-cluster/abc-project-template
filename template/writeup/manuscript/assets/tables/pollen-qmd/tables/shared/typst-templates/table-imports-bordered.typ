#import "@preview/tablem:0.2.0": tablem, three-line-table

#let bordered-table = tablem.with(
  render: (columns: auto, ..args) => {
    table(
      columns: columns,
      stroke: 0.5pt + gray,
      align: left + horizon,
      fill: (_, y) => if calc.odd(y) { rgb("f8f9fa") },
      ..args,
    )
  }
)