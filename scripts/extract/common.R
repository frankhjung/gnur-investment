# Shared Stage 1 Extraction Helpers and REQ-008 Verification Primitives
#
# Provides readxl worksheet reading, CSV reading/writing, dynamic column lookup,
# date parsing, generic RBA CSV extraction, and REQ-008 assertion helpers.

#' @title Assert Condition or Halt with Informative Error
#' @description Validates a single scalar logical predicate and aborts via
#'   `stop()` with a clear contextual error message if false.
#' @param condition Logical scalar expression expected to be `TRUE`.
#' @param message Character scalar error message emitted on failure.
#' @return Invisibly returns `TRUE` when assertion passes.
#' @examples
#' assert_true(2L + 2L == 4L, "Basic arithmetic check")
assert_true <- function(condition, message) {
  if (!isTRUE(condition)) {
    stop(message, call. = FALSE)
  }
  invisible(TRUE)
}

#' @title Read Worksheet Into Dense Character Matrix via readxl
#' @description Loads a worksheet from an `.xlsx` workbook as an unnamed
#'   character matrix with zero header assumptions for dynamic column lookup.
#' @param xlsx_path Character scalar path to `.xlsx` workbook.
#' @param sheet_name Character scalar worksheet tab name.
#' @return Character matrix representing all populated cells (`NA` when empty).
#' @examples
#' \dontrun{
#' read_xlsx_sheet(
#'   "data/raw/CMO-Historical-Data-Monthly.xlsx",
#'   "Monthly Prices"
#' )
#' }
read_xlsx_sheet <- function(xlsx_path, sheet_name) {
  assert_true(
    file.exists(xlsx_path),
    sprintf("Missing XLSX input file: %s", xlsx_path)
  )
  df <- readxl::read_excel(
    path = xlsx_path,
    sheet = sheet_name,
    col_names = FALSE,
    col_types = "text",
    .name_repair = "minimal",
    progress = FALSE
  )
  unname(as.matrix(df))
}

#' @title Read Statistical CSV Published by the RBA
#' @description Reads an RBA statistical CSV skipping 10 metadata rows so row 11
#'   (`Series ID`) becomes column headers while handling UTF-8 BOM safely. Uses
#'   `utils::read.csv(..., fill = TRUE)` rather than `readr::read_csv()`
#'   because ragged short RBA rows trigger `vroom` parsing-issue warnings.
#' @param csv_path Character scalar path to an RBA CSV file.
#' @return Data frame with character columns named by RBA `Series ID`.
#' @examples
#' \dontrun{
#' read_rba_csv("data/raw/f4-data.csv")
#' }
read_rba_csv <- function(csv_path) {
  assert_true(
    file.exists(csv_path),
    sprintf("Missing CSV input file: %s", csv_path)
  )
  utils::read.csv(
    csv_path,
    skip = 10L,
    header = TRUE,
    check.names = FALSE,
    stringsAsFactors = FALSE,
    colClasses = "character",
    fill = TRUE,
    fileEncoding = "UTF-8-BOM"
  )
}

#' @title Locate Unique Column Index by Header Name
#' @description Finds the exact single index matching `target_name` after
#'   trimming whitespace and halts via `stop()` on zero or duplicate hits.
#' @param header_names Character vector of column headers or `Series ID` codes.
#' @param target_name Character scalar header string to locate dynamically.
#' @param source_label Character scalar source name for diagnostics.
#' @return Integer scalar index matching `target_name`.
#' @examples
#' find_col_index(c("Series ID", "FXRUSD", "FXRTWI"), "FXRUSD", "f11-data.csv")
find_col_index <- function(header_names, target_name, source_label) {
  hits <- which(trimws(header_names) == target_name)
  assert_true(
    length(hits) == 1L,
    sprintf(
      "Expected unique column '%s' in %s (found %d)",
      target_name,
      source_label,
      length(hits)
    )
  )
  hits[[1L]]
}

