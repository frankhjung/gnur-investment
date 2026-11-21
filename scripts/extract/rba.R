# Reserve Bank of Australia (RBA) and ABS Extractors and REQ-008 Checks
#
# Data Provenance (REQ-006; retrieved 2026-11-19 / 2026-11-20):
# - rba-exchange-rates-1969-2009.xlsx: RBA Table F11 Historical (FXRUSD;
#   https://www.rba.gov.au/statistics/historical-data.html)
# - f11-data.csv: RBA Table F11 Exchange Rates (FXRUSD;
#   https://www.rba.gov.au/statistics/tables/csv/f11-data.csv)
# - f4-data.csv: RBA Table F4 Retail Deposit Rates (FRDIRSAB10K, FRDIRBTD10K1Y;
#   https://www.rba.gov.au/statistics/tables/csv/f4-data.csv)
# - f1.1-data.csv: RBA Table F1.1 Cash Rate Target (FIRMMCRT;
#   https://www.rba.gov.au/statistics/tables/csv/f1.1-data.csv)
# - g1-data.csv: RBA / ABS Table G1 CPI (GCPIAG, Sept 2025 = 100;
#   https://www.rba.gov.au/statistics/tables/csv/g1-data.csv)

#' @title Extract Merged RBA Table F11 `AUD/USD` Exchange Rates (`FXRUSD`)
#' @description Combines `rba-exchange-rates-1969-2009.xlsx` (`2006`–`2009`)
#'   and direct `f11-data.csv` (`2010`–present) locating `FXRUSD` dynamically
#'   on row 11 and normalising dates to month-start ISO `YYYY-MM-01`.
#' @param raw_dir Character scalar path to `data/raw/`.
#' @param io Named list of shared extraction helpers from `common.R`.
#' @return Sorted `tibble` with columns `date` (`Date`) and `aud_usd`.
#' @examples
#' \dontrun{
#' extract_rba_aud_usd("data/raw", io)
#' }
extract_rba_aud_usd <- function(raw_dir, io) {
  hist_path <- file.path(raw_dir, "rba-exchange-rates-1969-2009.xlsx")
  mat <- io$read_xlsx_sheet(hist_path, "Data")
  fx_col_hist <- io$find_col_index(
    mat[11L, ],
    "FXRUSD",
    "rba-exchange-rates-1969-2009.xlsx"
  )
  hist_mask <- seq_len(nrow(mat)) >= 12L &
    !is.na(mat[, 1L]) &
    !is.na(mat[, fx_col_hist])
  hist_dates <- mat[hist_mask, 1L] |>
    io$parse_excel_serial_date() |>
    lubridate::floor_date("month")
  hist_df <- tibble::tibble(
    date = hist_dates,
    aud_usd = round(as.numeric(mat[hist_mask, fx_col_hist]), 6L)
  )
  hist_df <- hist_df[
    hist_df$date >= as.Date("2006-01-01") &
      hist_df$date <= as.Date("2009-12-01"),
  ]

  curr_df <- io$extract_rba_csv_series(
    file.path(raw_dir, "f11-data.csv"),
    c(aud_usd = "FXRUSD"),
    date_format = "%d-%b-%Y",
    min_date = as.Date("2010-01-01"),
    digits = 6L
  )

  out <- dplyr::bind_rows(hist_df, curr_df)
  out[order(out$date), , drop = FALSE]
}

#' @title Verify `rba-aud-usd.csv` Against REQ-008 Invariants
#' @description Validates non-null unique ascending dates, `>= 250` monthly rows
#'   from `2006-01-01`, and exact RBA Table F11 spot values.
#' @param data_dir Character scalar path to `data/`.
#' @param io Named list of shared extraction helpers from `common.R`.
#' @return Integer scalar verified row count.
#' @examples
#' \dontrun{
#' verify_rba_aud_usd("data", io)
#' }
verify_rba_aud_usd <- function(data_dir, io) {
  fx <- io$read_prepared_csv(data_dir, "rba-aud-usd.csv")
  f_dt <- io$assert_strict_dates(fx, "date", "rba-aud-usd.csv")
  io$assert_true(
    nrow(fx) >= 250L && min(f_dt) == as.Date("2006-01-01"),
    "rba-aud-usd.csv failed >= 250 row check"
  )

  checks <- tibble::tribble(
    ~date,        ~col,      ~expected,
    "2006-07-01", "aud_usd", 0.7658,
    "2026-02-01", "aud_usd", 0.7126,
    "2026-07-01", "aud_usd", 0.7030
  )
  io$assert_spot_checks(fx, checks, "fx")
  nrow(fx)
}

