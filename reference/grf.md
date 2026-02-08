# Generate a Gaussian Random Field

Generates a Gaussian random field (GRF) based on the Matern model of
spatial autocorrelation.

## Usage

``` r
grf(x, range, fun = "scale", ...)
```

## Arguments

- x:

  A template raster of class
  [`SpatRaster`](https://rspatial.github.io/terra/reference/SpatRaster-class.html)
  (from the terra package).

- range:

  Numeric. The range parameter of the variogram model (in spatial units
  of `x` raster).

- fun:

  A function to apply to the generated values (default is
  [`scale`](https://rdrr.io/r/base/scale.html) to standardize the GRF).

- ...:

  Additional arguments passed to the function specified in `fun`.

## Value

A
[`SpatRaster`](https://rspatial.github.io/terra/reference/SpatRaster-class.html)
object containing the generated Gaussian random field.

## Examples

``` r
library(terra)
r <- rast(nrows = 100, ncols = 100, xmin = 0, xmax = 100, ymin = 0, ymax = 100)
grf_field <- grf(r, range = 30)
plot(grf_field)


```
