# bivarCopula [<img src="man/figures/bivarCopula_hex.png" align="right" width="15%" height="15%" alt="bivarCopula Logo"/>](https://benlug.github.io/bivarCopula/)

[![R-CMD-check](https://github.com/benlug/bivarCopula/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/benlug/bivarCopula/actions/workflows/R-CMD-check.yaml)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)

bivarCopula fits bivariate copula models with full Bayesian inference via [Stan](https://mc-stan.org/). It jointly estimates the copula dependence parameter and marginal distribution parameters, returning posterior draws for uncertainty quantification and model comparison.

## Why bivarCopula?

Copulas separate the modeling of marginal distributions from the modeling of dependence. This lets you choose the best-fitting distribution for each variable independently, then capture how the variables relate through a copula function without restrictive joint distribution assumptions.

bivarCopula makes this approach accessible in R with:

- Full Bayesian inference: posterior distributions for all parameters, not just point estimates
- Flexible marginals: mix and match Normal, Lognormal, Exponential, and Beta distributions
- Multiple copula families: Gaussian, Clayton, and Joe copulas for different dependence structures
- Built-in diagnostics: Rhat, ESS, and pointwise log-likelihoods for LOO-CV model comparison
- Modern Stan backend: powered by CmdStan via cmdstanr for fast, reliable sampling

## Supported Models

### Copula Families

- Gaussian: `rho` in `(-1, 1)` for symmetric dependence without tail dependence
- Clayton: `theta > 0` for lower tail dependence
- Joe: `theta >= 1` for upper tail dependence

### Marginal Distributions

- Normal: `mu`, `sigma`
- Lognormal: `mu`, `sigma`; data must be positive
- Exponential: `lambda`; data must be positive
- Beta: `alpha`, `beta`; data must be in `(0, 1)`

Each marginal can be set independently, giving 16 possible marginal combinations per copula family.

## Installation

bivarCopula requires [CmdStan](https://mc-stan.org/cmdstanr/). Install it first if you have not already:

```r
install.packages("cmdstanr", repos = c("https://stan-dev.r-universe.dev", getOption("repos")))
cmdstanr::install_cmdstan()
```

Then install bivarCopula from GitHub:

```r
# install.packages("devtools")
devtools::install_github("benlug/bivarCopula")
```

## Quick Start

Simulate data from a Gaussian copula with normal and lognormal marginals, then recover the parameters:

```r
library(bivarCopula)
library(copula)

# Simulate bivariate data
set.seed(123)
cop <- normalCopula(param = 0.5, dim = 2)
margins <- c("norm", "lnorm")
params <- list(list(mean = 0, sd = 1), list(meanlog = 0, sdlog = 0.8))
mvdc_copula <- mvdc(cop, margins = margins, paramMargins = params)
data <- rMvdc(1000, mvdc_copula)

# Fit the model
fit <- fit_bivariate_copula(data,
  copula = "gaussian",
  marginals = c("normal", "lognormal"),
  seed = 123
)

# Inspect results
summary(fit)
coef(fit)
```

Try a different copula family:

```r
# Clayton copula for lower tail dependence
fit_clay <- fit_bivariate_copula(data,
  copula = "clayton",
  marginals = c("normal", "lognormal"),
  seed = 123
)

# Compare models via LOO-CV
library(loo)
loo_gauss <- loo(fit$fit$draws("log_lik", format = "matrix"))
loo_clay <- loo(fit_clay$fit$draws("log_lik", format = "matrix"))
loo_compare(loo_gauss, loo_clay)
```

## Learning More

- [Get Started](https://benlug.github.io/bivarCopula/articles/bivarCopula-intro.html): a comprehensive introduction with examples for all copula families, diagnostics, and prior specification.
- [Function Reference](https://benlug.github.io/bivarCopula/reference/index.html): complete documentation for all exported functions and methods.
- [Changelog](https://benlug.github.io/bivarCopula/news/index.html): version history and release notes.

## Getting Help

- Browse the [package website](https://benlug.github.io/bivarCopula/) for documentation and vignettes.
- Report bugs or request features on [GitHub Issues](https://github.com/benlug/bivarCopula/issues).
