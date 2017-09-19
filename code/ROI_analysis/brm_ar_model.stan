// generated with brms 1.10.0
functions { 
} 
data { 
  int<lower=1> N;  // total number of observations 
  vector[N] Y;  // response variable 
  int<lower=1> K;  // number of population-level effects 
  matrix[N, K] X;  // population-level design matrix 
  // data for group-level effects of ID 1 
  int<lower=1> J_1[N]; 
  int<lower=1> N_1; 
  int<lower=1> M_1; 
  vector[N] Z_1_1; 
  vector[N] Z_1_2; 
  int<lower=1> NC_1; 
  // data needed for ARMA correlations 
  int<lower=0> Kar;  // AR order 
  int<lower=0> Kma;  // MA order 
  int<lower=0> J_lag[N]; 
  int prior_only;  // should the likelihood be ignored? 
} 
transformed data { 
  int Kc = K - 1; 
  matrix[N, K - 1] Xc;  // centered version of X 
  vector[K - 1] means_X;  // column means of X before centering 
  int max_lag = max(Kar, Kma); 
  for (i in 2:K) { 
    means_X[i - 1] = mean(X[, i]); 
    Xc[, i - 1] = X[, i] - means_X[i - 1]; 
  } 
} 
parameters { 
  vector[Kc] b;  // population-level effects 
  real temp_Intercept;  // temporary intercept 
  real<lower=0> sigma;  // residual SD 
  vector<lower=0>[M_1] sd_1;  // group-level standard deviations 
  matrix[M_1, N_1] z_1;  // unscaled group-level effects 
  // cholesky factor of correlation matrix 
  cholesky_factor_corr[M_1] L_1; 
  vector<lower=-1,upper=1>[Kar] ar;  // autoregressive effects 
} 
transformed parameters { 
  // group-level effects 
  matrix[N_1, M_1] r_1 = (diag_pre_multiply(sd_1, L_1) * z_1)'; 
  vector[N_1] r_1_1 = r_1[, 1]; 
  vector[N_1] r_1_2 = r_1[, 2]; 
} 
model { 
  vector[N] mu = Xc * b + temp_Intercept; 
  // objects storing residuals 
  matrix[N, max_lag] E = rep_matrix(0, N, max_lag); 
  vector[N] e; 
  for (n in 1:N) { 
    mu[n] = mu[n] + (r_1_1[J_1[n]]) * Z_1_1[n] + (r_1_2[J_1[n]]) * Z_1_2[n]; 
    // computation of ARMA correlations 
    e[n] = Y[n] - mu[n]; 
    for (i in 1:J_lag[n]) { 
      E[n + 1, i] = e[n + 1 - i]; 
    } 
    mu[n] = mu[n] + head(E[n], Kar) * ar; 
  } 
  // priors including all constants 
  target += student_t_lpdf(sigma | 3, 0, 10)
    - 1 * student_t_lccdf(0 | 3, 0, 10); 
  target += student_t_lpdf(sd_1 | 3, 0, 10)
    - 2 * student_t_lccdf(0 | 3, 0, 10); 
  target += lkj_corr_cholesky_lpdf(L_1 | 1); 
  target += normal_lpdf(to_vector(z_1) | 0, 1); 
  // likelihood including all constants 
  if (!prior_only) { 
    target += normal_lpdf(Y | mu, sigma); 
  } 
} 
generated quantities { 
  // actual population-level intercept 
  real b_Intercept = temp_Intercept - dot_product(means_X, b); 
  corr_matrix[M_1] Cor_1 = multiply_lower_tri_self_transpose(L_1); 
  vector<lower=-1,upper=1>[NC_1] cor_1; 
  // take only relevant parts of correlation matrix 
  cor_1[1] = Cor_1[1,2]; 
} 