# Summarize a copula_fit object

Returns a tibble of posterior summaries for the model parameters,
including mean, median, standard deviation, MAD, quantiles, and
convergence diagnostics (Rhat, ESS).

## Usage

``` r
# S3 method for class 'copula_fit'
summary(object, ...)
```

## Arguments

- object:

  A `copula_fit` object.

- ...:

  Additional arguments (unused).

## Value

A tibble from
[`posterior::summarise_draws()`](https://mc-stan.org/posterior/reference/draws_summary.html)
with one row per parameter and columns for summary statistics and
diagnostics.

## Examples

``` r
if (FALSE) { # \dontrun{
fit <- fit_bivariate_copula(data,
  copula = "gaussian",
  marginals = c("normal", "lognormal")
)
summary(fit)
} # }
```
