pkgname <- "copulaStan"
source(file.path(R.home("share"), "R", "examples-header.R"))
options(warn = 1)
library('copulaStan')

base::assign(".oldSearch", base::search(), pos = 'CheckExEnv')
base::assign(".old_wd", base::getwd(), pos = 'CheckExEnv')
cleanEx()
nameEx("fit_bivariate_copula")
### * fit_bivariate_copula

flush(stderr()); flush(stdout())

### Name: fit_bivariate_copula
### Title: Fit Bivariate Copula Model
### Aliases: fit_bivariate_copula

### ** Examples

## Not run: 
##D library(copula)
##D library(copulaStan)
##D 
##D set.seed(2024)
##D n <- 1000
##D cop <- normalCopula(param = 0.5, dim = 2)
##D margins <- c("norm", "lnorm")
##D params <- list(list(mean = 0.8, sd = 2), list(meanlog = 0, sdlog = 0.8))
##D mvdc_copula <- mvdc(cop, margins = margins, paramMargins = params)
##D data <- rMvdc(n, mvdc_copula)
##D 
##D fit <- fit_bivariate_copula(data,
##D   copula = "gaussian",
##D   marginals = c("normal", "lognormal"),
##D   seed = 2024
##D )
##D print(fit)
##D summary(fit)
## End(Not run)




### * <FOOTER>
###
cleanEx()
options(digits = 7L)
base::cat("Time elapsed: ", proc.time() - base::get("ptime", pos = 'CheckExEnv'),"\n")
grDevices::dev.off()
###
### Local variables: ***
### mode: outline-minor ***
### outline-regexp: "\\(> \\)?### [*]+" ***
### End: ***
quit('no')
