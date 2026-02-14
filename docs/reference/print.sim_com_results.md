# Print `sim_com_results` Object

Print `sim_com_results` Object

## Usage

``` r
# S3 method for class 'sim_com_results'
print(x, ...)
```

## Arguments

- x:

  `sim_com_results` object; returned by the [`sim_com`](sim_com.md)
  function

- ...:

  further arguments passed to or from other methods; none specified

## Value

`sim_com_results` object is invisibly returned (the `x` param)

## Examples

``` r
# Read simulation data from the mrangr package
simulated_com <- get_simulated_com()

# Print
print(simulated_com)
#> Class: sim_com_results
#> 
#> N_map: 
#> Dimentions [rows, cols, time, species]:  15 15 20 4 
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
