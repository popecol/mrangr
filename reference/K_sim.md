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
nspec <- 4
nrows <- ncols <- 10
xmin <- 250000; xmax <- xmin + nrows * 1000
ymin <- 600000; ymax <- ymin + ncols * 1000
id <- rast(nrows = nrows, ncols = ncols, xmin = xmin, xmax = xmax,
                                         ymin = ymin, ymax = ymax)
crs(id) <- "epsg:2180"

# Correlation matrix of carrying capacities
cor_mat <- FieldSimR::rand_cor_mat(nspec, -0.5, 0.5, pos.def = TRUE)
#> 'cor_mat' is already positive (semi)-definite, matrix was not altered
cor_mat
#>              1          2          3            4
#> 1  1.000000000 -0.4926006 -0.0336065 -0.002222611
#> 2 -0.492600559  1.0000000 -0.2102328  0.232881987
#> 3 -0.033606503 -0.2102328  1.0000000  0.272521511
#> 4 -0.002222611  0.2328820  0.2725215  1.000000000

# Generate and define the distributions and parameters
# of correlated carrying capacity maps
K_map <- K_sim(nspec, id, range = 20000, cor_mat = cor_mat, qfun = qlnorm,
               meanlog = 2, sdlog = 0.5)
K_map
#> class       : SpatRaster 
#> size        : 10, 10, 4  (nrow, ncol, nlyr)
#> resolution  : 1000, 1000  (x, y)
#> extent      : 250000, 260000, 6e+05, 610000  (xmin, xmax, ymin, ymax)
#> coord. ref. : ETRF2000-PL / CS92 (EPSG:2180) 
#> source(s)   : memory
#> names       :         1,         2,         3,         4 
#> min values  :  2.577818,  3.131871,  1.651497,  1.147984 
#> max values  : 19.764208, 26.369231, 26.986155, 19.070624 
hist(K_map)

plot(K_map)

```
