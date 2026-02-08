# Convert `sim_com_results` to SpatRaster(s)

Converts simulated population abundance data from a `sim_com_results`
object (produced by
[`sim_com()`](https://popecol.github.io/mrangr/reference/sim_com.md))
into
[`SpatRaster`](https://rspatial.github.io/terra/reference/SpatRaster-class.html)
objects.

## Usage

``` r
# S3 method for class 'sim_com_results'
to_rast(
  obj,
  species = seq_len(dim(obj$N_map)[4]),
  time_points = obj$sim_time,
  ...
)
```

## Arguments

- obj:

  An object of class `sim_com_results`, returned by
  [`sim_com()`](https://popecol.github.io/mrangr/reference/sim_com.md).

- species:

  Integer vector. Species ID(s) to extract.

- time_points:

  Integer vector. Time step(s) to extract (excluding burn-in).

- ...:

  Currently unused.

## Value

- If `length(time_points) == 1`, returns a `SpatRaster` with species as
  layers.

- If `length(time_points) > 1`, returns a named list of `SpatRaster`
  objects, one per species.

- If only one species is selected with multiple time points, returns a
  single `SpatRaster`.

## Examples

``` r
# Read simulation data from the mrangr package
simulated_com <- get_simulated_com()

# Extract one timestep, all species
r1 <- to_rast(simulated_com, time_points = 10)

# Extract multiple timesteps, one species
r2 <- to_rast(simulated_com, species = 2, time_points = c(1, 5, 10))

# Extract multiple timesteps, multiple species
r3 <- to_rast(simulated_com, species = c(1, 2), time_points = c(1, 5, 10))

```
