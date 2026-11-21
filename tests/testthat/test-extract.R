# Unit and Integration Tests for Stage 1 Extraction Pipeline

source(file.path("scripts", "convert_xlsx.R"))

test_that("read_xlsx_sheet loads Excel workbooks as character matrices", {
  mods <- load_extract_modules()
  expect_error(
    mods$io$read_xlsx_sheet("data/raw/missing.xlsx", "Sheet1"),
    "Missing XLSX input file"
  )
  if (requireNamespace("readxl", quietly = TRUE)) {
    mat <- mods$io$read_xlsx_sheet(
      file.path("data", "raw", "stw-monthly-2006-2026.xlsx"),
      "STW Historical Data.csv"
    )
    expect_true(is.matrix(mat))
    expect_equal(dim(mat), c(242L, 7L))
    expect_equal(mat[1L, 1L:2L], c("Date", "Price"))
  }
})

test_that("find_col_index trims headers and errors on missing or duplicates", {
  mods <- load_extract_modules()
  headers <- c("Series ID", " FXRUSD ", "FXRTWI", "DUP", "DUP")
  expect_equal(mods$io$find_col_index(headers, "FXRUSD", "test.csv"), 2L)
  expect_error(
    mods$io$find_col_index(headers, "MISSING", "test.csv"),
    "Expected unique column"
  )
  expect_error(
    mods$io$find_col_index(headers, "DUP", "test.csv"),
    "found 2"
  )
})

test_that("date helpers parse RBA and Excel serial dates to month-start", {
  mods <- load_extract_modules()
  dmy_mon <- mods$io$parse_rba_date(
    c(" 29-Jan-2010 ", "31-Oct-2026"),
    "%d-%b-%Y"
  )
  expect_equal(dmy_mon, as.Date(c("2010-01-01", "2026-10-01")))

  dmy_slash <- mods$io$parse_rba_date(c("30/06/2006", "30/06/2026"), "%d/%m/%Y")
  expect_equal(dmy_slash, as.Date(c("2006-06-01", "2026-06-01")))

  expect_error(
    suppressWarnings(mods$io$parse_rba_date("99-Foo-2020", "%d-%b-%Y")),
    "Invalid"
  )
  expect_equal(
    mods$io$parse_excel_serial_date(c("38900", "46204")),
    as.Date(c("2006-07-02", "2026-07-01"))
  )
})

test_that("extract_rba_csv_series handles BOM, ragged rows, and sorting", {
  mods <- load_extract_modules()
  tmp_csv <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp_csv), add = TRUE)

  lines <- c(
    "\ufeffF11 TEST",
    rep("Metadata,Row", 9L),
    "Series ID,UNUSED,TARGET_A,TARGET_B",
    "31-Dec-2005,0,3.5,4.5",
    "31-Mar-2010,1,5.25,6.10",
    "29-Jan-2010,2,4.75,5.80",
    "30-Apr-2010,3,,6.20",
    "short_ragged_row",
    ""
  )
  writeLines(lines, tmp_csv, useBytes = TRUE)

  res <- mods$io$extract_rba_csv_series(
    tmp_csv,
    c(series_a = "TARGET_A", series_b = "TARGET_B"),
    date_format = "%d-%b-%Y",
    min_date = as.Date("2006-01-01"),
    digits = 4L
  )
  expect_equal(nrow(res), 2L)
  expect_equal(res$date, as.Date(c("2010-01-01", "2010-03-01")))
  expect_equal(res$series_a, c(4.75, 5.25))
  expect_equal(res$series_b, c(5.80, 6.10))
})

test_that("assert_strict_dates and assert_spot_checks enforce invariants", {
  mods <- load_extract_modules()
  ok_df <- data.frame(
    date = c("2006-07-01", "2006-08-01"),
    val = c(10.0, 12.5),
    stringsAsFactors = FALSE
  )
  expect_equal(
    mods$io$assert_strict_dates(ok_df, "date", "ok.csv"),
    as.Date(c("2006-07-01", "2006-08-01"))
  )

  dup_df <- ok_df[c(1L, 1L), ]
  expect_error(
    mods$io$assert_strict_dates(dup_df, "date", "dup.csv"),
    "Duplicate"
  )
  desc_df <- ok_df[c(2L, 1L), ]
  expect_error(
    mods$io$assert_strict_dates(desc_df, "date", "desc.csv"),
    "Non-ascending"
  )
  na_df <- data.frame(
    date = c("2006-07-01", NA),
    val = c(1, 2),
    stringsAsFactors = FALSE
  )
  expect_error(
    mods$io$assert_strict_dates(na_df, "date", "na.csv"),
    "NA values"
  )

  checks_ok <- tibble::tribble(
    ~date,        ~col,  ~expected,
    "2006-07-01", "val", 10.0
  )
  expect_true(mods$io$assert_spot_checks(ok_df, checks_ok, "ok"))

  checks_bad <- tibble::tribble(
    ~date,        ~col,  ~expected,
    "2006-07-01", "val", 99.0
  )
  expect_error(
    mods$io$assert_spot_checks(ok_df, checks_bad, "bad"),
    "Spot check failed"
  )
})

test_that("REQ-008 verifiers validate all seven committed prepared CSVs", {
  mods <- load_extract_modules()
  pipeline <- build_extract_pipeline(mods)
  counts <- purrr::imap_int(pipeline, function(step, csv_name) {
    step$verify("data", mods$io)
  })
  expect_true(counts[["gold-prices.csv"]] >= 250L)
  expect_true(counts[["rba-aud-usd.csv"]] >= 250L)
  expect_equal(counts[["stw-prices.csv"]], 241L)
  expect_equal(counts[["stw-distributions.csv"]], 62L)
  expect_true(counts[["rba-deposit-rates.csv"]] >= 250L)
  expect_equal(counts[["abs-cpi.csv"]], 81L)
  expect_true(counts[["rba-cash-rate.csv"]] >= 250L)
})
