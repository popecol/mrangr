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

  An object created by the [`sim_com()`](sim_com.md) function,
  containing simulation data.

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
#> 1 57 261500 611500       1    1 0
#> 2 89 263500 609500       1    1 0
#> 3 57 261500 611500       2    1 3
#> 4 89 263500 609500       2    1 2
#> 5 57 261500 611500       3    1 0
#> 6 89 263500 609500       3    1 0

# Option 2: Randomly sample sites (different for each year)
sampled_data_02 <- virtual_ecologist(simulated_com, type = "random_all_layers")
head(sampled_data_02)
#>    id      x      y species time n
#> 1 158 257500 604500       1    1 0
#> 2   6 255500 614500       1    1 0
#> 3  95 254500 608500       1    2 0
#> 4 170 254500 603500       1    2 0
#> 5  22 256500 613500       1    3 0
#> 6  28 262500 613500       1    3 0

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
#> 4 211 250500 600500       2    1 18.010816
#> 5 183 252500 602500       2   10  1.584975
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
#> 4 211 250500 600500       2    1 16
#> 5 183 252500 602500       2   10  2
#> 6 155 254500 604500       2   20  0

```
