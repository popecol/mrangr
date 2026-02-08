# initialise_com ----

test_that("initialise_com() returns correct class and structure", {

  K_map <- rast(nrows = 10, ncols = 10, nlyrs = 2)
  values(K_map) <- runif(ncell(K_map) * 2, 1, 10)
  names(K_map) <- c("K1", "K2")

  a <- matrix(c(NA, 0.2, 0.1, NA), nrow = 2)
  r <- c(1.1, 1.2)

  result <- initialise_com(K_map = K_map, r = r, a = a)

  expect_s3_class(result, "sim_com_data")
  expect_equal(result$nspec, 2)
  expect_true(inherits(result$n1_map, "PackedSpatRaster"))
  expect_true(inherits(result$K_map, "PackedSpatRaster"))
  expect_type(result$spec_data, "list")
  expect_equal(length(result$spec_data), 2)
})

test_that("initialise_com() works with scalar r", {

  K_map <- rast(nrows = 5, ncols = 5, nlyrs = 3)
  values(K_map) <- runif(ncell(K_map) * 3, 0, 10)
  a <- matrix(0.1, nrow = 3, ncol = 3)
  diag(a) <- NA

  expect_no_error(initialise_com(K_map = K_map, r = 1, a = a))
})

test_that("invalid r length throws error", {

  K_map <- rast(nrows = 5, ncols = 5, nlyrs = 3)
  values(K_map) <- runif(ncell(K_map) * 3, 0, 10)
  a <- matrix(0.1, 3, 3)
  diag(a) <- NA

  expect_error(
    initialise_com(K_map = K_map, r = c(1, 2), a = a),
    "must be either a scalar or a numeric vector"
  )
})

test_that("invalid a matrix throws error", {

  K_map <- rast(nrows = 5, ncols = 5, nlyrs = 2)
  values(K_map) <- runif(ncell(K_map) * 2, 0, 10)

  bad_a <- matrix(1, nrow = 2, ncol = 3)

  expect_error(
    initialise_com(K_map = K_map, r = c(1, 1), a = bad_a),
    "must be a square matrix"
  )
})

test_that("invasion list is applied correctly", {

  K_map <- rast(nrows = 5, ncols = 5, nlyrs = 2)
  values(K_map) <- runif(ncell(K_map) * 2, 0, 10)
  a <- matrix(0.1, 2, 2); diag(a) <- NA
  invasion <- initialise_inv(invaders = 1, invasion_times = c(5, 10))

  result <- initialise_com(K_map = K_map, r = c(1, 1), a = a, invasion = invasion)

  expect_equal(result$invasion$invaders, 1)
  expect_true(all(values(unwrap(result$n1_map)[[1]]) == 0)) # invader n1 map set to 0
})

test_that("kernel_args validation works", {

  K_map <- rast(nrows = 5, ncols = 5, nlyrs = 2)
  values(K_map) <- runif(ncell(K_map) * 2, 0, 10)
  a <- matrix(0.1, 2, 2); diag(a) <- NA

  expect_error(
    initialise_com(K_map = K_map, r = c(1, 1), a = a, kernel_args = list(list(rate = 0.001))),
    "must be a list of the same length"
  )
})


# initialise_inv ----
test_that("initialise_inv() returns correct structure", {

  inv <- initialise_inv(
    invaders = c(1, 2),
    invasion_times = matrix(c(5, 10, 15, 20), nrow = 2, byrow = TRUE),
    propagule_size = 5
  )
  expect_type(inv, "list")
  expect_named(inv, c("invaders", "propagule_size", "invasion_times"))
  expect_equal(inv$propagule_size, 5)
  expect_equal(nrow(inv$invasion_times), 2)
  expect_equal(inv$invaders, c(1, 2))
})

test_that("initialise_inv() handles vector invasion_times", {

  inv <- initialise_inv(c(3, 4), invasion_times = c(5, 10))

  expect_equal(nrow(inv$invasion_times), 2)
  expect_equal(ncol(inv$invasion_times), 2)
  expect_equal(inv$invasion_times[1, ], c(5, 10))
  expect_equal(inv$invasion_times[2, ], c(5, 10))
})

test_that("initialise_inv() fails with invalid invaders", {

  expect_error(initialise_inv(c(-1, 2), c(5, 10)), "positive integers")
  expect_error(initialise_inv(c(1.5, 2), c(5, 10)), "positive integers")
  expect_error(initialise_inv("a", c(5, 10)), "must be a vector of positive integers")
})

test_that("initialise_inv() fails with invalid propagule_size", {

  expect_error(initialise_inv(1, c(5), propagule_size = 0), "must be a single positive integer")
  expect_error(initialise_inv(1, c(5), propagule_size = c(1, 2)), "must be a single positive integer")
})

test_that("initialise_inv() fails when matrix rows don't match invader count", {

  bad_matrix <- matrix(c(5, 10), nrow = 1)

  expect_error(initialise_inv(c(1, 2), invasion_times = bad_matrix), "one row per invader")
})

test_that("initialise_inv() returns integer matrix when given vector", {

  inv <- initialise_inv(c(1, 2), c(5, 10, 15))

  expect_equal(dim(inv$invasion_times), c(2, 3))
  expect_true(is.matrix(inv$invasion_times))
})

# K_n1_map_check ----

test_that("K_n1_map_check passes with matching rasters and valid values", {

  K <- rast(nrows = 5, ncols = 5)
  values(K) <- runif(ncell(K), 0, 10)

  n1 <- rast(K)
  values(n1) <- runif(ncell(n1), 0, 5)

  expect_no_error(K_n1_map_check(K, n1))
})

test_that("K_n1_map_check catches mismatched geometry", {

  K <- rast(nrows = 5, ncols = 5)
  values(K) <- runif(ncell(K), 0, 10)

  n1 <- rast(nrows = 6, ncols = 5)
  values(n1) <- runif(ncell(n1), 0, 5)

  expect_error(
    K_n1_map_check(K, n1),
    "compareGeom"
  )
})

test_that("K_n1_map_check catches mismatched NA positions", {

  K <- rast(nrows = 5, ncols = 5)
  values(K) <- runif(ncell(K), 0, 10)
  values(K)[1] <- NA

  n1 <- rast(K)
  values(n1) <- values(K)
  values(n1)[1] <- 5   # non-NA where K is NA

  expect_error(
    K_n1_map_check(K, n1),
    "NA values in different grid cells"
  )
})

test_that("K_n1_map_check catches negative values in n1_map", {

  K <- rast(nrows = 5, ncols = 5)
  values(K) <- runif(ncell(K), 0, 10)

  n1 <- rast(K)
  values(n1) <- runif(ncell(n1), -1, 1)

  expect_error(
    K_n1_map_check(K, n1),
    "n1_map can contain only non-negative"
  )
})

test_that("K_n1_map_check catches negative values in K_map", {

  K <- rast(nrows = 5, ncols = 5)
  values(K) <- runif(ncell(K), -2, 2)

  n1 <- rast(K)
  values(n1) <- runif(ncell(n1), 0, 1)

  expect_error(
    K_n1_map_check(K, n1),
    "K_map can contain only non-negative"
  )
})

test_that("K_n1_map_check passes with NAs in same locations", {

  K <- rast(nrows = 5, ncols = 5)
  values(K) <- runif(ncell(K), 0, 10)
  values(K)[c(3, 7)] <- NA

  n1 <- rast(K)
  values(n1) <- runif(ncell(n1), 0, 5)
  values(n1)[c(3, 7)] <- NA

  expect_no_error(K_n1_map_check(K, n1))
})

