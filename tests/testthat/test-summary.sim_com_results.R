test_that("summary.sim_com_results returns correct structure", {

  simulated_com <- readRDS(test_path("fixtures", "sim_com_results.rds"))

  # Run without plotting
  s <- summary(simulated_com, plot = FALSE)

  expect_s3_class(s, "summary.sim_com_results")
  expect_named(s, c("sim_time", "extinction", "N_map_sm"))

  expect_type(s$sim_time, "double")
  expect_true(is.logical(s$extinction))
  expect_s3_class(s$N_map_sm, "data.frame")

  # Check expected columns
  expected_cols <- c("species", "min", "q1", "median", "mean", "q3", "max")
  expect_true(all(expected_cols %in% names(s$N_map_sm)))

  nspec <- dim(simulated_com$N_map)[4]
  expect_equal(nrow(s$N_map_sm), nspec)
})


test_that("summary.sim_com_results optionally plots when plot = TRUE", {
  skip_on_cran()

  simulated_com <- readRDS(test_path("fixtures", "sim_com_results.rds"))

  # Should trigger plot silently
  expect_silent(summary(simulated_com, plot = TRUE))

  # When plot = FALSE, should skip plotting branch
  expect_silent(summary(simulated_com, plot = FALSE))
})


test_that("print.summary.sim_com_results outputs all expected sections", {

  simulated_com <- readRDS(test_path("fixtures", "sim_com_results.rds"))
  s <- summary(simulated_com, plot = FALSE)

  printed <- capture.output(print(s))

  expect_true(any(grepl("Summary of sim_com_results object", printed)))
  expect_true(any(grepl("Abundances summary", printed)))
  expect_true(any(grepl("Simulated time steps", printed)))
  expect_true(any(grepl("Extinction", printed)))
})

test_that("summarise_species_abundance returns correct statistics", {

  simulated_com <- readRDS(test_path("fixtures", "sim_com_results.rds"))
  N_map <- simulated_com$N_map

  result <- summarise_species_abundance(N_map, simulated_com$spec_names)

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), dim(N_map)[4])
  expect_true(all(c("species", "min", "mean", "max") %in% names(result)))
})


test_that("summarise_species_abundance ignores NA values gracefully", {

  simulated_com <- readRDS(test_path("fixtures", "sim_com_results.rds"))
  N_map <- simulated_com$N_map
  N_map[1, 1, 1, 1] <- NA

  result <- summarise_species_abundance(N_map, simulated_com$spec_names)
  expect_true(all(is.finite(result$mean)))
})
