
#' Simulate Community Dynamics Over Time
#'
#' This function simulates species interactions and population dynamics over a given period.
#' It accounts for species invasions and updates population abundances at each time step.
#'
#' @param obj An object of class `sim_com_data`, as returned by [`initialise_com()`].
#' @param time Integer. Total number of simulation steps. Must be >= 2.
#' @param burn Integer. Number of initial burn-in steps to exclude from the output. Must be >= 0 and < `time`.
#' @param progress_bar Logical. Whether to display a progress bar during the simulation.
#'
#' @return An object of class `sim_com_results`, a list containing:
#' \describe{
#'   \item{extinction}{Named logical vector indicating species that went extinct.}
#'   \item{sim_time}{Integer. Duration of the output simulation (excluding burn-in).}
#'   \item{id}{A [`SpatRaster`][terra::SpatRaster-class] object used as a geographic template.}
#'   \item{N_map}{4D array \[rows, cols, time, species\] of population abundances.}

#' }
#'
#' @export
#'
#' @examples
#' \donttest{
#' # Read community data from the mrangr package
#' community <- get_community()
#'
#' # Simulation
#' simulated_com_01 <- sim_com(obj = community, time = 10)
#'
#' # Simulation with burned time steps
#' simulated_com_02 <- sim_com(obj = community, time = 10, burn = 3)
#' }
#'
sim_com <- function(obj, time, burn = 0, progress_bar = TRUE) {

  assert_that(
    inherits(obj, "sim_com_data"),
    msg = "'obj' must be of class 'sim_com_data', typically returned by 'initialise_com()'.")

  assert_that(
    is.count(time),
    time >= 2,
    msg = "'time' must be a positive integer >= 2.")

  assert_that(
    is.count(burn) || burn == 0,
    burn < time,
    msg = "'burn' must be a non-negative integer and less than 'time'.")

  assert_that(
    is.flag(progress_bar),
    msg = "'progress_bar' must be a logical value (TRUE or FALSE).")

  nspec <- length(obj$spec_data)
  extinction_status <- vector(length = nspec)
  invasion <- obj$invasion
  a <- obj$a

  if (!is.null(invasion)) {

    inv_check(invasion)

    invaders <- invasion$invaders
    inv_time <- invasion$invasion_times
    propagule_size <- invasion$propagule_size
  }

  id <- unwrap(obj$spec_data[[1]]$id) # Grid cell identifiers as a raster
  nrows <- nrow(id)
  ncols <- ncol(id)

  dim <- c(nrows, ncols, time, nspec)
  N <- array(0L, dim = dim)
  K <- array(0, dim = dim)
  dK <- array(0, dim = dim[-3])  # [nrows, ncols, nspec]

  K_map <- unwrap(obj$K_map)
  n1_map <- unwrap(obj$n1_map)

  K[, , 1, ] <- as.array(K_map)
  N[, , 1, ] <- as.array(n1_map)

  dlist <- obj$dlist


  # Initialize progress bar
  if (progress_bar) {
    pb <- utils::txtProgressBar(min = 1, max = time, style = 3, width = 60)
    utils::setTxtProgressBar(pb, 1)
  }

  # Time loop
  for (t in 2:time) {

    # Handle invasions
    if(!is.null(invasion)) {
      for (j in seq(length(invaders))) {
        if(any(t == inv_time[j, ] + 1)) {
          x <- sample.int(nrows, 1)
          y <- sample.int(ncols, 1)
          N[x, y, t - 1, invaders[j]] <- N[x, y, t - 1, invaders[j]] + propagule_size
        }
      }
    }

    # Simulate species for time t
    N[, , t, ] <- vapply(
      seq(nspec),
      sim_species, obj = obj, dK = dK, N = N, K = K, t = t,
      a = a, dlist = dlist, id = id, e = extinction_status,
      FUN.VALUE = matrix(0, nrows, ncols)
    )


    # Check extinction status
    extinction_status <- get_extinction_status(N, t, nspec)
    if (all(extinction_status)) {
      break
    }

    if (progress_bar) utils::setTxtProgressBar(pb, t)
  }
  if (progress_bar) close(pb)


  # Prepare list with extinction status, simulated time and abundances
  out <- list(
    extinction = setNames(extinction_status, obj$spec_names),
    spec_names = obj$spec_names,
    sim_time = t - burn,
    id = obj[["spec_data"]][[1]][["id"]],
    N_map = N[, , (burn + 1):t, , drop = FALSE]
  )
  # set class
  class(out) <- c("sim_com_results", class(out))

  return(out)
}



#' Simulate a Single Species for One Time Step
#'
#' Internal function used by `sim_com()` to simulate the population dynamics
#' of one species, given its interactions and the previous time step's state.
#'
#' @param i Integer. Species index.
#' @param obj A `sim_com_data` object from `initialise_com()`.
#' @param dK Array. Temporary array for computing species interactions \[rows, cols, species\].
#' @param N 4D array. Population abundances \[rows, cols, time, species\].
#' @param K 4D array. Carrying capacities \[rows, cols, time, species\].
#' @param t Integer. Current time step.
#' @param a Matrix. Interaction matrix.
#' @param dlist List. Dispersal distance list.
#' @param id SpatRaster. Grid ID raster.
#' @param e Logical. Extinction status.
#'
#' @return Matrix of population abundances at time `t` for species `i` \[rows, cols\].
#'
#' @noRd
#'
sim_species <- function(i, obj, dK, N, K, t, a, dlist, id, e) {

  if (e[i]) {
    return(N[, , t - 1, i])
  }

  nspec <- obj$nspec
  dK[] <- 0

  for (j in seq(nspec)) {
    dK[, , j] <- a[i, j] * N[, , t - 1, j]
  }

  sum_dK <- apply(dK, 1:2, sum, na.rm = TRUE)
  K[, , t, i] <- pmax(K[, , 1, i] + sum_dK, 0)

  n1_m <- terra::setValues(terra::rast(id), N[, , t - 1, i])
  K_m <- terra::setValues(terra::rast(id), K[, , t, i])

  obj$spec_data[[i]] <- update(
    obj$spec_data[[i]],
    n1_map = n1_m,
    K_map = K_m,
    dlist = dlist)

  sim_results <- rangr::sim(
    obj$spec_data[[i]],
    time = 2,
    quiet = TRUE, progress_bar = FALSE)

  return(sim_results$N_map[, , 2])
}


#' Get Extinction Status
#'
#' @param N 4D array. Population abundances \[rows, cols, time, species\].
#' @param t Integer. Current time step.
#' @param nspec Integer. Number of species.
#'
#' @return Logical vector of length `nspec`..
#'
#' @noRd
get_extinction_status <- function(N, t, nspec) {

  extinction_status <-
    vapply(
      seq(nspec),
      function(i)
        ifelse(sum(N[, , t, i], na.rm = TRUE) == 0,
               TRUE,
               FALSE),
      FUN.VALUE = logical(1))

  return(extinction_status)
}
