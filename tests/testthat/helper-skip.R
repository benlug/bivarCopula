# tests/testthat/helper-skip.R

skip_if_no_cmdstan <- function() {
    testthat::skip_if_not_installed("cmdstanr")
    testthat::skip_if_not(
        nzchar(Sys.getenv("CMDSTAN")) || tryCatch(
            {
                cmdstanr::cmdstan_path()
                TRUE
            },
            error = function(e) FALSE
        ),
        message = "CmdStan is not installed"
    )
}
