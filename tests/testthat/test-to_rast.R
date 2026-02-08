test_that("to_rast.sim_com_results returns expected output structure", {

  sim_com_results <- readRDS(test_path("fixtures", "sim_com_results.rds"))

  # One time point, all species
  out1 <- to_rast(sim_com_results, time_points = 1)
  expect_s4_class(out1, "SpatRaster")
  expect_equal(terra::nlyr(out1), 4)

  # One species, multiple time points
  out2 <- to_rast(sim_com_results, species = 1, time_points = c(1, 2))
  expect_s4_class(out2, "SpatRaster")
  expect_equal(terra::nlyr(out2), 2)

  # Multiple species, multiple time points
  out3 <- to_rast(sim_com_results, species = c(1, 2), time_points = c(1, 2))
  expect_type(out3, "list")
  expect_length(out3, 2)
  expect_true(all(vapply(out3, inherits, logical(1), what = "SpatRaster")))

  # Invalid species
  expect_error(to_rast(sim_com_results, species = 0), "species")
  expect_error(to_rast(sim_com_results, species = 99), "species")

  # Invalid time points
  expect_error(to_rast(sim_com_results, time_points = 0), "time_points")
  expect_error(to_rast(sim_com_results, time_points = 99), "time_points")

  # Invalid input object
  expect_error(to_rast(list()), "list")
})
