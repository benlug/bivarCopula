# Extract point estimates from a copula_fit

Returns posterior means of the model parameters as a named numeric
vector. Parameter names match those used in the Stan model (e.g.,
`"mu1[1]"`, `"sigma1[1]"`, `"rho[1]"`).

## Usage

``` r
# S3 method for class 'copula_fit'
coef(object, ...)
```

## Arguments

- object:

  A `copula_fit` object.

- ...:

  Additional arguments (unused).

## Value

A named numeric vector of posterior means, with one element per model
parameter.

## Examples

``` r
if (FALSE) { # \dontrun{
fit <- fit_bivariate_copula(data,
  copula = "gaussian",
  marginals = c("normal", "lognormal")
)
coef(fit)
} # }
```
