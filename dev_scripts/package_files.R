library(terra)
library(rangr)
library(mrangr)

set.seed(123)

# 1. Template raster ----
nrows <- 15
ncols <- 15

xmin <- 250000; xmax <- xmin + nrows * 1000
ymin <- 600000; ymax <- ymin + ncols * 1000
id <- rast(nrows = nrows, ncols = ncols, xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax)
crs(id) <- "epsg:2180"
id

# 2. Input maps ----
## 2.1 Carrying capacity maps ----

# No. of species in the community
nspec <- 4

# Correlation matrix of carrying capacity maps.
cor_mat <- FieldSimR::rand_cor_mat(nspec, -0.5, 0.5, pos.def = TRUE)

K_map_eg <- K_sim(nspec, id, range = diagonal(id), cor_mat = cor_mat, qfun = qlnorm, meanlog = 2, sdlog = 0.5)

K_map_eg[c(1:2, 16:17)] <- NA
K_map_eg; plot(K_map_eg)

## 2.2 Initial population numbers ----
n1_map_eg <- init(K_map_eg, \(n) rpois(n, as.vector(K_map_eg)))

n1_map_eg; plot(n1_map_eg)


# 3. Interaction matrix ----
mu_a <- -0.3 # mean strength of pairwise interactions
sigma_a <- 0.5 # sd of pairwise interactions
a_eg <- matrix(rnorm(nspec^2, mu_a, sigma_a), nrow = nspec, ncol = nspec)
diag(a_eg) <- NA
a_eg <- round(a_eg, 2)
a_eg

# 4. Initialise simulation parameters ----
community_eg <- initialise_com(
  K_map = K_map_eg,
  n1_map = n1_map_eg,
  r = 1.1,
  a = a_eg,
  rate = 0.002,
  invasion = initialise_inv(
    invaders = c(1, 3),
    invasion_times = c(2, 5)))

# 5. Simulation
simulated_com_eg <- sim_com(obj = community_eg, time = 20)

# 6. Save data ----
terra::writeRaster(K_map_eg, "inst/input_maps/K_map_eg.tif", overwrite = TRUE)
terra::writeRaster(n1_map_eg, "inst/input_maps/n1_map_eg.tif", overwrite = TRUE)

usethis::use_data(a_eg, overwrite = TRUE)

saveRDS(community_eg, "inst/extdata/community_eg.rds")
saveRDS(simulated_com_eg, "inst/extdata/simulated_com_eg.rds")

