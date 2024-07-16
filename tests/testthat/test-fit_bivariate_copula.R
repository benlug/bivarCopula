# tests/testthat/test-fit_bivariate_copula.R

library(copula)  # Load the copula package for normalCopula and claytonCopula

test_that("fit_bivariate_copula works with Gaussian copula and normal marginals", {
  set.seed(2024)
  true_rho <- 0.5
  n <- 2000
  margins <- c("norm", "lnorm")
  params <- list(list(mean = 0.8, sd = 2), list(meanlog = 0, sdlog = 0.8))
  cop <- normalCopula(param = true_rho, dim = 2)
  mvdc_copula <- mvdc(cop, margins = margins, paramMargins = params)
  data <- rMvdc(n, mvdc_copula)

  fit <- fit_bivariate_copula(data, copula = "gaussian", marginals = c("normal", "lognormal"),
                              iter = 500, chains = 2, warmup = 100,
                              seed = 2024, cores = 1)


  expect_s4_class(fit, "stanfit")  # check if fit is a S4 boject

  samples <- rstan::extract(fit)
  expect_true(length(samples) > 0)  # check that the number of samples is as expected

  expect_true("rho" %in% names(samples))  # check that the rho parameter is present in the fit
})

test_that("fit_bivariate_copula works with Clayton copula and normal marginals", {
  set.seed(2024)
  true_theta <- 2.0
  n <- 2000
  margins <- c("norm", "lnorm")
  params <- list(list(mean = 0.8, sd = 2), list(meanlog = 0, sdlog = 0.8))
  cop <- claytonCopula(param = true_theta, dim = 2)
  mvdc_copula <- mvdc(cop, margins = margins, paramMargins = params)
  data <- rMvdc(n, mvdc_copula)

  fit <- fit_bivariate_copula(data, copula = "clayton", marginals = c("normal", "lognormal"),
                              iter = 500, chains = 2, warmup = 100,
                              seed = 2024, cores = 1)

  expect_s4_class(fit, "stanfit")  # check if fit is a S4 boject

  samples <- rstan::extract(fit)
  expect_true(length(samples) > 0)  # check that the number of samples is as expected

  expect_true("theta" %in% names(samples))  # check that the theta parameter is present in the fit
})

test_that("fit_bivariate_copula works with Joe copula and normal marginals", {
  set.seed(2024)
  true_theta <- 2.0
  n <- 2000
  margins <- c("norm", "lnorm")
  params <- list(list(mean = 0.8, sd = 2), list(meanlog = 0, sdlog = 0.8))
  cop <- joeCopula(param = true_theta, dim = 2)
  mvdc_copula <- mvdc(cop, margins = margins, paramMargins = params)
  data <- rMvdc(n, mvdc_copula)

  fit <- fit_bivariate_copula(data, copula = "joe", marginals = c("normal", "lognormal"),
                              iter = 500, chains = 2, warmup = 100,
                              seed = 2024, cores = 1)

  expect_s4_class(fit, "stanfit")

  samples <- rstan::extract(fit)
  expect_true(length(samples) > 0)

  expect_true("theta" %in% names(samples))
})
