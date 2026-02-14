# Summary Of `sim_com_results` Object

Summary Of `sim_com_results` Object

## Usage

``` r
# S3 method for class 'sim_com_results'
summary(object, ...)
```

## Arguments

- object:

  `sim_com_results` object; returned by [`sim_com`](sim_com.md) function

- ...:

  further arguments passed to or from other methods; none specified

## Value

`summary.sim_com_results` object

## Examples

``` r
# Read simulation data from the mrangr package
simulated_com <- get_simulated_com()

# Summary
summary(simulated_com)
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
