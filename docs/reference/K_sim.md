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
#>             1           2          3          4
#> 1  1.00000000 -0.46784586 0.33996773 0.05823598
#> 2 -0.46784586  1.00000000 0.03455013 0.39482726
#> 3  0.33996773  0.03455013 1.00000000 0.34111883
#> 4  0.05823598  0.39482726 0.34111883 1.00000000

# Generate and define the distributions and parameters
# of correlated carrying capacity maps
K_map <- K_sim(nspec, id, range = 20000, cor_mat = cor_mat, qfun = qlnorm,
               meanlog = 2, sdlog = 0.5)
K_map
#> class       : SpatRaster
#> size        : 10, 10, 4  (nrow, ncol, nlyr)
#> resolution  : 1000, 1000  (x, y)
#> extent      : 250000, 260000, 600000, 610000  (xmin, xmax, ymin, ymax)
#> coord. ref. : ETRF2000-PL / CS92 (EPSG:2180)
#> source(s)   : memory
#> names       :         1,         2,         3,         4
#> min values  :  2.272714,  1.702707,  1.854232,  2.107359
#> max values  : 26.548617, 22.608242, 18.601883, 30.741726
hist(K_map)

plot(K_map)

```
