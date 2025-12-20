inline_issue <- function(year = "2025", issue = "01") {
  
  stopifnot(
    is.character(year), length(year) == 1,
    is.character(issue), length(issue) == 1
  )
  
  if (!requireNamespace("juicyjuice", quietly = TRUE)) {
    stop("Package 'juicyjuice' is required but not installed.")
  }
  
  issue_dir <- file.path("issues", year, issue)
  
  qmd_file <- file.path(
    issue_dir,
    paste0("newsletter_", year, "_", issue, ".qmd")
  )
  
  if (!file.exists(qmd_file)) {
    stop("QMD file not found: ", qmd_file)
  }
  
  # --- render via Quarto CLI (no R deps) ----
  cmd <- sprintf("quarto render %s --to html --quiet", shQuote(qmd_file))
  status <- system(cmd)
  
  if (status != 0) {
    stop("Quarto render failed for: ", qmd_file)
  }
  
  html_file <- sub("\\.qmd$", ".html", qmd_file)
  
  if (!file.exists(html_file)) {
    stop("Rendered HTML not found: ", html_file)
  }
  
  # --- inline CSS ----
  html <- paste(
    readLines(html_file, warn = FALSE, encoding = "UTF-8"),
    collapse = "\n"
  )
  
  html <- juicyjuice::css_inline(html)
  
  writeLines(html, html_file, useBytes = TRUE)
  
  message("Rendered and inlined: ", html_file)
  invisible(html_file)
}
