# Consolidated Review and Update Plan

*Consolidated from Gemini and Claude reviews for Frank Jung's report
"[Twenty Years of AUD 1,000: Gold, Fixed Interest and Australian Equities
(2006–2026)][report]" (dated 21 November 2026). Requirements reviewed and
finalised 23 November 2026.*

## Summary

Both reviews confirm that the core arithmetic, accounting, and pipeline in
`scripts/model.R` are sound: the CAGRs, CPI ratio (`102.31 / 59.65`), MER drags,
whole-unit DRP ledger, and gold tax rows in Table 4 all recompute accurately.

Following the requirements review, the project updates are scoped to preserve
the immutable raw datasets in `data/raw/` and the canonical 241-month (`2006-07`
to `2026-07`) 20-year window while strengthening the analytical model and report
across three areas:

- **New Rolling-Window Model (`scripts/model.R` & `article.Rmd`):** Compute 5-,
  10-, and 15-year rolling-window CAGRs and win rates across all overlapping
  start months in the 241-month dataset to quantify endpoint sensitivity.
- **Methodological Disclosures & Framing (`article.Rmd` & `requirements.md`):**
  Quantify the monthly-average variance smoothing on gold, justify the July 2026
  cut-off, foreground net-of-MER Gold ETF comparisons alongside gross spot gold,
  clarify pre-tax vs. after-tax franking bases, strengthen the franking
  verification caveat, document single-country ASX 200 concentration, and refine
  fixed-interest caveats.
- **Legal Precision, Terminology & Self-Contained Synthesis (`article.Rmd` &
  `GLOSSARY.md`):** Distinguish GST-free first supply (s 38-385) from input
  taxed subsequent supplies (s 40-100), rename "RBA Cash Rate Floor" to "RBA
  Cash Rate Benchmark", soften the 2018 and Price-Only takeaways, and integrate
  a self-contained synthesis contrasting productive dividend compounding against
  monetary/FX repricing and tax deferral (without referencing external notes).

## Settled Scope and Non-Goals

- **In Scope:**
  - Deterministic rolling-window analysis (`5`, `10`, and `15` years) in
    `scripts/model.R`, unit-tested in `tests/testthat/test-model.R`, and
    presented as a summary table and narrative analysis in `article.Rmd`.
  - Terminology updates in `GLOSSARY.md` (`Cash Rate Benchmark`, `Rolling
    Window`) and specification updates in `docs/requirements.md`.
  - Narrative, table, chart-label, and caveat updates in `article.Rmd`.
- **Explicit Non-Goals (Out of Scope):**
  - Downloading new external raw files into `data/raw/` (no daily LBMA gold
    replacement, no post-July 2026 window extension, no external global ETF raw
    series).
  - Adding a fifth chart, a 50/50 rebalanced portfolio series, a monthly
    variable bonus-savings series, or a Dollar-Cost Averaging (DCA) model to
    `scripts/model.R`.
  - Referencing unpublished external "February 2026 notes", Warren Buffett, or
    Scott Pape directly in `article.Rmd`.

## Data and Modelling Issues to Address

### 1. Gold and STW Observation Frequency Mismatch

Gold uses the World Bank monthly average (converted at month-end FX), whereas
`ASX:STW` uses month-end closes. Averaging smooths a series: for a random walk,
monthly changes of an averaged series have roughly two-thirds of the true
point-to-point variance. This understates gold's `15.55%` annualised volatility
(a month-end series would sit nearer `19%`) and smooths intra-month peaks and
drawdowns relative to `ASX:STW`.

- **Agreed Action:** Retain the verified World Bank Pink Sheet series
  (`REQ-004`) and explicitly quantify in `article.Rmd` (Methodology and
  Risk/Drawdown sections) that monthly averaging reduces random-walk variance
  by roughly one-third, meaning gold's true point-to-point annualised
  volatility is closer to `~19%` and intra-month drawdowns were deeper than
  monthly averages show.

### 2. July 2026 Cut-Off Justification

