# Load Example Community Object

Loads a pre-simulated example of a spatial community object, useful for
demos and testing.

## Usage

``` r
get_community()
```

## Value

An object of class `sim_com_data` containing community structure,
simulation parameters, species-specific carrying capacity and initial
abundance maps.

## See also

[community_eg](https://popecol.github.io/mrangr/reference/community_eg.md)

## Examples

``` r
community <- get_community()
summary(community)
#> Summary of sim_com_data object
#> 
#> Input maps (K_map and n1_map) summary by species:
#>  species invader n1_min n1_mean n1_max K_min K_mean K_max
#>        1    TRUE      0    0.00      0  2.52   8.55 32.83
#>        2   FALSE      0    8.10     20  1.75   8.08 18.04
#>        3    TRUE      0    0.00      0  2.76   8.57 25.07
#>        4   FALSE      0    9.02     31  1.79   8.93 24.82
#> 
#> Species-specific parameters:
#>  species invader   r r_sd K_sd A dens_dep kernel  kernel_args
#>        1    TRUE 1.1    0    0 -      K2N "rexp" rate = 0.002
#>        2   FALSE 1.1    0    0 -      K2N "rexp" rate = 0.002
#>        3    TRUE 1.1    0    0 -      K2N "rexp" rate = 0.002
#>        4   FALSE 1.1    0    0 -      K2N "rexp" rate = 0.002
#> 
#> Interaction matrix (a):
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
