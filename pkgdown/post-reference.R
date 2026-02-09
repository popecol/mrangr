# Reset warnings (from our previous steps)
options(warn = 0)

# Remove the custom function from the Global Environment
if (exists("abs_rnorm", envir = .GlobalEnv)) {
  rm("abs_rnorm", envir = .GlobalEnv)
}
