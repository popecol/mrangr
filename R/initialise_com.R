
#' Initialise Community Simulation Data
#'
#' Prepares community-level input data for a spatial simulation.
#' This function builds on [`rangr::initialise()`][rangr::initialise]
#' by organising inputs for multiple species and their interactions.
#'
#' @param n1_map A [`SpatRaster`][terra::SpatRaster-class] with one layer per species representing the initial abundance.  If `NULL` (default), random initial values will be generated
#'   from a Poisson distribution using `K_map`.
#' @param K_map A [`SpatRaster`][terra::SpatRaster-class] with one layer per species representing carrying capacities.
#' @param r A numeric vector of intrinsic growth rates. It can be a single-element vector (if all species have the same intrinsic growth rate) or a vector of length equal to the number of species in the community.
#' @param a A square numeric matrix representing interaction coefficients between species. Each element `a_ij` is the per-capita interaction strength of species `j` on species `i`. It expresses the change in carrying capacity of species `i` by a single individual of species `j`. The diagonal must be `NA` and the matrix must be a square matrix of order equal to the number of species. It does not have to be symmetric.
#' @param dlist Optional. A list; target cells at a specified distance calculated
#' for every cell within the study area.
#' @param invasion Optional. A named list of specifying invasion configuration (can be prepared using [`initialise_inv`]). Must contain:
#' \describe{
#'   \item{invaders}{Integer vector of invading species indices.}
#'   \item{propagule_size}{Number of individuals introduced per invasion event.}
#'   \item{invasion_times}{Matrix of invasion times, with one row per invader.}
#'  }
#' @param use_names_K_map Logical. If `TRUE`, the layer names of `K_map` are
#' used as species names. If `FALSE`, species are numbered sequentially
#'   (`1:number_of_species`). Defaults to `TRUE`.
#' @param ... Additional named arguments passed to [`rangr::initialise()`][rangr::initialise]. Each must be either length 1 or equal to the number of species.
#' \describe{
#'   \item{kernel_args}{Optional. A list of lists, each containing named arguments for the corresponding
#'   species' kernel function. Must be the same length as number of species.}
#'   }
#' @return A list of class `sim_com_data` containing:
#' \describe{
#'   \item{spec_data}{A list of `sim_data` objects (one per species) returned by [`rangr::initialise()`][rangr::initialise].}
#'   \item{nspec}{The number of species.}
#'   \item{a}{The interaction matrix.}
#'   \item{r}{Intrinsic growth rate(s).}
#'   \item{n1_map}{Initial abundance maps (wrapped `SpatRaster`).}
#'   \item{K_map}{Carrying capacity maps (wrapped `SpatRaster`).}
#'   \item{max_dist}{The maximum dispersal distance across all species.}
#'   \item{dlist}{A list; target cells at a specified distance calculated
#' for every cell within the study area.}
#'   \item{invasion}{Invasion configuration (if any).}
#'   \item{call}{The matched call.}
#' }
#'
#' @export
#'
#' @examples
#' \donttest{
#' library(terra)
#'
#' # Read data from the mrangr package
#'
#' ## Input maps
#' K_map <- rast(system.file("input_maps/K_map_eg.tif", package = "mrangr"))
#' n1_map <- rast(system.file("input_maps/n1_map_eg.tif", package = "mrangr"))
#'
#' ## Interaction coefficients matrix
#' a <- a_eg
#'
#' # Initialise simulation parameters
#' community_01 <-
#'   initialise_com(
#'   K_map = K_map,
#'   n1_map = n1_map,
#'   r = 1.1,
#'   a = a,
#'   rate = 0.002)
#'
#' # With invaders
#' invasion <- initialise_inv(
#'   invaders = c(1, 3),
#'   invasion_times = c(2, 5))
#'
#' community_02 <- initialise_com(
#'   K_map = K_map,
#'   r = 1.1,
#'   a = a,
#'   rate = 0.002,
#'   invasion = invasion)
#'
#'
#' # Custom kernel function
#' abs_rnorm <- function(n, mean, sd) {
#'   abs(rnorm(n, mean = mean, sd = sd))
#' }
#'
#' community_03 <- initialise_com(
#'   K_map = K_map,
#'   n1_map = n1_map,
#'   r = c(1.1, 1.05, 1.2, 1),
#'   a = a,
#'   kernel_fun = c("rexp", "rexp", "abs_rnorm", "abs_rnorm"),
#'   kernel_args = list(
#'     list(rate = 0.002),
#'     list(rate = 0.001),
#'     list(mean = 0, sd = 1000),
#'     list(mean = 0, sd = 2000))
#' )
#' }
#'
initialise_com <-
  function(n1_map = NULL, K_map, r, a, dlist = NULL, invasion = NULL,
           use_names_K_map = TRUE, ...) {

    # Validate input types and dimensions ----------------------------------

    assert_that(inherits(K_map, "SpatRaster"))
    assert_that(nlyr(K_map) > 1,
                msg = "Input maps must have at least two layers to simulate a community.")
    if (is.null(n1_map)) {
      n1_map <- init(K_map, function(n) suppressWarnings(rpois(n, as.vector(K_map))))
    }
    assert_that(inherits(n1_map, "SpatRaster"))
    K_n1_map_check(K_map, n1_map)



    nspec <- terra::nlyr(K_map)
    assert_that(is.numeric(r), length(r) %in% c(1, nspec),
                msg = "'r' must be either a scalar or a numeric vector of length equal to the number of species.")
    assert_that(is.matrix(a), is.numeric(a))
    assert_that(nrow(a) == nspec, ncol(a) == nspec,
                msg = "The 'a' must be a square matrix of order equal to the number of species.")
    assert_that(all(is.na(diag(a))))

    if (!is.null(invasion))
      inv_check(invasion)

    dots <- list(...)

    if (!is.null(dots$kernel_args)) {
      kernel_args <- dots$kernel_args

      assert_that(
        is.list(kernel_args),
        length(kernel_args) == nspec,
        msg = "'kernel_args' must be a list of the same length as the number of species."
      )
      dots$kernel_args <- NULL
    } else {
      kernel_args <- NULL
    }

    # get species names
    spec_names <- if (use_names_K_map) names(K_map) else seq(nspec)
    names(n1_map) <- spec_names
    names(K_map) <- spec_names


    # Process additional parameters ----------------------------------------

    dots$r <- r  # include 'r' explicitly in the parameter list

    init_params <- lapply(seq_len(nspec), function(i) {
      params <- setNames(lapply(names(dots), function(arg_name) {
        x <- dots[[arg_name]]
        if (length(x) == 1) {
          x
        } else if (length(x) == nspec) {
          x[[i]]
        } else {
          stop(paste0(
            "Argument '", arg_name,
            "' must be of length 1 or equal to the number of species (", nspec,
            "), but has length ", length(x), "."
          ))
        }
      }), names(dots))

      # Process kernel_args
      # Merge kernel_args for this species
      if (!is.null(kernel_args)) {
        kargs <- kernel_args[[i]]
        if (!is.null(kargs)) {
          params <- c(params, kargs)
        }
      }

      return(params)
    })

    # Initialise each species ----------------------------------------------

    spec_data <- lapply(seq_len(nspec), function(i) {
      do.call(rangr::initialise,
              c(list(n1_map = n1_map[[i]], K_map = K_map[[i]], calculate_dist = FALSE),
                init_params[[i]]))
    })

    # Dispersal: use max max_dist across species ----------------------

    max_dist <- max(vapply(spec_data, function(x) x$max_dist, numeric(1)), na.rm = TRUE)

    if(is.null(dlist))
      dlist <- update(spec_data[[1]], calculate_dist = TRUE, max_dist = max_dist)$dlist


    # Handle invaders ------------------------------------------------------

    if (!is.null(invasion)) {
      invaders <- invasion$invaders

      # Set the initial abundance of the invading species to 0.
      n1_map[[invaders]] <- app(n1_map[[invaders]], set_zero)
    }

    # Assemble output ------------------------------------------------------

    if(length(r) != nspec)
      r <- rep(r, times = nspec)

    out <- list(
      spec_data = spec_data,
      nspec = nspec,
      spec_names = spec_names,
      r = r,
      a = a,
      n1_map = terra::wrap(n1_map),
      K_map = terra::wrap(K_map),
      max_dist = max_dist,
      dlist = dlist,
      invasion = invasion,
      call =
        get_com_initialise_call(match.call(), a, invasion, kernel_args, dots)
    )

    class(out) <- c("sim_com_data", class(out))
    return(out)
  }



