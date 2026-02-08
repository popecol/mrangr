test_that("plot_series runs and returns correct output", {
  skip_on_cran()  # skip plot-based tests on CRAN

  simulated_com <- readRDS(test_path("fixtures", "sim_com_results.rds"))

  # Capture the invisible return value
  result <- plot_series(simulated_com)

  # Check result type and dimensions
  expect_true(is.matrix(result))
  expect_equal(dim(result)[1], simulated_com$sim_time)
  expect_equal(dim(result)[2], dim(simulated_com$N_map)[4])

  # Transformation works
  result_log <- plot_series(simulated_com, trans = log1p)
  expect_equal(dim(result_log), dim(result))

  # Invalid trans argument throws error
  expect_error(plot_series(simulated_com, trans = "not_a_function"))

  # Spatial/time subsetting works
  result_subset <- plot_series(simulated_com, x = 1:3, y = 1:3, time = 1:5)
  expect_true(is.matrix(result_subset))
  expect_equal(dim(result_subset)[1], 5)
})

test_that("plot_series input validation stops as expected", {

  simulated_com <- readRDS(test_path("fixtures", "sim_com_results.rds"))

  # Out-of-bounds x and y
  expect_error(plot_series(simulated_com, x = 999:1000, y = 1:5),
               "`x` must be numeric indices within")
  expect_error(plot_series(simulated_com, x = 1:5, y = 999:1000),
               "`y` must be numeric indices within")

  # Non-numeric x, y, or time
  expect_error(plot_series(simulated_com, x = "a"),
               "`x` must be numeric indices within")
  expect_error(plot_series(simulated_com, y = "a"),
               "`y` must be numeric indices within")
  expect_error(plot_series(simulated_com, time = "a"),
               "`time` must be numeric values within")

  # Out-of-range time index
  expect_error(plot_series(simulated_com, time = 999),
               "`time` must be numeric values within")
})

test_that("plot_series handles all-NA region gracefully", {

  simulated_com <- readRDS(test_path("fixtures", "sim_com_results.rds"))

  # Make everything NA in selected region to trigger error
  mock_obj <- simulated_com
  mock_obj$N_map[] <- NA

  expect_error(
    plot_series(mock_obj, trans = log1p),
    "outside the study area"
  )
})

test_that("plot_series handles graphical arguments and invisibly returns output", {
  skip_on_cran()
  simulated_com <- readRDS(test_path("fixtures", "sim_com_results.rds"))

  # Should accept additional graphical args (like col)
  expect_silent({
    val <- plot_series(simulated_com, col = "blue")
  })
})
