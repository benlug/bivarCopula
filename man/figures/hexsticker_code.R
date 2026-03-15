## Hex sticker for bivarCopula
## Matches design language of dcvar hex sticker
## Built with ggplot2 only (no system deps required)

library(ggplot2)

# --- Hex geometry (shared with dcvar) ---
hex_polygon <- function(x_center = 0, y_center = 0, radius = 1) {
  angles <- seq(30, 390, by = 60) * pi / 180
  data.frame(
    x = x_center + radius * cos(angles),
    y = y_center + radius * sin(angles)
  )
}

hex_x_at_y <- function(y, radius = 0.93) {
  half_w <- radius * sqrt(3) / 2
  half_h <- radius
  ay <- abs(y)
  if (ay > half_h) return(c(0, 0))
  if (ay <= half_h / 2) {
    xmax <- half_w
  } else {
    xmax <- half_w * (1 - (ay - half_h / 2) / (half_h / 2))
  }
  c(-xmax, xmax)
}

rescale <- function(v, lo, hi) {
  r <- range(v, na.rm = TRUE)
  lo + (v - r[1]) / (r[2] - r[1]) * (hi - lo)
}

# --- Gumbel copula density on a grid with normal margins ---
# Gumbel has upper tail dependence and produces visually balanced contours
theta <- 1.8
grid_n <- 200
x_seq <- seq(-3, 3, length.out = grid_n)
y_seq <- seq(-3, 3, length.out = grid_n)
grid <- expand.grid(x = x_seq, y = y_seq)

u <- pnorm(grid$x)
v <- pnorm(grid$y)

# Gumbel copula density (analytical)
lu <- -log(u)
lv <- -log(v)
A  <- (lu^theta + lv^theta)^(1 / theta)
C  <- exp(-A)  # copula value

# c(u,v) = C(u,v) / (u*v) * (lu*lv)^(theta-1) * A^(2-2*theta+1/theta) *
#          (A + theta - 1) * (lu^theta + lv^theta)^(1/theta - 2)
# Simplified:
grid$z <- ifelse(
  u > 0.005 & v > 0.005 & u < 0.995 & v < 0.995,
  C / (u * v) * (lu * lv)^(theta - 1) / (A^(2 * theta - 2 - 1 / theta + 2 - 2)) *
    (A + theta - 1) / ((lu^theta + lv^theta)^(2 - 1 / theta)),
  NA
)

# Recompute more carefully to avoid formula errors
# Gumbel copula density:
# c(u,v) = C(u,v) * (lu*lv)^(theta-1) / (u*v) *
#          (A + theta - 1) / A^(2*theta - 1) *
#          (lu^theta + lv^theta)^(1/theta - 2)  ... nah, let me just use the
# known simplified form.
#
# Actually the cleanest form:
# c(u,v) = C(u,v) * (1/(u*v)) * (lu*lv)^(theta-1) *
#          A^(1/theta - 2) * (A + theta - 1) / (lu^theta + lv^theta)^(2 - 1/theta)
#
# But this simplifies since A = (lu^theta + lv^theta)^(1/theta), so
# A^(1/theta-2) / (lu^theta+lv^theta)^(2-1/theta) gets messy.
# Let's use a direct computation:

S <- lu^theta + lv^theta   # = A^theta
grid$z <- ifelse(
  u > 0.005 & v > 0.005 & u < 0.995 & v < 0.995,
  C * (lu * lv)^(theta - 1) / (u * v) * S^(1 / theta - 2) * (S^(1 / theta) + theta - 1),
  NA
)

# Multiply by normal marginal densities for the bivariate density
grid$z <- grid$z * dnorm(grid$x) * dnorm(grid$y)

# Cap extreme values
z_cap <- quantile(grid$z, 0.99, na.rm = TRUE)
grid$z <- pmin(grid$z, z_cap)