The report is published in November 2026 but ends in July 2026 (`2026-07-01`).
The July 2026 endpoint is required by the 241-month `ASX:STW` price extract,
the exact 20-term (`1 + 12 * 20`) July-to-July annual deposit rollover model,
and the uninterpolated June 2006 to June 2026 quarterly ABS CPI window.

- **Agreed Action:** Explicitly state in `article.Rmd` why July 2026 is the
  canonical 20-year cut-off and note that gold subsequently pulled back further
  from its early-2026 peak later in 2026.

### 3. Asymmetric Fee Drag and Pre-Tax Franking Basis

The opening narrative compares *gross* spot gold (`AUD 6,998.18`) against
*net-of-fee* `ASX:STW` (`AUD 3,899.71`, where State Street's MER of `0.286%` in
2006 down to `0.05%` today is already deducted inside NAV). Additionally,
pre-tax charts and Table 1 exclude franking credits, whereas Table 4 includes
them.

- **Agreed Action:** Report net-of-MER Gold ETF outcomes (`AUD 6,791.20` at
  `0.15%` MER and `AUD 6,459.10` at `0.40%` MER) alongside gross spot gold in
  the opening narrative and headline takeaways, and state explicitly alongside
  Table 1 that pre-tax `ASX:STW` figures exclude franking credits while Table 4
  incorporates them.

### 4. Franking Credit Verification Caveat

Cross-checking against SSGA's official distribution table covers only the `46`
distributions from June 2014 onwards; `17` of those `46` rows (over a third,
including `2019-06-27` at `0.00%` vs. `AUD 0.1923` per unit) differ on headline
franking. The `14` earlier in-window distributions (`2006–2013`) rely solely on
the InvestSMART schedule and are not cross-checked against SSGA.

- **Agreed Action:** Replace `"slightly understates"` in `article.Rmd` and
  `docs/requirements.md` with an explicit disclosure that `17 / 46` checked
  post-2014 rows differ on headline franking and `14` pre-2014 distributions
  were not cross-checked against SSGA, making Table 4's `ASX:STW` after-tax
  values (`AUD 3,314.54` at `32%`) a conservative lower bound.

### 5. Home-Country and Sector Concentration Bias

Using `ASX:STW` as the sole equity benchmark tests a single domestic market
heavily concentrated in mature, high-payout Australian banks and cyclical
miners, whereas unhedged AUD gold benefits from AUD depreciation during global
crises.

- **Agreed Action:** Add an explicit scope disclosure in `article.Rmd` noting
  that `ASX:STW` reflects a dividend-heavy domestic index rather than unhedged
  global growth equities (such as MSCI World or the S&P 500).

### 6. Fixed-Interest ("Bonus Savings") Model Limitations and Terminology

- **Annual rate lock:** Locking July's bonus savings rate for 12 months makes
  intra-year drawdowns zero by construction (so the `0.44%` annualised
  volatility only reflects annual step-changes between July locks) and lags
  mid-year variable rate rises such as the 2022–2023 tightening cycle.
- **Bonus-rate upper bound & ACCC timeframe:** A passive 20-year
  "set-and-forget" investor would miss monthly deposit conditions and revert to
  base rates (`~0.05%–0.50%`), making `3.29%` p.a. an optimistic upper bound.
  The ACCC finding that `71%` of bonus accounts missed bonus interest in a given
  month came from a first-half 2023 (`1H 2023`) snapshot, not a 20-year mean.
- **Terminology fix:** Rename `"RBA Cash Rate Floor"` to `"RBA Cash Rate
  Benchmark"` across `article.Rmd`, `GLOSSARY.md`, and `docs/requirements.md`,
  because the RBA cash rate is a monetary-policy benchmark rather than a retail
  deposit floor.

## Framing, Legal Precision, and Narrative Synthesis

### 1. Precise GST Wording (s 38-385 vs. s 40-100)

Under the *A New Tax System (Goods and Services Tax) Act 1999* and ATO Ruling
[GSTR 2003/10][ato-gstr], section `38-385` makes only the *first* supply of
precious metal after refining GST-free, whereas subsequent supplies to investors
are *input taxed* under section `40-100` (with fineness thresholds of `>= 99.5%`
for gold and `>= 99.9%` for silver).

