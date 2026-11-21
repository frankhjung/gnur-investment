#!/usr/bin/env Rscript

# Stage 1 Data Preparation: Coordinate Extraction & Verification Modules
#
# Usage:
#   Rscript scripts/convert_xlsx.R
#
# Reads permanent read-only inputs in data/raw/ and writes (overwriting
# prior extracts) clean UTF-8 prepared CSVs into data/, then verifies all
# REQ-008 invariants before exiting. Never modifies data/raw/.
#
# Source modules live under scripts/extract/:
# - common.R: readxl workbook reader, RBA CSV parser, date utilities & checks
# - gold.R:   World Bank CMO monthly gold extractor & REQ-008 checks
# - rba.R:    RBA FX, deposit rates, CPI, and cash rate extractors/checks
# - stw.R:    ASX:STW monthly price and distribution extractors/checks
#
# Data Provenance (REQ-006; see data/raw/file-sources.md for URLs & SHA-256).

#' @title Source Extraction Module into Isolated Environment
#' @description Validates `path` exists and loads it via `sys.source()` into a
#'   dedicated environment without polluting `.GlobalEnv`.
#' @param path Character scalar path to an extraction R module.
#' @return Environment populated with the module's functions.
#' @examples
#' \dontrun{
#' mod <- load_module("scripts/extract/common.R")
#' }
load_module <- function(path) {
  if (!file.exists(path)) {
    stop(sprintf("Missing extraction module: %s", path), call. = FALSE)
  }
  env <- new.env(parent = globalenv())
  sys.source(path, envir = env)
  env
}

#' @title Load All Stage 1 Extraction and Verification Modules
#' @description Sources `common.R`, `gold.R`, `rba.R`, and `stw.R` into isolated
#'   environments and exposes `io` helpers for explicit dependency injection.
#' @param extract_dir Character scalar directory containing Stage 1 modules.
#' @return Named list with `io`, `gold`, `rba`, and `stw` module contexts.
#' @examples
#' \dontrun{
#' mods <- load_extract_modules()
#' }
load_extract_modules <- function(
  extract_dir = file.path("scripts", "extract")
) {
  common <- load_module(file.path(extract_dir, "common.R"))
  list(
    io = as.list(common),
    gold = load_module(file.path(extract_dir, "gold.R")),
    rba = load_module(file.path(extract_dir, "rba.R")),
    stw = load_module(file.path(extract_dir, "stw.R"))
  )
}

#' @title Build Declarative Stage 1 Extraction and Verification Pipeline
#' @description Maps each prepared CSV output filename to its dataset-specific
#'   `extract(raw_dir, io)` and `verify(data_dir, io)` functions.
#' @param mods Named list returned by `load_extract_modules()`.
#' @return Named list keyed by prepared CSV filename.
#' @examples
#' \dontrun{
#' pipeline <- build_extract_pipeline(load_extract_modules())
#' }
build_extract_pipeline <- function(mods) {
  list(
    `gold-prices.csv` = list(
      extract = mods$gold$extract_gold_prices,
      verify = mods$gold$verify_gold_prices
    ),
    `rba-aud-usd.csv` = list(
      extract = mods$rba$extract_rba_aud_usd,
      verify = mods$rba$verify_rba_aud_usd
    ),
    `stw-prices.csv` = list(
      extract = mods$stw$extract_stw_prices,
      verify = mods$stw$verify_stw_prices
    ),
    `stw-distributions.csv` = list(
      extract = mods$stw$extract_stw_distributions,
      verify = mods$stw$verify_stw_distributions
    ),
    `rba-deposit-rates.csv` = list(
      extract = mods$rba$extract_rba_deposit_rates,
      verify = mods$rba$verify_rba_deposit_rates
    ),
    `abs-cpi.csv` = list(
      extract = mods$rba$extract_abs_cpi,
      verify = mods$rba$verify_abs_cpi
    ),
    `rba-cash-rate.csv` = list(
      extract = mods$rba$extract_rba_cash_rate,
      verify = mods$rba$verify_rba_cash_rate
    )
  )
}

#' @title Resolve Project `data/` Directory Path
#' @description Locates `data/` containing `data/raw/` from the repository root.
#' @return Character scalar path to `data`.
#' @examples
#' \dontrun{
#' resolve_data_dir()
#' }
resolve_data_dir <- function() {
  if (!dir.exists(file.path("data", "raw"))) {
    stop(
      "Cannot locate data/raw/ from current working directory",
      call. = FALSE
    )
  }
  "data"
}

#' @title Run Stage 1 Extraction and REQ-008 Verification
#' @description Coordinates all source-family modules to extract the eight
#'   active datasets in `data/raw/`, overwrite seven prepared CSVs in `data/`,
#'   and run all REQ-008 invariants.
#' @param data_dir Character scalar path to `data/`.
#' @param extract_dir Character scalar directory containing Stage 1 modules.
#' @return Invisibly returns named integer vector of verified row counts.
#' @examples
#' \dontrun{
#' main()
#' }
main <- function(
  data_dir = resolve_data_dir(),
  extract_dir = file.path("scripts", "extract")
) {
  mods <- load_extract_modules(extract_dir)
  pipeline <- build_extract_pipeline(mods)
  raw_dir <- file.path(data_dir, "raw")

  purrr::iwalk(pipeline, function(step, csv_name) {
    df <- step$extract(raw_dir, mods$io)
    mods$io$write_prepared_csv(df, file.path(data_dir, csv_name))
  })

  counts <- purrr::imap_int(pipeline, function(step, csv_name) {
    step$verify(data_dir, mods$io)
  })

  message("Stage 1 complete. REQ-008 verification passed:")
  purrr::iwalk(counts, function(cnt, nm) {
    message(sprintf("  %-24s %d rows", nm, cnt))
  })
  invisible(counts)
}

if (sys.nframe() == 0L) {
  main()
}
