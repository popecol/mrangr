#' Print `sim_com_results` Object
#'
#' @param x `sim_com_results` object; returned by the [`sim_com`] function
#' @param ... further arguments passed to or from other methods; none specified
#'
#' @returns `sim_com_results` object is invisibly returned (the `x` param)
#'
#' @export
#'
#' @method print sim_com_results
#'
#' @examples
#' # Read simulation data from the mrangr package
#' simulated_com <- get_simulated_com()
#'
#' # Print
#' print(simulated_com)
#'
print.sim_com_results <- function(x, ...) {

  cat("Class: sim_com_results\n\n")

  cat("N_map: \n")
  cat("Dimentions [rows, cols, time, species]: ", dim(x$N_map),"\n")
  cat("Abundances summary: \n")
  print(summarise_species_abundance(x$N_map, x$spec_names))

  cat("\nSimulated time steps: ", x$sim_time, "\n\n")

  cat("Extinction: \n")
  print(x$extinction)

  invisible(x)
}
