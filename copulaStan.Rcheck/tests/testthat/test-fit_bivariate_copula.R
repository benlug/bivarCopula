# tests/testthat/test-fit_bivariate_copula.R

library(copula)

test_that("fit_bivariate_copula works with Gaussian copula and normal+lognormal marginals", {
  skip_if_no_cmdstan()

  set.seed(2024)
  n <- 500
  margins <- c("norm", "lnorm")
  params <- list(list(mean = 0.8, sd = 2), list(meanlog = 0, sdlog = 0.8))
  cop <- normalCopula(param = 0.5, dim = 2)
  mvdc_copula <- mvdc(cop, margins = margins, paramMargins = params)
  data <- rMvdc(n, mvdc_copula)

  fit <- fit_bivariate_copula(data,
    copula = "gaussian", marginals = c("normal", "lognormal"),
    iter = 200, chains = 2, warmup = 200,
    seed = 2024, refresh = 0
  )

  expect_s3_class(fit, "copula_fit")
  expect_equal(fit$copula, "gaussian")
  expect_equal(fit$marginals, c("normal", "lognormal"))
  expect_equal(fit$data_dim, c(500L, 2L))

  # Check summary works
  summ <- summary(fit)
  expect_true(nrow(summ) > 0)
  expect_true("rho[1]" %in% summ$variable)

  # Check coef works
  co <- coef(fit)
  expect_true("rho[1]" %in% names(co))
})

test_that("fit_bivariate_copula works with Clayton copula", {
  skip_if_no_cmdstan()

  set.seed(2024)
  n <- 500
  margins <- c("norm", "lnorm")
  params <- list(list(mean = 0.8, sd = 2), list(meanlog = 0, sdlog = 0.8))
  cop <- claytonCopula(param = 2.0, dim = 2)
  mvdc_copula <- mvdc(cop, margins = margins, paramMargins = params)
  data <- rMvdc(n, mvdc_copula)

  fit <- fit_bivariate_copula(data,
    copula = "clayton", marginals = c("normal", "lognormal"),
    iter = 200, chains = 2, warmup = 200,
    seed = 2024, refresh = 0
  )

  expect_s3_class(fit, "copula_fit")
  expect_true("theta_clayton[1]" %in% summary(fit)$variable)
})

test_that("fit_bivariate_copula works with Joe copula", {
  skip_if_no_cmdstan()

  set.seed(2024)
  n <- 500
  margins <- c("norm", "lnorm")
  params <- list(list(mean = 0.8, sd = 2), list(meanlog = 0, sdlog = 0.8))
  cop <- joeCopula(param = 2.0, dim = 2)
  mvdc_copula <- mvdc(cop, margins = margins, paramMargins = params)
  data <- rMvdc(n, mvdc_copula)

  fit <- fit_bivariate_copula(data,
    copula = "joe", marginals = c("normal", "lognormal"),
    iter = 200, chains = 2, warmup = 200,
    seed = 2024, refresh = 0
  )

  expect_s3_class(fit, "copula_fit")
  expect_true("theta_joe[1]" %in% summary(fit)$variable)
})
