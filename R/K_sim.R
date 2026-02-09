#' Carrying Capacity Map Simulator
#'
#' Generates multiple carrying capacity maps based on spatially autocorrelated Gaussian Random Fields (GRFs), with optional correlation between layers.
#'
#' @param n Integer. Number of maps to generate.
#' @param id A [`SpatRaster`][terra::SpatRaster-class] object used as a geographic template.
#' @param range Numeric. Spatial autocorrelation parameter passed to the \code{grf} function.
#' @param cor_mat Optional correlation matrix. If \code{NULL}, maps are generated independently.
#' @param qfun Quantile function to apply to the generated GRFs (default: [`qnorm`][stats::qnorm]).
#' @param ... Additional arguments passed to the quantile function \code{qfun}.
#'
#' @return A [`SpatRaster`][terra::SpatRaster-class] object with \code{n} layers, each representing a carrying capacity map.
#' @import terra
#' @export
#'
#' @examples
#' library(terra)
#' library(FieldSimR)
#'
#' # Community parameters
#' nspec <- 4
#' nrows <- ncols <- 10
#' xmin <- 250000; xmax <- xmin + nrows * 1000
#' ymin <- 600000; ymax <- ymin + ncols * 1000
#' id <- rast(nrows = nrows, ncols = ncols, xmin = xmin, xmax = xmax,
#'                                          ymin = ymin, ymax = ymax)
#' crs(id) <- "epsg:2180"
#'
#' # Correlation matrix of carrying capacities
#' cor_mat <- FieldSimR::rand_cor_mat(nspec, -0.5, 0.5, pos.def = TRUE)
#' cor_mat
#'
#' # Generate and define the distributions and parameters
#' # of correlated carrying capacity maps
#' K_map <- K_sim(nspec, id, range = 20000, cor_mat = cor_mat, qfun = qlnorm,
#'                meanlog = 2, sdlog = 0.5)
#' K_map
#' hist(K_map)
#' plot(K_map)
#'
K_sim <- function(n, id, range, cor_mat = NULL, qfun = qnorm, ...) {

  # Generate a matrix of independent standardised GRFs
  independent_grfs <- replicate(n, terra::values(grf(id, range = range))[, 1])

  if (is.null(cor_mat)) {
    correlated_grfs <- independent_grfs
  } else {
    # Introduce correlation using Cholesky decomposition
    L <- chol(cor_mat)
    correlated_grfs <- independent_grfs %*% L
  }

  # Apply parametric quantile mapping
  p <- pnorm(correlated_grfs)
  target <- p
  target[] <- qfun(p, ...)

  # Convert GRFs to raster layers
  K_list <- vector("list", n)
  for (i in 1:n) {
    K <- id
    terra::values(K) <- target[, i]
    K_list[[i]] <- K
  }

  # Stack the maps
  K_map <- terra::rast(K_list)
  names(K_map) <- seq_len(n)

  return(K_map)
}




#' Generate a Gaussian Random Field
#'
#' Generates a Gaussian random field (GRF) based on the Matern model of spatial autocorrelation.
#'
#' @param x A template raster of class [`SpatRaster`][terra::SpatRaster-class] (from the \pkg{terra} package).
#' @param range Numeric. The range parameter of the variogram model (in spatial units of \code{x} raster).
#' @param fun A function to apply to the generated values (default is [`scale`][base::scale] to standardize the GRF).
#' @param ... Additional arguments passed to the function specified in \code{fun}.
#'
#' @return A [`SpatRaster`][terra::SpatRaster-class] object containing the generated Gaussian random field.
#'
#' @export
#'
#' @examples
#' library(terra)
#' r <- rast(nrows = 100, ncols = 100, xmin = 0, xmax = 100, ymin = 0, ymax = 100)
#' grf_field <- grf(r, range = 30)
#' plot(grf_field)
#'
#'
grf <- function(x, range, fun = "scale", ...) {

  trans <- match.fun(fun)

  # Create a data frame of coordinates for simulation
  xy <- terra::crds(x, na.rm = FALSE)
  xy[] <- as.numeric(xy)
  xy <- as.data.frame(xy)

  # Define a variogram model
  vgm_model <- gstat::vgm(psill = 1, model = "Mat", range = range)

  # Simulate Gaussian random field
  gstat_model <- gstat::gstat(formula = z ~ 1, locations = ~ x + y, dummy = TRUE,
                              beta = 0, model = vgm_model, nmax = 20)

  # Predict values over the grid
  z <- predict(gstat_model, newdata = xy, nsim = 1, debug.level = 0)$sim1
  z_trans <- trans(z, ...)

  terra::values(x) <- z_trans

  return(x)
}
