# Update `sim_com_data` Object

Updates the parameters used to create a `sim_com_data` object, returned
by
[`initialise_com()`](https://popecol.github.io/mrangr/reference/initialise_com.md).

## Usage

``` r
# S3 method for class 'sim_com_data'
update(object, ..., evaluate = TRUE)
```

## Arguments

- object:

  A `sim_com_data` object, as returned by
  [`initialise_com()`](https://popecol.github.io/mrangr/reference/initialise_com.md).

- ...:

  Named arguments to update. These should be valid arguments to
  [`initialise_com()`](https://popecol.github.io/mrangr/reference/initialise_com.md).
  If `kernel_fun` is updated, any associated `kernel_args` (if present
  in previous call) will also be replaced.

- evaluate:

  Logical (default `TRUE`). If `TRUE`, the function returns the
  re-evaluated updated object; if `FALSE`, it returns the updated
  function call without evaluating it.

## Value

If `evaluate = TRUE`, a new `sim_com_data` object with updated
parameters. If `evaluate = FALSE`, a `call` object representing the
updated function call.

## Details

- If dispersal-related arguments such as `max_dist`, `kernel_fun`, or
  `kernel_args` are changed, the existing `dlist` is removed and
  recalculated unless a new `dlist` is explicitly provided.

- If `n1_map` or `K_map` is updated, the `dlist` will also be removed to
  ensure consistency.

## See also

[`initialise_com()`](https://popecol.github.io/mrangr/reference/initialise_com.md)

## Examples

``` r
# \donttest{
library(terra)

# Read data from the mrangr package

## Input maps
K_map <- rast(system.file("input_maps/K_map_eg.tif", package = "mrangr"))
n1_map <- rast(system.file("input_maps/n1_map_eg.tif", package = "mrangr"))

## Competition coefficients matrix
a <- a_eg

# Initialise simulation parameters
community_01 <-
  initialise_com(
  K_map = K_map,
  r = 1.1,
  a = a,
  rate = 0.002)

# Update simulation parameters

# Custom kernel function
abs_rnorm <- function(n, mean, sd) {
  abs(rnorm(n, mean = mean, sd = sd))
}

community_02 <- update(community_01,
  kernel_fun = c("rexp", "rexp", "abs_rnorm", "abs_rnorm"),
  kernel_args = list(
   list(rate = 0.002),
   list(rate = 0.001),
   list(mean = 0, sd = 1000),
   list(mean = 0, sd = 2000)))
#> Error in get(as.character(FUN), mode = "function", envir = envir): object 'abs_rnorm' of mode 'function' was not found
# }
```
