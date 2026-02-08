#' Load Example Community Object
#'
#' Loads a pre-simulated example of a spatial community object, useful for
#' demos and testing.
#'
#' @return
#' An object of class `sim_com_data` containing community structure,
#' simulation parameters, species-specific carrying capacity and initial
#' abundance maps.
#'
#' @export
#'
#' @examples
#' community <- get_community()
#' summary(community)
#'
get_community <- function() {
  readRDS(system.file("extdata/community_eg.rds", package = "mrangr"))
}

#' Load Example Simulated Community Results
#'
#' Loads a pre-run simulation output, based on the example community data.
#' Useful for examples, unit tests, or visualization.
#'
#' @return
#' An object of class `sim_com_results` containing simulation output for
#' a community over time.
#'
#' @export
#'
#' @examples
#' sim <- get_simulated_com()
#' plot(sim)
#'
get_simulated_com <- function() {
  readRDS(system.file("extdata/simulated_com_eg.rds", package = "mrangr"))
}

#' Compute Maximum Possible Distance for a Raster Object
#'
#' Calculates the diagonal length of a raster's extent, accounting for the
#' coordinate reference system.
#'
#' @param x A raster object.
#'
#' @return The diagonal distance in meteres.
#'
#' @export
#'
#' @examples
#' library(terra)
#'
#' # Read data from the mrangr package
#' K_map <- rast(system.file("input_maps/K_map_eg.tif", package = "mrangr"))
#'
#' diagonal(K_map)
#'
diagonal <- function(x) {
  e <- as.vector(terra::ext(x))
  corners <- rbind(e[c(1, 3)], e[c(2, 4)])
  v <- vect(corners, crs = crs(x))
  d <- terra::distance(v)

  return(ceiling(as.numeric(d)))
}


#' Set Non-Missing Values to Zero
#'
#' This function takes an object and sets all non-missing
#' values to zero, while leaving missing values unchanged.
#'
#' @param x A vector or other object for which `is.na()` and subsetting with `[]`
#'   are defined (e.g., vector, data frame, SpatRaster).
#'
#' @return An object of the same type as `x` with all originally non-missing
#'   elements replaced by zero.
#'
#' @examples
#' # Example with a numeric vector
#' vec <- c(1, 2, NA, 4, NA, 5)
#' set_zero(vec)
#'
#' @export
#'
set_zero <- function(x) {
  # Select elements that are NOT NA and assign 0 to them.
  x[!is.na(x)] <- 0
  return(x)
}
