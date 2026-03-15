# bivarCopula: Bayesian Bivariate Copula Models with Stan

[![bivarCopula
logo](reference/figures/bivarCopula_hex.png)](https://benlug.github.io/bivarCopula/)

`bivarCopula` is an R package for fitting Bayesian bivariate copula
models with [Stan](https://mc-stan.org/). It estimates marginal
distribution parameters and the copula dependence parameter jointly,
returning posterior draws for uncertainty quantification, convergence
diagnostics, and model comparison.

## Installation

`bivarCopula` depends on [`cmdstanr`](https://mc-stan.org/cmdstanr/) and
a working CmdStan installation.

Install `cmdstanr` and CmdStan:

``` r
install.packages(
  "cmdstanr",
  repos = c("https://stan-dev.r-universe.dev", getOption("repos"))
)
cmdstanr::install_cmdstan()
```

Install `bivarCopula` from GitHub:

``` r
install.packages("remotes")
remotes::install_github("benlug/bivarCopula")
```

## Example

The example below simulates data from a Gaussian copula with normal and
lognormal marginals, then fits the corresponding Bayesian model.

``` r
library(bivarCopula)
library(copula)

set.seed(123)

cop <- normalCopula(param = 0.5, dim = 2)
margins <- c("norm", "lnorm")
params <- list(
  list(mean = 0, sd = 1),
  list(meanlog = 0, sdlog = 0.8)
)

sim <- mvdc(copula = cop, margins = margins, paramMargins = params)
data <- rMvdc(1000, sim)

fit <- fit_bivariate_copula(
  data,
  copula = "gaussian",
  marginals = c("normal", "lognormal"),
  seed = 123
)

print(fit)
summary(fit)
coef(fit)
```

You can compare alternative copula families with `loo` using the stored
pointwise log-likelihood draws:

``` r
fit_clayton <- fit_bivariate_copula(
  data,
  copula = "clayton",
  marginals = c("normal", "lognormal"),
  seed = 123
)

library(loo)
loo_gaussian <- loo(fit$fit$draws("log_lik", format = "matrix"))
loo_clayton <- loo(fit_clayton$fit$draws("log_lik", format = "matrix"))
loo_compare(loo_gaussian, loo_clayton)
```

## Supported Models

### Copula Families

| Copula   | Parameter          | Interpretation                               |
|----------|--------------------|----------------------------------------------|
| Gaussian | `rho` in `(-1, 1)` | Symmetric dependence without tail dependence |
| Clayton  | `theta > 0`        | Lower-tail dependence                        |
| Joe      | `theta >= 1`       | Upper-tail dependence                        |

### Marginal Distributions

| Distribution | Parameters      | Data requirements |
|--------------|-----------------|-------------------|
| Normal       | `mu`, `sigma`   | None              |
| Lognormal    | `mu`, `sigma`   | Positive data     |
| Exponential  | `lambda`        | Positive data     |
| Beta         | `alpha`, `beta` | Data in `(0, 1)`  |

Each variable can use a different marginal distribution, giving 16
supported marginal combinations for each copula family.

## Documentation

- Package website: <https://benlug.github.io/bivarCopula/>
- Getting started article:
  <https://benlug.github.io/bivarCopula/articles/bivarCopula-intro.html>
- Function reference:
  <https://benlug.github.io/bivarCopula/reference/index.html>
- Changelog: <https://benlug.github.io/bivarCopula/news/index.html>

## Citation

If you use `bivarCopula` in your work, cite it with:

``` r
citation("bivarCopula")
```

## Getting Help

- Report bugs or request features at
  <https://github.com/benlug/bivarCopula/issues>
- For usage questions, include a minimal reproducible example when
  possible
