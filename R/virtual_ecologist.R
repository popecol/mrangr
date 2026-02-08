#' Virtual Ecologist
#'
#' Organizes and extracts community data from a simulated community object
#' based on one of three sampling methods: random proportion, constant random
#' sites, or user-provided sites.
#'
#' @param obj An object created by the [`sim_com()`] function,
#' containing simulation data.
#' @param sites An optional data frame specifying the sites for data extraction.
#' This data frame must contain three columns: `x`, `y` and `time`.
#' @param type character vector of length 1; describes the sampling type
#' (case-sensitive):
#' \itemize{
#'   \item `"random_one_layer"` - random selection of cells for which abundances
#'   are sampled; the same set of selected cells is used across all time steps.
#'   \item `"random_all_layers"` - random selection of cells for which abundances
#'   are sampled; a new set of cells is selected for each time step.
#'   \item `"from_data"` - user-defined selection of cells for which abundances
#'   are sampled; the user is required to provide a `data.frame` containing
#'   three columns: `"x"`, `"y"` and `"time"`.
#' }
#' @param prop A numeric value between 0 and 1. The proportion of cells to randomly
#' sample from the raster.
#' @param obs_error character vector of length 1; type of the distribution
#' that defines the observation process: "[`rlnorm`][stats::rlnorm()]"
#' (log-normal distribution) or "[`rbinom`][stats::rbinom()]" (binomial distribution).
#' @param obs_error_param numeric vector of length 1; standard deviation
#' (on a log scale) of the random noise in the observation process when
#' `"rlnorm"` is used, or probability of detection (success) when `"rbinom"` is used.
#'
#'
#' @return
#' A data frame with 6 columns:
#'
#' - `id`: unique cell identifier (factor)
#' - `x`, `y`: sampled cell coordinates
#' - `species`: species number or name
#' - `time`: sampled time step
#' - `n`: sampled abundance
#'
#' @export
#'
#' @examples
#' # Read simulated community data from the mrangr package
#' simulated_com <- get_simulated_com()
#'
#' # Option 1: Randomly sample sites (the same for each year)
#' sampled_data_01 <- virtual_ecologist(simulated_com)
#' head(sampled_data_01)
#'
#' # Option 2: Randomly sample sites (different for each year)
#' sampled_data_02 <- virtual_ecologist(simulated_com, type = "random_all_layers")
#' head(sampled_data_02)
#'
#' # Option 3: Sample sites based on user-provided data frame
#' custom_sites <- data.frame(
#'   x = c(250500, 252500, 254500),
#'   y = c(600500, 602500, 604500),
#'   time = c(1, 10, 20)
#' )
#' sampled_data_03 <- virtual_ecologist(simulated_com, sites = custom_sites)
#' head(sampled_data_03)
#'
#' # Option 4. Add noise - "rlnorm"
#' sampled_data_04 <- virtual_ecologist(
#'   simulated_com,
#'   sites = custom_sites,
#'   obs_error = "rlnorm",
#'   obs_error_param = log(1.2)
#' )
#' head(sampled_data_04)
#'
#' # Option 5. Add noise - "rbinom"
#' sampled_data_05 <- virtual_ecologist(
#'   simulated_com,
#'   sites = custom_sites,
#'   obs_error = "rbinom",
#'   obs_error_param = 0.8
#' )
#' head(sampled_data_05)
#'
#'
virtual_ecologist <- function(
    obj,
    type = c("random_one_layer", "random_all_layers", "from_data"),
    sites = NULL,
    prop = 0.01,
    obs_error = c("rlnorm", "rbinom"),
    obs_error_param = NULL) {

  # arguments validation
  type <- match.arg(type)
  obs_error <- match.arg(obs_error)

  assert_that(inherits(obj, "sim_com_results"),
              msg = "`obj` must be of class 'sim_com_results'")

  if (!is.null(sites)) {
    # ---- From data ----
    assert_that(is.data.frame(sites) || is.matrix(sites))
    sites <- as.data.frame(sites)
    assert_that(ncol(sites) >= 3,
                msg = "The 'sites' data must contain at least 3 columns.")
    assert_that(all(c("x", "y", "time") %in% names(sites)),
                msg = "The 'sites' data must contain columns: x, y, time.")
    assert_that(nrow(sites) > 0, msg = "The 'sites' data must contain at least 1 row.")
    assert_that(all(!is.na(sites)),
                msg = "Missing values found in 'sites'")
    assert_that(all(apply(sites, 2, is.numeric)),
                msg = "All columns in 'sites' must be numeric")

    out <- ve_from_data(obj, sites)

  } else {
    # ---- Random sampling ----
    assert_that(length(prop) == 1 && is.numeric(prop))
    assert_that(prop > 0 && prop <= 1,
                msg = "`prop` must be > 0 and <= 1")

    ncell_id <- terra::ncell(terra::unwrap(obj$id))
    size <- floor(prop * ncell_id)
    if (size < 1) {
      warning("Sampling proportion too small; at least one cell will be sampled.")
      size <- 1
    }

    if (type == "random_one_layer") {
      out <- ve_random_one_layer(obj, size)
    } else if (type == "random_all_layers") {
      out <- ve_random_all_layers(obj, size)
    }
  }

  rownames(out) <- NULL

  # ---- Observation error ----
  if (!is.null(obs_error_param)) {
    assert_that(length(obs_error_param) == 1,
                msg = "`obs_error_param` must be length 1")

    if (obs_error == "rlnorm") {
      assert_that(is.numeric(obs_error_param),
                  msg = "`obs_error_param` must be numeric for rlnorm")
      out$n <- stats::rlnorm(nrow(out), meanlog = log(out$n), sdlog = obs_error_param)

    } else if (obs_error == "rbinom") {
      assert_that(is.numeric(obs_error_param) && obs_error_param >= 0 && obs_error_param <= 1,
                  msg = "`obs_error_param` must be a probability between 0 and 1 for rbinom")
      out$n <- stats::rbinom(nrow(out), size = out$n, prob = obs_error_param)
    }
  }

  return(out)
}





