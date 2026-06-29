test_that("sim_com() runs correctly for minimal valid input", {

  test_sim_com_data <- readRDS(test_path("fixtures", "sim_com_data.rds"))

  result <-
    sim_com(test_sim_com_data, time = 3, burn = 0, progress_bar = FALSE)

  expect_s3_class(result, "sim_com_results")
  expect_true("extinction" %in% names(result))
  expect_true("sim_time" %in% names(result))
  expect_true("N_map" %in% names(result))
  expect_equal(dim(result$N_map)[3], 3)  # 3 time steps
  expect_equal(dim(result$N_map)[4], 4)  # 4 species
})

test_that("sim_com() correctly handles burn-in period", {

  test_sim_com_data <- readRDS(test_path("fixtures", "sim_com_data.rds"))

  result <-
    sim_com(test_sim_com_data, time = 5, burn = 2, progress_bar = FALSE)

  expect_equal(result$sim_time, 3)
  expect_equal(dim(result$N_map)[3], 3)
})

test_that("sim_com() produces expected extinction output", {

  test_sim_com_data <- readRDS(test_path("fixtures", "sim_com_data.rds"))

  result <-
    sim_com(test_sim_com_data, time = 2, burn = 0, progress_bar = FALSE)

  expect_named(result$extinction)
  expect_true(result$extinction[[1]])  # Should be extinct
})

test_that("sim_com() beaks if community is extinct", {

  test_sim_com_data <- readRDS(test_path("fixtures", "sim_com_data.rds"))

  test_sim_com_data$n1_map <- wrap(ifel(
    is.na(unwrap(test_sim_com_data$n1_map)), NA, 0
  ))

  test_sim_com_data$invasion <- NULL

  result <-
    sim_com(test_sim_com_data, time = 3, burn = 0, progress_bar = FALSE)

  expect_named(result$extinction)
  expect_true(all(result$extinction))  # Should go extinct
  expect_equal(result$sim_time, 2)
})

# --- Validation Tests ---

test_that("sim_com() errors with incorrect obj class", {

  expect_error(
    sim_com("not_a_sim_com_data", time = 10),
    "'obj' must be of class 'sim_com_data'"
  )
})

test_that("sim_com() errors with invalid time", {

  test_sim_com_data <- readRDS(test_path("fixtures", "sim_com_data.rds"))

  expect_error(
    sim_com(obj = test_sim_com_data, time = 1),
    "'time' must be a positive integer >= 2"
  )
})

test_that("sim_com() errors with invalid burn", {

  test_sim_com_data <- readRDS(test_path("fixtures", "sim_com_data.rds"))

  expect_error(
    sim_com(test_sim_com_data, time = 5, burn = 6),
    "'burn' must be a non-negative integer and less than 'time'"
  )
})

test_that("sim_com() errors with non-logical progress_bar", {

  test_sim_com_data <- readRDS(test_path("fixtures", "sim_com_data.rds"))

  expect_error(
    sim_com(test_sim_com_data, time = 5, progress_bar = "yes"),
    "'progress_bar' must be a logical value"
  )
})

test_that("sim_com() validates invasion object", {

  test_sim_com_data <- readRDS(test_path("fixtures", "sim_com_data.rds"))

  # Inject bad invasion object
  test_sim_com_data$invasion <- list(dummy = TRUE)

  expect_error(
    sim_com(test_sim_com_data, time = 5),
    "'invasion' must be a named list containing 'invaders', 'propagule_size', and 'invasion_times'"
  )
})

test_that("sim_com successfully processes valid dynamic K_map list", {

  sim_com_data <- readRDS(test_path("fixtures", "sim_com_data.rds"))

  static_K <- terra::unwrap(sim_com_data$K_map)
  nspec <- terra::nlyr(static_K)
  n_layers <- 5

  # Replicate the K map n_layers times as time steps for each species
  dynamic_K_list <- lapply(seq_len(nspec), function(i) {
    lyr <- static_K[[i]]
    # Combine layers into a single multi-layer SpatRaster
    dynamic_raster <- do.call(c, replicate(n_layers, lyr, simplify = FALSE))
    terra::wrap(dynamic_raster)
  })

  sim_com_data$K_map <- dynamic_K_list
  res <- sim_com(obj = sim_com_data, time = 3, burn = 0)

  expect_s3_class(res, "sim_com_results")
  expect_equal(res$sim_time, 3)
  expect_equal(dim(res$N_map)[3], 3)
})

test_that("sim_com throws an explicit error when simulation time exceeds available layers", {
  sim_com_data <- readRDS(test_path("fixtures", "sim_com_data.rds"))
  static_K <- terra::unwrap(sim_com_data$K_map)
  nspec <- terra::nlyr(static_K)

  # Create only 3 time layers
  dynamic_K_list <- lapply(seq_len(nspec), function(i) {
    dynamic_raster <- do.call(c, replicate(3, static_K[[i]], simplify = FALSE))
    terra::wrap(dynamic_raster)
  })
  sim_com_data$K_map <- dynamic_K_list

  # Request a 6-step simulation, which should trigger stop()
  expect_error(
    sim_com(obj = sim_com_data, time = 6, burn = 0),
    regexp = "Simulation time \\(6\\) exceeds the number of available time layers in K_map"
  )
})

test_that("sim_com detects and reports layer count mismatches between species", {
  sim_com_data <- readRDS(test_path("fixtures", "sim_com_data.rds"))
  static_K <- terra::unwrap(sim_com_data$K_map)
  nspec <- terra::nlyr(static_K)

  # Create 5 time layers
  dynamic_K_list <- lapply(seq_len(nspec), function(i) {
    dynamic_raster <- do.call(c, replicate(5, static_K[[i]], simplify = FALSE))
    terra::wrap(dynamic_raster)
  })

  # Change the second species – give it only 2 layers instead of 5
  short_raster <- do.call(c, replicate(2, static_K[[2]], simplify = FALSE))
  dynamic_K_list[[2]] <- terra::wrap(short_raster)

  sim_com_data$K_map <- dynamic_K_list

  expect_error(
    sim_com(obj = sim_com_data, time = 4, burn = 0),
    regexp = "Available layers per species: \\[5, 2, 5, 5\\]"
  )
})
