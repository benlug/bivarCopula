# tests/testthat/test-fit_bivariate_copula.R
# Integration tests that require a working CmdStan installation.

library(copula)

# --- Gaussian copula ---

test_that("returns copula_fit with correct metadata for Gaussian copula", {
    skip_if_no_cmdstan()

    set.seed(2024)
    n <- 500
    cop <- normalCopula(param = 0.5, dim = 2)
    mvdc_copula <- mvdc(cop,
        margins = c("norm", "lnorm"),
        paramMargins = list(list(mean = 0.8, sd = 2), list(meanlog = 0, sdlog = 0.8))
    )
    data <- rMvdc(n, mvdc_copula)

    fit <- fit_bivariate_copula(data,
        copula = "gaussian", marginals = c("normal", "lognormal"),
        iter = 200, chains = 2, warmup = 200,
        seed = 2024, refresh = 0
    )

    expect_s3_class(fit, "copula_fit")
    expect_identical(fit$copula, "gaussian")
    expect_identical(fit$marginals, c("normal", "lognormal"))
    expect_identical(fit$data_dim, c(500L, 2L))

    summ <- summary(fit)
    expect_true(nrow(summ) > 0)
    expect_true("rho[1]" %in% summ$variable)

    co <- coef(fit)
    expect_true(is.numeric(co))
    expect_true("rho[1]" %in% names(co))
})

# --- Clayton copula ---

test_that("returns copula_fit with theta_clayton for Clayton copula", {
    skip_if_no_cmdstan()

    set.seed(2024)
    n <- 500
    cop <- claytonCopula(param = 2.0, dim = 2)
    mvdc_copula <- mvdc(cop,
        margins = c("norm", "lnorm"),
        paramMargins = list(list(mean = 0.8, sd = 2), list(meanlog = 0, sdlog = 0.8))
    )
    data <- rMvdc(n, mvdc_copula)

    fit <- fit_bivariate_copula(data,
        copula = "clayton", marginals = c("normal", "lognormal"),
        iter = 200, chains = 2, warmup = 200,
        seed = 2024, refresh = 0
    )

    expect_s3_class(fit, "copula_fit")
    expect_true("theta_clayton[1]" %in% summary(fit)$variable)
})

# --- Joe copula ---

test_that("returns copula_fit with theta_joe for Joe copula", {
    skip_if_no_cmdstan()

    set.seed(2024)
    n <- 500
    cop <- joeCopula(param = 2.0, dim = 2)
    mvdc_copula <- mvdc(cop,
        margins = c("norm", "lnorm"),
        paramMargins = list(list(mean = 0.8, sd = 2), list(meanlog = 0, sdlog = 0.8))
    )
    data <- rMvdc(n, mvdc_copula)

    fit <- fit_bivariate_copula(data,
        copula = "joe", marginals = c("normal", "lognormal"),
        iter = 200, chains = 2, warmup = 200,
        seed = 2024, refresh = 0
    )

    expect_s3_class(fit, "copula_fit")
    expect_true("theta_joe[1]" %in% summary(fit)$variable)
})
