test_that("plot.sim_com_results validates inputs and runs correctly", {
  skip_on_cran()

  # Setup
  simulated_com <- readRDS(test_path("fixtures", "sim_com_results.rds"))

  dims <- dim(simulated_com$N_map)
  n_species <- dims[4]
  n_time <- simulated_com$sim_time

  # 1. Basic functionality
  expect_silent({
    out <- plot(simulated_com)
  })
  expect_true(inherits(out, "SpatRaster"))

  # 2. Multiple species and single time
  expect_silent({
    out <- plot(simulated_com, species = 1:n_species, time_points = 1)
  })
  expect_s4_class(out, "SpatRaster")

  # 3. Single species, multiple time points
  expect_silent({
    out <- plot(simulated_com, species = 1, time_points = 1:3)
  })
  expect_s4_class(out, "SpatRaster")

  # 4. Invalid time_points (exceeds sim_time)
  expect_error(
    plot(simulated_com, time_points = n_time + 1),
    "Invalid 'time_points':"
  )

  # 5. Custom main titles with correct length
  n_layers <- n_species * 2
  valid_main <- rep("custom title", n_layers)
  expect_silent({
    out <- plot(simulated_com, species = 1:n_species, time_points = 1:2, main = valid_main)
  })

  # 6. Custom main titles with incorrect length
  invalid_main <- rep("bad length", n_layers - 1)
  expect_error(
    plot(simulated_com, species = 1:n_species, time_points = 1:2, main = invalid_main),
    "length.main"
  )

  # 7. Explicit range argument
  expect_silent({
    out <- plot(simulated_com, species = 1, time_points = 1, range = c(0, 1))
  })
  expect_s4_class(out, "SpatRaster")

  # 8. Range automatically set to NULL if zero-abundance
  mock_x <- simulated_com
  mock_x$N_map[] <- 0
  expect_silent({
    out <- plot(mock_x, species = 1, time_points = 1)
  })
  expect_s4_class(out, "SpatRaster")
})

test_that("plot.sim_com_results handles list output from to_rast()", {
  skip_on_cran()

  simulated_com <- readRDS(test_path("fixtures", "sim_com_results.rds"))

  # If to_rast() returns a list of SpatRasters (multiple species case)
  expect_silent({
    out <- plot(simulated_com, species = 1:2, time_points = 1:2)
  })

  expect_true(inherits(out, "list"))
})
