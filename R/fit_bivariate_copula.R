#' Fit Bivariate Copula Model
#'
#' @description
#' Fits a bivariate copula model to data with marginal parameter estimation.
#' Supports Gaussian, Clayton, and Joe copulas with normal, lognormal,
#' exponential, or beta marginal distributions. Uses CmdStan for Bayesian
#' inference via the `cmdstanr` package.
#'
#' @param U A numeric matrix with exactly two columns containing the observed
#'   data. Each column corresponds to one variable.
#' @param copula Character string specifying the copula type. One of
#'   `"gaussian"`, `"clayton"`, or `"joe"`.
#' @param marginals A character vector of length 2 specifying the marginal
#'   distributions. Each element must be one of `"normal"`, `"lognormal"`,
#'   `"exponential"`, or `"beta"`.
#' @param iter Number of sampling iterations per chain (after warmup).
#'   Default is 1000.
#' @param chains Number of MCMC chains. Default is 4.
#' @param warmup Number of warmup iterations per chain. Default is 1000.
#' @param thin Thinning rate. Default is 1.
#' @param seed Random seed for reproducibility. Default is `NULL`.
#' @param adapt_delta Target acceptance rate for NUTS. Default is 0.8.
#' @param max_treedepth Maximum tree depth for NUTS. Default is 10.
#' @param parallel_chains Number of chains to run in parallel. Default is 1.
#' @param refresh How often to print progress (in iterations). Set to 0 for
#'   silent. Default is 500.
#'
#' @return A `copula_fit` object (S3 class) containing:
#' \describe{
#'   \item{`fit`}{The CmdStanMCMC fit object from `cmdstanr`.}
#'   \item{`copula`}{The copula type used.}
#'   \item{`marginals`}{The marginal distributions used.}
#'   \item{`data_dim`}{Dimensions of the input data (rows, columns).}
#' }
#'
#' @examples
#' \dontrun{
#' library(copula)
#' library(copulaStan)
#'
#' set.seed(2024)
#' n <- 1000
#' cop <- normalCopula(param = 0.5, dim = 2)
#' margins <- c("norm", "lnorm")
#' params <- list(list(mean = 0.8, sd = 2), list(meanlog = 0, sdlog = 0.8))
#' mvdc_copula <- mvdc(cop, margins = margins, paramMargins = params)
#' data <- rMvdc(n, mvdc_copula)
#'
#' fit <- fit_bivariate_copula(data,
#'   copula = "gaussian",
#'   marginals = c("normal", "lognormal"),
#'   seed = 2024
#' )
#' print(fit)
#' summary(fit)
#' }
#'
#' @export
fit_bivariate_copula <- function(U, copula, marginals,
                                 iter = 1000, chains = 4, warmup = 1000,
                                 thin = 1, seed = NULL,
                                 adapt_delta = 0.8, max_treedepth = 10,
                                 parallel_chains = 1, refresh = 500) {
  # --- Input validation ---
  validate_inputs(U, copula, marginals)

  N <- nrow(U)
  y1 <- U[, 1]
  y2 <- U[, 2]

  dist_map <- c("normal" = 1L, "lognormal" = 2L, "exponential" = 3L, "beta" = 4L)
  copula_map <- c("gaussian" = 1L, "clayton" = 2L, "joe" = 3L)

  dist1 <- dist_map[marginals[1]]
  dist2 <- dist_map[marginals[2]]
  copula_type <- copula_map[copula]

  stan_data <- list(
    N = N,
    y1 = y1,
    y2 = y2,
    dist1 = dist1,
    dist2 = dist2,
    copula_type = copula_type
  )

  # --- Get compiled model ---
  model <- get_stan_model()

  # --- Initial values ---
  init_fn <- function() {
    inits <- list()

    if (dist1 %in% c(1L, 2L)) {
      inits$mu1 <- array(0, dim = 1)
      inits$sigma1 <- array(1, dim = 1)
    }
    if (dist1 == 3L) inits$lambda1 <- array(1, dim = 1)
    if (dist1 == 4L) {
      inits$alpha1 <- array(2, dim = 1)
      inits$beta1 <- array(2, dim = 1)
    }

    if (dist2 %in% c(1L, 2L)) {
      inits$mu2 <- array(0, dim = 1)
      inits$sigma2 <- array(1, dim = 1)
    }
    if (dist2 == 3L) inits$lambda2 <- array(1, dim = 1)
    if (dist2 == 4L) {
      inits$alpha2 <- array(2, dim = 1)
      inits$beta2 <- array(2, dim = 1)
    }

    if (copula_type == 1L) inits$rho <- array(0, dim = 1)
    if (copula_type == 2L) inits$theta_clayton <- array(1, dim = 1)
    if (copula_type == 3L) inits$theta_joe <- array(2, dim = 1)

    inits
  }

  # --- Sample ---
  fit <- model$sample(
    data = stan_data,
    iter_sampling = iter,
    iter_warmup = warmup,
    chains = chains,
    thin = thin,
    seed = seed,
    adapt_delta = adapt_delta,
    max_treedepth = max_treedepth,
    parallel_chains = parallel_chains,
    refresh = refresh,
    init = init_fn
  )

  # --- Build S3 result ---
  copula_fit(
    fit = fit,
    copula = copula,
    marginals = marginals,
    data_dim = dim(U)
  )
}


