# Example Of Carrying Capacity Map

[`SpatRaster`](https://rspatial.github.io/terra/reference/SpatRaster-class.html)
object with 4 layer that can be passed to
[`initialise_com`](initialise_com.md) a as simulation
([`sim_com`](sim_com.md)) starting point.

This map is compatible with [`n1_map_eg.tif`](n1_map_eg.tif.md).

## Format

[`SpatRaster`](https://rspatial.github.io/terra/reference/SpatRaster-class.html)
object with 4 layers, each with 15 rows and 15 columns. Contains numeric
values representing carrying capacity and NA's indicating unsuitable
areas.

## Source

Data generated in-house to serve as an example (using spatial
autocorrelation).

## Examples

``` r
terra::rast(system.file("input_maps/K_map_eg.tif", package = "mrangr"))
#> class       : SpatRaster 
#> size        : 15, 15, 4  (nrow, ncol, nlyr)
#> resolution  : 1000, 1000  (x, y)
#> extent      : 250000, 265000, 6e+05, 615000  (xmin, xmax, ymin, ymax)
#> coord. ref. : ETRF2000-PL / CS92 (EPSG:2180) 
#> source      : K_map_eg.tif 
#> names       :         1,         2,        3,         4 
#> min values  :  2.521231,  1.747702,  2.76080,  1.785377 
#> max values  : 32.832001, 18.041435, 25.07158, 24.817247 
```
