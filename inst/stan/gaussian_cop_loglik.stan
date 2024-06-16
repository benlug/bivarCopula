real gaussian_cop_loglik(real u, real v, real rho) {
  real rho_sq = square(rho);
  real inv_rho_sq = 1 - square(rho);
  real z1 = inv_Phi(u);
  real z2 = inv_Phi(v);
  real term1 = -0.5 * log(inv_rho_sq);
  real term2 = (rho * z1 * z2 - 0.5 * (square(z1) + square(z2)) * rho_sq) / inv_rho_sq;

  return term1 + term2;
}

real gaussian_copula_density(real u, real v, real rho) {
  real rho_sq = square(rho);
  real inv_rho_sq = 1 - rho_sq;
  real z1 = inv_Phi(u);
  real z2 = inv_Phi(v);
  real term1 = 1 / (2 * pi() * sqrt(inv_rho_sq));
  real term2 = exp(-0.5 * (square(z1) + square(z2) - 2 * rho * z1 * z2) / inv_rho_sq);

  return term1 * term2;
}
