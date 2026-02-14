# Package index

## Simulation preparation

- [`grf()`](grf.md) : Generate a Gaussian Random Field

- [`K_sim()`](K_sim.md) : Carrying Capacity Map Simulator

- [`initialise_inv()`](initialise_inv.md) : Initialise Invasion
  Parameters

- [`initialise_com()`](initialise_com.md) : Initialise Community
  Simulation Data

- [`update(`*`<sim_com_data>`*`)`](update.sim_com_data.md) :

  Update `sim_com_data` Object

- [`summary(`*`<sim_com_data>`*`)`](summary.sim_com_data.md) :

  Summary Of `sim_com_data` Object

## Simulation

- [`sim_com()`](sim_com.md) : Simulate Community Dynamics Over Time

- [`summary(`*`<sim_com_results>`*`)`](summary.sim_com_results.md) :

  Summary Of `sim_com_results` Object

## Post-processing

- [`virtual_ecologist()`](virtual_ecologist.md) : Virtual Ecologist

- [`to_rast(`*`<sim_com_results>`*`)`](to_rast.sim_com_results.md) :

  Convert `sim_com_results` to SpatRaster(s)

- [`plot(`*`<sim_com_results>`*`)`](plot.sim_com_results.md) :

  Plot `sim_com_results` Object

- [`plot_series()`](plot_series.md) : Community Time-Series Plot

## Data

- [`K_map_eg.tif`](K_map_eg.tif.md) : Example Of Carrying Capacity Map
- [`n1_map_eg.tif`](n1_map_eg.tif.md) : Example Of Abundance Map At
  First Time Step Of The Simulation
- [`a_eg`](a_eg.md) : Example Of Interaction Coefficients Matrix
- [`get_community()`](get_community.md) : Load Example Community Object
- [`community_eg`](community_eg.md) : Example Community Data
- [`get_simulated_com()`](get_simulated_com.md) : Load Example Simulated
  Community Results
- [`simulated_com_eg`](simulated_com_eg.md) : Example Simulated
  Community Output

## Helper functions

- [`diagonal()`](diagonal.md) : Compute Maximum Possible Distance for a
  Raster Object
- [`set_zero()`](set_zero.md) : Set Non-Missing Values to Zero
