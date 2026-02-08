test_that("print.sim_com_data prints all expected sections", {

  com <- readRDS(test_path("fixtures", "sim_com_data.rds"))

  printed <- capture.output(print(com))

  expect_true(any(grepl("Class: sim_com_data", printed)))
  expect_true(any(grepl("Number of species:", printed)))
  expect_true(any(grepl("Species-specific parameters", printed)))
  expect_true(any(grepl("Max dispersal distance", printed)))
  expect_true(any(grepl("Border types", printed)))
  expect_true(any(grepl("K_map", printed)))
  expect_true(any(grepl("n1_map", printed)))
  expect_true(any(grepl("Competition matrix", printed)))
})


test_that("print.sim_com_data prints invasion info when invasion is present", {

  com <- readRDS(test_path("fixtures", "sim_com_data.rds"))
  inv <- com$invasion

  expect_true(!is.null(inv))
  printed <- capture.output(print(com))

  expect_true(any(grepl("Invasion settings", printed)))
  expect_true(any(grepl("Invader species", printed)))
  expect_true(any(grepl("Propagule size", printed)))
  expect_true(any(grepl("Invasion times", printed)))
})


test_that("extract_species_params returns correct structure without invasion", {

  com <- readRDS(test_path("fixtures", "sim_com_data.rds"))

  df <- extract_species_params(com$spec_data, com$spec_names)
  expect_s3_class(df, "data.frame")

  expect_named(df, c("species", "r", "r_sd", "K_sd", "A", "dens_dep", "kernel", "kernel_args"))
  expect_equal(nrow(df), com$nspec)
})


test_that("extract_species_params includes invasion column when invasion present", {

  com <- readRDS(test_path("fixtures", "sim_com_data.rds"))

  df <- extract_species_params(com$spec_data, com$spec_names, com$invasion)
  expect_true("invader" %in% names(df))
  expect_type(df$invader, "logical")
})


test_that("extract_species_params handles missing kernel args", {

  com <- readRDS(test_path("fixtures", "sim_com_data.rds"))

  # Remove kernel function and call from first species
  com$spec_data[[1]]$kernel_fun <- NULL
  com$spec_data[[1]]$call <- NULL

  df <- extract_species_params(com$spec_data, com$spec_names)
  expect_true(is.na(df$kernel_args[1]))
})


test_that("print_inv prints all expected invasion info", {

  com <- readRDS(test_path("fixtures", "sim_com_data.rds"))
  inv <- com$invasion

  printed <- capture.output(print_inv(inv, com$spec_names))

  expect_true(any(grepl("Invasion settings", printed)))
  expect_true(any(grepl("Invader species", printed)))
  expect_true(any(grepl("Propagule size", printed)))
  expect_true(any(grepl("Invasion times", printed)))
})

test_that("print.sim_com_data handles NULL invasion", {

  com <- readRDS(test_path("fixtures", "sim_com_data.rds"))
  com$invasion <- NULL

  expect_output(print(com))
})
