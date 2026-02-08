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
cor_mat <- FieldSimR::rand_cor_mat(nspec, 0.5, 0.99, pos.def = TRUE)
all(eigen(cor_mat)$values >= 0) # test (must be TRUE)

K_map <- K_sim(nspec, id, range = diagonal(id), cor_mat = cor_mat, qfun = qlnorm, meanlog = 2, sdlog = 0.5)
K_map
hist(K_map, breaks = 50)
pairs(log1p(K_map))
plot(K_map)

library(tweedie)
K_map <- K_sim(nspec, id, range = diagonal(id), cor_mat = cor_mat, qfun = qtweedie, xi = 1.5, mu = 10, phi = 5)
K_map
hist(K_map, breaks = 50)
hist(log1p(K_map), breaks = 50)
pairs(log1p(K_map))
plot(K_map)

library(EnvStats)
K_map <- K_sim(nspec, id, range = diagonal(id), cor_mat = cor_mat, qfun = rzmlnorm, meanlog = 2, sdlog = 0.5, p.zero = 0.5)
K_map
hist(K_map, breaks = 50)
pairs(log1p(K_map))
plot(K_map)


# 3. Interaction matrix ----
mu_a <- -0.3 # mean strength of pairwise interactions
sigma_a <- 0.5 # sd of pairwise interactions
a <- matrix(rnorm(nspec^2, mu_a, sigma_a), nrow = nspec, ncol = nspec)
diag(a) <- NA
a <- round(a, 2)
a

# 4. Initialise simulation parameters ----

# Testy (do usunięca później)
initialise_inv(invaders = 1, invasion_times = 10)
initialise_inv(invaders = c(1, 3), invasion_times = c(10, 20, 30), 2)

(times <- rbind(c(5, 10), c(3, 7)))
initialise_inv(invaders = 1, invasion_times = times) # ma być błąd
initialise_inv(invaders = 1:2, invasion_times = times)
initialise_inv(invaders = 1, invasion_times = array()) # ma być błąd

invasion <- initialise_inv(invaders = c(1, 3), invasion_times = c(10, 20, 30))
data <- initialise_com(K_map = K_map, r = 1, a = a, rate = 1 / 500, max_dist = diagonal(id), invasion = invasion)

dlist <- data$dlist


# 4.1 Updating simulation parameters ----
data <- update(data, rate = c(1 / 1e3, 1 / 500), n1_map = K_map, dlist = dlist) # ma być błąd
data <- update(data, rate = round(1 / seq(100, 1000, length.out = nspec), 5), n1_map = K_map, dlist = dlist)

invasion <- initialise_inv(invaders = c(1, 3), invasion_times = 10, 1000)
data <- update(data, invasion = invasion, rate = 1 / 500, n1_map = NULL, dlist = dlist, a = a)
summary(data)

data <- update(data, invasion = NULL)
summary(data)


# 4.2 Print and summary sim_com_data ----
library(extraDistr)

data1 <- initialise_com(
  K_map = K_map,
  r = seq(from = 1, by = 0.2, length.out = nspec),
  a = a)

print(data1)
summary(data1)

data2 <- update(
  data1,
  kernel_fun = "rht",
  nu = 100, sigma = 2000,
  invasion = initialise_inv(invaders = c(1, 3), invasion_times = c(3, 6)),
  dlist = data1$dlist)

print(data2)
summary(data2)


data3 <- update(
  data2,
  kernel_fun = c("rexp", "rht", "rexp", "rht"),
  kernel_args = list(
    list(rate = 0.002),
    list(nu = 100, sigma = 2000),
    list(rate = 0.002),
    list(nu = 100, sigma = 2000)),
  dlist = data1$dlist)

print(data3)
summary(data3)

# 5. Simulate community ----
time <- 23
burn <- 3
sim_time <- time - burn

com <- sim_com(data, time, burn)
# com <- sim_com(data, time, progress_bar = FALSE)
com <- sim_com(data, time = burn + 1, burn)

N <- com$N_map
dim(N)


# Results ----

# Maps
plot(com)
plot(com, species = c(1, 3))
plot(com, species = 5)
plot(com, time = 1)
plot(com, time = com$sim_time + 1)
plot(com, main = c("Ab", "Cd"))
plot(com, main = c("Ab", "Cd", "Ef", "GH"))
plot(com, range = c(0, 30))


# Community time-series
plot_series(com)
plot_series(com, col = col, lty = 1, lwd = 3)
n <- plot_series(com); dim(n)
plot_series(com, col = col, trans = log1p)
plot_series(com, x = 1, y = 1)
plot_series(com, x = 1:5)
plot_series(com, x = 100)
plot_series(com, time = 10:20)
plot_series(com, time = 100)
n <- plot_series(com, species = 2:3); dim(n)
plot_series(com, species = 5)

# Conversion to rast
rst <- to_rast(com)
rst
plot(rst)


# Virtual Ecologist ----

f <- function(x) dlnorm(x, sdlog = 0.1)
curve(f, from = 0, to = 2)

d <- rlnorm(100, 1, 0.5)
de <- rlnorm(100, meanlog = log(d), sdlog = 0.1)
plot(d, de); abline(a = 0, b = 1)

nsites <- 10
# ve <- spatSample(to_rast(com), nsites, xy = TRUE)

id <- rast(com$id)
site <- sample(values(id), nsites)
xy <- data.frame(site = site, x = xFromCell(id, site), y = yFromCell(id, site))
sites <- expand.grid(site = site, spec = seq(nspec), time_step = seq(com$sim_time))
sites <- merge(sites, xy, by = "site")

ve <- virtual_ecologist(
  com,
  type = "from_data",
  sites = sites,
  obs_error = "rlnorm",
  obs_error_param = 0.1
)
summary(ve)


ve <- virtual_ecologist(
  com,
  type = "random_one_layer",
  prop = 0.004,
  obs_error = "rbinom",
  obs_error_param = 0.5
)
summary(ve)
