
# Warning: Use this file only with a stable package version!
# Ensure that the generated data is correct before you save it.

library(rangr)
library(terra)

# 1. Template raster ----
nrows <- ncols <- 10
xmin <- 250000; xmax <- xmin + nrows * 1000
ymin <- 600000; ymax <- ymin + ncols * 1000
id <- rast(nrows = nrows, ncols = ncols, xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax)
crs(id) <- "epsg:2180"
id

# No. of species in the community
nspec <- 4

# Correlation matrix of carrying capacity maps.
cor_mat <- FieldSimR::rand_cor_mat(nspec, -0.5, 0.5, pos.def = TRUE)
all(eigen(cor_mat)$values >= 0) # test (must be TRUE)

K_map <- K_sim(nspec, id, range = diagonal(id), cor_mat = cor_mat, qfun = qlnorm, meanlog = 2, sdlog = 0.5)


# 3. Interaction matrix ----
mu_a <- -0.3 # mean strength of pairwise interactions
sigma_a <- 0.5 # sd of pairwise interactions
a <- matrix(rnorm(nspec^2, mu_a, sigma_a), nrow = nspec, ncol = nspec)
diag(a) <- NA
a <- round(a, 2)


# 4. Initialise simulation parameters ----
invasion <- initialise_inv(invaders = c(1, 3), invasion_times = c(5, 10))
sim_com_data <- initialise_com(K_map = K_map, r = 1, a = a, rate = 1 / 500, max_dist = diagonal(id), invasion = invasion)

# 5. Simulation ----
sim_com_results <- sim_com(sim_com_data, time = 20)

# Save test data ----
saveRDS(
  id,
  file = "tests/testthat/fixtures/id.rds")
saveRDS(
  sim_com_data,
  file = "tests/testthat/fixtures/sim_com_data.rds")
saveRDS(
  sim_com_results,
  file = "tests/testthat/fixtures/sim_com_results.rds")
