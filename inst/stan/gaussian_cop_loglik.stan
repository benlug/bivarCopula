real gaussian_cop_loglik(real u, real v, real rho) {
  real rho_sq = square(rho);
  return (0.5 * rho * (-2. * u * v + square(u) * rho + square(v) * rho)) / (-1. + rho_sq)
         - 0.5 * log1m(rho_sq);
}
