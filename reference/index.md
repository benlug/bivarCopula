# Package index

## Fitting Models

The main function for specifying and fitting bivariate copula models
with flexible marginal distributions.

- [`fit_bivariate_copula()`](https://benlug.github.io/bivarCopula/reference/fit_bivariate_copula.md)
  : Fit Bivariate Copula Model

## Working with Results

S3 methods for inspecting fitted models, extracting posterior summaries,
and obtaining point estimates.

- [`print(`*`<copula_fit>`*`)`](https://benlug.github.io/bivarCopula/reference/print.copula_fit.md)
  : Print a copula_fit object
- [`summary(`*`<copula_fit>`*`)`](https://benlug.github.io/bivarCopula/reference/summary.copula_fit.md)
  : Summarize a copula_fit object
- [`coef(`*`<copula_fit>`*`)`](https://benlug.github.io/bivarCopula/reference/coef.copula_fit.md)
  : Extract point estimates from a copula_fit

## Internals

Internal constructor and utilities. These are documented for
transparency but are not intended for direct use.

- [`copula_fit()`](https://benlug.github.io/bivarCopula/reference/copula_fit.md)
  : Create a copula_fit object
- [`get_stan_model()`](https://benlug.github.io/bivarCopula/reference/get_stan_model.md)
  : Get the compiled Stan model (compiles on first use, caches for
  reuse)
