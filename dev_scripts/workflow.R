library(terra)
library(rangr)
library(mrangr)

library(RColorBrewer)
# display.brewer.all(type = "qual")
pal <- brewer.pal(8, "Dark2")
col <- adjustcolor(pal, alpha.f = 0.5)


# 1. Template raster ----
nrows <- ncols <- 50
xmin <- 250000; xmax <- xmin + nrows * 1000
ymin <- 600000; ymax <- ymin + ncols * 1000
id <- rast(nrows = nrows, ncols = ncols, xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax)
crs(id) <- "epsg:2180"
id


# 2. Carrying capacity maps ----

# No. of species in the community
nspec <- 4

# Correlation matrix of carrying capacity maps.
cor_mat <- FieldSimR::rand_cor_mat(nspec, -0.5, 0.5, pos.def = TRUE)

K_map <- K_sim(nspec, id, range = diagonal(id), cor_mat = cor_mat, qfun = qlnorm, meanlog = 2, sdlog = 0.5)
K_map
plot(K_map)


# 3. Interaction matrix ----
mu_a <- -0.3 # mean strength of pairwise interactions
sigma_a <- 0.5 # sd of pairwise interactions
a <- matrix(rnorm(nspec^2, mu_a, sigma_a), nrow = nspec, ncol = nspec)
diag(a) <- NA
a <- round(a, 2)
a

# 4. Initialise simulation parameters ----
invasion <- initialise_inv(invaders = c(1, 3), invasion_times = c(10, 20, 30))
data <- initialise_com(K_map = K_map, r = 1, a = a, rate = 1 / 500, max_dist = diagonal(id), invasion = invasion)
summary(data)
dlist <- data$dlist

data <- initialise_com(K_map = K_map, r = 1, a = a, max_dist = diagonal(id), dlist = dlist)
summary(data)


# 5. Simulate community ----
time <- 20
com <- sim_com(data, time)
summary(com)
N <- com$N_map
dim(N)


# 6. Figures ----

# Maps
plot(com)
plot(com, time = 1)
plot(com, main = LETTERS[seq(nspec)])


# Community time-series
plot_series(com, col = col, lty = 1, lwd = 2)
plot_series(com, trans = log1p)
plot_series(com, x = 1, y = 1)


# 7. Virtual Ecologist ----

ve <- virtual_ecologist(
  com,
  type = "random_one_layer",
  prop = 0.01,
  obs_error = "rlnorm",
  obs_error_param = 0.1
)

summary(ve)

