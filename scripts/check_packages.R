#!/usr/bin/env Rscript

# Verify required GNU R packages for Stage 1 extraction and Stage 2 rendering.
#
# Usage:
#   Rscript scripts/check_packages.R [--mode=all|render|extract]

#' @title Return Required Packages for a Given Pipeline Mode
#' @description Maps a pipeline mode (`"all"`, `"render"`, or `"extract"`) to
#'   the sorted vector of required CRAN package names.
#' @param mode Character scalar pipeline mode.
#' @return Character vector of required CRAN package names.
#' @examples
#' required_packages("render")
required_packages <- function(mode = "all") {
  render_pkgs <- c(
    "dplyr",
    "ggplot2",
    "knitr",
    "lubridate",
    "purrr",
    "readr",
    "rmarkdown",
    "scales",
    "tibble"
  )
  extract_pkgs <- c(
    "dplyr",
    "lubridate",
    "purrr",
    "readr",
    "readxl",
    "tibble"
  )

  switch(
    mode,
    all = sort(unique(c(render_pkgs, extract_pkgs))),
    render = sort(render_pkgs),
    extract = sort(extract_pkgs),
    stop(
      sprintf(
        "Invalid --mode '%s'. Expected one of: all, render, extract.",
        mode
      ),
      call. = FALSE
    )
  )
}

#' @title Parse Optional `--mode=` CLI Argument
#' @description Extracts the `--mode` flag from `commandArgs(trailingOnly=TRUE)`
#'   or defaults to `"all"`.
#' @param args Character vector of CLI arguments.
#' @return Character scalar mode name.
#' @examples
#' parse_mode_arg(c("--mode=render"))
parse_mode_arg <- function(args) {
  if (length(args) == 0L) {
    return("all")
  }
  mode_args <- args[startsWith(args, "--mode=")]
  if (length(mode_args) != 1L) {
    stop(
      "Usage: Rscript scripts/check_packages.R [--mode=all|render|extract]",
      call. = FALSE
    )
  }
  sub("^--mode=", "", mode_args[[1L]])
}

#' @title Verify Required GNU R Packages Are Installed
#' @description Checks each required package via `requireNamespace()`, prints
#'   installed versions, and aborts with an actionable `install.packages()`
#'   command if any package is missing.
#' @param mode Character scalar pipeline mode (`"all"`, `"render"`, or
#'   `"extract"`).
#' @return Invisibly returns a named logical vector of package availability.
#' @examples
#' \dontrun{
#' verify_packages("all")
#' }
verify_packages <- function(mode = "all") {
  pkgs <- required_packages(mode)
  available <- vapply(pkgs, requireNamespace, logical(1L), quietly = TRUE)

  installed_pkgs <- pkgs[available]
  if (length(installed_pkgs) > 0L) {
    versions <- vapply(
      installed_pkgs,
      function(p) as.character(utils::packageVersion(p)),
      character(1L)
    )
    cat(sprintf("Verified GNU R packages (mode: %s):\n", mode))
    mapply(
      function(p, v) cat(sprintf("  [OK] %-12s %s\n", p, v)),
      installed_pkgs,
      versions
    )
  }

  missing_pkgs <- pkgs[!available]
  if (length(missing_pkgs) > 0L) {
    install_cmd <- sprintf(
      "install.packages(c(%s))",
      paste(sprintf('"%s"', missing_pkgs), collapse = ", ")
    )
    msg_fmt <- paste0(
      "Missing required GNU R package(s): %s\n",
      "Install with:\n  Rscript -e '%s'"
    )
    stop(
      sprintf(msg_fmt, paste(missing_pkgs, collapse = ", "), install_cmd),
      call. = FALSE
    )
  }

  invisible(available)
}

if (sys.nframe() == 0L) {
  mode <- parse_mode_arg(commandArgs(trailingOnly = TRUE))
  verify_packages(mode)
}
