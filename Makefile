SHELL := bash
.SHELLFLAGS := -euo pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables

RSCRIPT      := Rscript
R_CMD        := Rscript
PROJECT      := $(notdir $(CURDIR))
PUBLIC_DIR   := public
HTML_OUT     := $(PUBLIC_DIR)/index.html
PDF_OUT      := $(PUBLIC_DIR)/$(PROJECT).pdf
PREPARED_CSV := $(wildcard data/*.csv)
RAW_DATA     := $(wildcard data/raw/*)

.DEFAULT_GOAL := help

.PHONY: help check-packages check-packages-extract check-packages-render extract test html pdf all clean

help: ## Show available Make targets
	@awk 'BEGIN {FS = ":.*## "} /^[a-zA-Z0-9_-]+:.*## / {printf "  %-24s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

check-packages: ## Verify all Stage 1 and Stage 2 GNU R packages are installed
	@$(RSCRIPT) scripts/check_packages.R --mode=all

check-packages-extract: ## Verify Stage 1 extraction GNU R packages are installed
	@$(RSCRIPT) scripts/check_packages.R --mode=extract

check-packages-render: ## Verify Stage 2 reporting GNU R packages are installed
	@$(RSCRIPT) scripts/check_packages.R --mode=render

extract: check-packages-extract ## Run Stage 1 R extraction scripts to generate CSVs in data/
	@$(RSCRIPT) scripts/convert_xlsx.R

test: check-packages-render ## Run unit and integration tests for Stage 1 and Stage 2 scripts
	@$(RSCRIPT) tests/run_tests.R

html: check-packages-render $(HTML_OUT) ## Render HTML report to public/index.html

$(HTML_OUT): article.Rmd make.R scripts/model.R assets/article.css assets/images/banner.jpg $(PREPARED_CSV)
	@mkdir -p $(PUBLIC_DIR)
	@$(R_CMD) make.R article.Rmd $(HTML_OUT)

pdf: check-packages-render $(PDF_OUT) ## Render PDF report to public/investments.pdf

$(PDF_OUT): article.Rmd make.R scripts/model.R assets/preamble.tex assets/images/banner.jpg $(PREPARED_CSV)
	@mkdir -p $(PUBLIC_DIR)
	@$(R_CMD) make.R article.Rmd $(PDF_OUT)

all: extract test html pdf ## Run extraction, tests, and render HTML and PDF reports

clean: ## Remove rendered reports and temporary build files
	@$(RM) -rf $(PUBLIC_DIR) cache figure *.log *.aux *.out *.toc *.tex
