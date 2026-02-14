# Initialise Invasion Parameters

Prepares a list of invasion configuration details, including the
identifiers of the invading species, the times of invasion and the
number of individuals introduced at each event. Result of this helper
function is designed to be passed to
[`initialise_com()`](initialise_com.md) as `invasion` argument.

## Usage

``` r
initialise_inv(invaders, invasion_times, propagule_size = 1)
```

## Arguments

- invaders:

  An integer vector of species indices indicating which species are
  invaders.These indices should match the species layers in the input
  maps (`n1_map` and `K_map`).

- invasion_times:

  A matrix or vector specifying when each invader enters the system. If
  a vector is provided, it is assumed to apply to all invaders. If a
  matrix, it must have one row per invader and columns corresponding to
  invasion events.

- propagule_size:

  A numeric scalar specifying the number of individuals introduced at
  each invasion time. Defaults to 1.

## Value

A named list with the following components:

- invaders:

  Integer vector of invading species indices.

- propagule_size:

  Number of individuals introduced per invasion event.

- invasion_times:

  Matrix of invasion times, with one row per invader.

## Examples

``` r
# Define invaders and invasion times
initialise_inv(
  invaders = c(1, 3),
  invasion_times = matrix(c(5, 10, 5, 20), nrow = 2, byrow = TRUE),
  propagule_size = 10
)
#> $invaders
#> [1] 1 3
#> 
#> $propagule_size
#> [1] 10
#> 
#> $invasion_times
#>      [,1] [,2]
#> [1,]    5   10
#> [2,]    5   20
#> 

# Uniform invasion times across all invaders
initialise_inv(
  invaders = c(2, 4),
  invasion_times = c(5, 10, 15)
)
#> $invaders
#> [1] 2 4
#> 
#> $propagule_size
#> [1] 1
#> 
#> $invasion_times
#>      [,1] [,2] [,3]
#> [1,]    5   10   15
#> [2,]    5   10   15
#> 
```
