# copulaStan [<img src="man/figures/copulaStan_hex.png" align="right" width="15%" height="15%" alt="copulaStan Logo"/>](https://benlug.github.io/copulaStan/)

<!-- badges: start -->
[![R-CMD-check](https://github.com/benlug/copulaStan/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/benlug/copulaStan/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The `copulaStan` package fits bivariate Gaussian, Clayton, and Joe copula models using Stan. It supports normal, lognormal, exponential, and beta marginal distributions with full Bayesian inference via `cmdstanr`.

## Prerequisites

`copulaStan` requires [CmdStan](https://mc-stan.org/cmdstanr/) to be installed:

```r
install.packages("cmdstanr", repos = c("https://stan-dev.r-universe.dev", getOption("repos")))
cmdstanr::install_cmdstan()
```

## Installation

Install the development version from [GitHub](https://github.com/benlug/copulaStan):

```r
# install.packages("devtools")
devtools::install_github("benlug/copulaStan")
```

## Example

Fit a bivariate Gaussian copula model with normal and lognormal marginals:

```r
library(copula)
library(copulaStan)

set.seed(123)
n <- 1000
cop <- normalCopula(param = 0.5, dim = 2)
margins <- c("norm", "lnorm")
params <- list(list(mean = 0, sd = 1), list(meanlog = 0, sdlog = 0.8))
mvdc_copula <- mvdc(cop, margins = margins, paramMargins = params)
data <- rMvdc(n, mvdc_copula)

fit <- fit_bivariate_copula(data,
  copula = "gaussian",
  marginals = c("normal", "lognormal"),
  seed = 123
)
print(fit)
summary(fit)
coef(fit)
```

Fit a Clayton copula:

```r
set.seed(123)
cop <- claytonCopula(param = 2.0, dim = 2)
margins <- c("norm", "lnorm")
params <- list(list(mean = 0.8, sd = 2), list(meanlog = 0, sdlog = 0.8))
mvdc_copula <- mvdc(cop, margins = margins, paramMargins = params)
data <- rMvdc(1000, mvdc_copula)

fit <- fit_bivariate_copula(data,
  copula = "clayton",
  marginals = c("normal", "lognormal"),
  seed = 123
)
fit
```
