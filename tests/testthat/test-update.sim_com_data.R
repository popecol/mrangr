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
