
# Community Simulator


# Libraries & functions ---------------------------------------------------

# library(devtools)
# install_github("ropensci/rangr")
library(rangr)
library(terra)
library(parallel)
library(FieldSimR)

source("R/helpers.R")
source("R/K_sim.R")

sim_species <- function(i) {
  # For each species 'i', calculates the total impact of the remaining
  # species on it (as a change in carrying capacity relative to the baseline).
  # One simulation step is then performed, i.e. the abundance of species 'i' in
  # the next time step is calculated.
  # Argument:
  #     i: index of a species in the community.
  # Returns 3-dimensional array of population numbers of species 'i'.

  dK[] <- 0
  for (j in seq(nspec))
    dK[, , j] <- a[i, j] * N[, , t - 1, j]
  sum_dK <- apply(dK, 1:2, sum, na.rm = TRUE)
  K[, , t, i] <- pmax(K[, , 1, i] + sum_dK, 0)
  n1_m <- setValues(rast(id), N[, , t - 1, i])
  K_m <- setValues(rast(id), K[, , t, i])
  data[[i]] <- update(data[[i]], n1_map = n1_m, K_map = K_m, dlist = dlist)
  sim_results <- sim(data[[i]], time = 2)
  return(sim_results[["N_map"]][, , 2])
}


# Template blank raster ---------------------------------------------------

nrows <- ncols <- 10
xmin <- 250000; xmax <- xmin + nrows * 1000
ymin <- 600000; ymax <- ymin + ncols * 1000
id <- rast(nrows = nrows, ncols = ncols, xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax)
# crs(id) <- "local" # issue?
crs(id) <- "epsg:2180"
id

max_dist <- diagonal(id)
# nrows <- nrow(id)
# ncols <- ncol(id)


# Community parameters ----------------------------------------------------

# Number of species
nspec <- 9

# Interaction matrix ----

# a_ij is the per-capita interaction strength of species j on species i.
# It expresses the change in carrying capacity of species i by a single individual of species j.

# set.seed(1)
mu_a <- 0 # mean strength of pairwise interactions
sigma_a <- 0.5 # sd of pairwise interactions

a <- matrix(rnorm(nspec^2, mu_a, sigma_a), nrow = nspec, ncol = nspec)
# a <- ifelse(abs(a) > 0.2, a, 0)
# zeros <- 0.5
# a[sample(nspec^2, nspec^2 * zeros)] <- 0
diag(a) <- NA
(a <- round(a, 2))
summary(as.vector(a)); hist(a)


# Invasions ---------------------------------------------------------------

# Which species are invaders
invaders <- 1:2
n_invaders <- length(invaders)
if(n_invaders < 1) invaders <- NULL

# Invasion time for each species (rows: species, cols: time)
times <- seq(5, 20, 5)
propagule_number <- length(times) # the number of release events
invasion_time <- matrix(times, n_invaders, propagule_number, byrow = TRUE)
invasion_time

propagule_size <- 1 # number of individuals involved in any one release event

(propagule_pressure <- propagule_number * propagule_size)


# Simulating correlated carrying capacity maps ----------------------------

# Correlation matrix of carrying capacities
cor_mat <- rand_cor_mat(nspec, 0.2, 0.8, pos.def = TRUE)
round(cor_mat, 2)
# coefs <- cor_mat[lower.tri(cor_mat)]
# summary(coefs); hist(coefs)

K_map <- K_sim(nspec, id, range = 20000, cor_mat = cor_mat, qfun = qlnorm, meanlog = 2, sdlog = 0.5)
K_map
hist(K_map)
# pairs(log(K_map))
plot(K_map)

# Initial population numbers
n1_map <- init(K_map, \(n) rpois(n, as.vector(K_map)))

# Set zero for invaders
n1_map[[invaders]] <- 0

names(n1_map) <- paste0("n1_", seq(nspec))
n1_map; plot(n1_map)


# Species d <- ta ------------------------------------------------------------

# Intrinsic population growth rate
r <- 1

# Calculating target cells for dispersal
dlist_data <- initialise(n1_map[[1]], K_map[[1]], r = 1, rate = 1 / 100, max_dist = max_dist)
dlist <- dlist_data[["dlist"]]

data <- lapply(1:nspec,
               \(i) initialise(n1_map = n1_map[[i]],
                               K_map = K_map[[i]],
                               r = 1,
                               rate = 1 / 100,
                               calculate_dist = FALSE))

# data <- lapply(1:nspec, \(i) update(data[[i]], dlist = dlist))


# Cluster configuration ---------------------------------------------------

# detectCores(logical = FALSE)
cl <- makeCluster(9)

clusterEvalQ(cl, {
  library(terra)
  library(rangr)
})

clusterExport(cl, c("nspec", "data", "dlist", "a"))



# Simulation --------------------------------------------------------------

time <- 50
burn <- 0
sim_time <- burn + time
inv_time <- burn + invasion_time

dim <- c(nrows, ncols, sim_time, nspec)
N <- array(0L, dim = dim)
K <- array(0, dim = dim)
dK <- array(0, dim = dim[-3])

K[, , 1, ] <- as.array(K_map)
N[, , 1, ] <- as.array(n1_map)

clusterExport(cl, c("dK", "K"))

clusterEvalQ(cl, {
  id <- data[[1]][["id"]]
  # r <- data[[1]][["r"]]
  # NULL
})


# Loop through time
pb <- txtProgressBar(min = 1, max = sim_time, style = 3, width = 60)
setTxtProgressBar(pb, 1)

for (t in 2:sim_time) {

  # Invasions
  if(n_invaders > 0) {
    for (j in seq(n_invaders)) {
      if(any(t == inv_time[j, ] + 1)) {
        x <- sample.int(nrows, 1)
        y <- sample.int(ncols, 1)
        N[x, y, t - 1, invaders[j]] <- N[x, y, t - 1, invaders[j]] + propagule_size
      }
    }
  }

  clusterExport(cl, c("N", "t"))
  N[, , t, ] <- parSapply(cl, seq(nspec), sim_species)
  setTxtProgressBar(pb, t)
}
close(pb)


if(burn > 0) N <- N[, , -c(1:burn), ]
dim(N)

# At the end:
N_map <- rast(N[, , time, ])
hist(N_map, breaks = 25)
hist(log1p(N_map), breaks = 25)
plot(N_map)
# plot(log1p(N_map))

# packed_K_map <- wrap(K_map)
# save(packed_K_map, r, a, N, file = "data/sim_1.RData")
# save(packed_K_map, r, a, N, file = "data/sim_2.RData")


# Plot time-series -------------------------------------------------------

# Population numbers
n <- plot_series(N, col = col)
add_legend("top", legend = 1:nspec, lwd = 2, col = col, horiz = TRUE, bty = "n")
# cor(n)

# Smoothed trajectories
n <- plot_series(N, col = col, smooth = TRUE)

# Random site
matplot(N[sample.int(nrows, 1), sample.int(ncols, 1), , ], type = "l", col = col, xlab = "Time", ylab = "No. of individuals", lty = 1, lwd = 2)

# Invaders
N_inv <- apply(N[, , , invaders, drop = FALSE], 3:4, sum)
matplot(1:time, N_inv, type = "l", main = "Invaders", xlab = "Time", ylab = "No. of individuals", lwd = 2, col = col[invaders], lty = 1); abline(v = invasion_time, lty = 2, col = col[rep(invaders, ncol(invasion_time))])




# Cleaning ----------------------------------------------------------------

stopCluster(cl)
