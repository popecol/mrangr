# Plot `sim_com_results` Object

Draws simulated abundance maps for any species at any time

## Usage

``` r
# S3 method for class 'sim_com_results'
plot(
  x,
  species = seq_len(dim(x$N_map)[4]),
  time_points = x$sim_time,
  type = "continuous",
  main,
  range,
  ...
)
```

## Arguments

- x:

  An object of class `sim_com_results`, returned by
  [`sim_com()`](sim_com.md).

- species:

  Integer vector. Species ID(s) to plot.

- time_points:

  Integer vector. Time step(s) to plot (excluding burn-in).

- type:

  Character vector of length 1. Type of map: "continuous" (default),
  "classes" or "interval" (case-sensitive)

- main:

  Character vector. Plot titles (one for each layer)

- range:

  Numeric vector of length 2. Range of values to be used for the legend
  (if `type = "continuous"`), which by default is calculated from the
  N_map slot of `sim_com_results` object

- ...:

  Further arguments passed to
  [`terra::plot`](https://rspatial.github.io/terra/reference/plot.html)

## Value

\#' \* If `length(time_points) == 1`, returns a `SpatRaster` with
species as layers.

- If only one species is selected with multiple time points, returns a
  single `SpatRaster`.

## Examples

``` r
# Read simulation data from the mrangr package
simulated_com <- get_simulated_com()

# Plot
plot(simulated_com)

```
