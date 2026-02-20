# tests/testthat/test-copula_fit.R
# Tests for the copula_fit S3 class constructor and copula_pars() helper.
# These tests do NOT require Stan/cmdstanr.

# --- Constructor ---

test_that("copula_fit() creates object with correct class", {
    obj <- copulaStan:::copula_fit(
        fit = NULL,
        copula = "gaussian",
        marginals = c("normal", "lognormal"),
        data_dim = c(100L, 2L)
    )
    expect_s3_class(obj, "copula_fit")
})

test_that("copula_fit() stores all fields", {
    fake_fit <- list(placeholder = TRUE)
    obj <- copulaStan:::copula_fit(
        fit = fake_fit,
        copula = "clayton",
        marginals = c("exponential", "beta"),
        data_dim = c(50L, 2L)
    )
    expect_identical(obj$fit, fake_fit)
    expect_identical(obj$copula, "clayton")
    expect_identical(obj$marginals, c("exponential", "beta"))
    expect_identical(obj$data_dim, c(50L, 2L))
})

# --- copula_pars() ---

test_that("copula_pars() returns mu/sigma for normal marginals and rho for gaussian copula", {
    obj <- copulaStan:::copula_fit(
        fit = NULL, copula = "gaussian",
        marginals = c("normal", "normal"), data_dim = c(10L, 2L)
    )
    pars <- copulaStan:::copula_pars(obj)
    expect_contains(pars, c("mu1[1]", "sigma1[1]", "mu2[1]", "sigma2[1]", "rho[1]"))
})

test_that("copula_pars() returns mu/sigma for lognormal marginals", {
    obj <- copulaStan:::copula_fit(
        fit = NULL, copula = "gaussian",
        marginals = c("lognormal", "lognormal"), data_dim = c(10L, 2L)
    )
    pars <- copulaStan:::copula_pars(obj)
    expect_contains(pars, c("mu1[1]", "sigma1[1]", "mu2[1]", "sigma2[1]"))
})

test_that("copula_pars() returns lambda for exponential marginals", {
    obj <- copulaStan:::copula_fit(
        fit = NULL, copula = "gaussian",
        marginals = c("exponential", "exponential"), data_dim = c(10L, 2L)
    )
    pars <- copulaStan:::copula_pars(obj)
    expect_contains(pars, c("lambda1[1]", "lambda2[1]", "rho[1]"))
    expect_false(any(grepl("^mu|^sigma", pars)))
})

test_that("copula_pars() returns alpha/beta for beta marginals", {
    obj <- copulaStan:::copula_fit(
        fit = NULL, copula = "gaussian",
        marginals = c("beta", "beta"), data_dim = c(10L, 2L)
    )
    pars <- copulaStan:::copula_pars(obj)
    expect_contains(pars, c("alpha1[1]", "beta1[1]", "alpha2[1]", "beta2[1]", "rho[1]"))
})

test_that("copula_pars() returns theta_clayton for Clayton copula", {
    obj <- copulaStan:::copula_fit(
        fit = NULL, copula = "clayton",
        marginals = c("normal", "normal"), data_dim = c(10L, 2L)
    )
    pars <- copulaStan:::copula_pars(obj)
    expect_contains(pars, "theta_clayton[1]")
    expect_false("rho[1]" %in% pars)
    expect_false("theta_joe[1]" %in% pars)
})

test_that("copula_pars() returns theta_joe for Joe copula", {
    obj <- copulaStan:::copula_fit(
        fit = NULL, copula = "joe",
        marginals = c("normal", "normal"), data_dim = c(10L, 2L)
    )
    pars <- copulaStan:::copula_pars(obj)
    expect_contains(pars, "theta_joe[1]")
    expect_false("rho[1]" %in% pars)
    expect_false("theta_clayton[1]" %in% pars)
})

test_that("copula_pars() handles mixed marginals correctly", {
    obj <- copulaStan:::copula_fit(
        fit = NULL, copula = "clayton",
        marginals = c("exponential", "beta"), data_dim = c(10L, 2L)
    )
    pars <- copulaStan:::copula_pars(obj)
    expect_contains(pars, c("lambda1[1]", "alpha2[1]", "beta2[1]", "theta_clayton[1]"))
    expect_false(any(c("mu1[1]", "sigma1[1]", "lambda2[1]") %in% pars))
})

# --- S3 method dispatch ---

test_that("print.copula_fit is registered and dispatches", {
    expect_true("print.copula_fit" %in% methods("print"))
})

test_that("summary.copula_fit is registered and dispatches", {
    expect_true("summary.copula_fit" %in% methods("summary"))
})

test_that("coef.copula_fit is registered and dispatches", {
    expect_true("coef.copula_fit" %in% methods("coef"))
})
