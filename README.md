# copulaStan [<img src="man/figures/copulaStan_hex.png" align="right" width="15%" height="15%" alt="copulaStan Logo"/>](https://benlug.github.io/copulaStan/)

<!-- badges: start -->
[![R-CMD-check](https://github.com/benlug/copulaStan/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/benlug/copulaStan/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

## Overview

Copulas are functions that describe the dependence structure between random variables, separately from their marginal distributions. This separation makes them a flexible tool for modeling multivariate data with non-standard dependencies.

`copulaStan` fits bivariate copula models with full Bayesian inference via [Stan](https://mc-stan.org/). It jointly estimates the copula dependence parameter and marginal distribution parameters, returning posterior draws for uncertainty quantification and model comparison.

## Supported Models

| Copula     | Dependence parameter | Dependence structure         |
|------------|----------------------|------------------------------|
| Gaussian   | `rho` in (-1, 1)    | Symmetric, no tail dependence |
| Clayton    | `theta` > 0         | Lower tail dependence        |
| Joe        | `theta` >= 1        | Upper tail dependence        |

Each marginal can be independently set to one of:

- **Normal** -- parameters: `mu`, `sigma`
- **Lognormal** -- parameters: `mu`, `sigma` (data must be positive)
- **Exponential** -- parameter: `lambda` (data must be positive)
- **Beta** -- parameters: `alpha`, `beta` (data must be in (0, 1))

## Installation

`copulaStan` requires [CmdStan](https://mc-stan.org/cmdstanr/). Install it first if you have not already:

```r
install.packages("cmdstanr", repos = c("https://stan-dev.r-universe.dev", getOption("repos")))
cmdstanr::install_cmdstan()
```

Then install `copulaStan` from GitHub:

```r
# install.packages("devtools")
devtools::install_github("benlug/copulaStan")
```

## Example

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

Fit a Clayton copula instead:

```r
set.seed(123)
cop <- claytonCopula(param = 2.0, dim = 2)
mvdc_copula <- mvdc(cop, margins = margins, paramMargins = params)
data <- rMvdc(1000, mvdc_copula)

fit <- fit_bivariate_copula(data,
  copula = "clayton",
  marginals = c("normal", "lognormal"),
  seed = 123
)
coef(fit)
#>          mu1[1]       sigma1[1]          mu2[1]       sigma2[1] theta_clayton[1]
#>           0.006           0.998          -0.001           0.797            2.032
```

## Getting Help

- Browse the [pkgdown site](https://benlug.github.io/copulaStan/) for full documentation and the introductory vignette.
- Report bugs or request features on [GitHub Issues](https://github.com/benlug/copulaStan/issues).
