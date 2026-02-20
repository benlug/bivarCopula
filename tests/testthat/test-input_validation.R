# tests/testthat/test-input_validation.R

test_that("rejects non-matrix input", {
    expect_error(
        fit_bivariate_copula(data.frame(x = 1:10, y = 1:10),
            copula = "gaussian", marginals = c("normal", "normal")
        ),
        "must be a numeric matrix"
    )
})

test_that("rejects matrix with wrong number of columns", {
    expect_error(
        fit_bivariate_copula(matrix(1:30, ncol = 3),
            copula = "gaussian", marginals = c("normal", "normal")
        ),
        "must have exactly 2 columns"
    )
})

test_that("rejects matrix with NA values", {
    U <- matrix(c(1, 2, NA, 4, 5, 6), ncol = 2)
    expect_error(
        fit_bivariate_copula(U, copula = "gaussian", marginals = c("normal", "normal")),
        "must not contain NA"
    )
})

test_that("rejects matrix with Inf values", {
    U <- matrix(c(1, 2, Inf, 4, 5, 6), ncol = 2)
    expect_error(
        fit_bivariate_copula(U, copula = "gaussian", marginals = c("normal", "normal")),
        "must not contain"
    )
})

test_that("rejects invalid copula name", {
    U <- matrix(rnorm(20), ncol = 2)
    expect_error(
        fit_bivariate_copula(U, copula = "frank", marginals = c("normal", "normal")),
        "must be one of"
    )
})

test_that("rejects invalid marginal name", {
    U <- matrix(rnorm(20), ncol = 2)
    expect_error(
        fit_bivariate_copula(U, copula = "gaussian", marginals = c("normal", "gamma")),
        "must be one of"
    )
})

test_that("rejects wrong length marginals", {
    U <- matrix(rnorm(20), ncol = 2)
    expect_error(
        fit_bivariate_copula(U, copula = "gaussian", marginals = c("normal")),
        "length 2"
    )
})

test_that("rejects negative values for lognormal marginals", {
    U <- matrix(c(-1, 2, 3, 4, 5, 6), ncol = 2)
    expect_error(
        fit_bivariate_copula(U, copula = "gaussian", marginals = c("lognormal", "normal")),
        "must be positive"
    )
})

test_that("rejects negative values for exponential marginals", {
    U <- matrix(c(-1, 2, 3, 4, 5, 6), ncol = 2)
    expect_error(
        fit_bivariate_copula(U, copula = "gaussian", marginals = c("exponential", "normal")),
        "must be positive"
    )
})

test_that("rejects out-of-range values for beta marginals", {
    U <- matrix(c(0.1, 0.5, 1.5, 0.3, 0.4, 0.6), ncol = 2)
    expect_error(
        fit_bivariate_copula(U, copula = "gaussian", marginals = c("beta", "normal")),
        "must be in"
    )
})

test_that("rejects matrix with fewer than 2 observations", {
    U <- matrix(c(1, 2), ncol = 2)
    expect_error(
        fit_bivariate_copula(U, copula = "gaussian", marginals = c("normal", "normal")),
        "at least 2 observations"
    )
})

test_that("rejects matrix with zero-variance column", {
    U <- matrix(c(5, 5, 5, 5, 1, 2, 3, 4), ncol = 2)
    expect_error(
        fit_bivariate_copula(U, copula = "gaussian", marginals = c("normal", "normal")),
        "near-zero variance"
    )
})

test_that("rejects invalid MCMC parameters", {
    U <- matrix(rnorm(20), ncol = 2)
    expect_error(
        fit_bivariate_copula(U, copula = "gaussian", marginals = c("normal", "normal"),
                             iter = -1),
        "iter"
    )
    expect_error(
        fit_bivariate_copula(U, copula = "gaussian", marginals = c("normal", "normal"),
                             adapt_delta = 1.5),
        "adapt_delta"
    )
    expect_error(
        fit_bivariate_copula(U, copula = "gaussian", marginals = c("normal", "normal"),
                             parallel_chains = 10, chains = 4),
        "parallel_chains"
    )
})
