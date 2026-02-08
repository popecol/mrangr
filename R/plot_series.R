#' Community Time-Series Plot
#'
#' This function plots a community time-series for a given location and time.
#'
#' @param obj An object of class `sim_com_results`.
#' @param x Indices for the x-dimension - first dimension of the `obj$N_map` (default: full range).
#' @param y Indices for the y-dimension - second dimension of the `obj$N_map` (default: full range).
#' @param time Indices for the time-dimension - third dimension of the `obj$N_map` (default: full range).
#' @param species Indices for the species - fourth dimension of the `obj$N_map` (default: full range).
#' @param trans An optional function to apply to the calculated mean series
#'   before plotting (e.g., `log`, `log1p`). Defaults to `NULL` (no transformation).
#' @param ... Additional graphical parameters passed to `plot`.
#'
#'
#' @return Invisibly returns a matrix of the mean (and possibly transformed) abundance values for each species.
#' @export
#'
#' @examples
#' # Read simulation data from the mrangr package
#' simulated_com <- get_simulated_com()
#'
#' # Plot
#' plot_series(simulated_com)
#' plot_series(simulated_com, x = 5:12, y = 1:5)
#' plot_series(simulated_com, time = 1:5)
#' plot_series(simulated_com, trans = log1p)
#'
plot_series <- function(obj,
                        x = seq(dim(obj$N_map)[1]),
                        y = seq(dim(obj$N_map)[2]),
                        time = seq(obj$sim_time),
                        species = seq(dim(obj$N_map)[4]),
                        trans = NULL,
                        ...) {

  # Validate input
  assert_that(
    inherits(obj, "sim_com_results"),
    msg = "`obj` must be of class 'sim_com_results'"
  )

  N_map <- obj$N_map
  dims <- dim(N_map) # rows (x), cols (y), time, species

  # Validate x
  assert_that(
    is.numeric(x),
    all(x >= 1),
    all(x <= dims[1]),
    all(x == floor(x)),
    msg = paste0("`x` must be numeric indices within: 1-", dims[1])
  )

  # Validate y
  assert_that(
    is.numeric(y),
    all(y >= 1),
    all(y <= dims[2]),
    all(y == floor(y)),
    msg = paste0("`y` must be numeric indices within: 1-", dims[2])
  )

  # Validate time
  assert_that(
    is.numeric(time),
    all(time >= 1),
    all(time <= dims[3]),
    all(time == floor(time)),
    msg = paste0("`time` must be numeric values within the simulation time range: 1-", obj$sim_time)
  )

  # Validate trans
  if (!is.null(trans)) {
    assert_that(is.function(trans), msg = "'trans' argument must be a function or NULL")
  }


  # Subset the object
  N_map <- N_map[x, y, time, species, drop = FALSE]

  # Calculate mean across the first two dimensions (spatial)
  # for each combination of the third (time) and fourth (species) dimensions
  n <- apply(N_map, 3:4, mean, na.rm = TRUE)

  # Apply transformation if 'trans' is provided and is a function
  if (!is.null(trans)) {
    n <- trans(n)

    if (all(is.na(n))) {
      stop("The selected region is located outside the study area.")
    }
  }


  # Plotting
  graphics::plot(time, time, type = "n", ylim = range(n, na.rm = TRUE), xlab = "Time", ylab = "Mean abundance", ...)
  graphics::matlines(time, n, ...)

  # Invisibly return the calculated (and possibly transformed) mean series
  return(invisible(n))
}

