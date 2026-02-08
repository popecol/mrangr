library(terra)
library(rangr)
library(mrangr)


set.seed(123)

# K_sim_basic ----

# define species number
nspec <- 2
# define map dimensions
nrows <- ncols <- 100

# prepare template raster
xmin <- 250000; xmax <- xmin + nrows * 1000
ymin <- 600000; ymax <- ymin + ncols * 1000
id <- rast(nrows = nrows, ncols = ncols, xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax)
crs(id) <- "epsg:2180"
id

# generate autocorrelated carrying capacity map
K_map <- K_sim(n = nspec, id, range = 5e5, qfun = qlnorm, meanlog = 2, sdlog = 0.5)
plot(K_map, main = paste0("K_", names(K_map)))


# r init ----

first_com <- initialise_com(
  n1_map = round(K_map / 2),
  K_map = K_map,
  r = 1.1,
  a = a,
  rate = 1 / 500)


# sim ----

first_sim <- sim_com(first_com, time = 100)


plot(first_sim, time = c(1, 100))
plot_series(first_sim)
legend("bottomright", title = "Species", legend = 1:nspec,
       lty = 1:nspec, lwd = 2, col = 1:nspec)
plot(first_sim, time = c(1, 100))


# save ----
terra::writeRaster(K_map, "vignettes/K_map.tif", overwrite = TRUE)
save(first_com, file = "vignettes/first_com.rda")
save(first_sim, file = "vignettes/first_sim.rda")