#' @title Extract Monthly RBA Table F4 Retail Deposit Rates
#' @description Reads `f4-data.csv`, locates `FRDIRSAB10K` (bonus savings) and
#'   `FRDIRBTD10K1Y` (1-year term deposit) dynamically, normalises `DD-Mon-YYYY`
#'   dates to `YYYY-MM-01`, and filters `>= 2006-01-01`.
#' @param raw_dir Character scalar path to `data/raw/`.
#' @param io Named list of shared extraction helpers from `common.R`.
#' @return Sorted `tibble` with `date`, `bonus_savings_rate_pct`, and
#'   `term_deposit_1y_rate_pct`.
#' @examples
#' \dontrun{
#' extract_rba_deposit_rates("data/raw", io)
#' }
extract_rba_deposit_rates <- function(raw_dir, io) {
  io$extract_rba_csv_series(
    file.path(raw_dir, "f4-data.csv"),
    c(
      bonus_savings_rate_pct = "FRDIRSAB10K",
      term_deposit_1y_rate_pct = "FRDIRBTD10K1Y"
    ),
    date_format = "%d-%b-%Y",
    min_date = as.Date("2006-01-01"),
    digits = 4L
  )
}

#' @title Verify `rba-deposit-rates.csv` Against REQ-008 Invariants
#' @description Validates non-null unique ascending dates, `>= 250` monthly rows
#'   from `2006-01-01`, and all 10 RBA Table F4 deposit-rate spot checks.
#' @param data_dir Character scalar path to `data/`.
#' @param io Named list of shared extraction helpers from `common.R`.
#' @return Integer scalar verified row count.
#' @examples
#' \dontrun{
#' verify_rba_deposit_rates("data", io)
#' }
verify_rba_deposit_rates <- function(data_dir, io) {
  dep <- io$read_prepared_csv(data_dir, "rba-deposit-rates.csv")
  dp_dt <- io$assert_strict_dates(dep, "date", "rba-deposit-rates.csv")
  io$assert_true(
    nrow(dep) >= 250L && min(dp_dt) == as.Date("2006-01-01"),
    "rba-deposit-rates.csv failed >= 250 row check"
  )

  checks <- tibble::tribble(
    ~date,        ~col,                       ~expected, ~check_label,
    "2006-07-01", "bonus_savings_rate_pct",   4.00,      "dep-bs",
    "2008-07-01", "bonus_savings_rate_pct",   5.50,      "dep-bs",
    "2021-07-01", "bonus_savings_rate_pct",   0.35,      "dep-bs",
    "2025-07-01", "bonus_savings_rate_pct",   4.25,      "dep-bs",
    "2026-07-01", "bonus_savings_rate_pct",   4.80,      "dep-bs",
    "2006-07-01", "term_deposit_1y_rate_pct", 5.40,      "dep-td",
    "2008-07-01", "term_deposit_1y_rate_pct", 8.25,      "dep-td",
    "2021-07-01", "term_deposit_1y_rate_pct", 0.25,      "dep-td",
    "2025-07-01", "term_deposit_1y_rate_pct", 3.60,      "dep-td",
    "2026-07-01", "term_deposit_1y_rate_pct", 5.00,      "dep-td"
  )
  io$assert_spot_checks(dep, checks, "dep")
  nrow(dep)
}

#' @title Extract Quarterly ABS / RBA Table G1 Consumer Price Index (`GCPIAG`)
#' @description Reads `g1-data.csv`, locates `GCPIAG` dynamically, drops blank
#'   and empty future placeholder rows, normalises `DD/MM/YYYY` to quarter
#'   month-start, and filters `2006-06-01` through `2026-06-01`.
#' @param raw_dir Character scalar path to `data/raw/`.
#' @param io Named list of shared extraction helpers from `common.R`.
#' @return Sorted `tibble` with columns `date` (`Date`) and `cpi_index`.
#' @examples
#' \dontrun{
#' extract_abs_cpi("data/raw", io)
#' }
extract_abs_cpi <- function(raw_dir, io) {
  io$extract_rba_csv_series(
    file.path(raw_dir, "g1-data.csv"),
    c(cpi_index = "GCPIAG"),
    date_format = "%d/%m/%Y",
    min_date = as.Date("2006-06-01"),
    max_date = as.Date("2026-06-01"),
    digits = 4L
  )
}

