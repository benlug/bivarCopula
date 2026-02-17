# tests/testthat/test-parameter_recovery.R
#
# These tests verify that the copula models can recover true parameter values
# within reasonable posterior intervals. They use small samples and short chains
# for speed, so tolerances are generous.

library(copula)

test_that("Gaussian copula recovers rho", {
    skip_if_no_cmdstan()

    set.seed(42)
    true_rho <- 0.5
    n <- 500

    cop <- normalCopula(param = true_rho, dim = 2)
    margins <- c("norm", "norm")
    params <- list(list(mean = 0, sd = 1), list(mean = 0, sd = 1))
    mvdc_copula <- mvdc(cop, margins = margins, paramMargins = params)
    data <- rMvdc(n, mvdc_copula)

    fit <- fit_bivariate_copula(data,
        copula = "gaussian", marginals = c("normal", "normal"),
        iter = 500, chains = 2, warmup = 500,
        seed = 42, refresh = 0
    )

    rho_est <- coef(fit)["rho[1]"]
    expect_true(abs(rho_est - true_rho) < 0.15,
        info = sprintf("rho estimate %.3f too far from truth %.3f", rho_est, true_rho)
    )
})

test_that("Clayton copula recovers theta", {
    skip_if_no_cmdstan()

    set.seed(42)
    true_theta <- 2.0
    n <- 500

    cop <- claytonCopula(param = true_theta, dim = 2)
    margins <- c("norm", "norm")
    params <- list(list(mean = 0, sd = 1), list(mean = 0, sd = 1))
    mvdc_copula <- mvdc(cop, margins = margins, paramMargins = params)
    data <- rMvdc(n, mvdc_copula)

    fit <- fit_bivariate_copula(data,
        copula = "clayton", marginals = c("normal", "normal"),
        iter = 500, chains = 2, warmup = 500,
        seed = 42, refresh = 0
    )

    theta_est <- coef(fit)["theta_clayton[1]"]
    expect_true(abs(theta_est - true_theta) < 1.0,
        info = sprintf("theta estimate %.3f too far from truth %.3f", theta_est, true_theta)
    )
})

test_that("Joe copula recovers theta", {
    skip_if_no_cmdstan()

    set.seed(42)
    true_theta <- 3.0
    n <- 500

    cop <- joeCopula(param = true_theta, dim = 2)
    margins <- c("norm", "norm")
    params <- list(list(mean = 0, sd = 1), list(mean = 0, sd = 1))
    mvdc_copula <- mvdc(cop, margins = margins, paramMargins = params)
    data <- rMvdc(n, mvdc_copula)

    fit <- fit_bivariate_copula(data,
        copula = "joe", marginals = c("normal", "normal"),
        iter = 500, chains = 2, warmup = 500,
        seed = 42, refresh = 0
    )

    theta_est <- coef(fit)["theta_joe[1]"]
    expect_true(abs(theta_est - true_theta) < 1.5,
        info = sprintf("theta estimate %.3f too far from truth %.3f", theta_est, true_theta)
    )
})
