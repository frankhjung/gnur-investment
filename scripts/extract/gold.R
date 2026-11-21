# World Bank Pink Sheet Monthly Gold Extractor and REQ-008 Checks
#
# Data Provenance (REQ-006; retrieved 2026-11-20):
# - CMO-Historical-Data-Monthly.xlsx: World Bank Pink Sheet ("Monthly Prices",
#   Gold, USD/troy oz; https://www.worldbank.org/en/research/commodity-markets)

#' @title Extract World Bank Monthly Gold Spot Prices (`USD/troy oz`)
#' @description Reads `CMO-Historical-Data-Monthly.xlsx` sheet `Monthly Prices`,
#'   locates `Gold` dynamically on row 5, parses `YYYYMmm` period codes from
#'   row 7 onward, and filters to `>= 2006-01-01`.
#' @param raw_dir Character scalar path to `data/raw/`.
#' @param io Named list of shared extraction helpers from `common.R`.
#' @return Sorted `tibble` with columns `date` (`Date`) and `gold_usd`.
#' @examples
#' \dontrun{
#' extract_gold_prices("data/raw", io)
#' }
extract_gold_prices <- function(raw_dir, io) {
  wb_path <- file.path(raw_dir, "CMO-Historical-Data-Monthly.xlsx")
  mat <- io$read_xlsx_sheet(wb_path, "Monthly Prices")
  gold_col <- io$find_col_index(
    mat[5L, ],
    "Gold",
    "CMO-Historical-Data-Monthly.xlsx"
  )

  row_mask <- seq_len(nrow(mat)) >= 7L
  codes <- trimws(mat[row_mask, 1L])
  vals <- mat[row_mask, gold_col]
  is_period <- !is.na(codes) & grepl("^[0-9]{4}M[0-9]{2}$", codes)

  dates <- readr::parse_date(
    paste0(sub("M", "-", codes[is_period], fixed = TRUE), "-01"),
    format = "%Y-%m-%d"
  )
  prices <- round(as.numeric(vals[is_period]), 4L)

  out <- tibble::tibble(date = dates, gold_usd = prices)
  out <- out[!is.na(out$date) & out$date >= as.Date("2006-01-01"), ]
  out[order(out$date), , drop = FALSE]
}

#' @title Verify `gold-prices.csv` Against REQ-008 Invariants
#' @description Validates non-null unique ascending dates, `>= 250` monthly rows
#'   from `2006-01-01`, and exact World Bank Pink Sheet spot values.
#' @param data_dir Character scalar path to `data/`.
#' @param io Named list of shared extraction helpers from `common.R`.
#' @return Integer scalar verified row count.
#' @examples
#' \dontrun{
#' verify_gold_prices("data", io)
#' }
verify_gold_prices <- function(data_dir, io) {
  gold <- io$read_prepared_csv(data_dir, "gold-prices.csv")
  g_dt <- io$assert_strict_dates(gold, "date", "gold-prices.csv")
  io$assert_true(
    nrow(gold) >= 250L && min(g_dt) == as.Date("2006-01-01"),
    "gold-prices.csv failed >= 250 row check"
  )

  checks <- tibble::tribble(
    ~date,        ~col,       ~expected,
    "2006-07-01", "gold_usd", 634.00,
    "2026-02-01", "gold_usd", 5020.00,
    "2026-07-01", "gold_usd", 4073.00
  )
  io$assert_spot_checks(gold, checks, "gold")
  nrow(gold)
}
