# **Claude Review of Report**

## *Review of Frank Jung's report "[Twenty Years of AUD 1,000: Gold, Fixed Interest and Australian Equities (2006–2026)](https://frankhjung.github.io/gnur-investment/)", dated 21 November 2026\. Prepared 23 November 2026\.*

## **Summary**

I found no arithmetic errors. The CAGRs, the CPI ratio (102.31/59.65), the MER drags, the whole-unit DRP ledger and the gold tax rows in Table 4 all recompute correctly. The real problems are in how the series are built and how the results are read.

# **Things to fix**

### **1\. Gold and STW are observed at different times**

The gold series is the World Bank monthly average, converted at month-end FX, while STW uses month-end closes. Averaging smooths a series. For a random walk, the monthly changes of an averaged series have roughly two-thirds of the true variance. That would put gold's 15.55% volatility nearer 19%, and it would make the "gold fell about half as far as equities" claim much weaker.

The smoothing is visible in the data. The March 2026 record of A\$7,094/oz is a monthly-average figure, while the daily spot high was A\$7,772.92 on 29 January 2026\. Gold's drawdown, volatility and peak are therefore flattered relative to STW. Either use month-end gold (LBMA PM fix or a daily series) or smooth both assets the same way.

### **2\. The end date is four months stale**

The report is published on 21 November but ends in July 2026\. Gold was about A\$5,463/oz on 19 November, and on 16 November it was 26.3% below the January high. Back-solving from the report's index, July works out to roughly A\$5,790/oz, so the headline CAGR would only drop a little. The bigger change is that gold's current drawdown may match or beat the "max drawdown, June 2014" figure. The ASX 200 closed at 9,129 on 10 November, so STW has also moved. Either extend to November or state why July is the cut-off.

### **3\. "Shares" means one narrow Australian ETF**

The ASX 200 is concentrated in banks and miners. A global equity fund in AUD may well have beaten it over this window, and the conclusion on gold versus shares could shrink or disappear. This has not been tested, but the pipeline could add a global ETF easily.

The pre-tax charts also exclude franking, which understates STW against gold. Table 4 then includes franking, so the two parts of the report use different bases.

### **4\. The franking verification is thinner than "slightly understates"**

The cross-check covers 46 payouts from 2014 onwards, and 17 rows differ on headline franking. That is more than a third of the checked rows. The roughly 14 earlier distributions are not cross-checked at all, yet Table 4's after-tax figures depend on them.

## **5\. The fixed-interest model is generous in some ways and awkward in others**

* A bonus savings account is variable, but the model locks July's rate for 12 months. In 2021–22 that understated what a variable account paid as rates rose.

* The model assumes the bonus rate is always earned. The ACCC found that in the first half of 2023, 71% of bonus interest accounts on average did not receive the bonus in any given month. That is one half-year snapshot, not a 20-year figure, so treat 3.29% as an upper bound and phrase the 71% accordingly.

* Zero drawdown is true by construction in a rate-lock model, so the 0.44% volatility says little.

* "RBA Cash Rate Floor" is a misleading label, since the cash rate is not a floor.

### **6\. The GST statement is imprecise**

The report says bullion at 99.5% purity or better is GST-exempt under s 38-385. That section only makes the first supply after refining GST-free. Other supplies of precious metal are input taxed under s 40-100. The result for an investor is the same, but "GST-free" and "input taxed" are different things. Silver also has a different threshold: 99.9% fineness, versus 99.5% for gold.

## **7\. Two takeaways overreach**

* "Evaluating in 2018 would have crowned STW": Figure 2 shows gold and STW Total Return roughly level in 2018–19, and the text says STW "matched and briefly led". That is a near-tie, not a crown.

* "Exclude dividends and equities lose their purpose": price-only is a strawman, because nobody discards the dividends. Frame it as "an index price chart understates equity returns" and drop the price-only line from the takeaways.

## **Alternative interpretations and other periods**

The central finding is a window effect. The report says so itself: gold's CAGR is "largely" the 2024–26 breakout. Reading Figure 2, roughly half of gold's final balance came in about the last two and a half years, so a lump sum held through that spike benefits enormously.

Period tests that would show this:

* **Start at the 2011 gold peak.** The report's own index has AUD gold at about 1,987 in 2011 and not much higher in 2018–19, so roughly eight flat years.

* **Start at the November 2007 equity peak.** STW starts with the 47% GFC fall.

* **End at 2018\.** This is a near-tie, as above.

* **Go further back.** Gold's nominal USD peak of about US\$850 in January 1980 was not beaten until 2008\. This is from memory, so check it. Over that stretch gold was a dreadful holding.

* **Rolling windows.** Compute every 5-, 10-, 15- and 20-year start month from the CSVs and report the share of windows each asset wins. This would be the strongest addition to the report.

## **The February notes (Pape and Buffett)**

Scott Pape's silver example (shares about 9% p.a. against silver 6.4%) is the mirror image of this report. His 39-year anecdote ends at silver's own spike, and the 20-year result here ends at gold's. Both are true for their windows, so neither refutes the other.

Buffett's argument is about expected return from a non-productive asset, and a 20-year backtest ending at a record cannot settle that either way. Back-solving the report's USD index (starting near US\$630/oz), US dollar gold rose from US\$1,759 in August 2011 to about US\$4,000. That is roughly 5.6% p.a. over 15 years, which is arguably consistent with Buffett's point. Check this against the data before using it.

Copy points on the February notes:

* "Buffer" should be "Buffett" when comparing Investopedia with Buffett.

* Gold and silver are precious metals, not base metals, so the "I've never recommended investing in base metals" line is a slip. It is unclear whether that line is Pape's or Frank's.

* The Buffett summary is a second-hand article. Cite his 2011 shareholder letter instead.

# **Suggested next steps**

1. Rebuild the gold series on a month-end basis, or smooth STW the same way.

2. Extend the end date to November 2026, or justify July.

3. Add a global equity benchmark in AUD.

4. Add a rolling-window analysis (5, 10, 15, 20 years) and report win rates.

5. Fix the GST wording, the "2018 would have crowned STW" claim and the price-only takeaway.

# **Sources checked**

* ACCC Retail Deposits Inquiry final report and media release (December 2023): https\://www\.accc.gov.au/media-release/bank-customers-missing-out-on-earning-more-interest-from-savings

* ATO Goods and Services Tax Ruling GSTR 2003/10 (precious metals, s 38-385 and s 40-100): https\://www\.ato.gov.au/law/view/pdf/pbr/gstr2003-010.pdf

* ATO, reverse charge in the valuable metals industry (fineness thresholds): https\://www\.ato.gov.au/Business/GST/In-detail/Rules-for-specific-transactions/Reverse-charge-in-the-valuable-metals-industry/?page=4

* Melt Value, Australian gold price history (52-week high and November 2026 prices): https\://meltvalue.com/au/gold-price

* Metal Charts, gold price in AUD, 19 November 2026: https\://metalcharts.org/gold-price-in-aud

* AD HOC NEWS, S\&P/ASX 200 close, 10 November 2026: https\://www\.ad-hoc-news.de/boerse/news/marktberichte/s-p-asx-200-gains-1-1-percent-to-close-at-9-129/70488717

Gold and index prices are quoted from news and data sites and differ slightly between sources.