# Rescale coordinates to fit centred in hex
grid$xp <- rescale(grid$x, -0.52, 0.52)
grid$yp <- rescale(grid$y, -0.35, 0.35)

# Quantile-based contour breaks
z_pos <- grid$z[!is.na(grid$z) & grid$z > 0]
contour_breaks <- quantile(z_pos, probs = seq(0.5, 0.97, length.out = 7))

# --- Marginal density curves ---
dens_vals <- seq(-3, 3, length.out = 256)
dens_y    <- dnorm(dens_vals)
margin_y  <- rescale(dens_vals, -0.35, 0.35)

margin_width <- 0.22
d1_x_base <- -0.56
d2_x_base <-  0.56
d1_x <- d1_x_base - rescale(dens_y, 0, margin_width)
d2_x <- d2_x_base + rescale(dens_y, 0, margin_width)

# Clip density polygons to hex boundary
clip_to_hex <- function(x_density, y_density, x_base_val, side = "left",
                        radius = 0.88) {
  x_out <- x_density
  x_base_out <- rep(x_base_val, length(y_density))
  for (i in seq_along(y_density)) {
    bounds <- hex_x_at_y(y_density[i], radius = radius)
    if (side == "left") {
      x_out[i]      <- max(x_out[i], bounds[1])
      x_base_out[i] <- max(x_base_out[i], bounds[1])
    } else {
      x_out[i]      <- min(x_out[i], bounds[2])
      x_base_out[i] <- min(x_base_out[i], bounds[2])
    }
  }
  keep <- if (side == "left") x_out < x_base_out else x_out > x_base_out
  list(x_density = x_out[keep], x_base = x_base_out[keep], y = y_density[keep])
}

cl1 <- clip_to_hex(d1_x, margin_y, d1_x_base, "left")
cl2 <- clip_to_hex(d2_x, margin_y, d2_x_base, "right")

margin1_df <- data.frame(
  x = c(cl1$x_density, rev(cl1$x_base)),
  y = c(cl1$y, rev(cl1$y))
)
margin2_df <- data.frame(
  x = c(cl2$x_density, rev(cl2$x_base)),
  y = c(cl2$y, rev(cl2$y))
)

# --- Colours (same palette as dcvar) ---
col_fill   <- "#023047"
col_border <- "#219EBC"
col_line1  <- "#8ECAE6"
col_line2  <- "#FFB703"

# --- Build the sticker ---
hex <- hex_polygon(0, 0, radius = 1)
hex_inner <- hex_polygon(0, 0, radius = 0.97)

p <- ggplot() +
  # Hex fill
  geom_polygon(data = hex, aes(x, y), fill = col_fill, colour = NA) +
  # Gumbel copula contour lines
  geom_contour(data = grid, aes(x = xp, y = yp, z = z),
               colour = col_line1, linewidth = 0.5, alpha = 0.85,
               breaks = contour_breaks) +
  # Marginal density — left
  geom_polygon(data = margin1_df, aes(x, y),
               fill = NA, colour = col_line1, linewidth = 0.6) +
  # Marginal density — right
  geom_polygon(data = margin2_df, aes(x, y),
               fill = NA, colour = col_line2, linewidth = 0.6) +
  # Hex border (on top)
  geom_polygon(data = hex_inner, aes(x, y),
               fill = NA, colour = col_border, linewidth = 2) +
  coord_fixed(xlim = c(-1.05, 1.05), ylim = c(-1.05, 1.05)) +
  theme_void() +
  theme(
    legend.position = "none",
    plot.background = element_rect(fill = "transparent", colour = NA),
    plot.margin = margin(0, 0, 0, 0)
  )

# --- Save ---
outfile <- file.path(here::here(), "man", "figures", "bivarCopula_hex.png")
ggsave(outfile, p, width = 2, height = 2 * 2 / sqrt(3),
       dpi = 300, bg = "transparent")

message("Hex sticker saved to ", outfile)