# internal functions -----------------------------------------------------------


#' Randomly sample raster layers across species (same cells across all time steps)
#'
#' @param obj A `sim_com_results` object.
#' @param size Number of random cells to sample (same cells across all time steps).
#'
#' @return A data frame with columns `id`, `x`, `y`, `species`, `time`, `n`.
#' @noRd
#'
ve_random_one_layer <- function(obj, size) {

  N_map <- obj$N_map
  id_rast <- terra::unwrap(obj$id)
  dims <- dim(N_map)
  n_time <- dims[3]
  n_spec <- dims[4]
  spec_names <- obj$spec_names

  # random cell IDs shared across all species and time steps
  cell_ids <- sample(seq_len(terra::ncell(id_rast)), size = size)
  rc <- terra::rowColFromCell(id_rast, cell_ids)
  rows <- rc[, 1]
  cols <- rc[, 2]
  coords <- terra::xyFromCell(id_rast, cell_ids)

  # full cross product of sampled cells × species × time
  expand <- expand.grid(
    idx = seq_along(cell_ids),
    species = spec_names,
    time = seq_len(n_time)
  )

  # extract abundance values from 4D array
  n_vals <- N_map[cbind(rows[expand$idx], cols[expand$idx],
                        expand$time, expand$species)]

  # assemble output
  data.frame(
    id = factor(cell_ids[expand$idx]),
    x = coords[expand$idx, 1],
    y = coords[expand$idx, 2],
    species = expand$species,
    time = expand$time,
    n = n_vals
  )
}



#' Randomly sample raster layers across species and time steps
#'
#' @param obj A `sim_com_results` object.
#' @param size Number of random cells to sample at each time step for each species.
#'
#' @return A data frame with columns `id`, `x`, `y`, `species`, `time`, `n`.
#' @noRd
#'
ve_random_all_layers <- function(obj, size) {

  N_map   <- obj$N_map
  id_rast <- terra::unwrap(obj$id)
  dims    <- dim(N_map)
  n_time  <- dims[3]
  n_spec  <- dims[4]
  spec_names <- obj$spec_names
  n_cells <- terra::ncell(id_rast)

  # precompute all cell coordinates
  all_coords <- terra::xyFromCell(id_rast, 1:n_cells)

  # randomly select unique cells per (time, species) pair
  cell_ids <- replicate(n_time * n_spec,
                        sample.int(n_cells, size = size))

  # define all time × species combinations
  grid <- expand.grid(
    time = seq_len(n_time),
    species = spec_names
  )

  # full sampling plan
  grid_expanded <- data.frame(
    time = rep(grid$time, each = size),
    species = rep(grid$species, each = size),
    cell_id = as.vector(cell_ids)
  )

  # convert cell IDs to row/col indices
  rc <- terra::rowColFromCell(id_rast, grid_expanded$cell_id)

  # extract abundance values from 4D array
  n_vals <- N_map[cbind(
    rc[, 1],
    rc[, 2],
    grid_expanded$time,
    grid_expanded$species
  )]

  # assemble output
  coords <- all_coords[grid_expanded$cell_id, , drop = FALSE]
  data.frame(
    id = factor(grid_expanded$cell_id),
    x = coords[, 1],
    y = coords[, 2],
    species = grid_expanded$species,
    time = grid_expanded$time,
    n = n_vals
  )
}


#' Sample raster layers using user-supplied sites
#'
#' @param obj A `sim_com_results` object.
#' @param sites A data frame specifying the sites for data extraction.
#' Must contain columns `x`, `y`, and `time`.
#'
#' @return A data frame with columns `id`, `x`, `y`, `species`, `time`, `n`.
#' @noRd
#'
ve_from_data <- function(obj, sites) {

  N_map <- obj$N_map
  id_rast <- terra::unwrap(obj$id)
  dims <- dim(N_map)
  n_spec <- dims[4]
  spec_names <- obj$spec_names

  # convert coordinates to cell IDs and row/col indices
  cell_ids <- terra::cellFromXY(id_rast, sites[, c("x", "y")])
  rc <- terra::rowColFromCell(id_rast, cell_ids)
  rows <- rc[, 1]
  cols <- rc[, 2]

  # repeat each site for all species
  n_sites <- nrow(sites)
  sites_rep <- sites[rep(seq_len(n_sites), times = n_spec), ]
  spec_vec <- rep(seq_len(n_spec), each = n_sites)
  rows_rep <- rep(rows, times = n_spec)
  cols_rep <- rep(cols, times = n_spec)
  cell_rep <- rep(cell_ids, times = n_spec)

  # extract abundance values from 4D array
  n_vals <- N_map[cbind(rows_rep, cols_rep, sites_rep$time, spec_vec)]

  # assemble output
  data.frame(
    id = factor(cell_rep),
    x = sites_rep$x,
    y = sites_rep$y,
    species = spec_names[spec_vec],
    time = sites_rep$time,
    n = n_vals
  )
}