#' @title Parse Locale-Independent RBA Date String to Month-Start Date
#' @description Parses character dates using `readr::parse_date()` with an
#'   explicit English locale and normalises them to month-start `"YYYY-MM-01"`.
#' @param x Character vector of date strings.
#' @param format Character scalar `strptime` date pattern (e.g. `"%d-%b-%Y"`).
#' @return `Date` vector normalised to the first day of each month.
#' @examples
#' parse_rba_date(c("29-Jan-2010", "31-Oct-2026"), "%d-%b-%Y")
parse_rba_date <- function(x, format) {
  parsed <- readr::parse_date(
    trimws(x),
    format = format,
    locale = readr::locale("en")
  )
  assert_true(
    !anyNA(parsed),
    sprintf("Invalid '%s' date format encountered", format)
  )
  lubridate::floor_date(parsed, "month")
}

#' @title Parse Excel 1900-Epoch Serial Numbers Into Dates
#' @description Converts numeric or string Excel serial days (1899-12-30 epoch)
#'   into base R `Date` values.
#' @param x Numeric or character vector of Excel serial dates.
#' @return `Date` vector.
#' @examples
#' parse_excel_serial_date(c("38900", "46204"))
parse_excel_serial_date <- function(x) {
  as.Date(as.integer(round(as.numeric(x))), origin = "1899-12-30")
}

#' @title Extract One or More Series from an RBA Statistical CSV
#' @description Reads an RBA statistical CSV, locates `Series ID` columns
#'   dynamically, drops blank or short rows, parses dates to month-start,
#'   filters by date window, and sorts ascending.
#' @param csv_path Character scalar path to an RBA CSV file.
#' @param series_map Named character vector mapping output columns to RBA IDs.
#' @param date_format Character scalar `strptime` format of column 1 dates.
#' @param min_date `Date` scalar inclusive minimum observation date.
#' @param max_date Optional `Date` scalar inclusive maximum observation date.
#' @param digits Integer scalar decimal rounding precision.
#' @return Sorted `tibble` with `date` (`Date`) and extracted numeric columns.
#' @examples
#' \dontrun{
#' extract_rba_csv_series(
#'   "data/raw/f1.1-data.csv",
#'   c(cash_rate_pct = "FIRMMCRT"),
#'   "%d/%m/%Y",
#'   as.Date("2006-01-01")
#' )
#' }
extract_rba_csv_series <- function(
  csv_path,
  series_map,
  date_format,
  min_date,
  max_date = NULL,
  digits = 4L
) {
  assert_true(
    length(series_map) >= 1L && !is.null(names(series_map)),
    "series_map must be a non-empty named character vector"
  )
  df <- read_rba_csv(csv_path)
  col_indices <- purrr::map_int(
    series_map,
    find_col_index,
    header_names = names(df),
    source_label = basename(csv_path)
  )

  raw_dt <- trimws(df[[1L]])
  raw_cols <- purrr::map(col_indices, function(idx) trimws(df[[idx]]))
  keep <- Reduce(
    function(a, b) a & b,
    c(list(nzchar(raw_dt)), purrr::map(raw_cols, nzchar))
  )

  dates <- parse_rba_date(raw_dt[keep], format = date_format)
  num_cols <- purrr::map(
    raw_cols,
    function(col) round(as.numeric(col[keep]), digits)
  ) |>
    stats::setNames(names(series_map))

  out <- tibble::as_tibble(c(list(date = dates), num_cols))
  date_mask <- out$date >= min_date
  if (!is.null(max_date)) {
    date_mask <- date_mask & out$date <= max_date
  }
  out <- out[date_mask, , drop = FALSE]
  out[order(out$date), , drop = FALSE]
}

#' @title Write Prepared UTF-8 CSV Overwriting Any Existing Extract
#' @description Formats `Date` columns explicitly as `"%Y-%m-%d"` and writes an
#'   unquoted, headered CSV using UTF-8 LF conventions. Uses
#'   `utils::write.table()` rather than `readr::write_csv()` to preserve exact
#'   base-R decimal representation without IEEE-754 trailing digits.
#' @param df Data frame to serialise.
#' @param path Character scalar target CSV file path.
#' @return Invisibly returns `path`.
#' @examples
#' \dontrun{
#' write_prepared_csv(
#'   tibble::tibble(date = as.Date("2026-07-01"), v = 1),
#'   "out.csv"
#' )
#' }
write_prepared_csv <- function(df, path) {
  formatted <- lapply(df, function(col) {
    if (inherits(col, "Date")) format(col, "%Y-%m-%d") else col
  }) |>
    as.data.frame(stringsAsFactors = FALSE)
  utils::write.table(
    formatted,
    file = path,
    sep = ",",
    row.names = FALSE,
    col.names = TRUE,
    quote = FALSE,
    eol = "\n",
    fileEncoding = "UTF-8"
  )
  invisible(path)
}

