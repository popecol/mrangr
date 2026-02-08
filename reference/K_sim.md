# Carrying Capacity Map Simulator

Generates multiple carrying capacity maps based on spatially
autocorrelated Gaussian Random Fields (GRFs), with optional correlation
between layers.

## Usage

``` r
K_sim(n, id, range, cor_mat = NULL, qfun = qnorm, ...)
```

## Arguments

- n:

  Integer. Number of maps to generate.

- id:

  A
  [`SpatRaster`](https://rspatial.github.io/terra/reference/SpatRaster-class.html)
  object used as a geographic template.

- range:

  Numeric. Spatial autocorrelation parameter passed to the `grf`
  function.

- cor_mat:

  Optional correlation matrix. If `NULL`, maps are generated
  independently.

- qfun:

  Quantile function to apply to the generated GRFs (default:
  [`qnorm`](https://rdrr.io/r/stats/Normal.html)).

- ...:

  Additional arguments passed to the quantile function `qfun`.

## Value

A
[`SpatRaster`](https://rspatial.github.io/terra/reference/SpatRaster-class.html)
object with `n` layers, each representing a carrying capacity map.

## Examples

``` r
library(terra)
#> terra 1.8.93
library(FieldSimR)

# Community parameters
nspec <- 3
nrows <- ncols <- 10
xmin <- 250000; xmax <- xmin + nrows * 1000
ymin <- 600000; ymax <- ymin + ncols * 1000
id <- rast(nrows = nrows, ncols = ncols, xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax)
crs(id) <- "epsg:2180"
plot(id)


# Correlation matrix of carrying capacities
cor_mat <- matrix(c(1, 0.29, 0.32, 0.29, 1, 0.32, 0.32, 0.32, 1), nrow = nspec, ncol = nspec)
cor_mat
#>      [,1] [,2] [,3]
#> [1,] 1.00 0.29 0.32
#> [2,] 0.29 1.00 0.32
#> [3,] 0.32 0.32 1.00

# Generate and define the distributions and parameters of correlated carrying capacity maps
K_map <- K_sim(nspec, id, range = 20000, cor_mat = cor_mat, qfun = qlnorm, meanlog = 2, sdlog = 0.5)
K_map
#> class       : SpatRaster 
#> size        : 10, 10, 3  (nrow, ncol, nlyr)
#> resolution  : 1000, 1000  (x, y)
#> extent      : 250000, 260000, 6e+05, 610000  (xmin, xmax, ymin, ymax)
#> coord. ref. : ETRF2000-PL / CS92 (EPSG:2180) 
#> source(s)   : memory
#> names       :         1,         2,         3 
#> min values  :  1.991756,  2.115014,  2.723308 
#> max values  : 26.002093, 22.648015, 16.972968 
hist(K_map)

plot(K_map)

```
