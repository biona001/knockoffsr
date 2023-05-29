test_that("group knockoffs work", {
  library(Matrix)
  library(matrixcalc)
  ko <- knockoffsr::knockoff_setup("/Applications/Julia-1.8.app/Contents/Resources/julia/bin")

  # simulate data
  n <- 1000          # number of samples
  p <- 1000          # number of covariates
  m <- 1             # number of knockoffs to generate per feature
  groups = rep(1:200, each = 5)
  Sigma <- toeplitz(0.7^(0:(p-1)))
  mu <- rep(0, p)
  X <- MASS::mvrnorm(n=n, mu=mu, Sigma=Sigma)

  # exact model-X group knockoffs
  result <- ko$modelX_gaussian_group_knockoffs(X, "maxent", groups, mu, Sigma)
  S <- as.matrix(forceSymmetric(result$S))
  D <- as.matrix(forceSymmetric(2*result$Sigma - result$S))
  expect_true(is.positive.semi.definite(S, tol=1e-8))
  expect_true(is.positive.semi.definite(D, tol=1e-8))

  # 2nd order model-X group knockoffs
  result <- ko$modelX_gaussian_group_knockoffs(X, "maxent", groups)
  S <- as.matrix(forceSymmetric(result$S))
  D <- as.matrix(forceSymmetric(2*result$Sigma - result$S))
  expect_true(is.positive.semi.definite(S, tol=1e-8))
  expect_true(is.positive.semi.definite(D, tol=1e-8))
})
