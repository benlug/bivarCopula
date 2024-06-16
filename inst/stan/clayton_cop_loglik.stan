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
