#' Print `sim_com_data` Object
#'
#' @param x `sim_com_data` object; returned by the [`initialise_com`] function
#' @param ... further arguments passed to or from other methods;
#' currently none specified
#'
#' @returns `sim_com_data` object is invisibly returned (the `x` param)
#'
#' @export
#'
#' @method print sim_com_data
#'
#' @examples
#' # Read community data from the mrangr package
#' community <- get_community()
#'
#' # Print
#' print(community)
#'
print.sim_com_data <- function(x, ...) {
  cat("Class: sim_com_data\n\n")

  cat("Number of species:", x$nspec, "\n")

  cat("\nSpecies-specific parameters:\n")

  # extract values from each sim_data object
  param_table <- extract_species_params(x$spec_data, x$spec_names, x$invasion)
  print(param_table, row.names = FALSE)

  cat("\nMax dispersal distance across species (used to calculate 'dlist'):\n  ", toString(x$max_dist))
  cat("\n\nBorder types:\n  ", x$spec_data[[1]]$border, "\n")

  cat("\nK_map:\n")
  print(unwrap(x$K_map))
  cat("\nn1_map:\n")
  print(unwrap(x$n1_map))


  cat("\nCompetition matrix (a):\n")
  a_named <- x$a
  rownames(a_named) <- x$spec_names
  colnames(a_named) <- x$spec_names

  print(a_named)

  if (!is.null(x$invasion)) {
    print_inv(x$invasion, x$spec_names)
  }

  invisible(x)
}

# internal functions -----------------------------------------------------------

print_inv <- function(invasion, spec_names) {
  cat("\nInvasion settings:\n")
  cat("  Invader species: ", toString(spec_names[invasion$invaders]), "\n", sep = "")
  cat("  Propagule size: ", invasion$propagule_size, "\n", sep = "")
  cat("  Invasion times (rows: species, columns: time step):\n\n")

  inv_times <- invasion$invasion_times
  colnames(inv_times) <- paste0(
    "t",
    formatC(
      seq_len(ncol(inv_times)),
      width = nchar(ncol(inv_times)),
      format = "d",
      flag = "0"
    )
  )
  rownames(inv_times) <- spec_names[invasion$invaders]

  inv_str <- capture.output(print(inv_times))
  cat(paste0("  ", inv_str), sep = "\n")
}



extract_species_params <- function(spec_data_list, spec_names, invasion = NULL) {
  nspec <- length(spec_data_list)

  # Predefine empty data.frame with correct types
  params_df <- data.frame(
    species = integer(nspec),
    invader = logical(nspec),
    r = numeric(nspec),
    r_sd = numeric(nspec),
    K_sd = numeric(nspec),
    A = character(nspec),
    dens_dep = logical(nspec),
    kernel = character(nspec),
    kernel_args = character(nspec),
    stringsAsFactors = FALSE
  )

  for (i in seq_len(nspec)) {
    sd <- spec_data_list[[i]]

    arguments <- if (!is.null(sd$kernel_fun)) formalArgs(sd$kernel_fun) else NULL
    kernel_args_str <- NA_character_

    if (!is.null(arguments) && length(arguments) > 1 && !is.null(sd$call)) {
      arg_values <- character(length(arguments) - 1)
      for (j in seq_along(arg_values)) {
        arg_name <- arguments[j + 1]

        if (!is.null(sd$call[[arg_name]])) {
          val <- sd$call[[arg_name]]

          arg_values[j] <-
            paste0(arg_name, " = ",
                   if (is.null(val)) "1"
                   else as.character(signif(val), digits = 4))
        }
      }
      kernel_args_str <- paste(arg_values, collapse = ", ")
    }

    params_df[i, ] <- list(
      species = i,
      invader = if (!is.null(invasion)) i %in% invasion$invaders else FALSE,
      r = if (!is.null(sd$r)) round(sd$r, 4) else NA_real_,
      r_sd = if (!is.null(sd$r_sd)) round(sd$r_sd, 4) else NA_real_,
      K_sd = if (!is.null(sd$K_sd)) round(sd$K_sd, 4) else NA_real_,
      A = if (!is.na(sd$A)) sd$A else "-",
      dens_dep = if (!is.null(sd$dens_dep)) sd$dens_dep else NA,
      kernel = if (!is.null(sd$kernel_fun)) deparse(sd$kernel_fun)[1] else NA_character_,
      kernel_args = kernel_args_str
    )
  }

  params_df$species <- spec_names

  if (is.null(invasion)) {
    params_df$invader <- NULL
  }

  return(params_df)
}
