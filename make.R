#!/usr/bin/env R

# Render R markdown (Rmd) to HTML or PDF.
#
# Usage:
# Rscript make.R <source.Rmd> <output.(html|pdf)>

# load packages
require(rmarkdown)

ensure_output_dir <- function(path) {
  out_dir <- dirname(path)
  if (!dir.exists(out_dir) && out_dir != ".") {
    dir.create(out_dir, recursive = TRUE)
  }
}

# require parameters: source file and output file
args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 2) {
  stop("Usage: make.R <source.Rmd> <output.(html|pdf)>", call. = FALSE)
}

source_file <- args[1]
output_path <- args[2]
ensure_output_dir(output_path)
output_dir <- dirname(output_path)
output_name <- basename(output_path)

if (endsWith(output_name, ".html")) {
  render(source_file,
    html_document(
      css = "assets/article.css",
      theme = NULL,
      highlight = NULL,
      self_contained = TRUE,
      mathjax = NULL
    ),
    output_file = output_name,
    output_dir = output_dir
  )
} else if (endsWith(output_name, ".pdf")) {
  # Render in the project root so pdflatex resolves relative asset paths
  # (e.g. assets/images/banner.jpg), then move the finished PDF to output_path.
  tmp_pdf <- render(
    source_file,
    pdf_document(
      toc = TRUE,
      toc_depth = 3,
      includes = includes(in_header = "assets/preamble.tex")
    ),
    output_file = output_name,
    output_dir = "."
  )
  if (normalizePath(tmp_pdf, mustWork = TRUE) !=
      normalizePath(output_path, mustWork = FALSE)) {
    ok <- file.rename(tmp_pdf, output_path)
    if (!ok) {
      ok <- file.copy(tmp_pdf, output_path, overwrite = TRUE)
      unlink(tmp_pdf)
    }
    if (!ok) {
      stop(sprintf("Failed to move PDF to %s", output_path), call. = FALSE)
    }
  }
} else {
  stop("ERROR: output must end with .html or .pdf", call. = FALSE)
}
