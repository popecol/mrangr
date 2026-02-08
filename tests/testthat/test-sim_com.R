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