#' Initialise Invasion Parameters
#'
#' Prepares a list of invasion configuration details, including the identifiers of the invading species, the times of invasion and the number of individuals introduced at each event.
#' Result of this helper function is designed to be passed to [`initialise_com()`] as `invasion` argument.
#'
#' @param invaders An integer vector of species indices indicating which species are invaders.These indices should match the species layers in the input maps (`n1_map` and `K_map`).
#' @param invasion_times A matrix or vector specifying when each invader enters the system.
#'   If a vector is provided, it is assumed to apply to all invaders.
#'   If a matrix, it must have one row per invader and columns corresponding to invasion events.
#' @param propagule_size A numeric scalar specifying the number of individuals introduced
#'   at each invasion time. Defaults to 1.
#'
#' @return A named list with the following components:
#' \describe{
#'   \item{invaders}{Integer vector of invading species indices.}
#'   \item{propagule_size}{Number of individuals introduced per invasion event.}
#'   \item{invasion_times}{Matrix of invasion times, with one row per invader.}
#' }
#'
#' @export
#'
#' @examples
#' # Define invaders and invasion times
#' initialise_inv(
#'   invaders = c(1, 3),
#'   invasion_times = matrix(c(5, 10, 5, 20), nrow = 2, byrow = TRUE),
#'   propagule_size = 10
#' )
#'
#' # Uniform invasion times across all invaders
#' initialise_inv(
#'   invaders = c(2, 4),
#'   invasion_times = c(5, 10, 15)
#' )
#'
initialise_inv <- function(invaders, invasion_times, propagule_size = 1) {
  # Validate inputs
  assert_that(
    is.numeric(invaders),
    all(invaders > 0),
    all(invaders == floor(invaders)),
    msg = "'invaders' must be a vector of positive integers."
  )

  assert_that(
    is.count(propagule_size),
    msg = "'propagule_size' must be a single positive integer."
  )

  assert_that(
    is.numeric(invasion_times),
    all(invasion_times == floor(invasion_times)),
    all(invasion_times >= 0),
    msg = "'invasion_times' must be a vector or matrix of non-negative integers."
  )

  n <- length(invaders)

  if(is.null(dim(invasion_times))) {

    times <- length(invasion_times)
    invasion_times <- matrix(invasion_times, nrow = n, ncol = times, byrow = TRUE)
  } else {

    assert_that(
      is.matrix(invasion_times),
      nrow(invasion_times) == n,
      msg = paste0("'invasion_times' must be a matrix with one row per invader (", n, ").")
    )
  }

  # List of invasion parameters
  invasion <- list(invaders = invaders,
                   propagule_size = propagule_size,
                   invasion_times = invasion_times)


  return(invasion)
}


