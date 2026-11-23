# **Review of Report**

Your report, [*Twenty Years of AUD 1,000: Gold, Fixed Interest and Australian Equities (2006–2026)*](https://frankhjung.github.io/gnur-investment/), is methodologically rigorous, reproducible, and unusually transparent about Australian tax, currency translation, and DRP friction. However, placing it alongside your February 2026 notes on Scott Pape and Warren Buffett exposes a central tension: your data shows gold crushing Australian equities over 2006–2026, while your February notes argue that precious metals are unproductive assets that underperform equities over the long run.

A critical review of your report examines potential flaws, alternative interpretations, and how shifting the historical window changes the verdict.

## **1\. Fundamental & Methodological Critiques**

While the engineering and accounting in scripts/model.R are sound, four economic and structural assumptions subtly tilt the playing field:

* **Reinvestment-Rate Risk vs. Lump-Sum Timing (Endpoint Sensitivity):** Your study tests a single lump sum dropped in July 2006 and left untouched until July 2026\. Because gold has no internal cash flow, 100% of its compound annual growth rate (CAGR) depends on the exit price on the final day. Your window closes just four months after gold's historic March 2026 peak (AUD 8,569 indexed). In contrast, ASX:STW's return is anchored by 60 cash distributions compounded over two decades. Measuring a zero-yield asset from a cyclical trough to a generational blow-off top flatters its CAGR.  
* **Asymmetric Fee Drag on Equities vs. Gold:** You explicitly model two MER scenarios for Gold ETFs (0.15% and 0.40%) and note physical dealer spreads (2%–6%). For ASX:STW, you use historical market prices, noting that State Street's MER (0.286% in 2006 down to 0.05% today) is already baked into the NAV. While true, comparing *gross* spot gold (AUD 6,998.18) in the headline narrative against *net-of-fee* STW (AUD 3,899.71) gives gold an unstated 0.05%–0.29% annual head start in the headline figures.  
* **Home-Country & Sector Concentration Bias in STW:** Using ASX:STW as the sole proxy for "equities" tests a very specific equity market—one heavily concentrated in mature, high-payout Australian banks and cyclical miners rather than global compounding growth businesses. Comparing unhedged global gold (which benefits from a falling AUD during global crises) against a purely domestic, dividend-heavy index understates the long-term capital growth potential of global equities (e.g., MSCI World or S\&P 500).  
* **The "Bonus Savings" Illusion:** Your report models the RBA's advertised retail bonus savings rate (FRDIRSAB10K) rolled over every July, yielding 3.29% p.a. pre-tax. To your credit, you cite the ACCC finding that \~71% of savers miss monthly bonus conditions. In reality, a "set-and-forget" investor who walks away for 20 years (your stated premise) would fail the monthly deposit condition every single month, earning the base rate (\~0.05%–0.50%) rather than the bonus rate. Your fixed-interest benchmark therefore overstates passive cash returns.  
* **Franking Credit Understatement:** As noted in your verification caveat, your dataset understates franking credits on 17 rows (such as June 2019), meaning STW's after-tax return at the 32% bracket (AUD 3,314.54) is slightly conservative.

## **2\. Reconciling Your Report with Your February Notes (Alternative Interpretations)**

Your report does not actually refute Buffett or Scott Pape; rather, it illustrates the exact conditions under which their frameworks bend:

| Dimension | Buffett & Scott Pape (Feb Notes) | Your Report's Empirical Reality (2006–2026) | Synthesis / Alternative Interpretation |
| :---- | :---- | :---- | :---- |
| **Source of Return** | Productive yield: Equities generate earnings and dividends; metals sit idle. | Monetary & FX repricing: Gold's 10.22% CAGR came from central-bank buying and AUD depreciation (0.7658 to 0.7030), not internal yield. | Buffett is right about mechanics, wrong about price: Gold produced nothing, yet its price rose nearly 7x because fiat purchasing power fell and central banks repriced monetary reserves. |
| **Role of Dividends** | Pape notes dividends drive compounding (\~\$800/yr on \$20.2k). | 79% of STW's gains above principal came from reinvesting dividends (AUD 1,631 price-only vs. AUD 3,900 DRP). | Strong agreement: Without dividends, Australian equities failed even to beat CPI (AUD 1,715). |
| **Inflation & Crisis Hedge** | Buffett calls gold a poor inflation hedge; Investopedia calls it a safe haven. | Gold surged during the GFC (+46% in AUD while STW fell \-47%) and beat CPI by 4.08x real. | Currency-adjusted safe haven: For an Australian investor, unhedged gold acts as a double hedge—rising when global fear spikes and when the AUD falls during risk-off shocks. |
| **Tax Efficiency** | Pape warns of CGT and wide dealer spreads on physical silver. | Gold's 100% tax deferral \+ 50% CGT discount preserved 86% of its nominal value at the 32% tax rate, whereas annual tax destroyed cash's real value. | Tax deferral is a hidden superpower: Zero yield is a flaw for cash flow, but under ATO rules, paying zero annual tax for 20 years creates a massive compounding advantage over annually taxed dividends and interest. |

**The Key Alternative Interpretation:** Your report can be read not as "Gold is a better long-term wealth builder than stocks," but as **"In a high-tax, dividend-heavy jurisdiction (Australia) with a commodity-linked currency (AUD), a tax-deferred, unhedged monetary asset outperformed a mature domestic equity index during a two-decade sovereign debt and central-bank easing cycle."**

## **3\. What If a Different Period in History Was Chosen?**

Your Practical Takeaways section rightly notes that evaluating your exact rules in **2018** would have crowned ASX:STW the winner. Shifting the 20-year window across modern financial history shows just how regime-dependent the winner is:

* **1980–2000 (The Lost Two Decades for Gold):** If you started in January 1980 (at the peak of the late-1970s inflation panic, when USD gold hit \~\$850/oz) and walked away until 2000, gold lost roughly **65% of its nominal USD value** and over **80% of its real purchasing power**. Meanwhile, Australian and global equities entered one of the greatest bull markets in history, compounding at \~13%–15% p.a.  
* **1987–2026 (Scott Pape's 39-Year Window):** In your February note, Nathan's grandfather bought silver in 1987\. Over that 39-year span (which includes the 1990s disinflationary equity boom), Australian shares with reinvested dividends turned $701into~$20,200 (\~9.0% p.a.), more than doubling silver (\$7,836, or 6.4% p.a.). Had he bought gold in 1987 (\~AUD 600/oz), equities would still have comfortably led until gold's vertical spike in 2024–2026 closed the gap.  
* **2000–2020 (The Commodity Supercycle & GFC):** Starting in 2000 (the dot-com peak) and ending in 2020 (COVID-19) would also favour gold, as equities suffered two \~50% crashes (2000–2002 and 2008\) while gold rose from \~USD 280/oz to \~USD 1,900/oz.  
* **Dollar-Cost Averaging (DCA) vs. Lump Sum:** If an investor invested AUD 100 every month from 2006 to 2026 rather than a single AUD 1,000 lump sum in July 2006, STW's deep GFC drawdown (2008–2012) would have allowed them to accumulate cheap, high-yielding units for years, significantly narrowing gold's lead.

## **4\. Constructive Additions for Your Report**

To make the article bulletproof against critics from the Buffett/Pape camp, consider adding three brief points:

1. **Rolling 10-Year Return Win Rates:** Alongside your single 2006–2026 point-to-point table, mention how often STW Total Return beat Gold across all rolling 10-year sub-windows within your dataset (e.g., 2006–2016, 2007–2017, up to 2016–2026). This visually proves that gold's victory relies heavily on the 2024–2026 tail.  
2. **A 50/50 Portfolio Benchmark:** Showing a simple 50% STW / 50% Gold rebalanced portfolio would demonstrate Investopedia's diversification argument—capturing most of the upside while slashing STW's \-47.01% GFC drawdown roughly in half.  
3. **Explicit Contrast with Productive Compounding:** Acknowledge the Buffett/Pape critique directly: gold's 2006–2026 victory reflects an extraordinary repricing of fiat currency and sovereign debt, whereas equities rely on internal corporate earnings that do not require an ever-higher valuation multiple to compound.

Would you like to test a rolling-window or 50/50 rebalanced portfolio calculation in R to add to scripts/model.R?