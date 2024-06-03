# copulaStan

The `copulaStan` package provides functions to fit bivariate Gaussian and Clayton copula models using Stan. These models can handle both normal and non-normal marginals. 

## Installation

You can install the development version of `copulaStan` from ![GitHub](https://github.com/benlug/copulaStan) with:

```r
# install.packages("devtools")
devtools::install_github("yourusername/copulaStan")
```

## Example

This is a basic example which shows you how to fit a bivariate Gaussian copula model:

```r
library(copula)
library(copulaStan)
library(rstan)

set.seed(123)
true_rho <- 0.5
cop <- normalCopula(param = true_rho, dim = 2)
U <- rCopula(1000, cop)

fit <- fit_gaussian_copula(U, iter = 3000, chains = 4, warmup = 1500, thin = 1, seed = 123, control = list(adapt_delta = 0.95, max_treedepth = 10), cores = 4)
print(summary(fit$fit))
```

