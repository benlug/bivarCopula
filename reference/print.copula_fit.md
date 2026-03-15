# Print a copula_fit object

Displays a summary of the fitted copula model including the copula type,
marginal distributions, sample size, and a parameter summary table.

## Usage

``` r
# S3 method for class 'copula_fit'
print(x, ...)
```

## Arguments

- x:

  A `copula_fit` object.

- ...:

  Additional arguments (unused).

## Value

Invisibly returns the `copula_fit` object `x`, allowing usage in
pipelines.

## Examples

``` r
if (FALSE) { # \dontrun{
fit <- fit_bivariate_copula(data,
  copula = "gaussian",
  marginals = c("normal", "lognormal")
)
print(fit)
} # }
```
