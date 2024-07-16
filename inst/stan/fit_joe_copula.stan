
#include joe_cop_loglik.stan

data {
  int<lower=1> N;  // number of observations
  vector[N] y1;    // first marginal
  vector[N] y2;    // second marginal
  int<lower=1> marginal1;  // 1 for normal, 2 for lognormal
  int<lower=1> marginal2;  // 1 for normal, 2 for lognormal
}

parameters {
  real<lower=1> theta;  // Joe copula parameter
  real mu1;    // Mean for first marginal (if normal)
  real<lower=0> sigma1;  // Standard deviation for first marginal (if normal)
  real mu2;    // Mean for second marginal (if normal)
  real<lower=0> sigma2;  // Standard deviation for second marginal (if normal)
  real<lower=0> meanlog1;  // Mean log for first marginal (if lognormal)
  real<lower=0> sdlog1;  // Standard deviation log for first marginal (if lognormal)
  real<lower=0> meanlog2;  // Mean log for second marginal (if lognormal)
  real<lower=0> sdlog2;  // Standard deviation log for second marginal (if lognormal)
}

model {
  // Priors
  theta ~ normal(2, 1);
  if (marginal1 == 1) {
    mu1 ~ normal(0, 1);
    sigma1 ~ cauchy(0, 1);
  } else if (marginal1 == 2) {
    meanlog1 ~ normal(0, 1);
    sdlog1 ~ cauchy(0, 1);
  }
  if (marginal2 == 1) {
    mu2 ~ normal(0, 1);
    sigma2 ~ cauchy(0, 1);
  } else if (marginal2 == 2) {
    meanlog2 ~ normal(0, 1);
    sdlog2 ~ cauchy(0, 1);
  }

  // Likelihood
  for (n in 1:N) {
    real u1;
    real u2;
    if (marginal1 == 1) {
      u1 = normal_cdf(y1[n], mu1, sigma1);
    } else if (marginal1 == 2) {
      u1 = lognormal_cdf(y1[n], meanlog1, sdlog1);
    }
    if (marginal2 == 1) {
      u2 = normal_cdf(y2[n], mu2, sigma2);
    } else if (marginal2 == 2) {
      u2 = lognormal_cdf(y2[n], meanlog2, sdlog2);
    }
    target += joe_copula_lpdf(u1, u2 | theta);
  }
}
