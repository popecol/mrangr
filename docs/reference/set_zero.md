# Set Non-Missing Values to Zero

This function takes an object and sets all non-missing values to zero,
while leaving missing values unchanged.

## Usage

``` r
set_zero(x)
```

## Arguments

- x:

  A vector or other object for which
  [`is.na()`](https://rdrr.io/r/base/NA.html) and subsetting with `[]`
  are defined (e.g., vector, data frame, SpatRaster).

## Value

An object of the same type as `x` with all originally non-missing
elements replaced by zero.

## Examples

``` r
# Example with a numeric vector
vec <- c(1, 2, NA, 4, NA, 5)
set_zero(vec)
#> [1]  0  0 NA  0 NA  0
```
