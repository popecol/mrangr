#' @name K_map_eg.tif
#' @title Example Of Carrying Capacity Map
#' @docType data
#'
#' @description
#' [`SpatRaster`][terra::SpatRaster-class] object with 4 layer that can be
#' passed to [`initialise_com`] a as simulation ([`sim_com`]) starting point.
#'
#' This map is compatible with [`n1_map_eg.tif`].
#'
#' @format [`SpatRaster`][terra::SpatRaster-class] object with 4 layers, each
#' with 15 rows and 15 columns. Contains numeric values representing carrying
#' capacity and NA's indicating unsuitable areas.
#'
#' @source Data generated in-house to serve as an example
#' (using spatial autocorrelation).
#'
#' @examples
#' terra::rast(system.file("input_maps/K_map_eg.tif", package = "mrangr"))
#'
NULL


#' @name n1_map_eg.tif
#' @title Example Of Abundance Map At First Time Step Of The Simulation
#' @docType data
#'
#' @description
#' [`SpatRaster`][terra::SpatRaster-class] object with 4 layer that can be
#' passed to [`initialise_com`] a as simulation ([`sim_com`]) starting point.
#'
#' This map is compatible with [`K_map_eg.tif`].
#'
#' @format [`SpatRaster`][terra::SpatRaster-class] object with 4 layers, each
#' with 15 rows and 15 columns. Contains integer values representing abundance
#' and NA's indicating unsuitable areas.
#'
#' @source Data generated in-house to serve as an example.
#'
#' @examples
#' terra::rast(system.file("input_maps/n1_map_eg.tif", package = "mrangr"))
#'
NULL


#' @title Example Of Interaction Coefficients Matrix
#'
#' @description
#' A square numeric matrix representing interaction coefficients between
#' species. `a_ij` is the per-capita interaction strength of species `j`
#' on species `i`. It expresses the change in carrying capacity of species `i`
#' by a single individual of species `j`.
#' This data is compatible with [`n1_map_eg.tif`] and [`K_map_eg.tif`] maps.
#'
#' @format A numeric matrix with 4 rows and 4 columns containing interaction coefficients.
#'
#' @source Data generated in-house to serve as an example
#'
"a_eg"

#' @name community_eg
#' @title Example Community Data
#' @docType data
#'
#' @description
#' A pre-initialized `sim_com_data` object used to demonstrate community
#' structure and simulation input. It contains 4 species with spatially
#' correlated carrying capacity and initial abundance maps.
#'
#' This object can be accessed via the [`get_community`] function.
#'
#' @format An object of class `sim_com_data` from the `mrangr` package generated
#' using [`initialise_com`].
#'
#' @seealso [`get_community`], [`initialise_com`]
#'
#' @source Data generated in-house to serve as an example
#'
NULL

#' @name simulated_com_eg
#' @title Example Simulated Community Output
#' @docType data
#'
#' @description
#' A `sim_com_results` object containing results of a 20-step simulation of
#' a 4-species community.
#'
#' The simulation was generated using the [`community_eg`] object.
#'
#' This object can be accessed via the [`get_simulated_com`] function.
#'
#' @format An object of class `sim_com_results` from the `mrangr` package
#' generated using [`sim_com`].
#'
#' @seealso [`get_simulated_com`], [`plot.sim_com_results`], [`sim_com`]
#'
#' @source Data generated in-house to serve as an example
#'
NULL
