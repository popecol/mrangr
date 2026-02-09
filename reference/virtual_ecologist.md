# Virtual Ecologist

Organizes and extracts community data from a simulated community object
based on one of three sampling methods: random proportion, constant
random sites, or user-provided sites.

## Usage

``` r
virtual_ecologist(
  obj,
  type = c("random_one_layer", "random_all_layers", "from_data"),
  sites = NULL,
  prop = 0.01,
  obs_error = c("rlnorm", "rbinom"),
  obs_error_param = NULL
)
```

## Arguments

- obj:

  An object created by the
  [`sim_com()`](https://popecol.github.io/mrangr/reference/sim_com.md)
  function, containing simulation data.

- type:

  character vector of length 1; describes the sampling type
  (case-sensitive):

  - `"random_one_layer"` - random selection of cells for which
    abundances are sampled; the same set of selected cells is used
    across all time steps.

  - `"random_all_layers"` - random selection of cells for which
    abundances are sampled; a new set of cells is selected for each time
    step.

  - `"from_data"` - user-defined selection of cells for which abundances
    are sampled; the user is required to provide a `data.frame`
    containing three columns: `"x"`, `"y"` and `"time"`.

- sites:

  An optional data frame specifying the sites for data extraction. This
  data frame must contain three columns: `x`, `y` and `time`.

- prop:

  A numeric value between 0 and 1. The proportion of cells to randomly
  sample from the raster.

- obs_error:

  character vector of length 1; type of the distribution that defines
  the observation process:
  "[`rlnorm`](https://rdrr.io/r/stats/Lognormal.html)" (log-normal
  distribution) or "[`rbinom`](https://rdrr.io/r/stats/Binomial.html)"
  (binomial distribution).

- obs_error_param:

  numeric vector of length 1; standard deviation (on a log scale) of the
  random noise in the observation process when `"rlnorm"` is used, or
  probability of detection (success) when `"rbinom"` is used.

## Value

A data frame with 6 columns:

- `id`: unique cell identifier (factor)

- `x`, `y`: sampled cell coordinates

- `species`: species number or name

- `time`: sampled time step

- `n`: sampled abundance

## Examples

``` r
# Read simulated community data from the mrangr package
simulated_com <- get_simulated_com()

# Option 1: Randomly sample sites (the same for each year)
sampled_data_01 <- virtual_ecologist(simulated_com)
head(sampled_data_01)
#>   id      x      y species time n
#> 1 24 258500 613500       1    1 0
#> 2 62 251500 610500       1    1 0
#> 3 24 258500 613500       2    1 8
#> 4 62 251500 610500       2    1 6
#> 5 24 258500 613500       3    1 0
#> 6 62 251500 610500       3    1 0

# Option 2: Randomly sample sites (different for each year)
sampled_data_02 <- virtual_ecologist(simulated_com, type = "random_all_layers")
head(sampled_data_02)
#>    id      x      y species time n
#> 1  76 250500 609500       1    1 0
#> 2 155 254500 604500       1    1 0
#> 3 172 256500 603500       1    2 0
#> 4 152 251500 604500       1    2 0
#> 5 141 255500 605500       1    3 0
#> 6  48 252500 611500       1    3 0

# Option 3: Sample sites based on user-provided data frame
custom_sites <- data.frame(
  x = c(250500, 252500, 254500),
  y = c(600500, 602500, 604500),
  time = c(1, 10, 20)
)
sampled_data_03 <- virtual_ecologist(simulated_com, sites = custom_sites)
head(sampled_data_03)
#>    id      x      y species time  n
#> 1 211 250500 600500       1    1  0
#> 2 183 252500 602500       1   10  0
#> 3 155 254500 604500       1   20  0
#> 4 211 250500 600500       2    1 17
#> 5 183 252500 602500       2   10  2
#> 6 155 254500 604500       2   20  0

# Option 4. Add noise - "rlnorm"
sampled_data_04 <- virtual_ecologist(
  simulated_com,
  sites = custom_sites,
  obs_error = "rlnorm",
  obs_error_param = log(1.2)
)
head(sampled_data_04)
#>    id      x      y species time         n
#> 1 211 250500 600500       1    1  0.000000
#> 2 183 252500 602500       1   10  0.000000
#> 3 155 254500 604500       1   20  0.000000
#> 4 211 250500 600500       2    1 17.682822
#> 5 183 252500 602500       2   10  1.976307
#> 6 155 254500 604500       2   20  0.000000

# Option 5. Add noise - "rbinom"
sampled_data_05 <- virtual_ecologist(
  simulated_com,
  sites = custom_sites,
  obs_error = "rbinom",
  obs_error_param = 0.8
)
head(sampled_data_05)
#>    id      x      y species time  n
#> 1 211 250500 600500       1    1  0
#> 2 183 252500 602500       1   10  0
#> 3 155 254500 604500       1   20  0
#> 4 211 250500 600500       2    1 13
#> 5 183 252500 602500       2   10  1
#> 6 155 254500 604500       2   20  0

```
