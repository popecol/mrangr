test_that("virtual_ecologist handles random_one_layer sampling correctly", {

  sim_obj <- readRDS(test_path("fixtures", "sim_com_results.rds"))
  prop_val <- 0.05
  time <- dim(sim_obj$N_map)[3]
  n_spec <- dim(sim_obj$N_map)[4]

  expected_nrow <- floor(100 * prop_val) * time * n_spec

  # Test 1: Default call (random_one_layer, prop=0.01)
  result_default <- virtual_ecologist(sim_obj)

  expect_s3_class(result_default, "data.frame")
  expect_true(all(c("id", "x", "y", "species", "time", "n") %in% names(result_default)))
  expect_true(nrow(result_default) > 0)


  # Test 2: Specific prop
  result <- virtual_ecologist(sim_obj, type = "random_one_layer", prop = prop_val)

  expect_s3_class(result, "data.frame")

  # Check expected dimensions: size * n_time * n_spec
  expect_equal(nrow(result), expected_nrow)

  # Check that ids are the same for all time_steps for a given species
  coords <- unique(result[c("id", "species")])
  expect_equal(nrow(coords), floor(100 * prop_val) * n_spec)
})

test_that("virtual_ecologist handles random_all_layers sampling correctly", {

  sim_obj <- readRDS(test_path("fixtures", "sim_com_results.rds"))
  prop_val <- 0.05
  time <- dim(sim_obj$N_map)[3]
  n_spec <- dim(sim_obj$N_map)[4]

  expected_nrow <- floor(100 * prop_val) * time * n_spec

  # Test
  result <- virtual_ecologist(sim_obj, type = "random_all_layers", prop = prop_val)

  expect_s3_class(result, "data.frame")
  expect_true(all(c("id", "x", "y", "species", "time", "n") %in% names(result)))
  expect_equal(nrow(result), expected_nrow)

  # Check that x and y coordinates are *different* across time steps
  # for a given species - should be equal to total rows
  coords <- unique(result[c("x", "y", "species", "time")])
  expect_equal(nrow(coords), expected_nrow)
})

test_that("virtual_ecologist handles from_data sampling correctly", {

  sim_obj <- readRDS(test_path("fixtures", "sim_com_results.rds"))
  test_id <- readRDS(test_path("fixtures", "id.rds"))

  time <- dim(sim_obj$N_map)[3]
  n_spec <- dim(sim_obj$N_map)[4]
  crds <- crds(unwrap(sim_obj$id), df = TRUE)

  set.seed(123)
  sampled_crds <- crds[sample.int(nrow(crds), size = 2), ]


  custom_sites <- data.frame(
    x = sampled_crds$x,
    y = sampled_crds$y,
    time = c(10, 20)
  )

  rc <- terra::rowColFromCell(
    test_id, terra::cellFromXY(test_id, custom_sites[, c("x", "y")]))

  # Test 1: Correct use
  result <- virtual_ecologist(sim_obj, type = "from_data", sites = custom_sites)
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), nrow(custom_sites)*n_spec)
  expect_equal(
    sim_obj$N_map[cbind(
      rep(rc[,1], times = n_spec),
      rep(rc[,2], times = n_spec),
      rep(custom_sites$time, times = n_spec),
      rep(seq_len(n_spec), each = nrow(custom_sites)))],
    result[["n"]])

  # Test 2: Ensure the `sites` argument overrides `type`
  result_test <- virtual_ecologist(sim_obj, sites = custom_sites)
  expect_equal(result, result_test)

  # Test 3: Sites as a matrix
  sites_matrix <- as.matrix(custom_sites)
  result_matrix <- virtual_ecologist(sim_obj, sites = sites_matrix)
  expect_s3_class(result_matrix, "data.frame")
  expect_equal(nrow(result_matrix), nrow(custom_sites) * n_spec)
})

test_that("virtual_ecologist handles observation error 'rlnorm'", {

  sim_obj <- readRDS(test_path("fixtures", "sim_com_results.rds"))
  crds <- crds(unwrap(sim_obj$id), df = TRUE)

  set.seed(123)
  sampled_crds <- crds[sample.int(nrow(crds), size = 2), ]


  custom_sites <- data.frame(
    x = sampled_crds$x,
    y = sampled_crds$y,
    species = c(1, 2),
    time = c(10, 20)
  )
  obs_param <- log(1.2)

  # Test
  result <- virtual_ecologist(
    sim_obj,
    sites = custom_sites,
    obs_error = "rlnorm",
    obs_error_param = obs_param
  )

  expect_s3_class(result, "data.frame")
  expect_true(all(result$n >= 0)) # Log-normal output is non-negative
  expect_false(all(result$n == virtual_ecologist(sim_obj, sites = custom_sites)$n)) # Values should have changed
})

test_that("virtual_ecologist handles observation error 'rbinom'", {

  sim_obj <- readRDS(test_path("fixtures", "sim_com_results.rds"))
  crds <- crds(unwrap(sim_obj$id), df = TRUE)

  set.seed(123)
  sampled_crds <- crds[sample.int(nrow(crds), size = 2), ]

  custom_sites <- data.frame(
    x = sampled_crds$x,
    y = sampled_crds$y,
    species = c(1, 2),
    time = c(10, 20)
  )
  obs_param <- 0.8

  # Test
  result <- virtual_ecologist(
    sim_obj,
    sites = custom_sites,
    obs_error = "rbinom",
    obs_error_param = obs_param
  )

  # Get the original counts
  original_result <- virtual_ecologist(sim_obj, sites = custom_sites)

  expect_s3_class(result, "data.frame")
  expect_true(all(result$n <= original_result$n))
  expect_true(all(result$n >= 0))
  expect_true(is.numeric(result$n) && all(result$n == floor(result$n)))
})

