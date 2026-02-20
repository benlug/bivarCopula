# tests/testthat/test-input_validation.R

# --- Data type and shape validation ---

test_that("errors when U is not a matrix", {
    expect_error(
        fit_bivariate_copula(data.frame(x = 1:10, y = 1:10),
            copula = "gaussian", marginals = c("normal", "normal")
        ),
        "must be a numeric matrix"
    )
})

test_that("errors when U has wrong number of columns", {
    expect_error(
        fit_bivariate_copula(matrix(1:30, ncol = 3),
            copula = "gaussian", marginals = c("normal", "normal")
        ),
        "must have exactly 2 columns"
    )
    expect_error(
        fit_bivariate_copula(matrix(1:10, ncol = 1),
            copula = "gaussian", marginals = c("normal", "normal")
        ),
        "must have exactly 2 columns"
    )
})

test_that("errors when U contains non-numeric values", {
    U <- matrix(c("a", "b", "c", "d"), ncol = 2)
    expect_error(
        fit_bivariate_copula(U, copula = "gaussian", marginals = c("normal", "normal")),
        "must be numeric"
    )
})

test_that("errors when U contains NA values", {
    U <- matrix(c(1, 2, NA, 4, 5, 6), ncol = 2)
    expect_error(
        fit_bivariate_copula(U, copula = "gaussian", marginals = c("normal", "normal")),
        "must not contain NA"
    )
})

test_that("errors when U contains NaN values", {
    U <- matrix(c(1, 2, NaN, 4, 5, 6), ncol = 2)
    expect_error(
        fit_bivariate_copula(U, copula = "gaussian", marginals = c("normal", "normal")),
        "must not contain"
    )
})

test_that("errors when U contains Inf values", {
    U <- matrix(c(1, 2, Inf, 4, 5, 6), ncol = 2)
    expect_error(
        fit_bivariate_copula(U, copula = "gaussian", marginals = c("normal", "normal")),
        "must not contain"
    )
})

# --- Observation count ---

test_that("errors when U has a single observation", {
    U <- matrix(c(1, 2), nrow = 1, ncol = 2)
    expect_error(
        fit_bivariate_copula(U, copula = "gaussian", marginals = c("normal", "normal")),
        "at least 2 observations"
    )
})

test_that("errors when U has zero rows", {
    U <- matrix(numeric(0), nrow = 0, ncol = 2)
    expect_error(
        fit_bivariate_copula(U, copula = "gaussian", marginals = c("normal", "normal")),
        "at least 2 observations"
    )
})

test_that("accepts U with exactly 2 observations", {
    # 2 observations is the minimum; should pass input validation.
    # This will fail at the Stan step (no cmdstan), so we call validate_inputs directly.
    U <- matrix(c(1, 2, 3, 4), ncol = 2)
    expect_true(
        copulaStan:::validate_inputs(U, copula = "gaussian", marginals = c("normal", "normal"))
    )
})

# --- Variance check ---

test_that("errors when a column has zero variance", {
    U <- matrix(c(5, 5, 5, 5, 1, 2, 3, 4), ncol = 2)
    expect_error(
        fit_bivariate_copula(U, copula = "gaussian", marginals = c("normal", "normal")),
        "near-zero variance"
    )
})

# --- Copula argument ---

test_that("errors when copula is invalid", {
    U <- matrix(rnorm(20), ncol = 2)
    expect_error(
        fit_bivariate_copula(U, copula = "frank", marginals = c("normal", "normal")),
        "must be one of"
    )
})

test_that("errors when copula has length > 1", {
    U <- matrix(rnorm(20), ncol = 2)
    expect_error(
        fit_bivariate_copula(U, copula = c("gaussian", "clayton"),
                             marginals = c("normal", "normal")),
        "must be one of"
    )
})

# --- Marginals argument ---

test_that("errors when marginals contains invalid name", {
    U <- matrix(rnorm(20), ncol = 2)
    expect_error(
        fit_bivariate_copula(U, copula = "gaussian", marginals = c("normal", "gamma")),
        "must be one of"
    )
})

test_that("errors when marginals has wrong length", {
    U <- matrix(rnorm(20), ncol = 2)
    expect_error(
        fit_bivariate_copula(U, copula = "gaussian", marginals = c("normal")),
        "length 2"
    )
    expect_error(
        fit_bivariate_copula(U, copula = "gaussian",
                             marginals = c("normal", "normal", "normal")),
        "length 2"
    )
})

# --- Data-distribution compatibility ---

test_that("errors when lognormal marginal receives non-positive values", {
    U <- matrix(c(-1, 2, 3, 4, 5, 6), ncol = 2)
    expect_error(
        fit_bivariate_copula(U, copula = "gaussian", marginals = c("lognormal", "normal")),
        "must be positive"
    )
})

test_that("errors when exponential marginal receives non-positive values", {
    U <- matrix(c(-1, 2, 3, 4, 5, 6), ncol = 2)
    expect_error(
        fit_bivariate_copula(U, copula = "gaussian", marginals = c("exponential", "normal")),
        "must be positive"
    )
})

