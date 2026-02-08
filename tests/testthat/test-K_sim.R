test_that("K_sim generates a SpatRaster with correct dimensions (No correlation)", {

  # Setup
  template_raster <- readRDS(test_path("fixtures", "id.rds"))
  n_maps <- 3
  range_val <- 10
  set.seed(123)
  k_map_independent <- K_sim(n_maps, template_raster, range = range_val)


  expect_s4_class(k_map_independent, "SpatRaster")
  expect_equal(terra::nlyr(k_map_independent), n_maps)
  expect_equal(terra::nrow(k_map_independent), terra::nrow(template_raster))
  expect_equal(terra::ncol(k_map_independent), terra::ncol(template_raster))
  expect_equal(names(k_map_independent), as.character(seq_len(3)))
})

test_that("K_sim generates correlated maps and applies qfun", {

  # Setup
  template_raster <- readRDS(test_path("fixtures", "id.rds"))
  n_maps <- 3
  range_val <- 10
  cor_mat <- matrix(c(1, 0.5, 0.1, 0.5, 1, 0.2, 0.1, 0.2, 1), nrow = 3, ncol = 3)
  set.seed(123)
  k_map_correlated <-
    K_sim(n_maps, template_raster, range = range_val, cor_mat = cor_mat,
          qfun = qlnorm, meanlog = 2, sdlog = 0.5)


  expect_s4_class(k_map_correlated, "SpatRaster")
  expect_equal(terra::nlyr(k_map_correlated), n_maps)

  # Check quantile mapping (qlnorm should produce positive, right-skewed values)
  values_mean <- mean(terra::values(k_map_correlated))
  expect_true(all(terra::values(k_map_correlated) > 0)) # Log-normal must be positive
  expect_true(values_mean > 1) # Expected log-normal mean is exp(meanlog + sdlog^2/2) = exp(2 + 0.25/2) ~ 8.5
})


test_that("grf generates a standardized SpatRaster", {

  # Setup
  template_raster <- readRDS(test_path("fixtures", "id.rds"))
  set.seed(123)
  grf_scaled <- grf(template_raster, range = 20)

  expect_s4_class(grf_scaled, "SpatRaster")
  expect_equal(terra::nlyr(grf_scaled), 1)

  # Check standardization: mean ~ 0, sd ~ 1
  values <- terra::values(grf_scaled)
  expect_true(abs(mean(values)) < 1e-6) # Mean is very close to zero
  expect_true(abs(sd(values) - 1) < 1e-6) # SD is very close to one

  # Check for spatial autocorrelation (a basic check, non-zero spatial structure)
  expect_true(sd(values) > 0.05)
})
