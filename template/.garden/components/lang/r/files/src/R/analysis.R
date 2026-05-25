# src/R/analysis.R — starter R analysis script
# Planted by: just grow lang:r
#
# This script demonstrates the canonical analysis pattern for this project.
# Replace with your own analysis logic.

library(tidyverse)
library(ggplot2)

# ─── Load data ────────────────────────────────────────────────────────────────

# Example: load from data/primary/
# data_path <- file.path("data", "primary", "dataset.csv")
# df <- read_csv(data_path)

# Placeholder: Palmer Penguins-style toy data
df <- tibble(
  species  = c("Adelie", "Adelie", "Chinstrap", "Gentoo", "Gentoo"),
  bill_len = c(39.1, 40.3, 46.5, 47.6, 50.0),
  flipper  = c(181L, 186L, 195L, 211L, 230L),
  mass     = c(3750L, 3800L, 3500L, 4200L, 5700L)
)

# ─── Summarise ────────────────────────────────────────────────────────────────

summary_df <- df |>
  group_by(species) |>
  summarise(
    n            = n(),
    mean_bill    = mean(bill_len),
    mean_flipper = mean(flipper),
    mean_mass    = mean(mass),
    .groups = "drop"
  )

print(summary_df)

# ─── Visualise ────────────────────────────────────────────────────────────────

p <- ggplot(df, aes(x = bill_len, y = flipper, colour = species)) +
  geom_point(size = 3) +
  labs(
    title    = "Bill length vs flipper length",
    subtitle = "By species",
    x        = "Bill length (mm)",
    y        = "Flipper length (mm)",
    colour   = "Species"
  ) +
  theme_minimal()

# Save figure
fig_dir <- file.path("data", "reports", "figures")
dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)
ggsave(file.path(fig_dir, "bill-vs-flipper.png"), p, width = 7, height = 5)

message("Figure saved to data/reports/figures/bill-vs-flipper.png")
