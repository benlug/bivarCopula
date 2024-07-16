#include likelihood_functions.stan

data {
  int<lower=0> N;                  // number of observations
  vector[N] y1;                    // variable 1
  vector[N] y2;                    // variable 2
  int<lower=1, upper=4> dist1;     // distribution type for variable 1 (1 = normal, 2 = lognormal, 3 = exponential, 4 = beta)
  int<lower=1, upper=4> dist2;     // distribution type for variable 2 (1 = normal, 2 = lognormal, 3 = exponential, 4 = beta)
  int<lower=1, upper=3> copula_type; // copula type (1 = gaussian, 2 = clayton, 3 = joe)
}

parameters {
  real mu1[dist1 == 1 || dist1 == 2 ? 1 : 0];    // mean for y1 (if normal or lognormal)
  real<lower=0> sigma1[dist1 == 1 || dist1 == 2 ? 1 : 0];  // standard deviation for y1 (if normal or lognormal)
  real<lower=0> lambda1[dist1 == 3 ? 1 : 0]; // rate for y1 (if exponential)
  real<lower=0> alpha1[dist1 == 4 ? 1 : 0];  // alpha for y1 (if beta)
  real<lower=0> beta1[dist1 == 4 ? 1 : 0];   // beta for y1 (if beta)

  real mu2[dist2 == 1 || dist2 == 2 ? 1 : 0];    // mean for y2 (if normal or lognormal)
  real<lower=0> sigma2[dist2 == 1 || dist2 == 2 ? 1 : 0];  // standard deviation for y2 (if normal or lognormal)
  real<lower=0> lambda2[dist2 == 3 ? 1 : 0]; // rate for y2 (if exponential)
  real<lower=0> alpha2[dist2 == 4 ? 1 : 0];  // alpha for y2 (if beta)
  real<lower=0> beta2[dist2 == 4 ? 1 : 0];   // beta for y2 (if beta)

  real<lower=-1, upper=1> rho[copula_type == 1 ? 1 : 0];     // copula correlation parameter of y1 and y2 (for Gaussian copula)
  real<lower=0> theta[copula_type != 1 ? 1 : 0];             // copula parameter (for Clayton and Joe copulas)
}

model {

  // intermediate quantities to not be written out
  vector[N] x1;
  vector[N] x2;

  if (dist1 == 1) {
    x1 = gaussian_marginal_cdf_vec(y1, mu1[1], sigma1[1]);
  } else if (dist1 == 2) {
    x1 = lognormal_marginal_cdf_vec(y1, mu1[1], sigma1[1]);
  } else if (dist1 == 3) {
    x1 = exponential_marginal_cdf_vec(y1, lambda1[1]);
  } else if (dist1 == 4) {
    x1 = beta_marginal_cdf_vec(y1, alpha1[1], beta1[1]);
  }

  if (dist2 == 1) {
    x2 = gaussian_marginal_cdf_vec(y2, mu2[1], sigma2[1]);
  } else if (dist2 == 2) {
    x2 = lognormal_marginal_cdf_vec(y2, mu2[1], sigma2[1]);
  } else if (dist2 == 3) {
    x2 = exponential_marginal_cdf_vec(y2, lambda2[1]);
  } else if (dist2 == 4) {
    x2 = beta_marginal_cdf_vec(y2, alpha2[1], beta2[1]);
  }

  // Priors
  if (dist1 == 1 || dist1 == 2) {
    mu1 ~ normal(0, 1);
    sigma1 ~ cauchy(0, 2);         // prior for standard deviation of y1
  } else if (dist1 == 3) {
    lambda1 ~ cauchy(0, 2);        // prior for rate of y1
  } else if (dist1 == 4) {
    alpha1 ~ cauchy(0, 2);
    beta1 ~ cauchy(0, 2);
  }

  if (dist2 == 1 || dist2 == 2) {
    mu2 ~ normal(0, 1);
    sigma2 ~ cauchy(0, 2);         // prior for standard deviation of y2
  } else if (dist2 == 3) {
    lambda2 ~ cauchy(0, 2);        // prior for rate of y2
  } else if (dist2 == 4) {
    alpha2 ~ cauchy(0, 2);
    beta2 ~ cauchy(0, 2);
  }

  if (copula_type == 1) {
    rho ~ uniform(-1, 1);            // prior for Gaussian copula correlation parameter
  } else {
    theta ~ cauchy(0, 2);            // prior for Clayton and Joe copula parameter
  }

  // marginal distribution for y1
  if (dist1 == 1) {
    y1 ~ normal(mu1[1], sigma1[1]);
  } else if (dist1 == 2) {
    y1 ~ lognormal(mu1[1], sigma1[1]);
  } else if (dist1 == 3) {
    y1 ~ exponential(lambda1[1]);
  } else if (dist1 == 4) {
    y1 ~ beta(alpha1[1], beta1[1]);
  }

  // marginal distribution for y2
  if (dist2 == 1) {
    y2 ~ normal(mu2[1], sigma2[1]);
  } else if (dist2 == 2) {
    y2 ~ lognormal(mu2[1], sigma2[1]);
  } else if (dist2 == 3) {
    y2 ~ exponential(lambda2[1]);
  } else if (dist2 == 4) {
    y2 ~ beta(alpha2[1], beta2[1]);
  }

  // Copula log-likelihood
  if (copula_type == 1) {
    for (n in 1:N) {
      target += gaussian_cop_loglik(x1[n], x2[n], rho[1]);
    }
  } else if (copula_type == 2) {
    for (n in 1:N) {
      target += clayton_copula_log_density(x1[n], x2[n], theta[1]);
    }
  } else if (copula_type == 3) {
    for (n in 1:N) {
      target += joe_copula_log_density(x1[n], x2[n], theta[1]);
    }
  }
}

