# Internal environment to cache compiled Stan model
.copulaStan_env <- new.env(parent = emptyenv())

#' Get the compiled Stan model (compiles on first use, caches for reuse)
#' @keywords internal
get_stan_model <- function() {
    if (!is.null(.copulaStan_env$model)) {
        return(.copulaStan_env$model)
    }

    if (!requireNamespace("cmdstanr", quietly = TRUE)) {
        cli::cli_abort(
            "The {.pkg cmdstanr} package is required. Install it with:",
            body = c(
                i = '{.code install.packages("cmdstanr", repos = c("https://stan-dev.r-universe.dev", getOption("repos")))}'
            )
        )
    }

    stan_file <- system.file("stan", "fit_bivariate_copula.stan",
        package = "copulaStan"
    )


    # Fallback for devtools::load_all() / devtools::test()
    if (stan_file == "" || !file.exists(stan_file)) {
        stan_file <- file.path("inst", "stan", "fit_bivariate_copula.stan")
    }

    if (!file.exists(stan_file)) {
        cli::cli_abort("Stan model file not found. Make sure the package is installed correctly.")
    }

    # Compile (cmdstanr caches automatically based on file hash)
    model <- cmdstanr::cmdstan_model(
        stan_file = stan_file,
        include_paths = dirname(stan_file)
    )

    .copulaStan_env$model <- model
    model
}
