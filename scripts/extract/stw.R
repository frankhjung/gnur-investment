# Australian Equities (ASX:STW) Price and Distribution Extractors & Checks
#
# Data Provenance (REQ-006; retrieved 2026-11-19):
# - stw-monthly-2006-2026.xlsx: Investing.com AU ASX:STW Monthly Close
#   (https://au.investing.com/etfs/spdr-s-p-asx-200-historical-data)
# - stw-dividends.csv: InvestSMART / SSGA ASX:STW Distribution Schedule
#   (see data/raw/file-sources.md for full canonical URLs & SHA-256)

#' @title Extract `ASX:STW` Monthly Closing Prices
#' @description Reads `stw-monthly-2006-2026.xlsx`, retains only `Date` and
#'   `Price`, formats dates to `YYYY-MM-01`, and sorts ascending (`2006-07` to
#'   `2026-07`).
#' @param raw_dir Character scalar path to `data/raw/`.
#' @param io Named list of shared extraction helpers from `common.R`.
#' @return Sorted `tibble` with columns `date` (`Date`) and `stw_price_aud`.
#' @examples
#' \dontrun{
#' extract_stw_prices("data/raw", io)
#' }
extract_stw_prices <- function(raw_dir, io) {
  wb_path <- file.path(raw_dir, "stw-monthly-2006-2026.xlsx")
  mat <- io$read_xlsx_sheet(wb_path, "STW Historical Data.csv")
  date_col <- io$find_col_index(
    mat[1L, ],
    "Date",
    "stw-monthly-2006-2026.xlsx"
  )
  price_col <- io$find_col_index(
    mat[1L, ],
    "Price",
    "stw-monthly-2006-2026.xlsx"
  )

  keep <- seq_len(nrow(mat)) >= 2L &
    !is.na(mat[, date_col]) &
    !is.na(mat[, price_col])
  dates <- mat[keep, date_col] |>
    io$parse_excel_serial_date() |>
    lubridate::floor_date("month")
  prices <- round(as.numeric(mat[keep, price_col]), 4L)

  out <- tibble::tibble(date = dates, stw_price_aud = prices)
  out[order(out$date), , drop = FALSE]
}

#' @title Verify `stw-prices.csv` Against REQ-008 Invariants
#' @description Validates non-null unique ascending dates, exact 241-month
#'   coverage (`2006-07-01` to `2026-07-01`), and key STW closing prices.
#' @param data_dir Character scalar path to `data/`.
#' @param io Named list of shared extraction helpers from `common.R`.
#' @return Integer scalar verified row count.
#' @examples
#' \dontrun{
#' verify_stw_prices("data", io)
#' }
verify_stw_prices <- function(data_dir, io) {
  stw_p <- io$read_prepared_csv(data_dir, "stw-prices.csv")
  sp_dt <- io$assert_strict_dates(stw_p, "date", "stw-prices.csv")
  io$assert_true(
    nrow(stw_p) == 241L &&
      min(sp_dt) == as.Date("2006-07-01") &&
      max(sp_dt) == as.Date("2026-07-01"),
    "stw-prices.csv failed 241-row coverage check"
  )

  checks <- tibble::tribble(
    ~date,        ~col,            ~expected,
    "2006-07-01", "stw_price_aud", 49.19,
    "2026-02-01", "stw_price_aud", 82.63,
    "2026-07-01", "stw_price_aud", 80.22
  )
  io$assert_spot_checks(stw_p, checks, "stw")
  nrow(stw_p)
}

#' @title Extract Normalised `ASX:STW` Cash Distributions and Franking
#' @description Parses raw `stw-dividends.csv` via `readr::read_csv()`, converts
#'   `%` franking strings into `[0, 1]` proportions, drops
#'   `Trailing_Yield_Pct`, and sorts ascending by `ex_dividend_date`.
#' @param raw_dir Character scalar path to `data/raw/`.
#' @param io Named list of shared extraction helpers from `common.R`.
#' @return Sorted `tibble` with typed distribution columns.
#' @examples
#' \dontrun{
#' extract_stw_distributions("data/raw", io)
#' }
extract_stw_distributions <- function(raw_dir, io) {
  csv_path <- file.path(raw_dir, "stw-dividends.csv")
  io$assert_true(
    file.exists(csv_path),
    sprintf("Missing CSV input file: %s", csv_path)
  )
  df <- readr::read_csv(
    csv_path,
    col_types = readr::cols(.default = readr::col_character()),
    trim_ws = TRUE,
    na = character(),
    show_col_types = FALSE,
    progress = FALSE
  )
  keep <- nzchar(df$Ex_Dividend_Date) & nzchar(df$Payment_Date)
  df <- df[keep, , drop = FALSE]

  out <- tibble::tibble(
    ex_dividend_date = readr::parse_date(
      df$Ex_Dividend_Date,
      format = "%Y-%m-%d"
    ),
    payment_date = readr::parse_date(df$Payment_Date, format = "%Y-%m-%d"),
    cash_distribution_aud = round(as.numeric(df$Cash_Distribution_AUD), 4L),
    franking_pct = round(readr::parse_number(df$Franking_Pct) / 100, 6L),
    gross_distribution_aud = round(as.numeric(df$Gross_Distribution_AUD), 4L)
  )
  out[order(out$ex_dividend_date), , drop = FALSE]
}

#' @title Verify `stw-distributions.csv` Against REQ-008 Invariants
#' @description Validates non-null unique ascending `ex_dividend_date` keys,
#'   62 total / 60 in-window distributions, franking bounds and gross-up formula
#'   tolerance, and exact `2026-06-29` payout values.
#' @param data_dir Character scalar path to `data/`.
#' @param io Named list of shared extraction helpers from `common.R`.
#' @return Integer scalar verified row count.
#' @examples
#' \dontrun{
#' verify_stw_distributions("data", io)
#' }
verify_stw_distributions <- function(data_dir, io) {
  stw_d <- io$read_prepared_csv(data_dir, "stw-distributions.csv")
  sd_dt <- io$assert_strict_dates(
    stw_d,
    "ex_dividend_date",
    "stw-distributions.csv"
  )

  in_win <- sd_dt >= as.Date("2006-07-01") & sd_dt <= as.Date("2026-07-31")
  io$assert_true(
    nrow(stw_d) == 62L && sum(in_win) == 60L,
    "stw-distributions.csv failed 62 total / 60 in-window row check"
  )
  io$assert_true(
    all(stw_d$franking_pct >= 0 & stw_d$franking_pct <= 1),
    "franking_pct out of [0, 1] bounds"
  )
  expected_gross <- stw_d$cash_distribution_aud *
    (1 + stw_d$franking_pct * 30 / 70)
  io$assert_true(
    all(abs(stw_d$gross_distribution_aud - expected_gross) <= 0.002),
    "stw-distributions.csv franking gross-up exceeded 0.002 tolerance"
  )

  checks <- tibble::tribble(
    ~date,        ~col,                     ~expected, ~check_label,
    "2026-06-29", "cash_distribution_aud",  0.7963,    "stw-div-cash",
    "2026-06-29", "franking_pct",           0.3539,    "stw-div-frank",
    "2026-06-29", "gross_distribution_aud", 0.9171,    "stw-div-gross"
  )
  io$assert_spot_checks(stw_d, checks, "stw-div", date_col = "ex_dividend_date")
  nrow(stw_d)
}
