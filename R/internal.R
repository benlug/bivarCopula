# Internal constants shared across package functions
# Maps user-facing names to Stan integer codes

.dist_map <- c(
  "normal" = 1L,
  "lognormal" = 2L,
  "exponential" = 3L,
  "beta" = 4L
)

.copula_map <- c(
  "gaussian" = 1L,
  "clayton" = 2L,
  "joe" = 3L
)
