# Simulate Community Dynamics Over Time

This function simulates species interactions and population dynamics
over a given period. It accounts for species invasions and updates
population abundances at each time step.

## Usage

``` r
sim_com(obj, time, burn = 0, progress_bar = FALSE)
```

## Arguments

- obj:

  An object of class `sim_com_data`, as returned by
  [`initialise_com()`](initialise_com.md).

- time:

  Integer. Total number of simulation steps. Must be \>= 2.

- burn:

  Integer. Number of initial burn-in steps to exclude from the output.
  Must be \>= 0 and \< `time`.

- progress_bar:

  Logical. Whether to display a progress bar during the simulation.

## Value

An object of class `sim_com_results`, a list containing:

- extinction:

  Named logical vector indicating species that went extinct.

- sim_time:

  Integer. Duration of the output simulation (excluding burn-in).

- id:

  A
  [`SpatRaster`](https://rspatial.github.io/terra/reference/SpatRaster-class.html)
  object used as a geographic template.

- N_map:

  4D array \[rows, cols, time, species\] of population abundances.

## Examples

``` r
# \donttest{
# Read community data from the mrangr package
community <- get_community()

# Simulation
simulated_com_01 <- sim_com(obj = community, time = 10)

# Simulation with burned time steps
simulated_com_02 <- sim_com(obj = community, time = 10, burn = 3)
# }
```