# internal functions -----------------------------------------------------------

#' Validating K_map And n1_map
#'
#' This internal function checks if `K_map` and `n1_map` are correct (contain
#' only non-negative values or NAs) and corresponds to each other.
#' In case of any mistake in given data, suitable error message is printed.
#'
#' @inheritParams initialise_com
#'
#'
#' @noRd
#'
K_n1_map_check <- function(K_map, n1_map) {

  # compare n1_map and K_map
  compareGeom(n1_map, K_map)

  # check NAs placement
  assert_that(
    all(is.na(values(n1_map)) == is.na(values(K_map))),
    msg = "n1_map and K_map have NA values in different grid cells")


  # ensure values are non-negative
  if (!all(values(n1_map) >= 0, na.rm = TRUE)) {
    stop("n1_map can contain only non-negative values or NAs")
  }

  if (!all(values(K_map) >= 0, na.rm = TRUE)) {
    stop("K_map can contain only non-negative values or NAs")
  }
}


# helper function to get com_initialise call with info about dlist
get_com_initialise_call <- function(call, a, invasion, kernel_args, dots) {

  if ("dlist" %in% names(call)) {
    call$dlist <- TRUE
  }

  call$a <- a
  call$invasion <- NULL
  call$kernel_args <- kernel_args

  for (var in names(dots)) {
    call[[var]] <- dots[[var]]
  }


  return(call)
}


inv_check <- function(invasion) {

  assert_that(
    all(c("invaders", "propagule_size", "invasion_times") %in% names(invasion)),
    msg = "'invasion' must be a named list containing 'invaders', 'propagule_size', and 'invasion_times' (can be prepared using 'initialise_inv'.")

  invaders <- invasion$invaders
  invasion_times <- invasion$invasion_times
  propagule_size <- invasion$propagule_size

  assert_that(
    is.numeric(invaders),
    all(invaders > 0),
    all(invaders == floor(invaders)),
    msg = "'invaders' must be a vector of positive integers."
  )

  assert_that(
    is.count(propagule_size),
    msg = "'propagule_size' must be a single positive integer."
  )

  n <- length(invaders)
  assert_that(
    is.numeric(invasion_times),
    all(invasion_times == floor(invasion_times)),
    all(invasion_times >= 0),
    is.matrix(invasion_times),
    nrow(invasion_times) == n,
    msg = paste0("'invasion_times' must be a matrix of non-negative integers with one row per invader (", n, ")."))

}