# --- Input validation (internal) ---

validate_inputs <- function(U, copula, marginals) {
  # Check U is a matrix

  if (!is.matrix(U)) {
    cli::cli_abort("{.arg U} must be a numeric matrix, not {.cls {class(U)}}.")
  }

  if (ncol(U) != 2) {
    cli::cli_abort("{.arg U} must have exactly 2 columns, not {ncol(U)}.")
  }

  if (!is.numeric(U)) {
    cli::cli_abort("{.arg U} must be numeric.")
  }

  if (any(!is.finite(U))) {
    cli::cli_abort("{.arg U} must not contain NA, NaN, or Inf values.")
  }

  # Check copula
  valid_copulas <- c("gaussian", "clayton", "joe")
  if (length(copula) != 1 || !copula %in% valid_copulas) {
    cli::cli_abort(
      "{.arg copula} must be one of {.or {.val {valid_copulas}}}, not {.val {copula}}."
    )
  }

  # Check marginals
  valid_marginals <- c("normal", "lognormal", "exponential", "beta")
  if (length(marginals) != 2) {
    cli::cli_abort(
      "{.arg marginals} must be a character vector of length 2, not length {length(marginals)}."
    )
  }
  for (i in seq_along(marginals)) {
    if (!marginals[i] %in% valid_marginals) {
      cli::cli_abort(
        "marginals[{i}] must be one of {.or {.val {valid_marginals}}}, not {.val {marginals[i]}}."
      )
    }
  }

  # Check data-distribution compatibility
  if (marginals[1] %in% c("lognormal", "exponential") && any(U[, 1] <= 0)) {
    cli::cli_abort(
      "All values in column 1 of {.arg U} must be positive for {.val {marginals[1]}} marginals."
    )
  }
  if (marginals[2] %in% c("lognormal", "exponential") && any(U[, 2] <= 0)) {
    cli::cli_abort(
      "All values in column 2 of {.arg U} must be positive for {.val {marginals[2]}} marginals."
    )
  }
  if (marginals[1] == "beta" && (any(U[, 1] <= 0) || any(U[, 1] >= 1))) {
    cli::cli_abort(
      "All values in column 1 of {.arg U} must be in (0, 1) for beta marginals."
    )
  }
  if (marginals[2] == "beta" && (any(U[, 2] <= 0) || any(U[, 2] >= 1))) {
    cli::cli_abort(
      "All values in column 2 of {.arg U} must be in (0, 1) for beta marginals."
    )
  }

  invisible(TRUE)
}
