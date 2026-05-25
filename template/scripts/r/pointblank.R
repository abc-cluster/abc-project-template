# https://github.com/rstudio/pointblank

library(pointblank)


library(dplyr)

# Generate a simple `action_levels` object to
# set the `warn` state if a validation step
# has a single 'fail' test unit
al <- action_levels(warn_at = 1)

# Create a pointblank `agent` object, with the
# tibble as the target table. Use three validation
# functions, then, `interrogate()`. The agent will
# then have some useful intel.
agent <-
  dplyr::tibble(
    a = c(5, 7, 6, 5, NA, 7),
    b = c(6, 1, 0, 6, 0, 7)
  ) %>%
  create_agent(
    label = "A very *simple* example.",
    actions = al
  ) %>%
  col_vals_between(
    columns = a,
    left = 1,
    right = 9,
    na_pass = TRUE
  ) %>%
  col_vals_lt(
    columns = c, 12,
    preconditions = ~ . %>% dplyr::mutate(c = a + b)
  ) %>%
  col_is_numeric(columns = c(a, b)) %>%
  interrogate()
