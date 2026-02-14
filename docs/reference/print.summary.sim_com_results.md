# Print `summary.sim_results` Object

Print `summary.sim_results` Object

## Usage

``` r
# S3 method for class 'summary.sim_com_results'
print(x, ...)
```

## Arguments

- x:

  `summary.sim_com_results` object; returned by
  [`summary.sim_com_results`](summary.sim_com_results.md) function

- ...:

  further arguments passed to or from other methods; currently none
  specified

## Value

None

## Examples

``` r
# Read simulation data from the mrangr package
simulated_com <- get_simulated_com()

# Print summary
sim_com_summary <- summary(simulated_com)
print(sim_com_summary)
#> Summary of sim_com_results object
#> 
#> Abundances summary: 
#>   species min q1 median mean q3 max
#> 1       1   0  0      0 0.00  0   1
#> 2       2   0  2      4 4.93  7  21
#> 3       3   0  0      0 1.85  3  22
#> 4       4   0  2      5 6.97 11  32
#> 
#> Simulated time steps:  20 
#> 
#> Extinction: 
#>     1     2     3     4 
#>  TRUE FALSE FALSE FALSE 
```