- **Agreed Action:** Update Table 3, the Gold tax bullet in `article.Rmd`, and
  `REQ-017` in `docs/requirements.md` to cite both sections `38-385` (first
  supply GST-free) and `40-100` (subsequent supplies input taxed) and note the
  `99.5%` gold (`99.9%` silver) fineness thresholds.

### 2. Practical Takeaways Refinements

- **2018–2019 Near-Tie:** Replace `"evaluating the exact same rules in 2018
  would have crowned ASX:STW Total Return"` with accurate wording noting that in
  `2018–2019` `ASX:STW` Total Return matched and briefly led spot gold—a
  near-tie before gold's 2024–2026 breakout, as confirmed by the rolling-window
  win rates.
- **Price-Only Framing:** Reframe `"Exclude dividends and equities lose their
  purpose"` to `"Headline price indices understate equity returns"`, explaining
  why comparing a familiar index price chart (`stw_price_only`) against gold
  omits nearly four-fifths of `ASX:STW`'s total compounding.

### 3. Self-Contained Synthesis: Productive Yield vs. Monetary Repricing

Without referencing external notes, integrate a concise synthesis in
`article.Rmd` explaining *why* an unproductive asset outperformed a productive
equity index over 2006–2026 and when that verdict reverses:

- **Mechanics of the 2006–2026 Result:** Gold generated zero internal yield, yet
  its AUD price rose nearly 7x due to monetary/sovereign-debt repricing,
  central-bank reserve accumulation, AUD depreciation (`0.7658` to `0.7030`, and
  sharply lower during GFC risk-off shocks), and ATO tax deferral (`0%` annual
  tax for 20 years plus the `50%` CGT discount on disposal).
- **Historical Regime Sensitivity:** Point-to-point winners depend heavily on
  the entry and exit regime—for example, from the January 1980 USD gold peak
  (`~US$850/oz`, not surpassed in USD terms until 2008) through 2000, gold lost
  roughly two-thirds of its nominal USD value while equities compounded
  strongly; likewise, an investor entering at the August 2011 AUD gold peak
  (`AUD 1,987` indexed) endured roughly eight flat years through 2018–2019.

## Rolling-Window Analysis Specification (`scripts/model.R`)

### Mathematical Contract

Add pure functions `compute_rolling_windows()` and `summarise_rolling_windows()`
to `scripts/model.R` and expose `rolling_window_summary` from
`build_model_outputs()`:

- **Horizons:** $h \in \{5, 10, 15\}$ years ($m = 12h \in \{60, 120, 180\}$
  months), yielding `181` five-year, `121` ten-year, and `61` fifteen-year
  overlapping windows across the `241` monthly observations (`2006-07-01` to
  `2026-07-01`).
- **Evaluated Series:** `gold_aud`, `gold_etf_040`, `stw_total_return`, and
  `fixed_interest_bonus`.
- **Window Return & CAGR:** For start index $i \in \{1, \dots, 241 - m\}$ and
  end index $j = i + m$:
  - Growth multiplier: $M_{i,h} = V_j / V_i$
  - Window CAGR (%): $\text{CAGR}_{i,h} = (M_{i,h}^{1/h} - 1) \times 100$
- **Summary Metrics (`rolling_window_summary` tibble):** For each horizon
  `horizon_years` ($5, 10, 15$) and `series_variant`:
  - `n_windows`: integer count of overlapping windows (`181`, `121`, `61`).
  - `win_count` and `win_rate_pct`: share of windows where the series achieves
    the highest CAGR among the three primary asset classes (`gold_aud`,
    `stw_total_return`, `fixed_interest_bonus`), plus head-to-head win rate of
    `stw_total_return` vs. net-of-MER `gold_etf_040`.
  - `median_cagr_pct`, `min_cagr_pct`, `max_cagr_pct`: summary distribution of
    annualised returns across all start months.

## Project Update Checklist

