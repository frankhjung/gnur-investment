# Australian Investment Analysis (2006–2026)

A reproducible GNU R analysis comparing a single AUD 1,000 investment across
three Australian asset classes from July 2006 to July 2026: spot gold (and gold
ETFs), retail fixed interest (bonus savings, 1-year term deposits, and the RBA
cash rate), and Australian equities (`ASX:STW` price-only and reinvested
distributions).

The pipeline separates raw data extraction (Stage 1) from financial modelling
and report rendering (Stage 2), so rendered HTML and PDF reports are generated
deterministically from prepared UTF-8 CSV files.

For short definitions of terms used throughout the analysis, including MER,
CAGR, DRP and real versus nominal returns, see [GLOSSARY.md](GLOSSARY.md).

## Quick Start

From a clean checkout, verify the GNU R dependencies, prepare the data, run the
tests and build the HTML report:

```bash
make check-packages
make extract
make test
make html
```

The HTML report is written to `public/index.html`. Use `make pdf` to build the
PDF report or `make all` to prepare data, test the model and build both reports.

## Project Structure

```text
investments/
├── .github/workflows/pages.yml  # CI/CD pipeline to render and publish to Pages
├── Makefile                     # Authoritative build, extract, test, and render targets
├── README.md                    # Project overview and usage instructions
├── GLOSSARY.md                  # Financial and methodology definitions
├── article.Rmd                  # Primary R Markdown report
├── investments.Rproj            # RStudio project file (Makefile build type)
├── make.R                       # R Markdown renderer for HTML and PDF outputs
├── assets/                      # Styling, LaTeX preamble, and banner image
│   ├── article.css
│   ├── images/banner.jpg
│   └── preamble.tex
├── data/                        # Prepared UTF-8 CSVs consumed by the report
│   └── raw/                     # Permanent read-only raw workbooks and CSVs
├── docs/                        # Domain glossary and requirements records
│   └── requirements.md
├── public/                      # Gitignored rendered reports (index.html, PDF)
├── scripts/
│   ├── check_packages.R         # Verifies required GNU R packages
│   ├── convert_xlsx.R           # Stage 1 raw-to-CSV extractor & REQ-008 checks
│   └── model.R                  # Stage 2 pure financial model & validations
└── tests/
    ├── run_tests.R              # Non-interactive test runner
    └── testthat/test-model.R    # Unit and integration tests for model.R
```

## Prerequisites

- **GNU R** (4.1+ recommended for native pipe `|>`)
- **Required CRAN packages:** `dplyr`, `ggplot2`, `knitr`, `lubridate`,
  `purrr`, `readr`, `rmarkdown`, `scales`, `tibble`, `tidyr`, and `xml2`
- **Pandoc** (required by `rmarkdown` for HTML and PDF output)
- **LaTeX** (`pdflatex` with `booktabs`, `fancyhdr`, `geometry`, `mathpazo`,
  `microtype`, `enumitem`, `caption`, and `hyperref` for PDF rendering)

Verify that all required GNU R packages are installed before building:

```bash
make check-packages
```

## Make Targets

Run `make` (or `make help`) to display all documented targets:

```bash
make help
```

| Target | Description |
| :--- | :--- |
| `make help` | List available targets and their descriptions. |
| `make check-packages` | Verify all required GNU R packages are installed. |
| `make extract` | Run `scripts/convert_xlsx.R` to rebuild prepared CSVs in `data/` from `data/raw/` and verify REQ-008 invariants. |
| `make test` | Run unit and integration tests for `scripts/model.R`. |
| `make html` | Render `article.Rmd` to `public/index.html`. |
| `make pdf` | Render `article.Rmd` to `public/investments.pdf`. |
| `make all` | Run `extract`, `test`, `html`, and `pdf` in sequence. |
| `make clean` | Delete `public/` and temporary LaTeX/knitr build files. |

### Common Workflows

Rebuild prepared CSVs from raw inputs and run the test suite:

```bash
make extract
make test
```

Render reports into the gitignored `public/` directory:

```bash
make html
make pdf
```

Force a clean rebuild of all outputs:

```bash
make clean
make all
```

## GitHub Pages Deployment

The workflow in [pages.yml](.github/workflows/pages.yml) runs automatically on
pushes to `main` (and via manual `workflow_dispatch`). It uses the
`ghcr.io/frankhjung/gnur:4.5.2` container to:

1. Verify all required GNU R packages (`make check-packages`).
2. Execute the model test suite (`make test`).
3. Render the prepared CSVs in `data/` into `public/index.html` (`make html`).
4. Upload `public/` and deploy it to GitHub Pages.

To enable publishing on GitHub, configure **Settings → Pages → Build and
deployment → Source** to **GitHub Actions**.