# --- Validation and Edge Case Tests ---
test_that("virtual_ecologist validates 'obj' class", {
  expect_error(virtual_ecologist(list(a = 1)), "`obj` must be of class 'sim_com_results'")
})

test_that("virtual_ecologist validates 'prop'", {

  sim_obj <- readRDS(test_path("fixtures", "sim_com_results.rds"))
  expect_error(virtual_ecologist(sim_obj, prop = 1.1), "`prop` must be > 0 and <= 1")
  expect_error(virtual_ecologist(sim_obj, prop = 0), "`prop` must be > 0 and <= 1")
  expect_error(virtual_ecologist(sim_obj, prop = "a"), "prop is not a numeric or integer vector")
})

test_that("virtual_ecologist handles small 'prop' with warning", {

  sim_obj <- readRDS(test_path("fixtures", "sim_com_results.rds"))
  time <- dim(sim_obj$N_map)[3]
  n_spec <- dim(sim_obj$N_map)[4]

  expect_warning(
    result <- virtual_ecologist(sim_obj, prop = 0.001),
    "Sampling proportion too small; at least one cell will be sampled."
  )
  expect_equal(nrow(result), time * n_spec)
})

test_that("virtual_ecologist validates 'sites' data frame", {

  sim_obj <- readRDS(test_path("fixtures", "sim_com_results.rds"))
  crds <- crds(unwrap(sim_obj$id), df = TRUE)

  set.seed(123)
  sampled_crds <- crds[sample.int(nrow(crds), size = 1),]

  valid_site <- data.frame(
    x = sampled_crds$x,
    y = sampled_crds$y,
    time = c(20)
  )


  # Missing columns
  expect_error(
    virtual_ecologist(sim_obj, sites = valid_site[, 2:3]),
    "The 'sites' data must contain at least 3 columns."
  )
  # Non-numeric columns
  invalid_sites_type <- valid_site
  invalid_sites_type$x <- "a"
  expect_error(
    virtual_ecologist(sim_obj, sites = invalid_sites_type),
    "All columns in 'sites' must be numeric"
  )
  # Empty sites
  expect_error(
    virtual_ecologist(sim_obj, sites = valid_site[0, ]),
    "The 'sites' data must contain at least 1 row."
  )
  # NA in sites
  invalid_sites_na <- valid_site
  invalid_sites_na$x[1] <- NA
  expect_error(
    virtual_ecologist(sim_obj, sites = invalid_sites_na),
    "Missing values found in 'sites'"
  )
})

test_that("virtual_ecologist validates 'obs_error_param'", {

  sim_obj <- readRDS(test_path("fixtures", "sim_com_results.rds"))
  crds <- crds(unwrap(sim_obj$id), df = TRUE)

  set.seed(123)
  sampled_crds <- crds[sample.int(nrow(crds), size = 1),]

  valid_site <- data.frame(
    x = sampled_crds$x,
    y = sampled_crds$y,
    species = c(2),
    time = c(20)
  )

  # rlnorm validation
  expect_error(
    virtual_ecologist(sim_obj, sites = valid_site, obs_error = "rlnorm", obs_error_param = c(0.1, 0.2)),
    "`obs_error_param` must be length 1"
  )
  expect_error(
    virtual_ecologist(sim_obj, sites = valid_site, obs_error = "rlnorm", obs_error_param = "a"),
    "`obs_error_param` must be numeric for rlnorm"
  )

  # rbinom validation
  expect_error(
    virtual_ecologist(sim_obj, sites = valid_site, obs_error = "rbinom", obs_error_param = 1.1),
    "`obs_error_param` must be a probability between 0 and 1 for rbinom"
  )
  expect_error(
    virtual_ecologist(sim_obj, sites = valid_site, obs_error = "rbinom", obs_error_param = -0.1),
    "`obs_error_param` must be a probability between 0 and 1 for rbinom"
  )
})

test_that("virtual_ecologist returns the same data without obs_error_param", {

  sim_obj <- readRDS(test_path("fixtures", "sim_com_results.rds"))
  crds <- crds(unwrap(sim_obj$id), df = TRUE)

  set.seed(123)
  sampled_crds <- crds[sample.int(nrow(crds), size = 1),]

  valid_site <- data.frame(
    x = sampled_crds$x,
    y = sampled_crds$y,
    species = c(2),
    time = c(20)
  )

  # Test for both error types when param is NULL
  result_rlnorm_null <- virtual_ecologist(sim_obj, sites = valid_site, obs_error = "rlnorm", obs_error_param = NULL)
  result_rbinom_null <- virtual_ecologist(sim_obj, sites = valid_site, obs_error = "rbinom", obs_error_param = NULL)

  # The result should be identical to the one without error arguments
  result_no_error <- virtual_ecologist(sim_obj, sites = valid_site)

  expect_equal(result_rlnorm_null, result_no_error)
  expect_equal(result_rbinom_null, result_no_error)
})

