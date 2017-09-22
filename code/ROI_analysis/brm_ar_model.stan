// generated with brms 1.7.0
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

  // data needed for ARMA effects 
  int<lower=0> Kar;  // AR order 
  int<lower=0> Kma;  // MA order 
  int<lower=1> Karma;  // max(Kma, Kar) 
  vector[N] tg;  // indicates independent groups
  int prior_only;  // should the likelihood be ignored? 
} 
transformed data { 
  int Kc; 
  matrix[N, K - 1] Xc;  // centered version of X 
  vector[K - 1] means_X;  // column means of X before centering 
  Kc = K - 1;  // the intercept is removed from the design matrix 
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
  matrix[N_1, M_1] r_1; 
  vector[N_1] r_1_1; 
  vector[N_1] r_1_2; 
  r_1 = (diag_pre_multiply(sd_1, L_1) * z_1)'; 
  r_1_1 = r_1[, 1];  
  r_1_2 = r_1[, 2];  
} 
model { 
  vector[N] mu; 
  // objects storing residuals 
  matrix[N, Karma] E; 
  vector[N] e; 
  mu = Xc * b + temp_Intercept; 
  E = rep_matrix(0.0, N, Karma); 
  for (n in 1:N) { 
    mu[n] = mu[n] + (r_1_1[J_1[n]]) * Z_1_1[n] + (r_1_2[J_1[n]]) * Z_1_2[n]; 
    // computation of ARMA effects 
    e[n] = (Y[n]) - mu[n]; 
    for (i in 1:Karma) { 
      if (n + 1 - i > 0 && n < N && tg[n + 1] == tg[n + 1 - i]) { 
        E[n + 1, i] = e[n + 1 - i]; 
      } 
    } 
    mu[n] = mu[n] + head(E[n], Kar) * ar; 
  } 
  // prior specifications 
  sigma ~ student_t(3, 0, 10); 
  sd_1 ~ student_t(3, 0, 10); 
  L_1 ~ lkj_corr_cholesky(1); 
  to_vector(z_1) ~ normal(0, 1); 
  // likelihood contribution 
  if (!prior_only) { 
    Y ~ normal(mu, sigma); 
  } 
} 
generated quantities { 
  real b_Intercept;  // population-level intercept 
  corr_matrix[M_1] Cor_1; 
  vector<lower=-1,upper=1>[NC_1] cor_1; 
  b_Intercept = temp_Intercept - dot_product(means_X, b); 
  // take only relevant parts of correlation matrix 
  Cor_1 = multiply_lower_tri_self_transpose(L_1); 
  cor_1[1] = Cor_1[1,2]; 
} 