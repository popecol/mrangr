#' Update `sim_com_data` Object
#'
#' @description
#' Updates the parameters used to create a `sim_com_data` object, returned
#' by [`initialise_com()`].
#'
#' @param object A `sim_com_data` object, as returned by [initialise_com()].
#' @param ... Named arguments to update. These should be valid arguments to `initialise_com()`.
#' If `kernel_fun` is updated, any associated `kernel_args` (if present in previous call) will also be replaced.
#' @param evaluate Logical (default `TRUE`). If `TRUE`, the function returns the re-evaluated
#' updated object; if `FALSE`, it returns the updated function call without evaluating it.
#'
#' @return
#' If `evaluate = TRUE`, a new `sim_com_data` object with updated parameters.
#' If `evaluate = FALSE`, a `call` object representing the updated function call.
#'
#' @details
#' - If dispersal-related arguments such as `max_dist`, `kernel_fun`, or `kernel_args`
#'   are changed, the existing `dlist` is removed and recalculated unless a new `dlist`
#'   is explicitly provided.
#' - If `n1_map` or `K_map` is updated, the `dlist` will also be removed to
#'   ensure consistency.
#'
#' @seealso [initialise_com()]
#'
#' @export
#' @method update sim_com_data
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
#' ## Competition coefficients matrix
#' a <- a_eg
#'
#' # Initialise simulation parameters
#' community_01 <-
#'   initialise_com(
#'   K_map = K_map,
#'   r = 1.1,
#'   a = a,
#'   rate = 0.002)
#'
#' # Update simulation parameters
#'
#' # Custom kernel function
#' abs_rnorm <- function(n, mean, sd) {
#'   abs(rnorm(n, mean = mean, sd = sd))
#' }
#'
#' community_02 <- update(community_01,
#'   kernel_fun = c("rexp", "rexp", "abs_rnorm", "abs_rnorm"),
#'   kernel_args = list(
#'    list(rate = 0.002),
#'    list(rate = 0.001),
#'    list(mean = 0, sd = 1000),
#'    list(mean = 0, sd = 2000)))
#' }
#'
update.sim_com_data <- function(object, ..., evaluate = TRUE) {

  # get call
  if (is.null(call <- getCall(object))) {
    stop("Need an object with call component")
  }

  # get parameters to update
  extras <- match.call(expand.dots = FALSE)$...


  if (length(extras)) { # if anything to update

    # transform call to a list
    call <- c(as.list(call))


    # if kernel to update - remove old kernel parameters from call
    if ("kernel_fun" %in% names(extras)) {

      kernel_args <- unique(unlist(
        lapply(seq(object$nspec),
               function(i)
                 formalArgs(object$spec_data[[i]]$kernel_fun)[-1])))

      call[kernel_args] <- NULL
      call["kernel_args"] <- NULL
    }

    # check if parameters to update are present in call
    existing <- !is.na(match(names(extras), names(call)))

    # for present ones - update them
    for (a in names(extras)[existing]) {
      call[[a]] <- extras[[a]]
    }

    # for absent parameters - add them
    if (any(!existing)) {
      call <- c(call, extras[!existing])
    }

    # dlist: given, inherited or to calculate
    if (!"dlist" %in% names(extras)) { # not given dlist

      # check if old dlist should be removed
      rm_old_dlist <- any(!is.na(match(
        names(extras),
        c(
          "max_dist", "kernel_fun", "kernel_args"
        )))) |
        sum(!is.na(match(
          names(extras),
          c(
            "n1_map", "K_map"
          )
        )), na.rm = TRUE) == 2

      if (rm_old_dlist) {
        call$dlist <- NULL
      } else { # given dlist
        call$dlist <- object$dlist
      }
    }

    # unwrap maps if not updated
    if(!"K_map" %in% names(extras)) {
      call$K_map <- unwrap(object$K_map)
    }

    if(!"n1_map" %in% names(extras)) {
      call$n1_map <- unwrap(object$n1_map)
    }

    # transform call to call object
    call <- as.call(call)


    # evaluate or return the call
    if (evaluate) {
      eval(call, parent.frame())
    } else {
      return(call)
    }

  } else { # if nothing to update

    warning("Nothing to update")
    object
  }
}