#' @title Verify `abs-cpi.csv` Against REQ-008 Invariants
#' @description Validates non-null unique ascending dates, exact 81-quarter
#'   coverage (`2006-06-01` to `2026-06-01`), and baseline/ending index values.
#' @param data_dir Character scalar path to `data/`.
#' @param io Named list of shared extraction helpers from `common.R`.
#' @return Integer scalar verified row count.
#' @examples
#' \dontrun{
#' verify_abs_cpi("data", io)
#' }
verify_abs_cpi <- function(data_dir, io) {
  cpi <- io$read_prepared_csv(data_dir, "abs-cpi.csv")
  cp_dt <- io$assert_strict_dates(cpi, "date", "abs-cpi.csv")
  io$assert_true(
    nrow(cpi) == 81L &&
      min(cp_dt) == as.Date("2006-06-01") &&
      max(cp_dt) == as.Date("2026-06-01"),
    "abs-cpi.csv failed 81-row coverage check"
  )

  checks <- tibble::tribble(
    ~date,        ~col,        ~expected,
    "2006-06-01", "cpi_index", 59.65,
    "2026-06-01", "cpi_index", 102.31
  )
  io$assert_spot_checks(cpi, checks, "abs-cpi")
  nrow(cpi)
}

#' @title Extract Monthly RBA Table F1.1 Cash Rate Target (`FIRMMCRT`)
#' @description Reads `f1.1-data.csv`, locates `FIRMMCRT` dynamically, removes
#'   pre-1990 blank entries and trailing lines, normalises `DD/MM/YYYY` to
#'   `YYYY-MM-01`, and filters `>= 2006-01-01`.
#' @param raw_dir Character scalar path to `data/raw/`.
#' @param io Named list of shared extraction helpers from `common.R`.
#' @return Sorted `tibble` with columns `date` (`Date`) and `cash_rate_pct`.
#' @examples
#' \dontrun{
#' extract_rba_cash_rate("data/raw", io)
#' }
extract_rba_cash_rate <- function(raw_dir, io) {
  io$extract_rba_csv_series(
    file.path(raw_dir, "f1.1-data.csv"),
    c(cash_rate_pct = "FIRMMCRT"),
    date_format = "%d/%m/%Y",
    min_date = as.Date("2006-01-01"),
    digits = 4L
  )
}

#' @title Verify `rba-cash-rate.csv` Against REQ-008 Invariants
#' @description Validates non-null unique ascending dates, `>= 250` monthly rows
#'   from `2006-01-01`, and exact RBA Table F1.1 cash-rate spot values.
#' @param data_dir Character scalar path to `data/`.
#' @param io Named list of shared extraction helpers from `common.R`.
#' @return Integer scalar verified row count.
#' @examples
#' \dontrun{
#' verify_rba_cash_rate("data", io)
#' }
verify_rba_cash_rate <- function(data_dir, io) {
  cash <- io$read_prepared_csv(data_dir, "rba-cash-rate.csv")
  cs_dt <- io$assert_strict_dates(cash, "date", "rba-cash-rate.csv")
  io$assert_true(
    nrow(cash) >= 250L && min(cs_dt) == as.Date("2006-01-01"),
    "rba-cash-rate.csv failed >= 250 row check"
  )

  checks <- tibble::tribble(
    ~date,        ~col,            ~expected,
    "2006-07-01", "cash_rate_pct", 5.75,
    "2008-08-01", "cash_rate_pct", 7.25,
    "2011-08-01", "cash_rate_pct", 4.75,
    "2020-11-01", "cash_rate_pct", 0.11,
    "2026-07-01", "cash_rate_pct", 4.35
  )
  io$assert_spot_checks(cash, checks, "cash")
  nrow(cash)
}
