
K_map <- rast(system.file("input_maps/K_map_eg.tif", package = "mrangr"))
K_map <- subset(K_map, 1:2)

# Example for 2 species with symmetric competition
nspec <- 2
a <- matrix(c(NA, -0.8, -0.8, NA), nrow = nspec, ncol = nspec)

first_com <- initialise_com(
  n1_map = round(K_map / 2),
  K_map = K_map,
  r = 1.1,
  a = a,
  rate = 1 / 500
)

first_sim <- sim_com(first_com, time = 100)

save(first_com, file = "inst/extdata/readme/first_com.rda")
save(first_sim, file = "inst/extdata/readme/first_sim.rda")
