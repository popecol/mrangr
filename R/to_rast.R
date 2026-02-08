#' Convert `sim_com_results` to SpatRaster(s)
#'
#' @description
#' Converts simulated population abundance data from a `sim_com_results` object
#' (produced by [`sim_com()`]) into [`SpatRaster`][terra::SpatRaster-class] objects.
#'
#' @param obj An object of class `sim_com_results`, returned by [`sim_com()`].
#' @param species Integer vector. Species ID(s) to extract.
#' @param time_points Integer vector. Time step(s) to extract (excluding burn-in).
#' @param ... Currently unused.
#'
#' @return
#' * If `length(time_points) == 1`, returns a `SpatRaster` with species as layers.
#' * If `length(time_points) > 1`, returns a named list of `SpatRaster` objects, one per species.
#' * If only one species is selected with multiple time points, returns a single `SpatRaster`.
#'
#'
#' @exportS3Method rangr::to_rast
#'
#' @examples
#'
#' # Read simulation data from the mrangr package
#' simulated_com <- get_simulated_com()
#'
#' # Extract one timestep, all species
#' r1 <- to_rast(simulated_com, time_points = 10)
#'
#' # Extract multiple timesteps, one species
#' r2 <- to_rast(simulated_com, species = 2, time_points = c(1, 5, 10))
#'
#' # Extract multiple timesteps, multiple species
#' r3 <- to_rast(simulated_com, species = c(1, 2), time_points = c(1, 5, 10))
#'
#'
to_rast.sim_com_results <- function(
    obj,
    species = seq_len(dim(obj$N_map)[4]),
    time_points = obj$sim_time,
    ...) {

  # Validate input
  assert_that(inherits(obj, "sim_com_results"),
              msg = "`obj` must be of class 'sim_com_results'")

  N_map <- obj$N_map
  dims <- dim(N_map) # rows, cols, time, species

  assert_that(
    is.numeric(time_points),
    all(time_points >= 1),
    all(time_points <= dims[3]),
    all(time_points == floor(time_points)),
    msg = paste0("`time_points` must be numeric values within the simulation time range: 1-", obj$sim_time)
  )

  assert_that(
    is.numeric(species),
    all(species >= 1),
    all(species <= dims[4]),
    all(species == floor(species)),
    msg = paste0("`species` must be numeric indices within the range of species: 1-", dim(obj$N_map)[4])
  )

  nam <- paste0("Species ", obj$spec_names[species])

  id <- terra::unwrap(obj$id)

  # Option 1: One time point -> species as layers
  if (length(time_points) == 1) {

    vals <- N_map[, , time_points, species]

    result <- id
    nlyr(result) <- length(species)
    values(result) <- vals
    names(result) <- nam

  } else {

    # Option 2: Multiple time points -> time as layers, species as separate rasters
    result <- lapply(species, function(sp) {
      vals <- N_map[, , time_points, sp]
      out <- id
      nlyr(out) <- length(time_points)
      values(out) <- vals
      names(out) <- paste0("t_", time_points)
      out
    })
    names(result) <- nam

    if (length(result) == 1)
      result <- result[[1]]
  }

  return(result)
}
