# Compute Maximum Possible Distance for a Raster Object

Calculates the diagonal length of a raster's extent, accounting for the
coordinate reference system.

## Usage

``` r
diagonal(x)
```

## Arguments

- x:

  A raster object.

## Value

The diagonal distance in meteres.

## Examples

``` r
library(terra)
#> terra 1.8.93

# Read data from the mrangr package
K_map <- rast(system.file("input_maps/K_map_eg.tif", package = "mrangr"))

diagonal(K_map)
#> [1] 21214
```