### Data Contracts, Glossary, and Requirements

- [x] Update [GLOSSARY.md](../GLOSSARY.md) with `Cash Rate Benchmark` and
      `Rolling Window`.
- [x] Update [docs/review.md](review.md) with settled scope, non-goals, and
      rolling-window specification.
- [x] Update [docs/requirements.md](requirements.md) to reflect `Cash Rate
      Benchmark`, the rolling-window data contract, the strengthened franking
      caveat, GST sections 38-385 / 40-100, ACCC 1H 2023 timeframe, and
      monthly-average gold variance notes.

### Analytical Model and Unit Tests (`scripts/model.R` & `tests/`)

- [x] Implement `compute_rolling_windows()` and `summarise_rolling_windows()` in
      `scripts/model.R`, include `rolling_window_summary` in
      `build_model_outputs()`, and validate it in `validate_model_outputs()`.
- [x] Add unit tests in `tests/testthat/test-model.R` covering rolling-window
      counts (`181`, `121`, `61`), win-rate bounds, and determinism.

### Article Narrative and Tables (`article.Rmd`)

- [x] Foreground net-of-MER Gold ETF results (`0.15%` and `0.40%` MER) alongside
      gross spot gold in the introduction and note the pre-tax vs. after-tax
      franking basis beside Table 1.
- [x] Document gold's monthly-average variance smoothing (`~15.55%` vs. `~19%`
      estimated point-to-point volatility), justify the July 2026 cut-off, and
      note domestic ASX 200 sector concentration.
- [x] Strengthen the `ASX:STW` franking verification caveat (`17 / 46`
      post-2014 rows differ; `14` pre-2014 rows unverified against SSGA).
- [x] Qualify `3.29%` p.a. Bonus Savings as an upper bound, note why intra-year
      rate locking produces `0.0%` drawdown (`0.44%` step-change volatility),
      specify the `1H 2023` ACCC snapshot, and rename `"RBA Cash Rate Floor"` to
      `"RBA Cash Rate Benchmark"`.
- [x] Add the Rolling-Window Win Rates summary table and endpoint-sensitivity
      discussion (including 2011 gold peak, 1980–2000 context, and productive
      compounding vs. monetary/tax-deferral synthesis).
- [x] Correct GST wording (s 38-385 first supply GST-free vs. s 40-100 input
      taxed; `99.5%` gold and `99.9%` silver fineness).
- [x] Refine the Practical Takeaways (2018–2019 near-tie and index price-chart
      understatement).

## Sources Checked

- [Twenty Years of AUD 1,000: Gold, Fixed Interest and Australian Equities
  (2006–2026)][report]
- [ACCC Retail Deposits Inquiry final report and media release (December
  2023)][accc-deposits]
- [ATO Goods and Services Tax Ruling GSTR 2003/10][ato-gstr] (precious metals,
  s 38-385 and s 40-100)
- [ATO, reverse charge in the valuable metals industry][ato-reverse-charge]
  (fineness thresholds)
- [Melt Value, Australian gold price history][melt-value] (52-week high and
  November 2026 prices)
- [Metal Charts, gold price in AUD, 19 November 2026][metal-charts]
- [AD HOC NEWS, S&P/ASX 200 close, 10 November 2026][ad-hoc-news]

[report]: https://frankhjung.github.io/gnur-investment/
[accc-deposits]: https://www.accc.gov.au/media-release/bank-customers-missing-out-on-earning-more-interest-from-savings
[ato-gstr]: https://www.ato.gov.au/law/view/pdf/pbr/gstr2003-010.pdf
[ato-reverse-charge]: https://www.ato.gov.au/Business/GST/In-detail/Rules-for-specific-transactions/Reverse-charge-in-the-valuable-metals-industry/?page=4
[melt-value]: https://meltvalue.com/au/gold-price
[metal-charts]: https://metalcharts.org/gold-price-in-aud
[ad-hoc-news]: https://www.ad-hoc-news.de/boerse/news/marktberichte/s-p-asx-200-gains-1-1-percent-to-close-at-9-129/70488717
