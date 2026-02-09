# Silence warnings and messages
options(warn = -1)

# Configure knitr options for examples
if (requireNamespace("knitr", quietly = TRUE)) {
  knitr::opts_chunk$set(
    warning = FALSE,
    message = FALSE,
    error = FALSE,
    # Adjust figure dimensions here (values are in inches)
    fig.width = 5,
    fig.height = 6, # Increase this number to make figures taller
    fig.align = "center"
  )
}


# The Custom Function Global Assignment
abs_rnorm <- function(n, mean, sd) {
  abs(rnorm(n, mean = mean, sd = sd))
}
# Force it into GlobalEnv so match.fun() can see it from within package calls
assign("abs_rnorm", abs_rnorm, envir = .GlobalEnv)

