#' Summary Of `sim_com_data` Object
#'
#' @param object `sim_com_data` object; returned by [`initialise_com`] function
#' @param ... further arguments passed to or from other methods; currently none used
#'
#' @return A list of class `summary.sim_com_data`
#' @export
#' @method summary sim_com_data
#'
#' @examples
#' # Read community data from the mrangr package
#' community <- get_community()
#'
#' # Summary
#' summary(community)
#'
summary.sim_com_data <- function(object, ...) {

  nspec <- object$nspec

  # Summarise wrapped n1_map and K_map
  n1_summary <-
    summarise_species_maps(object$n1_map, object$spec_names)
  K_summary  <-
    summarise_species_maps(object$K_map, object$spec_names)
  names(n1_summary) <- paste0("n1_", names(n1_summary))
  names(K_summary) <- paste0("K_", names(K_summary))

  # Species-level parameters
  species_param_summary <-
    extract_species_params(object$spec_data, object$spec_names, object$invasion)

  # Combined map and parameter summary
  maps_summary <- cbind(
    species = object$spec_names,
    invader = rep(FALSE, times = nspec),
    n1_summary[c("n1_min", "n1_mean", "n1_max")],
    K_summary[c("K_min", "K_mean", "K_max")]
  )

  if (!is.null(object$invasion)) {
    maps_summary$invader <- species_param_summary$invader
  } else {
    maps_summary$invader <- NULL
  }


  # Community-level parameters
  a_matrix <- object$a
  rownames(a_matrix) <- object$spec_names
  colnames(a_matrix) <- object$spec_names

  invasion_info <- object$invasion


  output <- list(
    maps_summary = maps_summary,
    species_params = species_param_summary,
    interaction_matrix = a_matrix,
    invasion = invasion_info,
    spec_names = object$spec_names
  )

  class(output) <- "summary.sim_com_data"
  return(output)
}


#' Print `summary.sim_com_data` Object
#'
#' @param x An object of class `summary.sim_com_data`
#' @param ... Additional arguments (not used)
#'
#' @return Invisibly returns `x`
#'
#' @export
#'
#' @method print summary.sim_com_data
#'
#' @examples
#' # Read community data from the mrangr package
#' community <- get_community()
#'
#' # Print summary
#' sim_com_data_summary <- summary(community)
#' print(sim_com_data_summary)
#'
print.summary.sim_com_data <- function(x, ...) {
  cat("Summary of sim_com_data object\n\n")

  cat("Input maps (K_map and n1_map) summary by species:\n")
  print(x$maps_summary, row.names = FALSE)

  cat("\nSpecies-specific parameters:\n")
  print(x$species_params, row.names = FALSE)

  if (!is.null(x$interaction_matrix)) {
    cat("\nInteraction matrix (a):\n")
    print(x$interaction_matrix)
  }

  if (!is.null(x$invasion)) {
    print_inv(x$invasion, x$spec_names)
  }


  invisible(x)
}


# internal functions -----------------------------------------------------------

summarise_species_maps <- function(wrapped_maps, spec_names) {
  maps <- unwrap(wrapped_maps)
  n <- nlyr(maps)

  summary_df <- data.frame(
    species = spec_names,
    min = numeric(n),
    q1 = numeric(n),
    median = numeric(n),
    mean = numeric(n),
    q3 = numeric(n),
    max = numeric(n),
    stringsAsFactors = FALSE
  )

  for (i in seq_len(n)) {
    vals <- terra::values(maps[[i]], mat = FALSE)
    stats <- summary(as.numeric(vals), na.rm = TRUE)
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
