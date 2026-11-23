# Glossary

## ABS

The Australian Bureau of Statistics, which publishes the Consumer Price Index
used to adjust nominal investment values for inflation.

## Analysis Window

The 241 monthly observations from July 2006 to July 2026 shared by every series.
The window is set by the `ASX:STW` price history; longer gold and exchange-rate
histories are discarded.

## Annual Rollover

The fixed-interest compounding model used in this analysis. At each July from
2006 to 2025, the monthly RBA Table F4 retail bonus-savings rate is locked for
12 months. At maturity, principal and interest are reinvested for the next
12-month term.

## ATO

The Australian Taxation Office, responsible for administering Australian tax
rules including income tax, capital gains tax and franking credits.

## ASX

The Australian Securities Exchange.

## CAGR

Compound annual growth rate. CAGR describes the constant annual rate that
connects a starting investment value to its ending investment value over a
specified period.

## Cash Rate Benchmark

The secondary fixed-interest reference series that compounds the Reserve Bank of
Australia monthly Cash Rate Target (`FIRMMCRT`). It represents an official
monetary-policy benchmark rather than a retail product or guaranteed deposit
floor.

_Avoid_: RBA Cash Rate Floor

## CGT

Capital gains tax. For eligible Australian individuals, CGT applies to a capital
gain when an investment is disposed of, subject to concessions and taxable
income.

## CPI

The Consumer Price Index measures changes in the prices paid by Australian
households. The analysis uses the ABS all-groups CPI to estimate inflation.

## DRP

A dividend reinvestment plan. Under a DRP, distributions paid by an investment
are used to acquire additional units instead of being paid as cash.

## ETF

An exchange-traded fund. An ETF holds a portfolio or commodity exposure and
trades on a securities exchange such as the ASX.

## Franking Credit

A tax credit attached to a dividend paid by an Australian company that has
already paid company tax. Eligible resident shareholders may use franking
credits to reduce their tax liability.

## Fractional DRP

The primary `ASX:STW` total-return model. Every cash distribution is reinvested
in full at the month's price, allowing fractional units. This is a theoretical
benchmark; it is not how a real ASX dividend reinvestment plan normally handles
small residual balances.

## Gold ETF Net-of-MER

A sensitivity series that reduces gross AUD spot gold by an ongoing ETF
Management Expense Ratio. The analysis applies `0.15%` per year for `ASX:PMGOLD`
and `0.40%` per year for `ASX:GOLD`.

## Maximum Drawdown

The largest percentage decline from a previous peak to a subsequent trough over
the analysis period.

## MER

Management Expense Ratio. An annual fund fee expressed as a percentage of assets
under management. The fee is typically deducted from fund assets rather than
billed separately to the investor.

## Nominal AUD

A value measured in Australian dollars at the prices or values applying in each
period, without adjustment for inflation.

## Prepared CSV

A UTF-8 CSV in `data/` written by `scripts/convert_xlsx.R` and its modular
extractors in `scripts/extract/`. It extracts the columns needed by this
analysis from permanent read-only inputs in `data/raw/`, sorts them in
ascending date order and replaces earlier extracts when rerun. The report reads
these prepared files at render time.

## Price-Only

The `ASX:STW` series that tracks unit price alone and ignores distributions.
It is plotted as a dashed reference line to show how excluding dividends
understates investment performance.

## Real AUD

A nominal value adjusted for inflation and expressed in the purchasing power of
June 2006 Australian dollars.

## RBA

The Reserve Bank of Australia, which publishes official cash-rate, deposit-rate
and exchange-rate data used in this analysis.

## Rolling Window

A fixed-duration sub-period (5, 10, or 15 years) stepped forward one month at a
time across the 241-month Analysis Window. Rolling windows test whether headline
point-to-point results depend on a specific entry or exit date.

## Total Return

The value of an investment with all income reinvested. For `ASX:STW`, this is
the cash DRP; for fixed interest, it is compounded interest; for gold, it equals
price change because gold pays no income.

## Volatility

The annualised variability of monthly investment returns. Higher volatility
indicates larger fluctuations in value, not necessarily a larger eventual loss.

## Whole-Unit DRP

A sensitivity model that mirrors a real ASX dividend reinvestment plan. The
model starts with whole units, holds residual cash in a zero-interest cash
ledger and buys additional whole units when sufficient cash accumulates.
