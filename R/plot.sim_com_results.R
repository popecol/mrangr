#' Plot `sim_com_results` Object
#'
#' @description Draws simulated abundance maps for any species at any time
#'
#' @param x An object of class `sim_com_results`, returned by [`sim_com()`].
#' @param species Integer vector. Species ID(s) to plot.
#' @param time_points Integer vector. Time step(s) to plot (excluding burn-in).
#' @param type Character vector of length 1. Type of map:
#' "continuous" (default), "classes" or "interval"  (case-sensitive)
#' @param main Character vector. Plot titles (one for each layer)
#' @param range Numeric vector of length 2. Range of values to be used for the
#' legend (if `type = "continuous"`), which by default is calculated from
#' the N_map slot of `sim_com_results` object
#' @param ... Further arguments passed to [`terra::plot`]
#'
#' @returns
#' #' * If `length(time_points) == 1`, returns a `SpatRaster` with species as layers.
#' * If only one species is selected with multiple time points, returns a single `SpatRaster`.
#'
#' @export
#' @method plot sim_com_results
#'
#' @examples
#' # Read simulation data from the mrangr package
#' simulated_com <- get_simulated_com()
#'
#' # Plot
#' plot(simulated_com)
#'
plot.sim_com_results <- function(
    x,
    species = seq_len(dim(x$N_map)[4]),
    time_points = x$sim_time,
    type = "continuous",
    main,
    range, ...) {


  # Validate time_points
  if (any(time_points > max(x$sim_time))) {
    stop("Invalid 'time_points': some exceed the simulated time range.")
  }

  # Default range - abundance range
  if (missing(range)) {
    range <- base::range(x$N_map[, , time_points, species], na.rm = TRUE)
    if (range[2] == 0) {
      range <- NULL
    }
  }

  spec_names <- x$spec_names
  # Default plot titles
  if (missing(main)) {
    main <- paste0("sp: ",  rep(spec_names, each = length(time_points)),
                   "\nt: ", rep(time_points, times = length(species)))
  } else {
    assert_that(length(main) == length(time_points) * length(species))
  }

  # Define raster / list of rasters from simulated data
  x_rast <- to_rast(
    obj = x,
    species = species,
    time_points = time_points
  )


  # Plot simulated abundances
  if(inherits(x_rast, "SpatRaster")) {

    plot(x_rast, type = type, range = range, main = main, ...)

  } else {

    # Combine all rasters into a single SpatRaster
    x_rast_unlisted <- rast(x_rast)

    # Create new names by combining list names and original layer names
    original_layer_names <- names(x_rast[[1]])
    new_layer_names <- unlist(lapply(names(x_rast), function(species_name) {
      paste0(species_name, ": ", original_layer_names)
    }))

    # Assign the new names to the combined raster
    names(x_rast_unlisted) <- new_layer_names

    plot(x_rast_unlisted, type = type, range = range, main = main,
         nc = length(time_points), nr = length(species), ...)

  }

  return(invisible(x_rast))
}
