# Load Example Simulated Community Results

Loads a pre-run simulation output, based on the example community data.
Useful for examples, unit tests, or visualization.

## Usage

``` r
get_simulated_com()
```

## Value

An object of class `sim_com_results` containing simulation output for a
community over time.

## See also

[simulated_com_eg](simulated_com_eg.md)

## Examples

``` r
sim <- get_simulated_com()
plot(sim)

```
