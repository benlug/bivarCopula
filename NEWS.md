# copulaStan 0.5.0

## Breaking Changes

* Migrated from `rstan` to `cmdstanr` for Stan model compilation and sampling.
  This requires `cmdstanr` and CmdStan to be installed.
* The return type of `fit_bivariate_copula()` is now a `copula_fit` S3 object
  (previously returned a raw `stanfit` S4 object).
* The `cores` argument is replaced by `parallel_chains`.
* The `control` argument is replaced by direct `adapt_delta` and `max_treedepth`
  arguments.
* Copula parameters are now named `rho[1]`, `theta_clayton[1]`, and
  `theta_joe[1]` (previously `rho[1]` and `theta[1]`).
* The Joe copula parameter `theta_joe` now has a lower bound of 1 (correct
  constraint per the Joe copula definition).

## Bug Fixes

* **Fixed incorrect Joe copula density formula.** The previous implementation
  did not match the standard derivation from the Joe copula CDF. Results from
  previous Joe copula fits are invalid.
* **Added CDF clamping** to prevent numerical issues (NaN/Inf) when marginal
  CDF values are exactly 0 or 1 during sampling.
* Fixed minor bug in Gaussian copula log-likelihood where `square(rho)` was
  computed twice instead of reusing `rho_sq`.
* Removed global side effect from `options(mc.cores = cores)`.

## New Features

* `copula_fit` S3 class with `print()`, `summary()`, and `coef()` methods for
  clean output and easy parameter extraction.
* Comprehensive input validation with informative error messages via `cli`.
* `generated quantities` block with pointwise `log_lik` for LOO-CV support.
* `refresh` argument to control sampling progress output.

## Improvements

* Updated Stan models to modern `array[]` syntax.
* Replaced heavy-tailed Cauchy priors with more appropriate defaults:
  Lognormal for scale parameters, Gamma for Beta shape parameters.
* Removed unused Stan functions and legacy Stan files
  (`fit_clayton_copula.stan`, `fit_joe_copula.stan`).
* Added R CMD check GitHub Actions workflow.
* Expanded test suite: input validation, parameter recovery, and S3 class tests.

## Dependencies

* Added: `cmdstanr`, `posterior`, `cli`
* Removed: `rstan`, `BH`, `RcppEigen`

# copulaStan 0.4.0

## New Features

* Added support for Exponential and Beta marginal distributions in
  `fit_bivariate_copula()`. Now supports: normal, lognormal, exponential,
  and beta.

## Bug Fixes

* Fixed minor bugs related to marginal distribution handling.

# copulaStan 0.3.1

## Improvements

* Unified copula functions into a single `fit_bivariate_copula()` entry point.

# copulaStan 0.3.0

## New Features

* Added `fit_gaussian_copula()` for bivariate Gaussian copula models with
  marginal parameter estimation. Supports normal and lognormal marginals.
* Included introductory vignette.

# copulaStan 0.2.0

## New Features

* Added functions to fit Clayton copula models.
* Improved documentation.

# copulaStan 0.1.0

## Initial Release

* Basic functionality to fit bivariate Gaussian copula models.
* Initial documentation and examples.
