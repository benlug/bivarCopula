#' Marginal distribution name to Stan integer code mapping
#'
#' Named integer vector mapping user-facing distribution names to the
#' integer codes expected by the Stan model: 1 = normal, 2 = lognormal,
#' 3 = exponential, 4 = beta.
#'
#' @keywords internal
#' @noRd
.dist_map <- c(
  "normal" = 1L,
  "lognormal" = 2L,
  "exponential" = 3L,
  "beta" = 4L
)

#' Copula type name to Stan integer code mapping
#'
#' Named integer vector mapping user-facing copula names to the
#' integer codes expected by the Stan model: 1 = gaussian, 2 = clayton,
#' 3 = joe.
#'
#' @keywords internal
#' @noRd
.copula_map <- c(
  "gaussian" = 1L,
  "clayton" = 2L,
  "joe" = 3L
)
