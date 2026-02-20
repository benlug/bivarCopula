// likelihood_functions.stan
// Stan user-defined functions for copula log-densities and vectorised marginal
// CDF helpers.  Included by fit_bivariate_copula.stan via #include.

functions {

  // ---------------------------------------------------------------------------
  // Gaussian Copula
  //
  // Log-density of the Gaussian (normal) copula.
  //   c(u, v; rho) = (1 - rho^2)^{-1/2}
  //     * exp[ (rho*z1*z2 - 0.5*rho^2*(z1^2 + z2^2)) / (1 - rho^2) ]
  // where z1 = Phi^{-1}(u), z2 = Phi^{-1}(v).
  //
  // Parameter constraints: rho in (-1, 1).
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
  //
  // Log-density of the Clayton copula.
  //   c(u, v; theta) = (theta + 1) * (u*v)^{-(theta+1)}
  //     * (u^{-theta} + v^{-theta} - 1)^{-(2*theta+1)/theta}
  //
  // Parameter constraints: theta > 0  (theta = 0 gives independence).
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
  // Log-density of the Joe copula.
  //
  // CDF:  C(u,v) = 1 - [a + b - a*b]^{1/theta}
  //       where a = (1-u)^theta, b = (1-v)^theta
  //
  // Density (derived by differentiating the CDF twice):
  //   c(u,v) = theta * (1-u)^{theta-1} * (1-v)^{theta-1} * S^{1/theta - 2}
  //            * [ S + (theta-1)/theta * (1-a)*(1-b) ]
  //   where S = a + b - a*b
  //
  // Parameter constraints: theta >= 1  (theta = 1 gives independence).
  //
  // Note on tolerance: S and the bracket term are clamped to 1e-15 (tighter
  // than the 1e-10 used for CDF clamping) because when u, v are close to 1,
  // a and b approach 0 making S very small.  The tighter floor avoids
  // log(0) while preserving more precision in the tail of the density.
  // ---------------------------------------------------------------------------

  real joe_cop_loglik(real u, real v, real theta) {
    real a = pow(1 - u, theta);
    real b = pow(1 - v, theta);
    real S = fmax(a + b - a * b, 1e-15);  // guard against underflow when u,v near 1
    real bracket = fmax(S + (theta - 1) / theta * (1 - a) * (1 - b), 1e-15);

    return log(theta)
           + (theta - 1) * (log1m(u) + log1m(v))
           + (1.0 / theta - 2) * log(S)
           + log(bracket);
  }

  // ---------------------------------------------------------------------------
  // Marginal CDF helpers
  //
  // Each function computes the elementwise CDF of a vector, returning values
  // clamped to [1e-10, 1 - 1e-10].
  //
  // Why clamp?  Copula log-densities are undefined when u or v equal exactly
  // 0 or 1.  Without clamping, extreme CDF values cause:
  //   - Gaussian copula: inv_Phi(0) = -Inf, inv_Phi(1) = +Inf
  //   - Clayton copula:  log(0) = -Inf, pow(0, -theta) = Inf
  //   - Joe copula:      log1m(1) = -Inf
  //
  // Why 1e-10 (not smaller)?  This tolerance is small enough to have
  // negligible impact on inference while staying well above machine epsilon,
  // preventing NaN/Inf propagation in the log-likelihood.  (By contrast,
  // the Joe copula uses a tighter 1e-15 floor internally for its S term
  // because that quantity can legitimately approach zero in the density
  // computation without being a boundary artefact.)
  // ---------------------------------------------------------------------------

  // Vectorised Normal CDF with clamping.
  vector normal_cdf_vec(vector y, real mu, real sigma) {
    int N = num_elements(y);
    vector[N] cdf_vals;
    for (n in 1:N) {
      cdf_vals[n] = fmin(fmax(normal_cdf(y[n] | mu, sigma), 1e-10), 1 - 1e-10);
    }
    return cdf_vals;
  }

  // Vectorised Log-Normal CDF with clamping.
  vector lognormal_cdf_vec(vector y, real mu, real sigma) {
    int N = num_elements(y);
    vector[N] cdf_vals;
    for (n in 1:N) {
      cdf_vals[n] = fmin(fmax(lognormal_cdf(y[n] | mu, sigma), 1e-10), 1 - 1e-10);
    }
    return cdf_vals;
  }

  // Vectorised Exponential CDF with clamping.
  vector exponential_cdf_vec(vector y, real lambda) {
    int N = num_elements(y);
    vector[N] cdf_vals;
    for (n in 1:N) {
      cdf_vals[n] = fmin(fmax(exponential_cdf(y[n] | lambda), 1e-10), 1 - 1e-10);
    }
    return cdf_vals;
  }

  // Vectorised Beta CDF with clamping.
  vector beta_cdf_vec(vector y, real alpha, real beta_param) {
    int N = num_elements(y);
    vector[N] cdf_vals;
    for (n in 1:N) {
      cdf_vals[n] = fmin(fmax(beta_cdf(y[n] | alpha, beta_param), 1e-10), 1 - 1e-10);
    }
    return cdf_vals;
  }
}
