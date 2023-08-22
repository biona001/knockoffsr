# knockoffsr

An interface to [Knockoffs.jl](https://github.com/biona001/Knockoffs.jl) from the R programming language. `knockoffsr` provides unique high performance methods for sampling various model-X knockoffs and ships with built-in routines for variable selection. Much of the functionality are unique and allow for orders of magnitude speedup over conventional methods. 'knockoffsr' attaches an R interface onto the package, allowing seamless use of this tooling by R users. 

## Installation

`knockoffsr` is not on CRAN yet. One can install the package using devtools:
```R
library(devtools)
install_github("biona001/knockoffsr")
```
Check installation is successful:
```R
library(knockoffsr)
ko <- knockoffsr::knockoff_setup()
```

## What if installation fails

1. **`install_github` does not work.** One can download the source code directly and install `knockoffsr` from a local file.
+ `wget -O knockoffsr.zip https://github.com/biona001/knockoffsr/archive/refs/heads/main.zip`
+ Within R, install package locally
```R
library(devtools)
devtools::install_local("knockoffsr.zip")
```

2. **Julia cannot be installed automatically.** In this case, one should manually install [Julia](https://julialang.org/downloads/), then give `knockoffsr` the path to Julia's executable
```R
library(knockoffsr)
julia_dir = "/Applications/Julia-1.8.app/Contents/Resources/julia/bin" # path to Julia executable
ko <- knockoffsr::knockoff_setup(julia_dir)
```

3. **Setup script for `JuliaCall` failed due to `LoadError` of from a `Global method definition` call** Please install the development version of [JuliaCall](https://github.com/Non-Contradiction/JuliaCall), see [this issue](https://github.com/Non-Contradiction/JuliaCall/issues/203) and [this issue](https://github.com/Non-Contradiction/JuliaCall/issues/205)
```R
library(devtools)
devtools::install_github("Non-Contradiction/JuliaCall")
```

If you encounter other installation errors, please file an issue on Github and I'll take a look asap.
 
## Usage

`knockoffsr` provides a direct wrapper over [`Knockoffs.jl`](https://github.com/biona001/Knockoffs.jl). The namespace is setup so that the standard syntax of Julia translates directly over to the R environment. There are 3 things to keep in mind:

+ All `Knockoffs.jl` commands are prefaced by `ko$`
+ All commands with a `!` are replaced with `_bang`, for example `solve_s!` becomes `solve_s_bang`.
+ All `Knockoffs.jl` functions that require a `Symmetric` matrix as inputs now accepts a regular matrix. However, for `hc_partition_groups` and `id_partition_groups`, one must set an extra argument `isSymmetric` to be `TRUE` or `FALSE`.

The first 2 syntax follows the practice of [diffeqr](https://github.com/SciML/diffeqr/tree/master).

## Documentation

Since `knockoffsr` is a wrapper of [`Knockoffs.jl`](https://github.com/biona001/Knockoffs.jl), the [documentation of Knockoffs.jl](https://biona001.github.io/Knockoffs.jl/dev/) will be the main source of documentation for `knockoffsr`.

## Example: Exact model-X group knockoffs

Lets simulate `X ~ N(0, Sigma)` where `Sigma` is a symmetric Toesplitz matrix. Here we assume every 5 variables form a group
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
