test_that("summary.sim_com_data produces correct structure and content", {

  community <- readRDS(test_path("fixtures", "sim_com_data.rds"))

  # Run summary
  s <- summary(community)

  # Check class and structure
  expect_s3_class(s, "summary.sim_com_data")
  expect_true(all(c("maps_summary", "species_params", "interaction_matrix", "invasion") %in% names(s)))

  # maps_summary should be a data.frame with expected columns
  expect_s3_class(s$maps_summary, "data.frame")
  expect_true(all(c("species", "n1_min", "n1_mean", "n1_max", "K_min", "K_mean", "K_max") %in% names(s$maps_summary)))

  # Dimensions and types
  expect_equal(nrow(s$maps_summary), community$nspec)
  expect_true(is.numeric(s$maps_summary$n1_mean))
  expect_true(is.logical(s$maps_summary$invader) || is.null(s$maps_summary$invader))

  # species_params should be a data.frame
  expect_s3_class(s$species_params, "data.frame")

  # interaction_matrix should be a matrix
  expect_true(is.matrix(s$interaction_matrix))
})

test_that("print.summary.sim_com_data prints expected sections", {

  community <- readRDS(test_path("fixtures", "sim_com_data.rds"))
  s <- summary(community)

  output <- capture.output(print(s))

  expect_true(any(grepl("Summary of sim_com_data object", output)))
  expect_true(any(grepl("Input maps", output)))
  expect_true(any(grepl("Species-specific parameters", output)))

  if (!is.null(s$interaction_matrix)) {
    expect_true(any(grepl("Interaction matrix", output)))
  }
})

test_that("summarise_species_maps returns expected stats", {

  community <- readRDS(test_path("fixtures", "sim_com_data.rds"))

  # Extract one wrapped map and summarise
  result <- summarise_species_maps(community$n1_map, community$spec_names)

  # Structure
  expect_s3_class(result, "data.frame")
  expect_true(all(c("species", "min", "q1", "median", "mean", "q3", "max") %in% names(result)))

  # Reasonable numeric values
  expect_true(all(is.finite(result$mean)))
  expect_equal(nrow(result), community$nspec)

  # Check monotonicity for sanity
  expect_true(all(result$min <= result$median))
  expect_true(all(result$median <= result$max))
})

test_that("summary.sim_com_data handles missing invasion slot", {

  community <- readRDS(test_path("fixtures", "sim_com_data.rds"))
  community$invasion <- NULL

  s <- summary(community)

  expect_s3_class(s, "summary.sim_com_data")
  expect_null(s$invasion)
  expect_null(s$maps_summary$invader)
})
