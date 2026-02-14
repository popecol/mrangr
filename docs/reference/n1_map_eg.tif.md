# Example Of Abundance Map At First Time Step Of The Simulation

[`SpatRaster`](https://rspatial.github.io/terra/reference/SpatRaster-class.html)
object with 4 layer that can be passed to
[`initialise_com`](https://popecol.github.io/mrangr/reference/initialise_com.md)
a as simulation
([`sim_com`](https://popecol.github.io/mrangr/reference/sim_com.md))
starting point.

This map is compatible with
[`K_map_eg.tif`](https://popecol.github.io/mrangr/reference/K_map_eg.tif.md).

## Format

[`SpatRaster`](https://rspatial.github.io/terra/reference/SpatRaster-class.html)
object with 4 layers, each with 15 rows and 15 columns. Contains integer
values representing abundance and NA's indicating unsuitable areas.

## Source

Data generated in-house to serve as an example.

## Examples

``` r
terra::rast(system.file("input_maps/n1_map_eg.tif", package = "mrangr"))
#> class       : SpatRaster 
#> size        : 15, 15, 4  (nrow, ncol, nlyr)
#> resolution  : 1000, 1000  (x, y)
#> extent      : 250000, 265000, 6e+05, 615000  (xmin, xmax, ymin, ymax)
#> coord. ref. : ETRF2000-PL / CS92 (EPSG:2180) 
#> source      : n1_map_eg.tif 
#> names       :  1,  2,  3,  4 
#> min values  :  1,  0,  0,  0 
#> max values  : 39, 20, 35, 31 
```
