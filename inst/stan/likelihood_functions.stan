functions {

  // Gaussian Copula Likelihood and Loglikelihood

  real gaussian_copula_density(real u, real v, real rho) {
    real rho_sq = square(rho);
    real inv_rho_sq = 1 - rho_sq;
    real z1 = inv_Phi(u);
    real z2 = inv_Phi(v);
    real term1 = 1 / (2 * pi() * sqrt(inv_rho_sq));
    real term2 = exp(-0.5 * (square(z1) + square(z2) - 2 * rho * z1 * z2) / inv_rho_sq);

    return term1 * term2;
  }

  real gaussian_cop_loglik(real u, real v, real rho) {
    real rho_sq = square(rho);
    real inv_rho_sq = 1 - square(rho);
    real z1 = inv_Phi(u);
    real z2 = inv_Phi(v);
    real term1 = -0.5 * log(inv_rho_sq);
    real term2 = (rho * z1 * z2 - 0.5 * (square(z1) + square(z2)) * rho_sq) / inv_rho_sq;

    return term1 + term2;
  }

  // Clayton Copula Likelihood and Loglikelihood

  real clayton_copula_log_density(real u, real v, real theta) {
    real log_c = log(theta + 1);
    real log_u = log(u);
    real log_v = log(v);
    real sum_pow = pow(u, -theta) + pow(v, -theta) - 1;
    real term1 = (-theta - 1) * (log_u + log_v);
    real term2 = -((2 * theta + 1) / theta) * log(sum_pow);

    return log_c + term1 + term2;
  }

  real clayton_copula_density(real u, real v, real theta) {
    real term1 = theta + 1;
    real term2 = pow(u, -theta - 1);
    real term3 = pow(v, -theta - 1);
    real term4 = pow(u, -theta) + pow(v, -theta) - 1;
    real term5 = pow(term4, -1/theta - 2);

    return term1 * term2 * term3 * term5;
  }

  // Joe Copula Likelihood and Loglikelihood

  real joe_copula_log_density(real u1, real u2, real theta) {
    real t1 = -log(1 - u1);
    real t2 = -log(1 - u2);
    real l1 = exp(-pow(t1, theta));
    real l2 = exp(-pow(t2, theta));
    real l3 = exp(-pow(t1 + t2, theta));
    return log(theta) - (theta + 1) * (t1 + t2) + (l1 + l2 - l3);
  }

  // normal disitribution

  real gaussian_marginal_log_lik(vector y, real mu, real sigma) {
    return normal_lpdf(y | mu, sigma);
  }

  vector gaussian_marginal_cdf_vec(vector y, real mu, real sigma) {
    int N = num_elements(y);
    vector[N] cdf_vals;
    for (n in 1:N) {
      cdf_vals[n] = normal_cdf(y[n], mu, sigma);
    }
    return cdf_vals;
  }

  // lognormal distribution

  real lognormal_marginal_log_lik(vector y, real mu, real sigma) {
    return lognormal_lpdf(y | mu, sigma);
  }

  vector lognormal_marginal_cdf_vec(vector y, real mu, real sigma) {
    int N = num_elements(y);
    vector[N] cdf_vals;
    for (n in 1:N) {
      cdf_vals[n] = lognormal_cdf(y[n], mu, sigma);
    }
    return cdf_vals;
  }

  // exponential distribution

  real exponential_marginal_log_lik(vector y, real lambda) {
    return exponential_lpdf(y | lambda);
  }

  vector exponential_marginal_cdf_vec(vector y, real lambda) {
    int N = num_elements(y);
    vector[N] cdf_vals;
    for (n in 1:N) {
      cdf_vals[n] = exponential_cdf(y[n], lambda);
    }
    return cdf_vals;
  }

  // beta distribution

  vector beta_marginal_cdf_vec(vector y, real alpha, real beta) {
    int N = num_elements(y);
    vector[N] cdf_vals;
    for (n in 1:N) {
      cdf_vals[n] = beta_cdf(y[n], alpha, beta);
    }
    return cdf_vals;
  }
}