#' @title Read Prepared UTF-8 CSV for Stage 1 Verification
#' @description Loads a prepared CSV from `data_dir` without type coercion of
#'   date strings so `assert_strict_dates()` can validate ISO syntax strictly.
#' @param data_dir Character scalar path to `data/`.
#' @param filename Character scalar CSV filename inside `data_dir`.
#' @return Data frame read from the prepared CSV.
#' @examples
#' \dontrun{
#' read_prepared_csv("data", "gold-prices.csv")
#' }
read_prepared_csv <- function(data_dir, filename) {
  path <- file.path(data_dir, filename)
  assert_true(
    file.exists(path),
    sprintf("Missing prepared CSV: %s", path)
  )
  utils::read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)
}

#' @title Verify Non-Null Data Frame and Strictly Ascending Unique Date Keys
#' @description Checks zero `NA` values across every column and enforces unique,
#'   strictly ascending ISO `Date` ordering on `date_col`.
#' @param df Data frame read from a prepared CSV.
#' @param date_col Character scalar date column name.
#' @param file_label Character scalar file name for error messages.
#' @return Parsed `Date` vector from `date_col`.
#' @examples
#' \dontrun{
#' assert_strict_dates(df, "date", "gold-prices.csv")
#' }
assert_strict_dates <- function(df, date_col, file_label) {
  has_na <- vapply(df, anyNA, logical(1L))
  assert_true(
    !any(has_na),
    sprintf("NA values detected in %s", file_label)
  )
  dates <- as.Date(df[[date_col]], format = "%Y-%m-%d")
  assert_true(!anyNA(dates), sprintf("Invalid dates in %s", file_label))
  assert_true(
    !anyDuplicated(dates),
    sprintf("Duplicate date keys in %s", file_label)
  )
  assert_true(
    all(diff(dates) > 0),
    sprintf("Non-ascending dates in %s", file_label)
  )
  dates
}

#' @title Assert Exact Numeric Spot Value at Key Date
#' @description Confirms a single row matches `target_date` and reconciles
#'   within numeric tolerance `1e-6`.
#' @param df Data frame read from prepared CSV.
#' @param date_col Character scalar date column name.
#' @param target_date Character scalar ISO `"YYYY-MM-DD"`.
#' @param value_col Character scalar numeric column name.
#' @param expected Numeric scalar expected value.
#' @param label Character scalar file name for error messages.
#' @return Invisibly returns `TRUE`.
#' @examples
#' \dontrun{
#' assert_spot_value(df, "date", "2006-07-01", "gold_usd", 634.0, "gold")
#' }
assert_spot_value <- function(
  df,
  date_col,
  target_date,
  value_col,
  expected,
  label
) {
  hits <- which(df[[date_col]] == target_date)
  assert_true(
    length(hits) == 1L,
    sprintf("Expected single row for %s in %s", target_date, label)
  )
  actual <- as.numeric(df[[value_col]][[hits]])
  assert_true(
    abs(actual - expected) <= 1e-6,
    sprintf(
      "Spot check failed in %s (%s %s): expected %.6f, got %.6f",
      label,
      target_date,
      value_col,
      expected,
      actual
    )
  )
  invisible(TRUE)
}

#' @title Execute Declarative Table of REQ-008 Spot Checks
#' @description Iterates over a tibble of expected `(date, col, expected)` rows
#'   (with optional `check_label`) and validates each via `assert_spot_value()`.
#' @param df Data frame read from prepared CSV.
#' @param checks `tibble` with columns `date`, `col`, `expected`, and optional
#'   `check_label`.
#' @param label Character scalar fallback label for error messages.
#' @param date_col Character scalar date column name (default `"date"`).
#' @return Invisibly returns `TRUE`.
#' @examples
#' \dontrun{
#' assert_spot_checks(df, checks_tbl, "gold")
#' }
assert_spot_checks <- function(df, checks, label, date_col = "date") {
  has_check_label <- "check_label" %in% names(checks)
  purrr::pwalk(
    checks,
    function(date, col, expected, check_label = label) {
      lbl <- if (has_check_label) check_label else label
      assert_spot_value(df, date_col, date, col, expected, lbl)
    }
  )
  invisible(TRUE)
}
