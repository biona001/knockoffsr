# knockoffsr

knockoffsr is a package for performing variable selecting via the knockoff filter. It utilizes [Knockoffs.jl](https://github.com/biona001/Knockoffs.jl) at its core to provide high-performance routines of various model-X solvers (SDP, ME, MVR), sampling knockoffs, and computing feature importance scores. 

## Installation

```R
library(devtools)
install_github("biona001/knockoffsr")
```
Test package is successfully installed
```R
julia_dir = "/Applications/Julia-1.8.app/Contents/Resources/julia/bin" # path to Julia executable
library(knockoffsr)
ko <- knockoffsr::knockoff_setup(julia_dir)
```

## Usage

`knockoffsr` provides a direct wrapper over `Knockoffs.jl`. The namespace is setup so that the standard syntax of Julia translates directly over to the R environment. There are two things to keep in mind:

+ All `Knockoffs.jl` commands are prefaced by `ko$`
+ All commands with a `!` are replaced with `_bang`, for example `solve_s!` becomes `solve_s_bang`.

This syntax follows the practice of [diffeqr](https://github.com/SciML/diffeqr/tree/master).

## Example: Exact model-X group knockoffs

First setup the package
```R
julia_dir = "/Applications/Julia-1.8.app/Contents/Resources/julia/bin" # path to Julia executable
library(knockoffsr)
ko <- knockoffsr::knockoff_setup(julia_dir)
```
Next lets simulate `X ~ N(0, Sigma)` where `Sigma` is a symmetric Toesplitz matrix. Here we assume every 5 variables form a group
```R
n <- 1000          # number of samples
p <- 1000          # number of covariates
m <- 1             # number of knockoffs to generate per feature
groups = rep(1:200, each = 5)
Sigma <- toeplitz(0.7^(0:(p-1)))
mu <- rep(0, p)
X <- MASS::mvrnorm(n=n, mu=mu, Sigma=Sigma)
```
We generate model-X group knockoffs as follows
```R
solver <- "maxent" # Maximum entropy solver, other choices include "mvr", "sdp", "equi"
result <- ko$modelX_gaussian_group_knockoffs(X, solver, groups, mu, Sigma, verbose=TRUE)

Maxent initial obj = -2087.692936466681
Iter 1 (PCA): obj = -1607.437164111949, δ = 0.48068405334794, t1 = 0.08, t2 = 0.51
Iter 2 (CCD): obj = -1589.9518385891724, δ = 0.046537146748585216, t1 = 0.2, t2 = 1.72, t3 = 0.0
Iter 3 (PCA): obj = -1570.4491015280207, δ = 0.32338244109035785, t1 = 0.27, t2 = 2.23
Iter 4 (CCD): obj = -1562.5471454507465, δ = 0.028462155141070353, t1 = 0.39, t2 = 3.4, t3 = 0.0
Iter 5 (PCA): obj = -1557.1393033537292, δ = 0.12456084458147469, t1 = 0.52, t2 = 3.9
Iter 6 (CCD): obj = -1552.4489159484517, δ = 0.020754156607443626, t1 = 0.63, t2 = 5.08, t3 = 0.0
Iter 7 (PCA): obj = -1549.8106156569438, δ = 0.07012194156366308, t1 = 0.7, t2 = 5.59
Iter 8 (CCD): obj = -1547.020766696056, δ = 0.015614065719369137, t1 = 0.81, t2 = 6.71, t3 = 0.01
Iter 9 (PCA): obj = -1545.5310885752167, δ = 0.051170185931354716, t1 = 0.87, t2 = 7.22
Iter 10 (CCD): obj = -1543.8817717502172, δ = 0.013019011861969437, t1 = 0.98, t2 = 8.35, t3 = 0.01
Iter 11 (PCA): obj = -1542.9960966431306, δ = 0.04029486159842444, t1 = 1.04, t2 = 8.86
Iter 12 (CCD): obj = -1542.0192637205878, δ = 0.011386766045753434, t1 = 1.15, t2 = 10.0, t3 = 0.01
Iter 13 (PCA): obj = -1541.4898664708526, δ = 0.033102222474122915, t1 = 1.21, t2 = 10.51
Iter 14 (CCD): obj = -1540.900570416842, δ = 0.01023411502927556, t1 = 1.31, t2 = 11.64, t3 = 0.01
Iter 15 (PCA): obj = -1540.578996100881, δ = 0.027573434751228434, t1 = 1.39, t2 = 12.14
Iter 16 (CCD): obj = -1540.2216962317439, δ = 0.009352305423346552, t1 = 1.49, t2 = 13.26, t3 = 0.01
Iter 17 (PCA): obj = -1540.0257796341727, δ = 0.023457719731933214, t1 = 1.55, t2 = 13.76
Iter 18 (CCD): obj = -1539.806801955504, δ = 0.008629474061312124, t1 = 1.65, t2 = 14.89, t3 = 0.01
Iter 19 (PCA): obj = -1539.6892344905818, δ = 0.020162878516815832, t1 = 1.71, t2 = 15.39
Iter 20 (CCD): obj = -1539.5543495056943, δ = 0.007951906306608823, t1 = 1.81, t2 = 16.53, t3 = 0.02
```
To extract the knockoffs, S matrix, and the final objective as
```R
Xko <- result$Xko
S <- result$S
obj <- result$obj
```
