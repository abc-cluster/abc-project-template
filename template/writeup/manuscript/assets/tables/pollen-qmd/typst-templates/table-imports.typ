#import "@preview/tablem:0.2.0": tablem, three-line-table

#let three-line-table = tablem.with(
  render: (columns: auto, ..args) => {
    table(
      columns: columns,
      stroke: none,
      align: left + horizon,
      table.hline(y: 0),
      table.hline(y: 1),
      ..args,
      table.hline(),
    )
  }
)