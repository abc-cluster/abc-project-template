// Performance-specific table functions with numeric formatting

#let performance-table(content) = {
  table(
    columns: 4,
    align: (left, right, right, right),
    stroke: (x, y) => (
      top: if y == 0 { 2pt } else if y == 1 { 1pt } else { 0.5pt },
      bottom: if y == 0 { 0pt } else { 0.5pt },
      left: 0pt,
      right: 0pt
    ),
    fill: (x, y) => if calc.even(y) and y > 0 { rgb("#f8f9fa") },
    ..content
  )
}