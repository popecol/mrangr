test_that("print.sim_com_results prints expected sections", {

  simulated_com <- readRDS(test_path("fixtures", "sim_com_results.rds"))

  printed <- capture.output(print(simulated_com))

  # Expected structure
  expect_true(any(grepl("Class: sim_com_results", printed)))
  expect_true(any(grepl("N_map", printed)))
  expect_true(any(grepl("Dimentions", printed, ignore.case = TRUE)))
  expect_true(any(grepl("Abundances summary", printed)))
  expect_true(any(grepl("Simulated time steps", printed)))
  expect_true(any(grepl("Extinction", printed)))
})
