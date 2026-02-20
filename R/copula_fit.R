#' Create a copula_fit object
#'
#' @param fit CmdStanMCMC fit object.
#' @param copula Copula type string.
#' @param marginals Character vector of marginal distribution names.
#' @param data_dim Dimensions of the input data.
#'
#' @return A `copula_fit` S3 object.
#' @keywords internal
copula_fit <- function(fit, copula, marginals, data_dim) {
    structure(
        list(
            fit = fit,
            copula = copula,
            marginals = marginals,
            data_dim = data_dim
        ),
        class = "copula_fit"
    )
}


#' Print a copula_fit object
#'
#' Displays a summary of the fitted copula model including the copula type,
#' marginal distributions, sample size, and a parameter summary table.
#'
#' @param x A `copula_fit` object.
#' @param ... Additional arguments (unused).
#'
#' @return Invisibly returns the `copula_fit` object `x`, allowing
#'   usage in pipelines.
#'
#' @examples
#' \dontrun{
#' fit <- fit_bivariate_copula(data,
#'   copula = "gaussian",
#'   marginals = c("normal", "lognormal")
#' )
#' print(fit)
#' }
#'
#' @export
print.copula_fit <- function(x, ...) {
    if (!requireNamespace("posterior", quietly = TRUE)) {
        cli::cli_abort(c(
            "The {.pkg posterior} package is required.",
            "i" = "Install with: {.code install.packages(\"posterior\")}"
        ))
    }

    cli::cli_h1("Bivariate Copula Fit")
    cli::cli_text("Copula: {.strong {x$copula}}")
    cli::cli_text("Marginals: {.val {x$marginals[1]}}, {.val {x$marginals[2]}}")
    cli::cli_text("Data: {x$data_dim[1]} observations")
    cli::cli_rule()

    draws <- posterior::as_draws_df(x$fit$draws())
    pars <- copula_pars(x)
    sub <- posterior::subset_draws(draws, variable = pars)
    summ <- posterior::summarise_draws(sub)
    print(summ)

    invisible(x)
}


#' Summarize a copula_fit object
#'
#' Returns a tibble of posterior summaries for the model parameters,
#' including mean, median, standard deviation, MAD, quantiles, and
#' convergence diagnostics (Rhat, ESS).
#'
#' @param object A `copula_fit` object.
#' @param ... Additional arguments (unused).
#'
#' @return A tibble from [posterior::summarise_draws()] with one row
#'   per parameter and columns for summary statistics and diagnostics.
#'
#' @examples
#' \dontrun{
#' fit <- fit_bivariate_copula(data,
#'   copula = "gaussian",
#'   marginals = c("normal", "lognormal")
#' )
#' summary(fit)
#' }
#'
#' @export
summary.copula_fit <- function(object, ...) {
    if (!requireNamespace("posterior", quietly = TRUE)) {
        cli::cli_abort(c(
            "The {.pkg posterior} package is required.",
            "i" = "Install with: {.code install.packages(\"posterior\")}"
        ))
    }

    draws <- posterior::as_draws_df(object$fit$draws())
    pars <- copula_pars(object)
    sub <- posterior::subset_draws(draws, variable = pars)
    posterior::summarise_draws(sub)
}


#' Extract point estimates from a copula_fit
#'
#' Returns posterior means of the model parameters as a named numeric
#' vector. Parameter names match those used in the Stan model (e.g.,
#' `"mu1[1]"`, `"sigma1[1]"`, `"rho[1]"`).
#'
#' @param object A `copula_fit` object.
#' @param ... Additional arguments (unused).
#'
#' @return A named numeric vector of posterior means, with one element
#'   per model parameter.
#'
#' @examples
#' \dontrun{
#' fit <- fit_bivariate_copula(data,
#'   copula = "gaussian",
#'   marginals = c("normal", "lognormal")
#' )
#' coef(fit)
#' }
#'
#' @export
coef.copula_fit <- function(object, ...) {
    if (!requireNamespace("posterior", quietly = TRUE)) {
        cli::cli_abort(c(
            "The {.pkg posterior} package is required.",
            "i" = "Install with: {.code install.packages(\"posterior\")}"
        ))
    }

    draws <- posterior::as_draws_df(object$fit$draws())
    pars <- copula_pars(object)
    sub <- posterior::subset_draws(draws, variable = pars)
    summ <- posterior::summarise_draws(sub, mean = mean)
    stats::setNames(summ$mean, summ$variable)
}


#' Get relevant parameter names for a copula_fit object
#'
#' Determines which Stan parameter names are relevant based on the
#' marginal distributions and copula type stored in a `copula_fit` object.
#'
#' @param x A `copula_fit` object.
#'
#' @return A character vector of Stan parameter names.
#' @keywords internal
#' @noRd
copula_pars <- function(x) {
    d1 <- .dist_map[x$marginals[1]]
    d2 <- .dist_map[x$marginals[2]]
    ct <- .copula_map[x$copula]

    pars <- character(0)

    # Marginal 1
    if (d1 %in% c(1L, 2L)) pars <- c(pars, "mu1[1]", "sigma1[1]")
    if (d1 == 3L) pars <- c(pars, "lambda1[1]")
    if (d1 == 4L) pars <- c(pars, "alpha1[1]", "beta1[1]")

    # Marginal 2
    if (d2 %in% c(1L, 2L)) pars <- c(pars, "mu2[1]", "sigma2[1]")
    if (d2 == 3L) pars <- c(pars, "lambda2[1]")
    if (d2 == 4L) pars <- c(pars, "alpha2[1]", "beta2[1]")

    # Copula
    if (ct == 1L) pars <- c(pars, "rho[1]")
    if (ct == 2L) pars <- c(pars, "theta_clayton[1]")
    if (ct == 3L) pars <- c(pars, "theta_joe[1]")

    pars
}
