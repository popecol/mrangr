test_that("get_simulated_com works", {

  sim <- get_simulated_com()
  expect_s3_class(sim, "sim_com_results")
})


test_that("get_community works", {

  community <- get_community()
  expect_s3_class(community, "sim_com_data")
})


test_that("diagonal works", {

  r <- rast(ncols=10, nrows=10, xmin=0, xmax=10, ymin=0, ymax=10, crs="epsg:3857")

  expect_equal(diagonal(r), 15)
})


test_that("set_zero works", {

  vec <- c(1, -2, NA)
  set_zero(vec)

  expect_equal(set_zero(vec), c(0, 0, NA))
})
