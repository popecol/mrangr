# Print `sim_com_data` Object

Print `sim_com_data` Object

## Usage

``` r
# S3 method for class 'sim_com_data'
print(x, ...)
```

## Arguments

- x:

  `sim_com_data` object; returned by the
  [`initialise_com`](https://popecol.github.io/mrangr/reference/initialise_com.md)
  function

- ...:

  further arguments passed to or from other methods; currently none
  specified

## Value

`sim_com_data` object is invisibly returned (the `x` param)

## Examples

``` r
# Read community data from the mrangr package
community <- get_community()

# Print
print(community)
#> Class: sim_com_data
#> 
#> Number of species: 4 
#> 
#> Species-specific parameters:
#>  species invader   r r_sd K_sd A dens_dep kernel  kernel_args
#>        1    TRUE 1.1    0    0 -      K2N "rexp" rate = 0.002
#>        2   FALSE 1.1    0    0 -      K2N "rexp" rate = 0.002
#>        3    TRUE 1.1    0    0 -      K2N "rexp" rate = 0.002
#>        4   FALSE 1.1    0    0 -      K2N "rexp" rate = 0.002
#> 
#> Max dispersal distance across species (used to calculate 'dlist'):
#>    2000
#> 
#> Border types:
#>    reprising 
#> 
#> K_map:
#> class       : SpatRaster 
#> size        : 15, 15, 4  (nrow, ncol, nlyr)
#> resolution  : 1000, 1000  (x, y)
#> extent      : 250000, 265000, 6e+05, 615000  (xmin, xmax, ymin, ymax)
#> coord. ref. : ETRF2000-PL / CS92 (EPSG:2180) 
#> source(s)   : memory
#> names       :         1,         2,        3,         4 
#> min values  :  2.521231,  1.747701,  2.76080,  1.785377 
#> max values  : 32.832002, 18.041435, 25.07158, 24.817247 
#> 
#> n1_map:
#> class       : SpatRaster 
#> size        : 15, 15, 4  (nrow, ncol, nlyr)
#> resolution  : 1000, 1000  (x, y)
#> extent      : 250000, 265000, 6e+05, 615000  (xmin, xmax, ymin, ymax)
#> coord. ref. : ETRF2000-PL / CS92 (EPSG:2180) 
#> source(s)   : memory
#> names       : 1,  2, 3,  4 
#> min values  : 0,  0, 0,  0 
#> max values  : 0, 20, 0, 31 
#> 
#> Competition matrix (a):
#>       1     2     3     4
#> 1    NA -1.04 -0.16 -0.56
#> 2 -0.32    NA  0.25 -0.45
#> 3 -1.27 -0.55    NA  0.24
#> 4 -0.64 -0.38  0.21    NA
#> 
#> Invasion settings:
#>   Invader species: 1, 3
#>   Propagule size: 1
#>   Invasion times (rows: species, columns: time step):
#> 
#>     t1 t2
#>   1  2  5
#>   3  2  5
```
