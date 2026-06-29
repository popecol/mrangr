test_that("update.sim_com_data updates parameters correctly", {

  com <- readRDS(test_path("fixtures", "sim_com_data.rds"))

  # Update a simple scalar parameter
  updated <- update(com, r = 2)

  expect_s3_class(updated, "sim_com_data")
  expect_false(identical(com, updated))
})


test_that("update.sim_com_data returns call when evaluate = FALSE", {

  com <- readRDS(test_path("fixtures", "sim_com_data.rds"))

  call_out <- update(com, r = 1.5, evaluate = FALSE)

  expect_s3_class(eval(call_out), "sim_com_data")
  expect_true(any(grepl("r = 1.5", deparse(call_out))))
})


test_that("update.sim_com_data replaces kernel_fun and removes old args", {

  com <- readRDS(test_path("fixtures", "sim_com_data.rds"))

  # Custom kernel function
  abs_rnorm <- function(n, mean, sd) {
    abs(rnorm(n, mean = mean, sd = sd))
  }

  new_kernel <- c("rexp", "rexp", "abs_rnorm", "abs_rnorm")
  new_kernel_args <- list(
        list(rate = 0.002),
        list(rate = 0.001),
        list(mean = 0, sd = 1000),
        list(mean = 0, sd = 2000))

  updated <- update(
    com,
    kernel_fun = new_kernel,
    kernel_args = new_kernel_args,
    dlist = com$dlist
  )

  expect_s3_class(updated, "sim_com_data")
  expect_equal(length(updated$spec_data), com$nspec)
  expect_true(all(
    vapply(updated$spec_data,
           function(x) (x$kernel_fun),
           character(1)) == new_kernel))
})


test_that("update.sim_com_data removes dlist when kernel_fun changes", {

  com <- readRDS(test_path("fixtures", "sim_com_data.rds"))

  com$dlist <- c(2, 6, 3)

  updated <- update(com, kernel_fun = "rexp")

  # dlist should be recomputed, not NULL
  expect_true(!is.null(updated$dlist))
  expect_false(identical(com$dlist, updated$dlist))
})



test_that("update.sim_com_data keeps dlist when unrelated params change", {

  com <- readRDS(test_path("fixtures", "sim_com_data.rds"))
  original_dlist <- com$dlist

  updated <- update(com, r = 1.2)
  expect_identical(updated$dlist, original_dlist)
})



test_that("update.sim_com_data handles missing dlist logic correctly", {

  com <- readRDS(test_path("fixtures", "sim_com_data.rds"))

  com$dlist <- NULL
  updated <- update(com, rate = 0.003)

  expect_true(inherits(updated$dlist, "list"))
})


test_that("update.sim_com_data throws error if call is missing", {

  dummy <- list()
  class(dummy) <- "sim_com_data"

  expect_error(update(dummy, r = 1.5), "Need an object with call component")
})


test_that("update.sim_com_data warns if nothing to update", {

  com <- readRDS(test_path("fixtures", "sim_com_data.rds"))
  expect_warning(update(com), "Nothing to update")
})

# update.sim_com_data with list-based K_map (time-dynamic) ----

test_that("update.sim_com_data handles list-based K_map when updating unrelated parameters", {

  com <- readRDS(test_path("fixtures", "sim_com_data.rds"))
  base_k <- unwrap(com$K_map)

  r1 <- mask(rast(base_k, nlyrs = 3, vals = 5), base_k[[1]])
  r2 <- mask(rast(base_k, nlyrs = 3, vals = 6), base_k[[1]])

  com$K_map <- list(r1, r2, r1, r1)

  updated <- update(com, r = c(1.5, 1.8, 1.2, 1.1))

  expect_s3_class(updated, "sim_com_data")
  expect_type(updated$K_map, "list")
  expect_length(updated$K_map, 4)
  expect_true(inherits(updated$K_map[[1]], "PackedSpatRaster"))

  expect_equal(updated$spec_data[[1]]$r, 1.5)
  expect_equal(updated$spec_data[[4]]$r, 1.1)
})

test_that("update.sim_com_data allows replacing K_map with a time-dynamic list", {

  com <- readRDS(test_path("fixtures", "sim_com_data.rds"))
  base_k <- unwrap(com$K_map)

  r1 <- mask(rast(base_k, nlyrs = 3, vals = 8), base_k[[1]])
  new_k_list <- list(r1, r1 + 1, r1 - 1, r1 + 4)
  names(new_k_list) <- 1:4

  updated <- update(com, K_map = new_k_list, r = com$r + 0.2, a = com$a * 2)

  expect_s3_class(updated, "sim_com_data")
  expect_type(updated$K_map, "list")

  # Verify new values are active (checking max to safely ignore NAs)
  unwrapped_k1 <- unwrap(updated$K_map[[1]])
  expect_equal(max(values(unwrapped_k1), na.rm = TRUE), 8)
})

test_that("update.sim_com_data returns an unwrapped list inside the call when evaluate = FALSE", {

  com <- readRDS(test_path("fixtures", "sim_com_data.rds"))
  base_k <- unwrap(com$K_map)

  r1 <- mask(rast(base_k, nlyrs = 3, vals = 5), base_k[[1]])
  r2 <- mask(rast(base_k, nlyrs = 3, vals = 6), base_k[[1]])

  com$K_map <- list(r1, r2, r1, r1)

  call_out <- update(com, r = 1.9, evaluate = FALSE)

  expect_true(is.call(call_out))

  call_list <- as.list(call_out)
  expect_type(call_list$K_map, "list")
  expect_s4_class(call_list$K_map[[1]], "SpatRaster")
  expect_s4_class(call_list$K_map[[4]], "SpatRaster")
})
