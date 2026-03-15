# Fit Bivariate Copula Model

Fits a bivariate copula model to data with marginal parameter
estimation. Supports Gaussian, Clayton, and Joe copulas with normal,
lognormal, exponential, or beta marginal distributions. Uses CmdStan for
Bayesian inference via the `cmdstanr` package.

## Usage

``` r
fit_bivariate_copula(
  U,
  copula,
  marginals,
  iter = 1000,
  chains = 4,
  warmup = 1000,
  thin = 1,
  seed = NULL,
  adapt_delta = 0.8,
  max_treedepth = 10,
  parallel_chains = 1,
  refresh = 500
)
```

## Arguments

- U:

  A numeric matrix with exactly two columns containing the observed
  data. Each column corresponds to one variable.

- copula:

  Character string specifying the copula type. One of `"gaussian"`,
  `"clayton"`, or `"joe"`.

- marginals:

  A character vector of length 2 specifying the marginal distributions.
  Each element must be one of `"normal"`, `"lognormal"`,
  `"exponential"`, or `"beta"`.

- iter:

  Number of sampling iterations per chain (after warmup). Default is
  1000.

- chains:

  Number of MCMC chains. Default is 4.

- warmup:

  Number of warmup iterations per chain. Default is 1000.

- thin:

  Thinning rate. Default is 1.

- seed:

  Random seed for reproducibility. Default is `NULL`.

- adapt_delta:

  Target acceptance rate for NUTS. Default is 0.8.

- max_treedepth:

  Maximum tree depth for NUTS. Default is 10.

- parallel_chains:

  Number of chains to run in parallel. Default is 1.

- refresh:

  How often to print progress (in iterations). Set to 0 for silent.
  Default is 500.

## Value

A `copula_fit` object (S3 class) containing:

- `fit`:

  The underlying `CmdStanMCMC` object from `cmdstanr`, providing access
  to raw draws, diagnostics, and the Stan model.

- `copula`:

  Character string of the copula type used (e.g., `"gaussian"`).

- `marginals`:

  Character vector of length 2 with the marginal distribution names
  (e.g., `c("normal", "lognormal")`).

- `data_dim`:

  Integer vector of length 2 giving the dimensions of the input data
  (rows, columns).

## Supported Models

**Copula types:**

- `"gaussian"`:

  Gaussian (normal) copula with correlation parameter `rho` in (-1, 1).

- `"clayton"`:

  Clayton copula with dependence parameter `theta_clayton` \> 0.
  Captures lower-tail dependence.

- `"joe"`:

  Joe copula with dependence parameter `theta_joe` \>= 1. Captures
  upper-tail dependence.

**Marginal distributions:**

- `"normal"`:

  Normal distribution with parameters `mu` (location) and `sigma` (scale
  \> 0).

- `"lognormal"`:

  Log-normal distribution with parameters `mu` (log-location) and
  `sigma` (log-scale \> 0). Data must be positive.

- `"exponential"`:

  Exponential distribution with rate parameter `lambda` \> 0. Data must
  be positive.

- `"beta"`:

  Beta distribution with shape parameters `alpha` \> 0 and `beta` \> 0.
  Data must be in (0, 1).

## Priors

The Stan model uses the following weakly informative priors:

- Normal / Log-normal marginals:

  `mu ~ normal(0, 5)`, `sigma ~ lognormal(0, 1)` (median = 1).

- Exponential marginals:

  `lambda ~ lognormal(0, 1)` (median = 1).

- Beta marginals:

  `alpha ~ gamma(2, 0.5)`, `beta ~ gamma(2, 0.5)`.

- Gaussian copula:

  `rho ~ uniform(-1, 1)`.

- Clayton copula:

  `theta_clayton ~ lognormal(0, 1)` (median = 1).

- Joe copula:

  `theta_joe ~ lognormal(log(2), 0.5)` (median = 2, lower-bounded at 1).

## See also

[`print.copula_fit()`](https://benlug.github.io/bivarCopula/reference/print.copula_fit.md),
[`summary.copula_fit()`](https://benlug.github.io/bivarCopula/reference/summary.copula_fit.md),
[`coef.copula_fit()`](https://benlug.github.io/bivarCopula/reference/coef.copula_fit.md)

## Examples

``` r
if (FALSE) { # \dontrun{
library(copula)
library(bivarCopula)

set.seed(2024)
n <- 1000
cop <- normalCopula(param = 0.5, dim = 2)
margins <- c("norm", "lnorm")
params <- list(
  list(mean = 0.8, sd = 2),
  list(meanlog = 0, sdlog = 0.8)
)
mvdc_copula <- mvdc(cop, margins = margins, paramMargins = params)
data <- rMvdc(n, mvdc_copula)

fit <- fit_bivariate_copula(data,
  copula = "gaussian",
  marginals = c("normal", "lognormal"),
  seed = 2024
)
print(fit)
summary(fit)
coef(fit)
} # }
```
