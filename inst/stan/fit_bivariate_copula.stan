#include likelihood_functions.stan
data {
  int<lower=1> N; // number of observations
  vector[N] y1; // variable 1
  vector[N] y2; // variable 2
  int<lower=1, upper=4> dist1; // distribution for y1: 1=normal, 2=lognormal, 3=exponential, 4=beta
  int<lower=1, upper=4> dist2; // distribution for y2: 1=normal, 2=lognormal, 3=exponential, 4=beta
  int<lower=1, upper=3> copula_type; // copula: 1=gaussian, 2=clayton, 3=joe
}
parameters {
  // Marginal parameters for y1
  array[dist1 == 1 || dist1 == 2 ? 1 : 0] real mu1;
  array[dist1 == 1 || dist1 == 2 ? 1 : 0] real<lower=0> sigma1;
  array[dist1 == 3 ? 1 : 0] real<lower=0> lambda1;
  array[dist1 == 4 ? 1 : 0] real<lower=0> alpha1;
  array[dist1 == 4 ? 1 : 0] real<lower=0> beta1;
  
  // Marginal parameters for y2
  array[dist2 == 1 || dist2 == 2 ? 1 : 0] real mu2;
  array[dist2 == 1 || dist2 == 2 ? 1 : 0] real<lower=0> sigma2;
  array[dist2 == 3 ? 1 : 0] real<lower=0> lambda2;
  array[dist2 == 4 ? 1 : 0] real<lower=0> alpha2;
  array[dist2 == 4 ? 1 : 0] real<lower=0> beta2;
  
  // Copula parameters
  array[copula_type == 1 ? 1 : 0] real<lower=-1, upper=1> rho; // Gaussian copula
  array[copula_type == 2 ? 1 : 0] real<lower=0> theta_clayton; // Clayton copula
  array[copula_type == 3 ? 1 : 0] real<lower=1> theta_joe; // Joe copula (theta >= 1)
}
model {
  // Compute probability integral transforms
  vector[N] x1;
  vector[N] x2;
  
  if (dist1 == 1) {
    x1 = normal_cdf_vec(y1, mu1[1], sigma1[1]);
  } else if (dist1 == 2) {
    x1 = lognormal_cdf_vec(y1, mu1[1], sigma1[1]);
  } else if (dist1 == 3) {
    x1 = exponential_cdf_vec(y1, lambda1[1]);
  } else if (dist1 == 4) {
    x1 = beta_cdf_vec(y1, alpha1[1], beta1[1]);
  }
  
  if (dist2 == 1) {
    x2 = normal_cdf_vec(y2, mu2[1], sigma2[1]);
  } else if (dist2 == 2) {
    x2 = lognormal_cdf_vec(y2, mu2[1], sigma2[1]);
  } else if (dist2 == 3) {
    x2 = exponential_cdf_vec(y2, lambda2[1]);
  } else if (dist2 == 4) {
    x2 = beta_cdf_vec(y2, alpha2[1], beta2[1]);
  }
  
  // --- Priors ---
  
  // Marginal priors for y1
  if (dist1 == 1 || dist1 == 2) {
    mu1 ~ normal(0, 5);
    sigma1 ~ lognormal(0, 1);      // positive-constrained: median=1, wide
  } else if (dist1 == 3) {
    lambda1 ~ lognormal(0, 1);     // positive-constrained: median=1, wide
  } else if (dist1 == 4) {
    alpha1 ~ gamma(2, 0.5);
    beta1 ~ gamma(2, 0.5);
  }

  // Marginal priors for y2
  if (dist2 == 1 || dist2 == 2) {
    mu2 ~ normal(0, 5);
    sigma2 ~ lognormal(0, 1);      // positive-constrained: median=1, wide
  } else if (dist2 == 3) {
    lambda2 ~ lognormal(0, 1);     // positive-constrained: median=1, wide
  } else if (dist2 == 4) {
    alpha2 ~ gamma(2, 0.5);
    beta2 ~ gamma(2, 0.5);
  }

  // Copula priors
  if (copula_type == 1) {
    rho ~ uniform(-1, 1);
  } else if (copula_type == 2) {
    theta_clayton ~ lognormal(0, 1);   // positive-constrained: median=1
  } else if (copula_type == 3) {
    theta_joe ~ lognormal(log(2), 0.5); // lower-bounded at 1: median=2
  }
  
  // --- Marginal likelihoods ---
  
  if (dist1 == 1) {
    y1 ~ normal(mu1[1], sigma1[1]);
  } else if (dist1 == 2) {
    y1 ~ lognormal(mu1[1], sigma1[1]);
  } else if (dist1 == 3) {
    y1 ~ exponential(lambda1[1]);
  } else if (dist1 == 4) {
    y1 ~ beta(alpha1[1], beta1[1]);
  }
  
  if (dist2 == 1) {
    y2 ~ normal(mu2[1], sigma2[1]);
  } else if (dist2 == 2) {
    y2 ~ lognormal(mu2[1], sigma2[1]);
  } else if (dist2 == 3) {
    y2 ~ exponential(lambda2[1]);
  } else if (dist2 == 4) {
    y2 ~ beta(alpha2[1], beta2[1]);
  }
  
  // --- Copula log-likelihood ---
  
  if (copula_type == 1) {
    for (n in 1 : N) {
      target += gaussian_cop_loglik(x1[n], x2[n], rho[1]);
    }
  } else if (copula_type == 2) {
    for (n in 1 : N) {
      target += clayton_cop_loglik(x1[n], x2[n], theta_clayton[1]);
    }
  } else if (copula_type == 3) {
    for (n in 1 : N) {
      target += joe_cop_loglik(x1[n], x2[n], theta_joe[1]);
    }
  }
}
generated quantities {
  vector[N] log_lik; // pointwise log-likelihood for LOO-CV
  {
    vector[N] x1;
    vector[N] x2;
    
    if (dist1 == 1) {
      x1 = normal_cdf_vec(y1, mu1[1], sigma1[1]);
    } else if (dist1 == 2) {
      x1 = lognormal_cdf_vec(y1, mu1[1], sigma1[1]);
    } else if (dist1 == 3) {
      x1 = exponential_cdf_vec(y1, lambda1[1]);
    } else if (dist1 == 4) {
      x1 = beta_cdf_vec(y1, alpha1[1], beta1[1]);
    }
    
    if (dist2 == 1) {
      x2 = normal_cdf_vec(y2, mu2[1], sigma2[1]);
    } else if (dist2 == 2) {
      x2 = lognormal_cdf_vec(y2, mu2[1], sigma2[1]);
    } else if (dist2 == 3) {
      x2 = exponential_cdf_vec(y2, lambda2[1]);
    } else if (dist2 == 4) {
      x2 = beta_cdf_vec(y2, alpha2[1], beta2[1]);
    }
    
    for (n in 1 : N) {
      real ll_marginal = 0;
      real ll_copula = 0;
      
      // Marginal log-lik for observation n
      if (dist1 == 1) 
        ll_marginal += normal_lpdf(y1[n] | mu1[1], sigma1[1]);
      else if (dist1 == 2) 
        ll_marginal += lognormal_lpdf(y1[n] | mu1[1], sigma1[1]);
      else if (dist1 == 3) 
        ll_marginal += exponential_lpdf(y1[n] | lambda1[1]);
      else if (dist1 == 4) 
        ll_marginal += beta_lpdf(y1[n] | alpha1[1], beta1[1]);
      
      if (dist2 == 1) 
        ll_marginal += normal_lpdf(y2[n] | mu2[1], sigma2[1]);
      else if (dist2 == 2) 
        ll_marginal += lognormal_lpdf(y2[n] | mu2[1], sigma2[1]);
      else if (dist2 == 3) 
        ll_marginal += exponential_lpdf(y2[n] | lambda2[1]);
      else if (dist2 == 4) 
        ll_marginal += beta_lpdf(y2[n] | alpha2[1], beta2[1]);
      
      // Copula log-lik for observation n
      if (copula_type == 1) 
        ll_copula = gaussian_cop_loglik(x1[n], x2[n], rho[1]);
      else if (copula_type == 2) 
        ll_copula = clayton_cop_loglik(x1[n], x2[n], theta_clayton[1]);
      else if (copula_type == 3) 
        ll_copula = joe_cop_loglik(x1[n], x2[n], theta_joe[1]);
      
      log_lik[n] = ll_marginal + ll_copula;
    }
  }
}
