library(copula)
library(ggplot2)
library(ggExtra)
library(hexSticker)
library(showtext)

clayton_density <- function(u, v, theta) {
  num <- (theta + 1) * (u * v)^(-theta - 1) * (u^(-theta) + v^(-theta) - 1)^(-2 - 1/theta)
  return(num)
}

theta <- 2.0
n <- 1000
cop <- claytonCopula(param = theta, dim = 2)
u <- rCopula(n, cop)
u <- qnorm(u)


p <- ggplot(data.frame(u), aes(x = u[,1], y = u[,2])) +
  geom_density2d(aes(colour = ..level..)) +
  geom_point(alpha = 0.3) +
  scale_colour_viridis_c() +
  theme_void() +
  theme(legend.position = "none",
        panel.grid = element_blank(),
        axis.title = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank())

p <- ggMarginal(p, type = "density", fill = "blue", alpha = 0.5, margins = "both", size = 4)

font_add_google("Gochi Hand", "gochi")
showtext_auto()

sticker(p,
        package = "",                    #
        p_size = 8,
        s_x = 1, s_y = 1,
        s_width = 1.4, s_height = 1.4,
        h_fill = "#1E90FF",
        h_color = "#00008B",
        spotlight = TRUE,
        l_x = 1, l_y = 1, l_alpha = 0.3,
        url = "copulaStan",
        u_size = 4,
        u_color = "#FFFFFF",
        filename = "inst/figures/copulaStan_hex.png")  # Output file

sticker_img <- png::readPNG("inst/figures/copulaStan_hex.png")
grid::grid.raster(sticker_img)

