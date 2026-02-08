# Initialise Community Simulation Data

Prepares community-level input data for a spatial simulation. This
function builds on
[`rangr::initialise()`](https://docs.ropensci.org/rangr/reference/initialise.html)
by organising inputs for multiple species and their interactions.

## Usage

``` r
initialise_com(
  n1_map = NULL,
  K_map,
  r,
  a,
  dlist = NULL,
  invasion = NULL,
  use_names_K_map = TRUE,
  ...
)
```

## Arguments

- n1_map:

  A
  [`SpatRaster`](https://rspatial.github.io/terra/reference/SpatRaster-class.html)
  with one layer per species representing the initial abundance. If
  `NULL` (default), random initial values will be generated from a
  Poisson distribution using `K_map`.

- K_map:

  A
  [`SpatRaster`](https://rspatial.github.io/terra/reference/SpatRaster-class.html)
  with one layer per species representing carrying capacities.

- r:

  A numeric vector of intrinsic growth rates. It can be a single-element
  vector (if all species have the same intrinsic growth rate) or a
  vector of length equal to the number of species in the community.

- a:

  A square numeric matrix representing interaction coefficients between
  species. Each element `a_ij` is the per-capita interaction strength of
  species `j` on species `i`. It expresses the change in carrying
  capacity of species `i` by a single individual of species `j`. The
  diagonal must be `NA` and the matrix must be a square matrix of order
  equal to the number of species. It does not have to be symmetric.

- dlist:

  Optional. A list; target cells at a specified distance calculated for
  every cell within the study area.

- invasion:

  Optional. A named list of specifying invasion configuration (can be
  prepared using
  [`initialise_inv`](https://popecol.github.io/mrangr/reference/initialise_inv.md)).
  Must contain:

  invaders

  :   Integer vector of invading species indices.

  propagule_size

  :   Number of individuals introduced per invasion event.

  invasion_times

  :   Matrix of invasion times, with one row per invader.

- use_names_K_map:

  Logical. If `TRUE`, the layer names of `K_map` are used as species
  names. If `FALSE`, species are numbered sequentially
  (`1:number_of_species`). Defaults to `TRUE`.

- ...:

  Additional named arguments passed to
  [`initialise()`](https://docs.ropensci.org/rangr/reference/initialise.html).
  Each must be either length 1 or equal to the number of species.

  kernel_args

  :   Optional. A list of lists, each containing named arguments for the
      corresponding species' kernel function. Must be the same length as
      number of species.

## Value

A list of class `sim_com_data` containing:

- spec_data:

  A list of `sim_data` objects (one per species) returned by
  [`initialise()`](https://docs.ropensci.org/rangr/reference/initialise.html).

- nspec:

  The number of species.

- a:

  The interaction matrix.

- r:

  Intrinsic growth rate(s).

- n1_map:

  Initial abundance maps (wrapped `SpatRaster`).

- K_map:

  Carrying capacity maps (wrapped `SpatRaster`).

- max_dist:

  The maximum dispersal distance across all species.

- dlist:

  A list; target cells at a specified distance calculated for every cell
  within the study area.

- invasion:

  Invasion configuration (if any).

- call:

  The matched call.

## Examples

``` r
# \donttest{
library(terra)

# Read data from the mrangr package

## Input maps
K_map <- rast(system.file("input_maps/K_map_eg.tif", package = "mrangr"))
n1_map <- rast(system.file("input_maps/n1_map_eg.tif", package = "mrangr"))

## Interaction coefficients matrix
a <- a_eg

# Initialise simulation parameters
community_01 <-
  initialise_com(
  K_map = K_map,
  n1_map = n1_map,
  r = 1.1,
  a = a,
  rate = 0.002)

# With invaders
invasion <- initialise_inv(
  invaders = c(1, 3),
  invasion_times = c(2, 5))

community_02 <- initialise_com(
  K_map = K_map,
  r = 1.1,
  a = a,
  rate = 0.002,
  invasion = invasion)


# Custom kernel function
abs_rnorm <- function(n, mean, sd) {
  abs(rnorm(n, mean = mean, sd = sd))
}

community_03 <- initialise_com(
  K_map = K_map,
  n1_map = n1_map,
  r = c(1.1, 1.05, 1.2, 1),
  a = a,
  kernel_fun = c("rexp", "rexp", "abs_rnorm", "abs_rnorm"),
  kernel_args = list(
    list(rate = 0.002),
    list(rate = 0.001),
    list(mean = 0, sd = 1000),
    list(mean = 0, sd = 2000))
)
#> Error in get(as.character(FUN), mode = "function", envir = envir): object 'abs_rnorm' of mode 'function' was not found
# }
```
