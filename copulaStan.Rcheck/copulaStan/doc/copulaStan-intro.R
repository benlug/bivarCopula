## ----setup, include = FALSE---------------------------------------------------
# Stan models require CmdStan; don't evaluate during R CMD check
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = FALSE
)

## -----------------------------------------------------------------------------
# library(copulaStan)
# library(copula)

## -----------------------------------------------------------------------------
# seed <- 2024
# set.seed(seed)
# true_rho <- 0.5
# n <- 2000
# 
# margins <- c("norm", "lnorm")
# params <- list(list(mean = 0.8, sd = 2), list(meanlog = 0, sdlog = 0.8))
# cop <- normalCopula(param = true_rho, dim = 2)
# mvdc_copula <- mvdc(cop, margins = margins, paramMargins = params)
# data <- rMvdc(n, mvdc_copula)
# 
# fit <- fit_bivariate_copula(data,
#   copula = "gaussian", marginals = c("normal", "lognormal"),
#   seed = seed
# )
# fit
# summary(fit)
# coef(fit)

## -----------------------------------------------------------------------------
# seed <- 2024
# set.seed(seed)
# true_rho <- 0.5
# n <- 2000
# 
# margins <- c("norm", "exp")
# params <- list(list(mean = 0.8, sd = 2), list(rate = 1))
# cop <- normalCopula(param = true_rho, dim = 2)
# mvdc_copula <- mvdc(cop, margins = margins, paramMargins = params)
# data <- rMvdc(n, mvdc_copula)
# 
# fit <- fit_bivariate_copula(data,
#   copula = "gaussian", marginals = c("normal", "exponential"),
#   seed = seed
# )
# fit

## -----------------------------------------------------------------------------
# seed <- 2024
# set.seed(seed)
# true_rho <- 0.5
# n <- 2000
# 
# margins <- c("beta", "beta")
# params <- list(list(shape1 = 2, shape2 = 5), list(shape1 = 3, shape2 = 4))
# cop <- normalCopula(param = true_rho, dim = 2)
# mvdc_copula <- mvdc(cop, margins = margins, paramMargins = params)
# data <- rMvdc(n, mvdc_copula)
# 
# fit <- fit_bivariate_copula(data,
#   copula = "gaussian", marginals = c("beta", "beta"),
#   seed = seed
# )
# fit

## -----------------------------------------------------------------------------
# seed <- 2024
# set.seed(seed)
# true_theta <- 2.0
# n <- 2000
# 
# margins <- c("norm", "lnorm")
# params <- list(list(mean = 0.8, sd = 2), list(meanlog = 0, sdlog = 0.8))
# cop <- claytonCopula(param = true_theta, dim = 2)
# mvdc_copula <- mvdc(cop, margins = margins, paramMargins = params)
# data <- rMvdc(n, mvdc_copula)
# 
# fit <- fit_bivariate_copula(data,
#   copula = "clayton", marginals = c("normal", "lognormal"),
#   seed = seed
# )
# fit

## -----------------------------------------------------------------------------
# seed <- 2024
# set.seed(seed)
# true_theta <- 2.0
# n <- 2000
# 
# margins <- c("norm", "lnorm")
# params <- list(list(mean = 0.8, sd = 2), list(meanlog = 0, sdlog = 0.8))
# cop <- joeCopula(param = true_theta, dim = 2)
# mvdc_copula <- mvdc(cop, margins = margins, paramMargins = params)
# data <- rMvdc(n, mvdc_copula)
# 
# fit <- fit_bivariate_copula(data,
#   copula = "joe", marginals = c("normal", "lognormal"),
#   seed = seed
# )
# fit

