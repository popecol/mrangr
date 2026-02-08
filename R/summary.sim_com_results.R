#' Summary Of `sim_com_results` Object
#'
#' @param object `sim_com_results` object; returned by [`sim_com`] function
#' @param ... further arguments passed to or from other methods; none specified
#'
#' @return `summary.sim_com_results` object
#' @export
#'
#' @method summary sim_com_results
#'
#' @examples
#' # Read simulation data from the mrangr package
#' simulated_com <- get_simulated_com()
#'
#' # Summary
#' summary(simulated_com)
#'
summary.sim_com_results <- function(object, ...) {

  output <- list()

  output$sim_time <- object$sim_time
  output$extinction <- object$extinction
  output$N_map_sm <-
    summarise_species_abundance(object$N_map, object$spec_names)

  class(output) <- "summary.sim_com_results"

  return(output)
}


#' Print `summary.sim_results` Object
#'
#' @param x `summary.sim_com_results` object; returned by
#' [`summary.sim_com_results`] function
#' @param ... further arguments passed to or from other methods;
#'            currently none specified
#'
#' @return None
#'
#' @export
#' @method print summary.sim_com_results
#'
#' @examples
#' # Read simulation data from the mrangr package
#' simulated_com <- get_simulated_com()
#'
#' # Print summary
#' sim_com_summary <- summary(simulated_com)
#' print(sim_com_summary)
#'
print.summary.sim_com_results <- function(x, ...) {

  cat("Summary of sim_com_results object\n\n")

  cat("Abundances summary: \n")
  print(x$N_map_sm)

  cat("\nSimulated time steps: ", x$sim_time, "\n\n")

  cat("Extinction: \n")
  print(x$extinction)
}


#' Summarise Species Abundance Across Space and Time
#'
#' Computes summary statistics of abundance for each species in a 4D abundance array.
#' This function is used internally by the [`summary.sim_com_results()`] method to
#' provide an overview of abundance distributions across all time steps and map cells.
#'
#' @param N_map A 4D numeric array of abundance values, typically extracted from a
#' `sim_com_results` object (returned by [`sim()`]). The array should have dimensions `[rows, cols, time, species]`.
#'
#' @return A `data.frame` with one row per species, and columns for:
#' - `species`: species index
#' - `min`: minimum abundance
#' - `q1`: first quartile (25%)
#' - `median`: median abundance
#' - `mean`: mean abundance
#' - `q3`: third quartile (75%)
#' - `max`: maximum abundance
#'
#' @details This function flattens the spatial and temporal dimensions of the `N_map` array,
#' summarising abundance distributions for each species. All `NA` values are ignored.
#'
#' @examples
#' simulated_com <- get_simulated_com()
#' N_map <- simulated_com$N_map
#' summarise_species_abundance(N_map)
#'
#' @noRd
#' @keywords internal
#' @seealso [summary.sim_com_results()]
#'
summarise_species_abundance <- function(N_map, spec_names) {

  n <- dim(N_map)[4]

  summary_df <- data.frame(
    species = spec_names,
    min     = numeric(n),
    q1      = numeric(n),
    median  = numeric(n),
    mean    = numeric(n),
    q3      = numeric(n),
    max     = numeric(n),
    stringsAsFactors = FALSE
  )

  for (i in seq_len(n)) {
    vals  <- N_map[, , , i]
    stats <- summary(vals, na.rm = TRUE)
    stats <- round(stats, 2)

    summary_df$min[i]    <- stats["Min."]
    summary_df$q1[i]     <- stats["1st Qu."]
    summary_df$median[i] <- stats["Median"]
    summary_df$mean[i]   <- stats["Mean"]
    summary_df$q3[i]     <- stats["3rd Qu."]
    summary_df$max[i]    <- stats["Max."]
  }

  return(summary_df)
}
