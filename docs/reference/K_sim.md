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
#>            1         2             3            4
#> 1  1.0000000 0.3916460 -0.2157692814 0.2158205970
#> 2  0.3916460 1.0000000  0.1954567640 0.2116401899
#> 3 -0.2157693 0.1954568  1.0000000000 0.0009836659
#> 4  0.2158206 0.2116402  0.0009836659 1.0000000000

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
#> names       :        1,         2,         3,         4 
#> min values  :  2.26365,  2.834283,  2.632185,  2.416798 
#> max values  : 36.38108, 30.058541, 19.374650, 22.407833 
hist(K_map)

plot(K_map)

```