test_that("errors when lognormal marginal receives zero values", {
    U <- matrix(c(0, 2, 3, 4, 5, 6), ncol = 2)
    expect_error(
        fit_bivariate_copula(U, copula = "gaussian", marginals = c("lognormal", "normal")),
        "must be positive"
    )
})

test_that("errors when exponential marginal receives zero values", {
    U <- matrix(c(0, 2, 3, 4, 5, 6), ncol = 2)
    expect_error(
        fit_bivariate_copula(U, copula = "gaussian", marginals = c("exponential", "normal")),
        "must be positive"
    )
})

test_that("errors when beta marginal receives values outside (0, 1)", {
    U <- matrix(c(0.1, 0.5, 1.5, 0.3, 0.4, 0.6), ncol = 2)
    expect_error(
        fit_bivariate_copula(U, copula = "gaussian", marginals = c("beta", "normal")),
        "must be in"
    )
})

test_that("errors when beta marginal receives value exactly at 0", {
    U <- matrix(c(0, 0.5, 0.3, 0.4, 0.6, 0.7), ncol = 2)
    expect_error(
        fit_bivariate_copula(U, copula = "gaussian", marginals = c("beta", "normal")),
        "must be in"
    )
})

test_that("errors when beta marginal receives value exactly at 1", {
    U <- matrix(c(1, 0.5, 0.3, 0.4, 0.6, 0.7), ncol = 2)
    expect_error(
        fit_bivariate_copula(U, copula = "gaussian", marginals = c("beta", "normal")),
        "must be in"
    )
})

test_that("errors when second column violates beta constraint", {
    U <- matrix(c(0.3, 0.4, 0.6, 0, 0.5, 0.7), ncol = 2)
    expect_error(
        fit_bivariate_copula(U, copula = "gaussian", marginals = c("normal", "beta")),
        "must be in"
    )
})

test_that("errors when second column violates positivity constraint", {
    U <- matrix(c(1, 2, 3, -1, 5, 6), ncol = 2)
    expect_error(
        fit_bivariate_copula(U, copula = "gaussian", marginals = c("normal", "lognormal")),
        "must be positive"
    )
})

# --- MCMC parameter validation ---

test_that("errors when iter is invalid", {
    U <- matrix(rnorm(20), ncol = 2)
    expect_error(
        fit_bivariate_copula(U, copula = "gaussian", marginals = c("normal", "normal"),
                             iter = -1),
        "iter"
    )
    expect_error(
        fit_bivariate_copula(U, copula = "gaussian", marginals = c("normal", "normal"),
                             iter = 0),
        "iter"
    )
})

test_that("errors when chains is invalid", {
    U <- matrix(rnorm(20), ncol = 2)
    expect_error(
        fit_bivariate_copula(U, copula = "gaussian", marginals = c("normal", "normal"),
                             chains = 0),
        "chains"
    )
})

test_that("errors when warmup is negative", {
    U <- matrix(rnorm(20), ncol = 2)
    expect_error(
        fit_bivariate_copula(U, copula = "gaussian", marginals = c("normal", "normal"),
                             warmup = -1),
        "warmup"
    )
})

test_that("errors when thin is invalid", {
    U <- matrix(rnorm(20), ncol = 2)
    expect_error(
        fit_bivariate_copula(U, copula = "gaussian", marginals = c("normal", "normal"),
                             thin = 0),
        "thin"
    )
})

test_that("errors when adapt_delta is out of (0, 1)", {
    U <- matrix(rnorm(20), ncol = 2)
    expect_error(
        fit_bivariate_copula(U, copula = "gaussian", marginals = c("normal", "normal"),
                             adapt_delta = 1.5),
        "adapt_delta"
    )
    expect_error(
        fit_bivariate_copula(U, copula = "gaussian", marginals = c("normal", "normal"),
                             adapt_delta = 0),
        "adapt_delta"
    )
    expect_error(
        fit_bivariate_copula(U, copula = "gaussian", marginals = c("normal", "normal"),
                             adapt_delta = 1),
        "adapt_delta"
    )
})

test_that("errors when parallel_chains exceeds chains", {
    U <- matrix(rnorm(20), ncol = 2)
    expect_error(
        fit_bivariate_copula(U, copula = "gaussian", marginals = c("normal", "normal"),
                             parallel_chains = 10, chains = 4),
        "parallel_chains"
    )
})

test_that("errors when seed is non-scalar", {
    U <- matrix(rnorm(20), ncol = 2)
    expect_error(
        fit_bivariate_copula(U, copula = "gaussian", marginals = c("normal", "normal"),
                             seed = c(1, 2)),
        "seed"
    )
})

test_that("errors when refresh is negative", {
    U <- matrix(rnorm(20), ncol = 2)
    expect_error(
        fit_bivariate_copula(U, copula = "gaussian", marginals = c("normal", "normal"),
                             refresh = -1),
        "refresh"
    )
})
