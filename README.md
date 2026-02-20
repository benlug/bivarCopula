# copulaStan [<img src="man/figures/copulaStan_hex.png" align="right" width="15%" height="15%" alt="copulaStan Logo"/>](https://benlug.github.io/copulaStan/)

<!-- badges: start -->
[![R-CMD-check](https://github.com/benlug/copulaStan/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/benlug/copulaStan/actions/workflows/R-CMD-check.yaml)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

**copulaStan** fits bivariate copula models with full Bayesian inference via [Stan](https://mc-stan.org/). It jointly estimates the copula dependence parameter and marginal distribution parameters, returning posterior draws for uncertainty quantification and model comparison.

## Why copulaStan?

Copulas separate the modeling of marginal distributions from the modeling of dependence. This lets you choose the best-fitting distribution for each variable independently, then capture how the variables relate through a copula function -- without restrictive joint distribution assumptions.

**copulaStan** makes this approach accessible in R with:

- **Full Bayesian inference** -- posterior distributions for all parameters, not just point estimates
- **Flexible marginals** -- mix and match Normal, Lognormal, Exponential, and Beta distributions
- **Multiple copula families** -- Gaussian, Clayton, and Joe copulas for different dependence structures
- **Built-in diagnostics** -- Rhat, ESS, and pointwise log-likelihoods for LOO-CV model comparison
- **Modern Stan backend** -- powered by CmdStan via cmdstanr for fast, reliable sampling

## Supported Models

### Copula Families

| Copula     | Parameter | Constraint | Dependence Structure         |
|------------|-----------|------------|------------------------------|
| Gaussian   | `rho`     | (-1, 1)    | Symmetric, no tail dependence |
| Clayton    | `theta`   | > 0        | Lower tail dependence        |
| Joe        | `theta`   | >= 1       | Upper tail dependence        |

### Marginal Distributions

| Distribution | Parameters        | Data Constraint         |
|--------------|-------------------|-------------------------|
| Normal       | `mu`, `sigma`     | --                      |
| Lognormal    | `mu`, `sigma`     | Data must be positive   |
| Exponential  | `lambda`          | Data must be positive   |
| Beta         | `alpha`, `beta`   | Data must be in (0, 1)  |

Each marginal can be set independently, giving 4 x 4 = 16 possible marginal combinations per copula family.

## Installation

**copulaStan** requires [CmdStan](https://mc-stan.org/cmdstanr/). Install it first if you have not already:

```r
install.packages("cmdstanr", repos = c("https://stan-dev.r-universe.dev", getOption("repos")))
cmdstanr::install_cmdstan()
```

Then install **copulaStan** from GitHub:

```r
# install.packages("devtools")
devtools::install_github("benlug/copulaStan")
```

## Quick Start

Simulate data from a Gaussian copula with normal and lognormal marginals, then recover the parameters:

```r
library(copulaStan)
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
print(fit)
#> -- Bivariate Copula Fit --------------------------------------------------------
#> Copula: gaussian
#> Marginals: "normal", "lognormal"
#> Data: 1000 observations
#> ----
#>   variable      mean  median     sd    mad      q5   q95 rhat ess_bulk ess_tail
#> 1 mu1[1]       0.024   0.024  0.032  0.032  -0.029 0.076 1.00     3814     2848
#> 2 sigma1[1]    1.005   1.005  0.023  0.023   0.967 1.042 1.00     3741     2751
#> 3 mu2[1]       0.014   0.014  0.026  0.027  -0.028 0.057 1.00     3710     2695
#> 4 sigma2[1]    0.812   0.811  0.019  0.019   0.781 0.844 1.00     3853     2874
#> 5 rho[1]       0.481   0.481  0.024  0.024   0.442 0.520 1.00     3918     2992

coef(fit)
#>     mu1[1]  sigma1[1]     mu2[1]  sigma2[1]     rho[1]
#>      0.024      1.005      0.014      0.812      0.481
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

- **[Get Started](https://benlug.github.io/copulaStan/articles/copulaStan-intro.html)** -- a comprehensive introduction with examples for all copula families, diagnostics, and prior specification.
- **[Function Reference](https://benlug.github.io/copulaStan/reference/index.html)** -- complete documentation for all exported functions and methods.
- **[Changelog](https://benlug.github.io/copulaStan/news/index.html)** -- version history and release notes.

## Getting Help

- Browse the [package website](https://benlug.github.io/copulaStan/) for documentation and vignettes.
- Report bugs or request features on [GitHub Issues](https://github.com/benlug/copulaStan/issues).
