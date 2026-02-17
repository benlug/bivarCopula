functions {

  // ---------------------------------------------------------------------------
  // Gaussian Copula
  // ---------------------------------------------------------------------------

  real gaussian_cop_loglik(real u, real v, real rho) {
    real rho_sq = square(rho);
    real one_minus_rho_sq = 1 - rho_sq;
    real z1 = inv_Phi(u);
    real z2 = inv_Phi(v);

    return -0.5 * log(one_minus_rho_sq)
           + (rho * z1 * z2 - 0.5 * rho_sq * (square(z1) + square(z2)))
             / one_minus_rho_sq;
  }

  // ---------------------------------------------------------------------------
  // Clayton Copula
  // ---------------------------------------------------------------------------

  real clayton_cop_loglik(real u, real v, real theta) {
    real log_u = log(u);
    real log_v = log(v);
    real S = pow(u, -theta) + pow(v, -theta) - 1;

    return log(theta + 1)
           + (-theta - 1) * (log_u + log_v)
           - ((2 * theta + 1) / theta) * log(S);
  }

  // ---------------------------------------------------------------------------
  // Joe Copula
  //
  // CDF:  C(u,v) = 1 - [a + b - a*b]^(1/theta)
  //       where a = (1-u)^theta, b = (1-v)^theta
  //
  // Density (derived by differentiating twice):
  //   c(u,v) = theta * (1-u)^(theta-1) * (1-v)^(theta-1) * S^(1/theta - 2)
  //            * [ S + (theta-1)/theta * (1-a)*(1-b) ]
  //   where S = a + b - a*b
  //
  // ---------------------------------------------------------------------------

  real joe_cop_loglik(real u, real v, real theta) {
    real a = pow(1 - u, theta);
    real b = pow(1 - v, theta);
    real S = a + b - a * b;
    real bracket = S + (theta - 1) / theta * (1 - a) * (1 - b);

    return log(theta)
           + (theta - 1) * (log1m(u) + log1m(v))
           + (1.0 / theta - 2) * log(S)
           + log(bracket);
  }

  // ---------------------------------------------------------------------------
  // Marginal CDF helpers (with clamping to avoid boundary issues)
  // ---------------------------------------------------------------------------

  vector normal_cdf_vec(vector y, real mu, real sigma) {
    int N = num_elements(y);
    vector[N] cdf_vals;
    for (n in 1:N) {
      cdf_vals[n] = fmin(fmax(normal_cdf(y[n] | mu, sigma), 1e-10), 1 - 1e-10);
    }
    return cdf_vals;
  }

  vector lognormal_cdf_vec(vector y, real mu, real sigma) {
    int N = num_elements(y);
    vector[N] cdf_vals;
    for (n in 1:N) {
      cdf_vals[n] = fmin(fmax(lognormal_cdf(y[n] | mu, sigma), 1e-10), 1 - 1e-10);
    }
    return cdf_vals;
  }

  vector exponential_cdf_vec(vector y, real lambda) {
    int N = num_elements(y);
    vector[N] cdf_vals;
    for (n in 1:N) {
      cdf_vals[n] = fmin(fmax(exponential_cdf(y[n] | lambda), 1e-10), 1 - 1e-10);
    }
    return cdf_vals;
  }

  vector beta_cdf_vec(vector y, real alpha, real beta_param) {
    int N = num_elements(y);
    vector[N] cdf_vals;
    for (n in 1:N) {
      cdf_vals[n] = fmin(fmax(beta_cdf(y[n] | alpha, beta_param), 1e-10), 1 - 1e-10);
    }
    return cdf_vals;
  }
}
