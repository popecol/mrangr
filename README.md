
# mrangr

<!-- badges: start -->

[![CRAN
release](https://www.r-pkg.org/badges/version/mrangr?color=green)](https://cran.r-project.org/package=mrangr)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.18641951.svg)](https://doi.org/10.5281/zenodo.18641951)
[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![R-CMD-check](https://github.com/popecol/mrangr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/popecol/mrangr/actions/workflows/R-CMD-check.yaml)
[![codecov](https://codecov.io/github/popecol/mrangr/graph/badge.svg?token=LF3PYFLBDN)](https://codecov.io/github/popecol/mrangr)
<!-- badges: end -->

The **mrangr** package is designed to simulate metacommunities within a
**spatially explicit, mechanistic framework**. It extends the
functionality of the [`rangr`](https://github.com/ropensci/rangr)
package by allowing for the simulation of **multiple interacting
species** via an asymmetric interaction matrix.

This tool mimics the essential processes shaping metacommunity dynamics:
local population growth, dispersal, and interspecific interactions.
Simulations take place in dynamic environments, facilitating projections
of community shifts in response to environmental changes.

## Installation

You can install **mrangr** with:

``` r
install.packages("mrangr")
```

## Basic Workflow

The `mrangr` workflow involves initialising a community with spatial
data and interaction parameters, running the simulation, and analysing
the results.

### 1. Input Maps and Interactions

You must provide carrying capacity maps (`K_map`) and initial abundance
maps (`n1_map`) as `SpatRaster` objects. For a community of $N$ species,
the rasters must contain $N$ layers.

``` r
# Load example maps
K_map <- rast(system.file("input_maps/K_map_eg.tif", package = "mrangr"))
K_map <- subset(K_map, 1:2)
```

Interspecific interactions are defined using an **interaction matrix**
($a$), where values represent the per-capita interaction strength of the
species in the column on the species in the row.

``` r
# Example for 2 species with symmetric competition
nspec <- 2
a <- matrix(c(NA, -0.8, -0.8, NA), nrow = nspec, ncol = nspec)
```

### 2. Community Initialisation

Use `initialise_com()` to create a `sim_com_data` object. This stores
all parameters, including the intrinsic growth rate ($r$) and the
dispersal rate.

``` r
first_com <- initialise_com(
  n1_map = round(K_map / 2), 
  K_map = K_map, 
  r = 1.1, 
  a = a, 
  rate = 1 / 500
)
```

### 3. Running the Simulation

The `sim_com()` function executes the simulation over a specified number
of time steps.

``` r
first_sim <- sim_com(first_com, time = 100)
```

### 4. Visualisation

You can visualise the final spatial distributions or the change in mean
abundance over time.

``` r
# Visualise spatial niches at specific time steps
plot(first_sim, time = c(1, 10, 100))
```

<img src="man/figures/README-vis-1.png" alt="" width="100%" />

``` r
# Plot abundance time series for all species
plot_series(first_sim)
```

<img src="man/figures/README-vis-2.png" alt="" width="100%" />

## Virtual Ecologist

The package includes a `virtual_ecologist()` function to simulate
real-world observation processes. This allows users to sample the
simulated community at defined points in space and time, incorporating
sampling effort and detection probability into the simulation.

## Citation

To cite **mrangr**, please use the `citation()` function:

``` r
library(mrangr)
citation("mrangr")
```

## Funding

This work was supported by the National Science Centre, Poland, grant
no. 2018/29/B/NZ8/00066 and the Poznań Supercomputing and Networking
Centre (grant no. pl0090-01).
